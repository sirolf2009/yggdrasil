package com.sirolf2009.yggdrasil.sif.transmutation

import org.junit.Test
import com.sirolf2009.yggdrasil.freyr.TestData

class TestNormaliseDiffStdDev {
	
	@Test
	def void test() {
		val simple = TestData.orderbookSimple
		val normalizer = new OrderbookNormaliseDiffStdDev()
		normalizer.accept(simple)
	}
	
}