package com.sirolf2009.yggdrasil.vor.optimize

import java.util.ArrayList
import org.deeplearning4j.nn.api.OptimizationAlgorithm
import org.deeplearning4j.nn.conf.Updater
import org.deeplearning4j.nn.weights.WeightInit
import org.nd4j.linalg.activations.Activation
import java.util.stream.Collectors

class ParameterGenerator {

	def static get(int minLayers, int maxLayers, int layerStep, double minLearningRate, double maxLearningRate, double learningRateStep, int minLayerSize, int maxLayerSize, int layerSizeStep) {
//		OptimizationAlgorithm.values.parallelStream.flatMap [ optimization |
//			WeightInit.values.parallelStream.flatMap [ weightInit |
				Updater.values.parallelStream.flatMap [ updater |
//					Activation.values.parallelStream.flatMap [ activation |
						val paramaters = new ArrayList()
						for (var layers = minLayers; layers <= maxLayers; layers++) {
							for (var learningRate = minLearningRate; learningRate <= maxLearningRate; learningRate++) {
								for (var layerSize = minLayerSize; layerSize <= maxLayerSize; layerSize++) {
									paramaters.add(new Parameters(OptimizationAlgorithm.STOCHASTIC_GRADIENT_DESCENT, WeightInit.XAVIER, updater, Activation.TANH, layers, learningRate, layerSize))
								}
							}
						}
						return paramaters.stream
//					]
//				]
//			]
		].collect(Collectors.toList())
	}

}
