package com.sirolf2009.yggdrasil.vor

import org.deeplearning4j.nn.multilayer.MultiLayerNetwork
import org.deeplearning4j.ui.api.UIServer
import org.deeplearning4j.ui.storage.InMemoryStatsStorage
import org.deeplearning4j.ui.stats.StatsListener

class Dl4jUI {
	
	def static attachUI(MultiLayerNetwork net) {
		val server = UIServer.instance
		val storage = new InMemoryStatsStorage()
		server.attach(storage)
		net.listeners += new StatsListener(storage)
	}
	
}