package com.sirolf2009.yggdrasil.vor.listener

import java.util.concurrent.atomic.AtomicBoolean
import org.deeplearning4j.nn.api.Model
import org.deeplearning4j.nn.multilayer.MultiLayerNetwork
import org.deeplearning4j.optimize.api.IterationListener
import org.eclipse.xtend.lib.annotations.Data
import org.nd4j.linalg.dataset.api.iterator.DataSetIterator
import org.apache.logging.log4j.LogManager

@Data class RegressionEvaluation implements IterationListener {
	
	val log = LogManager.logger
    val invoked = new AtomicBoolean(false)
    val int numberOfParams
    val DataSetIterator testDataIter
	
	override invoke() {
		invoked.set(true)
	}
	
	override invoked() {
		invoked.get()
	}
	
	override iterationDone(Model model, int iteration) {
		val evaluation = new org.deeplearning4j.eval.RegressionEvaluation(numberOfParams)
		while(testDataIter.hasNext()) {
			val t = testDataIter.next()
			val features = t.getFeatureMatrix()
			val labels = t.getLabels()
			val predicted = (model as MultiLayerNetwork).output(features, true)
			evaluation.evalTimeSeries(labels, predicted)
		}
		log.info("Epoch: " + iteration + "\n" + evaluation.stats())
		testDataIter.reset()
	}
	
}