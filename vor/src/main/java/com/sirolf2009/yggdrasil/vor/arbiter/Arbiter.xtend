package com.sirolf2009.yggdrasil.vor.arbiter

import com.sirolf2009.yggdrasil.vor.Vor
import com.sirolf2009.yggdrasil.vor.data.TrainAndTestData
import java.io.File
import java.text.SimpleDateFormat
import java.time.Duration
import java.time.temporal.ChronoUnit
import java.util.Date
import java.util.Map
import java.util.concurrent.TimeUnit
import org.deeplearning4j.arbiter.MultiLayerSpace
import org.deeplearning4j.arbiter.data.DataSetIteratorFactoryProvider
import org.deeplearning4j.arbiter.layers.GravesLSTMLayerSpace
import org.deeplearning4j.arbiter.layers.OutputLayerSpace
import org.deeplearning4j.arbiter.optimize.api.data.DataProvider
import org.deeplearning4j.arbiter.optimize.api.termination.MaxCandidatesCondition
import org.deeplearning4j.arbiter.optimize.api.termination.MaxTimeCondition
import org.deeplearning4j.arbiter.optimize.config.OptimizationConfiguration
import org.deeplearning4j.arbiter.optimize.generator.RandomSearchGenerator
import org.deeplearning4j.arbiter.optimize.parameter.continuous.ContinuousParameterSpace
import org.deeplearning4j.arbiter.optimize.parameter.discrete.DiscreteParameterSpace
import org.deeplearning4j.arbiter.optimize.parameter.integer.IntegerParameterSpace
import org.deeplearning4j.arbiter.optimize.runner.LocalOptimizationRunner
import org.deeplearning4j.arbiter.saver.local.FileModelSaver
import org.deeplearning4j.arbiter.scoring.RegressionValue
import org.deeplearning4j.arbiter.scoring.impl.TestSetRegressionScoreFunction
import org.deeplearning4j.arbiter.task.MultiLayerNetworkTaskCreator
import org.deeplearning4j.earlystopping.EarlyStoppingConfiguration
import org.deeplearning4j.earlystopping.saver.InMemoryModelSaver
import org.deeplearning4j.earlystopping.scorecalc.DataSetLossCalculator
import org.deeplearning4j.earlystopping.termination.MaxEpochsTerminationCondition
import org.deeplearning4j.nn.api.OptimizationAlgorithm
import org.deeplearning4j.nn.conf.Updater
import org.eclipse.xtend.lib.annotations.Data
import org.nd4j.linalg.activations.Activation
import org.nd4j.linalg.dataset.api.iterator.DataSetIterator
import org.nd4j.linalg.lossfunctions.LossFunctions.LossFunction

class Arbiter {

	new(TrainAndTestData datasets) {
		val esConf = new EarlyStoppingConfiguration.Builder() => [
			epochTerminationConditions(new MaxEpochsTerminationCondition(3))
			scoreCalculator(new DataSetLossCalculator(datasets.trainData, true)) // Might want to implement my own for R2
			modelSaver(new InMemoryModelSaver())
		]

		val mls = new MultiLayerSpace.Builder() => [
			optimizationAlgo(OptimizationAlgorithm.STOCHASTIC_GRADIENT_DESCENT)
			updater(Updater.NESTEROVS)
			l2(new ContinuousParameterSpace(0.0001, 0.05))
			iterations(1)
			addLayer(
				new GravesLSTMLayerSpace.Builder().nIn(datasets.format.numOfVariables).nOut(new IntegerParameterSpace(30, 600)).activation(new DiscreteParameterSpace(Activation.TANH, Activation.LEAKYRELU)).build()
			)
			addLayer(new OutputLayerSpace.Builder().nOut(datasets.format.numOfVariables).activation(Activation.IDENTITY).lossFunction(LossFunction.MSE).build())
			earlyStoppingConfiguration(esConf.build())
			pretrain(false)
			backprop(true)
		]

		val Map<String, Object> commands = #{
			DataSetIteratorFactoryProvider.FACTORY_KEY -> OrderbookDataSetIteratorFactory.canonicalName
		}

		val candidateGenerator = new RandomSearchGenerator(mls.build(), commands)

		val modelSavePath = new File(System.getProperty("java.io.tmpdir"), "Orderbook\\").absolutePath

		val file = new File(modelSavePath)
		if(file.exists())
			file.delete()
		file.mkdir()
		if(!file.exists())
			throw new RuntimeException()

		val configuration = new OptimizationConfiguration.Builder() => [
			candidateGenerator(candidateGenerator)
			dataProvider(new OrderbookDataSetProvider())
			modelSaver(new FileModelSaver(modelSavePath))
			scoreFunction(new TestSetRegressionScoreFunction(RegressionValue.CorrCoeff))
			terminationConditions(new MaxTimeCondition(120, TimeUnit.MINUTES), new MaxCandidatesCondition(400))
		]

		val runner = new LocalOptimizationRunner(configuration.build(), new MultiLayerNetworkTaskCreator())
		runner.execute()

		println("Done")
	}

	@Data static class OrderbookDataSetProvider implements DataProvider {

		override getDataType() {
			DataSetIterator
		}

		override testData(Map<String, Object> dataParameters) {
			if (dataParameters === null || dataParameters.isEmpty()) {
				return prepareData(Duration.ofHours(48).get(ChronoUnit.SECONDS)).testData
			} else if(dataParameters.containsKey("batchSize")) {
				return prepareData(dataParameters.get("batchSize") as Integer).testData
			} else {
				return prepareData(Duration.ofHours(48).get(ChronoUnit.SECONDS)).testData
			}
		}

		override trainData(Map<String, Object> dataParameters) {
			println("train "+dataParameters)
			if (dataParameters === null || dataParameters.isEmpty()) {
				return prepareData(Duration.ofHours(48).get(ChronoUnit.SECONDS)).trainData
			} else if(dataParameters.containsKey("batchSize")) {
				return prepareData(dataParameters.get("batchSize") as Integer).trainData
			} else {
				return prepareData(Duration.ofHours(48).get(ChronoUnit.SECONDS)).trainData
			}
		}

		def prepareData(long miniBatch) {
			val tmpFolder = new File("/tmp/", new SimpleDateFormat("HH:mm:ss").format(new Date()))
			tmpFolder.mkdir()
			tmpFolder.deleteOnExit()
			return Vor.loadNewDataPoints(tmpFolder, miniBatch, 63, miniBatch.intValue)
		}

	}

}
