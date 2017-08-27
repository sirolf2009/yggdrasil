package com.sirolf2009.yggdrasil.freyr.model

import com.sirolf2009.yggdrasil.freyr.TestData
import java.time.LocalDateTime
import org.junit.Test

import static org.junit.Assert.*

class TestTableOrderbook {
	
	val simple = TestData.orderbookSimple
	
	@Test
	def void testColumnDateTime() {
		assertEquals(1, simple.date.size)
		assertEquals(LocalDateTime.of(2017, 1, 1, 0, 0, 0, 0), simple.date.get(0))
	}
	
	@Test
	def void testBoughtSoldColumns() {
		assertEquals(1, simple.bought.size)
		assertEquals(0.2, simple.bought.get(0), 0.00001)
		assertEquals(1, simple.sold.size)
		assertEquals(0.1, simple.sold.get(0), 0.00001)
	}
	
	@Test
	def void testBidAskColumns() {
		assertEquals(30, simple.bids.size)
		assertEquals(15, simple.bids.get(0).get(0), 0.00001)
		assertEquals(1, simple.bids.get(28).get(0), 0.00001)
		assertEquals(30, simple.asks.size)
		assertEquals(16, simple.asks.get(0).get(0), 0.00001)
		assertEquals(30, simple.asks.get(28).get(0), 0.00001)
	}
	
	@Test
	def void testPriceColumns() {
		assertEquals(15, simple.bidPrices.size)
		assertEquals(15, simple.bidPrices.get(0).get(0), 0.00001)
		assertEquals(1, simple.bidPrices.get(14).get(0), 0.00001)
		assertEquals(15, simple.askPrices.size)
		assertEquals(16, simple.askPrices.get(0).get(0), 0.00001)
		assertEquals(30, simple.askPrices.get(14).get(0), 0.00001)
	}
	
	@Test
	def void testAmountColumns() {
		assertEquals(15, simple.bidAmounts.size)
		assertEquals(1, simple.bidAmounts.get(0).get(0), 0.00001)
		assertEquals(1, simple.bidAmounts.get(14).get(0), 0.00001)
		assertEquals(15, simple.askAmounts.size)
		assertEquals(1, simple.askAmounts.get(0).get(0), 0.00001)
		assertEquals(1, simple.askAmounts.get(14).get(0), 0.00001)
	}
	
}
