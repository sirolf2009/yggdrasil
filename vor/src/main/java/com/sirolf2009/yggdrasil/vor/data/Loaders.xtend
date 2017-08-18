package com.sirolf2009.yggdrasil.vor.data

import java.io.File
import java.nio.file.Files
import java.util.List
import java.util.function.Supplier
import org.apache.logging.log4j.LogManager
import org.deeplearning4j.util.ModelSerializer
import org.eclipse.xtend.lib.annotations.Data
import org.influxdb.InfluxDBFactory
import org.influxdb.dto.Query
import org.influxdb.dto.QueryResult
import org.deeplearning4j.nn.multilayer.MultiLayerNetwork

class Loaders {

	@Data static class InfluxOrderbook implements Supplier<QueryResult> {

		static val log = LogManager.logger
		extension val Arguments arguments

		override get() {
			val host = '''http://«influxHost»:«influxPort»'''
			log.info('''Downloading «datapoints» points from «host» with batch «datapointsBatch»''')
			val influx = InfluxDBFactory.connect(host)
			val batchesToDownload = Math.ceil(datapoints / datapointsBatch) as int
			(0 ..< batchesToDownload).map [
				val query = '''SELECT "value", "amount" FROM "orderbook"."autogen"."gdax" GROUP BY "side", "index" LIMIT «datapointsBatch» OFFSET «it*datapointsBatch»'''
				log.info(query)
				influx.query(new Query(query, database))
			].filter [
				if(error !== null) {
					log.error(error)
				}
				return results !== null && results.size() > 0 && results.get(0).series !== null
			].reduce [ a, b |
				a.results.addAll(b.results)
				a
			]
		}
	}

	@Data static class FileLines implements Supplier<List<String>> {

		static val log = LogManager.logger
		val File file

		override get() {
			log.info('''Loading «file»''')
			Files.readAllLines(file.toPath())
		}
	}

	@Data static class Network implements Supplier<MultiLayerNetwork> {

		static val log = LogManager.logger
		val File file

		override get() {
			log.info('''Loading network from «file»''')
			ModelSerializer.restoreMultiLayerNetwork(file)
		}
	}

}
