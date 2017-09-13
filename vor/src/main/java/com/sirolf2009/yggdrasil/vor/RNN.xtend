package com.sirolf2009.yggdrasil.vor

import java.util.function.Supplier
import org.deeplearning4j.nn.api.OptimizationAlgorithm
import org.deeplearning4j.nn.conf.NeuralNetConfiguration
import org.deeplearning4j.nn.conf.Updater
import org.deeplearning4j.nn.conf.layers.GravesLSTM
import org.deeplearning4j.nn.conf.layers.RnnOutputLayer
import org.deeplearning4j.nn.multilayer.MultiLayerNetwork
import org.deeplearning4j.nn.weights.WeightInit
import org.eclipse.xtend.lib.annotations.Data
import org.nd4j.linalg.activations.Activation
import org.nd4j.linalg.lossfunctions.LossFunctions
import org.deeplearning4j.nn.conf.BackpropType

@Data class RNN implements Supplier<MultiLayerNetwork> {

	int numOfVariables

	override get() {
		val builder = new NeuralNetConfiguration.Builder() => [
			seed = 123
			optimizationAlgo = OptimizationAlgorithm.STOCHASTIC_GRADIENT_DESCENT
			iterations(1)
			weightInit = WeightInit.XAVIER
			updater = Updater.NESTEROVS
			momentum = 0.8
			learningRate = 0.001
			dropOut = 0.5
			useRegularization = true
		]
		val config = builder.list() => [
			layer(0, new GravesLSTM.Builder().activation(Activation.TANH).nIn(numOfVariables).nOut(numOfVariables * 10).build())
			layer(1, new GravesLSTM.Builder().activation(Activation.TANH).nIn(numOfVariables * 10).nOut(numOfVariables * 10).build())
			layer(2, new RnnOutputLayer.Builder(LossFunctions.LossFunction.MSE).activation(Activation.IDENTITY).nIn(numOfVariables * 10).nOut(numOfVariables).build())
			backpropType = BackpropType.TruncatedBPTT
			tbpttBackLength = 100
			tbpttFwdLength = 100
		]
		val net = new MultiLayerNetwork(config.build())
		net.init()

		return net
	}

}
