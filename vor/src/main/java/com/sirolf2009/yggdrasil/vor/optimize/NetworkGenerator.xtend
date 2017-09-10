package com.sirolf2009.yggdrasil.vor.optimize

import org.deeplearning4j.nn.conf.NeuralNetConfiguration
import org.deeplearning4j.nn.conf.layers.GravesLSTM
import org.deeplearning4j.nn.conf.layers.RnnOutputLayer
import org.deeplearning4j.nn.multilayer.MultiLayerNetwork
import org.nd4j.linalg.activations.Activation
import org.nd4j.linalg.lossfunctions.LossFunctions

class NetworkGenerator {
	
	def static createNetwork(Parameters parameters, int numOfVariables) {
		val builder = new NeuralNetConfiguration.Builder() => [
			seed = 123
			optimizationAlgo = parameters.optimizationAlgorithm
			iterations(1)
			weightInit = parameters.weightInit
			updater = parameters.updater
			learningRate = parameters.learningRate
		]
		val config = builder.list() => [
			(0 ..< parameters.layers).forEach[layerIndex|
				val in = if(layerIndex == 0) numOfVariables else numOfVariables * parameters.hiddenlayerSize
				layer(layerIndex, new GravesLSTM.Builder().activation(Activation.TANH).nIn(in).nOut(numOfVariables * parameters.hiddenlayerSize).build())
			]
			layer(parameters.layers, new RnnOutputLayer.Builder(LossFunctions.LossFunction.MSE).activation(Activation.IDENTITY).nIn(numOfVariables * parameters.hiddenlayerSize).nOut(numOfVariables).build())
		]
		val net = new MultiLayerNetwork(config.build())
		net.init()

		return net
	}
	
}