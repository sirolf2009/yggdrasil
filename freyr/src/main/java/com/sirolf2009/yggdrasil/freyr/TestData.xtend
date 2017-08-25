package com.sirolf2009.yggdrasil.freyr

import com.sirolf2009.yggdrasil.freyr.model.TableOrderbook
import tech.tablesaw.api.Table

class TestData {

	def static getOrderbookSimple() {
		new TableOrderbook(Table.createFromReader(TestData.classLoader.getResourceAsStream("orderbook-simple.csv"), "Orderbook-Simple", TableOrderbook.OrderbookColumns, true, ','))
	}

	def static getOrderbookRows() {
		new TableOrderbook(Table.createFromReader(TestData.classLoader.getResourceAsStream("orderbook-rows.csv"), "Orderbook-Rows", TableOrderbook.OrderbookColumns, true, ','))
	}

}
