package com.sirolf2009.yggdrasil.sif.transmutation

import java.util.List
import java.util.function.Function
import org.apache.logging.log4j.LogManager

class CSV {
	
	static val log = LogManager.logger

	public static Function<List<List<Double>>, List<String>> matrixToCSV = [
		log.info("Converting to csv")
		map[
			map[it+""].reduce[a,b|a+","+b]
		]
	]

	public static Function<List<String>, String> joinAsLines = [
		log.info("Joining lines")
		stream().reduce[a, b|a + "\n" + b].get()
	]
	
}