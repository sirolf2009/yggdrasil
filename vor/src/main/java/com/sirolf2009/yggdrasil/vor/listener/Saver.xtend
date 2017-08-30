package com.sirolf2009.yggdrasil.vor.listener

import java.io.File
import java.util.concurrent.atomic.AtomicBoolean
import org.deeplearning4j.nn.api.Model
import org.deeplearning4j.optimize.api.IterationListener
import org.eclipse.xtend.lib.annotations.Data
import com.sirolf2009.yggdrasil.sif.saver.SaversFile.NetToFile
import org.deeplearning4j.nn.multilayer.MultiLayerNetwork

@Data class Saver implements IterationListener {
	
    val invoked = new AtomicBoolean(false)
    val File dataFolder
	
	override invoke() {
		invoked.set(true)
	}
	
	override invoked() {
		invoked.get()
	}
	
	override iterationDone(Model model, int iteration) {
		new NetToFile(new File(dataFolder, "network_"+iteration+".zip")).accept(model as MultiLayerNetwork)
	}
	
}