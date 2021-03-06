package com.sirolf2009.yggdrasil.freyr

import com.sirolf2009.yggdrasil.freyr.model.TableOrderbook
import java.io.InputStream
import tech.tablesaw.api.Table
import tech.tablesaw.io.csv.CsvReadOptions

class TestData {

	def static getOrderbookRealLarge() {
		new TableOrderbook(Table.read().csv(reader(TestData.classLoader.getResourceAsStream("orderbook-real-large.csv"), "Orderbook-Real-Large")))
	}

	def static getOrderbookReal() {
		new TableOrderbook(Table.read().csv(reader(TestData.classLoader.getResourceAsStream("orderbook-real.csv"), "Orderbook-Real")))
	}

	def static getOrderbookSimple() {
		new TableOrderbook(Table.read().csv(reader(TestData.classLoader.getResourceAsStream("orderbook-simple.csv"), "Orderbook-Simple")))
	}

	def static getOrderbookRows() {
		new TableOrderbook(Table.read().csv(reader(TestData.classLoader.getResourceAsStream("orderbook-rows.csv"), "Orderbook-Rows")))
	}
	
	def static reader(InputStream data, String name) {
		CsvReadOptions.builder(data, name).columnTypes(TableOrderbook.OrderbookColumns.map[type]).header(true).build()
	}

}
