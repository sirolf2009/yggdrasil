package com.sirolf2009.yggdrasil.vor.optimize

import org.deeplearning4j.nn.api.OptimizationAlgorithm
import org.deeplearning4j.nn.conf.Updater
import org.deeplearning4j.nn.weights.WeightInit
import org.eclipse.xtend.lib.annotations.Data
import org.nd4j.linalg.activations.Activation

@Data class Parameters {
	
	val OptimizationAlgorithm optimizationAlgorithm
	val WeightInit weightInit
	val Updater updater
	val Activation activationFunction
	val int layers
	val double learningRate
	val int hiddenlayerSize
	
}