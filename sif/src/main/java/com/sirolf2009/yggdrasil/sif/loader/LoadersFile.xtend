package com.sirolf2009.yggdrasil.sif.loader

import java.io.File
import org.apache.logging.log4j.LogManager
import org.deeplearning4j.util.ModelSerializer

class LoadersFile {
	
	static val log = LogManager.logger

	def static loadNetwork(String file) {
		return loadNetwork(new File(file))
	}

	def static loadNetwork(File file) {
		log.info('''Loading network from «file»''')
		ModelSerializer.restoreMultiLayerNetwork(file)
	}

}