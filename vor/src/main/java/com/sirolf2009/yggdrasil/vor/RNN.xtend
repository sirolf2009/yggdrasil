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
			updater = Updater.SGD
			learningRate = 0.005
		]
		val config = builder.list() => [
			layer(0, new GravesLSTM.Builder().rmsDecay(0.95).activation(Activation.TANH).updater(Updater.RMSPROP).nIn(numOfVariables).nOut(numOfVariables * 6).build())
			layer(1, new GravesLSTM.Builder().rmsDecay(0.95).activation(Activation.TANH).updater(Updater.RMSPROP).nIn(numOfVariables * 6).nOut(numOfVariables * 6).build())
			layer(2, new GravesLSTM.Builder().rmsDecay(0.95).activation(Activation.TANH).updater(Updater.RMSPROP).nIn(numOfVariables * 6).nOut(numOfVariables * 6).build())
			layer(3, new GravesLSTM.Builder().rmsDecay(0.95).activation(Activation.TANH).updater(Updater.RMSPROP).nIn(numOfVariables * 6).nOut(numOfVariables * 6).build())
			layer(4, new RnnOutputLayer.Builder(LossFunctions.LossFunction.MSE).momentum(0.95).activation(Activation.IDENTITY).nIn(numOfVariables * 6).nOut(numOfVariables).build())
			backpropType(BackpropType.TruncatedBPTT)
			tbpttBackLength = 100
			tbpttFwdLength = 100
		]
		val net = new MultiLayerNetwork(config.build())
		net.init()
		
		return net
	}
	
}
