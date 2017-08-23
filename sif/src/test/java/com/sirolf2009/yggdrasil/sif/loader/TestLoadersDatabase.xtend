package com.sirolf2009.yggdrasil.sif.loader

import org.junit.Test

class TestLoadersDatabase {
	
	@Test
	def void testLive() {
		LoadersDatabase.getDatapoints("http://freyr:8086", 32).get()
	}
	
}