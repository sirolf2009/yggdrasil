package com.sirolf2009.yggdrasil.sif.transmutation

import com.sirolf2009.yggdrasil.sif.TestData
import org.junit.Test
import junit.framework.Assert
import org.apache.commons.io.FileUtils
import java.io.File

class TestOrderbookNormaliseDiffStdDev {
	
	@Test
	def void test() {
		val table = TestData.orderbookSimple
		new OrderbookNormaliseDiffStdDev().accept(table)
		Assert.assertEquals(FileUtils.readFileToString(new File("src/test/resources/TestOrderbookNormaliseDiffStdDev/orderbook-simple-normalised.html")).trim(), table.printHtml.trim())
	}
	
}