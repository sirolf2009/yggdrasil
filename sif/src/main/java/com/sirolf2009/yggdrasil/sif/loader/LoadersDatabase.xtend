package com.sirolf2009.yggdrasil.sif.loader

import com.google.gson.Gson
import com.sirolf2009.yggdrasil.sif.model.OrderPoint
import java.io.File
import java.nio.file.Files
import java.nio.file.Paths
import java.util.List
import java.util.UUID
import java.util.concurrent.TimeUnit
import java.util.function.BinaryOperator
import java.util.function.Function
import java.util.function.Predicate
import net.jodah.failsafe.Failsafe
import net.jodah.failsafe.RetryPolicy
import org.apache.commons.io.FileUtils
import org.apache.commons.lang3.time.DateUtils
import org.apache.logging.log4j.LogManager
import org.influxdb.InfluxDBFactory
import org.influxdb.InfluxDBIOException
import org.influxdb.dto.Query
import org.influxdb.dto.QueryResult

import static extension com.sirolf2009.yggdrasil.sif.StreamExtensions.*

class LoadersDatabase {

	static val log = LogManager.logger
	static val batch = 1000

	def static getDatapoints(String influx, int orderPoints) {
		val database = InfluxDBFactory.connect(influx)
		val batchesToDownload = Math.ceil(orderPoints as double / batch as double) as int
		(0 ..< batchesToDownload).toList().stream().map [
			val query = '''SELECT "value", "amount", "bought", "sold" FROM "orderbook"."autogen"."gdax" GROUP BY "side", "index" LIMIT «batch» OFFSET «it*batch»'''
			log.info('''(«it»/«batchesToDownload») «query»''')
			database.query(new Query(query, "orderbook"))
		].filter(hasData).reduce(combine).map(parseOrderbook)
	}

	def static getDatapointsLarge(String influx, int orderPoints, File dataFolder) {
		dataFolder.listFiles.forEach[delete]
		val database = InfluxDBFactory.connect(influx)
		val batchesToDownload = Math.ceil(orderPoints / batch) as int
		val policy = new RetryPolicy().retryOn(InfluxDBIOException).withBackoff(1, 10, TimeUnit.MINUTES).withMaxRetries(10)
		(0 ..< batchesToDownload).toList().stream().map [
			val query = '''SELECT "value", "amount", "bought", "sold" FROM "orderbook"."autogen"."gdax" GROUP BY "side", "index" LIMIT «batch» OFFSET «it*batch»'''
			log.info(query)
			Failsafe.with(policy).get[database.query(new Query(query, "orderbook"))]
		].filter(hasData).forEach [
			Files.write(Paths.get(dataFolder.absolutePath, UUID.randomUUID.toString()), new Gson().toJson(it).bytes)
		]
		return parseDatapoints(dataFolder)
	}
	
	def static parseDatapoints(File folder) {
		val result = folder.listFiles.map[
			log.info("Parsing "+it)
			new Gson().fromJson(FileUtils.readFileToString(it), QueryResult)
		].reduce[a,b|combine.apply(a,b)]
		return parseOrderbook.apply(result)
	}

	public static Function<QueryResult, List<OrderPoint>> parseOrderbook = [
		log.info("Parsing the order book")
		results.parallelStream().flatMap [
			it.series.parallelStream().flatMap [
				val values = values
				val columns = columns

				val index = Integer.parseInt(tags.get("index"))
				val side = tags.get("side")
				val bought = Double.parseDouble(tags.get("bought"))
				val sold = Double.parseDouble(tags.get("sold"))
				(0 ..< values.size()).map [
					try {
						val time = DateUtils.parseDate(values.get(it).get(columns.indexOf("time")).toString(), #["yyyy-MM-dd'T'HH:mm:ss.SSSX", "yyyy-MM-dd'T'HH:mm:ss.SSSZ", "yyyy-MM-dd'T'HH:mm:ss.SSX", "yyyy-MM-dd'T'HH:mm:ss.SX", "yyyy-MM-dd'T'HH:mm:ssX"])
						val value = values.get(it).get(columns.indexOf("value")) as Double
						val amount = values.get(it).get(columns.indexOf("amount")) as Double
						return new OrderPoint(time, side, index, value, amount, bought, sold)
					} catch(Exception e) {
						log.error("Failed to parse " + it, e)
						return null
					}
				].filter[it !== null].toList().stream()
			]
		].collect()
	]

	public static Predicate<QueryResult> hasData = [
		if(it !== null && error !== null) {
			log.error(error)
		}
		return results !== null && results.size() > 0 && results.get(0).series !== null
	]

	public static BinaryOperator<QueryResult> combine = [ a, b |
		a.results.addAll(b.results)
		a
	]

}
