package com.sirolf2009.yggdrasil.vor.data

import org.influxdb.InfluxDBFactory
import org.influxdb.dto.Query
import org.junit.Test

import static com.sirolf2009.yggdrasil.vor.data.Converters.*

class TestConverters {

	@Test
	def void testParseOrderbook() {
		val influx = InfluxDBFactory.connect('''http://freyr:8086''')
		val result = influx.query(new Query('''SELECT "value", "amount" FROM "orderbook"."autogen"."gdax" GROUP BY "side", "index" LIMIT 100''', "orderbook"))
		parseOrderbook.apply(result)
	}

}