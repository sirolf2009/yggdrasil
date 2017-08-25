package com.sirolf2009.yggdrasil.vor

import com.sirolf2009.yggdrasil.freyr.model.TableOrderbook
import java.util.ArrayList
import org.deeplearning4j.nn.multilayer.MultiLayerNetwork

import static extension com.sirolf2009.yggdrasil.sif.TableExtensions.*

class Predict {

	def static predictMultiStep(MultiLayerNetwork net, TableOrderbook table, int stepsToPredict) {
		net.rnnClearPreviousState()
		val data = table.preparePredictData(1)

		var previous = data.last()
		for (var i = 0; i < data.size(); i++) {
			previous = net.rnnTimeStep(data.get(i))
		}
		val predictions = new ArrayList()
		for (var i = 0; i < stepsToPredict; i++) {
			previous = net.rnnTimeStep(previous)
			predictions.add(previous)
		}
		return predictions
	}

	def static preparePredictData(TableOrderbook table, int steps) {
		(0 ..< (table.rowCount - (steps-1))).map [
			table.rows(it, it + steps).toMatrix()
		].toList()
	}

}
