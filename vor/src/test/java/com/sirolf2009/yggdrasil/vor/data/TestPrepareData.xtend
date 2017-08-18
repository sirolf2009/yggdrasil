package com.sirolf2009.yggdrasil.vor.data

import org.junit.Test

class TestPrepareData {

	@Test
	def void testCreatePredict() {
		val csv = #[
			"1,2,3,4",
			"5,6,7,8",
			"-1,-2,-3,-4",
			"-5,-6,-7,-8"
		]
		
		println("Output "+PrepareData.createDataSet2(csv, 1))
		println("Output "+PrepareData.createDataSet2(csv, 2))
	}

}