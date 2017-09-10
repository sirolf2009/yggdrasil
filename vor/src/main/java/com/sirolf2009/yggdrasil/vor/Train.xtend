package com.sirolf2009.yggdrasil.vor

import java.util.ArrayList
import java.util.List
import java.util.function.Consumer
import org.apache.logging.log4j.LogManager
import org.deeplearning4j.nn.multilayer.MultiLayerNetwork
import org.deeplearning4j.optimize.api.IterationListener
import org.eclipse.xtend.lib.annotations.Data
import org.nd4j.linalg.dataset.api.iterator.DataSetIterator
import java.time.Duration

@Data class Train implements Consumer<MultiLayerNetwork> {
	
	static val log = LogManager.logger
	
	val DataSetIterator trainData
	val int epochs
	val List<IterationListener> listeners
	
	new(DataSetIterator trainData, int epochs) {
		this(trainData, epochs, new ArrayList())
	}
	
	new(DataSetIterator trainData, int epochs, List<IterationListener> listeners) {
		this.trainData = trainData
		this.epochs = epochs
		this.listeners = new ArrayList()
		this.listeners += listeners
	}

	override accept(MultiLayerNetwork net) {
		log.info("Training...")
		(0 ..< epochs).forEach [epoch|
			val start = System.currentTimeMillis() 
			net.fit(trainData)
			log.info("Epoch "+epoch+" completed in "+Duration.ofMillis(System.currentTimeMillis() - start))
			trainData.reset()
			listeners.forEach[iterationDone(net, epoch)]
		]
	}
	
}
