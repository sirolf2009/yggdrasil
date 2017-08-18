package com.sirolf2009.yggdrasil.vor

import java.util.ArrayList
import java.util.List
import org.deeplearning4j.nn.multilayer.MultiLayerNetwork
import org.nd4j.linalg.api.ndarray.INDArray

class Predict {
	
	def static predict(MultiLayerNetwork net, List<INDArray> data, int stepsToPredict) {
		net.rnnClearPreviousState()
		var INDArray lastTick = null
		for (var i = 0; i < data.length; i++) {
			lastTick = net.rnnTimeStep(data.get(i))
		}
		val outputs = new ArrayList()
		for (var i = 0; i < stepsToPredict; i++) {
			lastTick = net.rnnTimeStep(lastTick)
			outputs.add(lastTick)
		}
		return outputs
	}
	
}