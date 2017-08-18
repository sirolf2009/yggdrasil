package com.sirolf2009.yggdrasil.sif.loader

import com.sirolf2009.yggdrasil.sif.model.OrderPoint
import java.util.List
import java.util.function.Function
import java.util.function.Predicate
import org.apache.commons.lang3.time.DateUtils
import org.apache.logging.log4j.LogManager
import org.influxdb.InfluxDBFactory
import org.influxdb.dto.Query
import org.influxdb.dto.QueryResult

import static extension com.sirolf2009.yggdrasil.sif.StreamExtensions.*
import java.util.function.BinaryOperator

class LoadersDatabase {

	static val log = LogManager.logger
	static val batch = 5000

	def static getDatapoints(String influx, int orderPoints) {
		val database = InfluxDBFactory.connect(influx)
		val batchesToDownload = Math.ceil(orderPoints / batch) as int
		(0 ..< batchesToDownload).toList().stream().map [
			database.query(new Query('''SELECT "value", "amount" FROM "orderbook"."autogen"."gdax" GROUP BY "side", "index" LIMIT «batch» OFFSET «it*batch»''', "orderbook"))
		].filter(hasData).reduce(combine).map(parseOrderbook)
	}

	public static Function<QueryResult, List<OrderPoint>> parseOrderbook = [
		log.info("Parsing the order book")
		results.parallelStream().flatMap [
			it.series.parallelStream().flatMap [
				val values = values
				val columns = columns

				val index = Integer.parseInt(tags.get("index"))
				val side = tags.get("side")
				(0 ..< values.size()).map [
					try {
						val time = DateUtils.parseDate(values.get(it).get(columns.indexOf("time")).toString(), #["yyyy-MM-dd'T'HH:mm:ss.SSSX", "yyyy-MM-dd'T'HH:mm:ss.SSSZ", "yyyy-MM-dd'T'HH:mm:ss.SSX", "yyyy-MM-dd'T'HH:mm:ss.SX", "yyyy-MM-dd'T'HH:mm:ssX"])
						val value = values.get(it).get(columns.indexOf("value")) as Double
						val amount = values.get(it).get(columns.indexOf("amount")) as Double
						return new OrderPoint(time, side, index, value, amount)
					} catch(Exception e) {
						log.error("Failed to parse " + it, e)
						return null
					}
				].filter[it !== null].toList().stream()
			]
		].collect()
	]

	public static Predicate<QueryResult> hasData = [
		if(error !== null) {
			log.error(error)
		}
		return results !== null && results.size() > 0 && results.get(0).series !== null
	]

	public static BinaryOperator<QueryResult> combine = [ a, b |
		a.results.addAll(b.results)
		a
	]

}
