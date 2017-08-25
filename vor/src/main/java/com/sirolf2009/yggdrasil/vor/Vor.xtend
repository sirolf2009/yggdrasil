package com.sirolf2009.yggdrasil.vor

import com.beust.jcommander.JCommander
import com.sirolf2009.yggdrasil.sif.TrainingData
import com.sirolf2009.yggdrasil.sif.loader.LoadersFile
import com.sirolf2009.yggdrasil.sif.saver.SaversFile.NetToFile
import com.sirolf2009.yggdrasil.sif.transmutation.CSV
import com.sirolf2009.yggdrasil.sif.transmutation.INDArrays
import com.sirolf2009.yggdrasil.vor.data.Arguments
import com.sirolf2009.yggdrasil.vor.data.DataFormat
import com.sirolf2009.yggdrasil.vor.data.TrainAndTestData
import java.io.File
import java.nio.file.Files
import java.nio.file.Paths
import org.apache.logging.log4j.LogManager
import org.datavec.api.records.reader.impl.csv.CSVSequenceRecordReader
import org.datavec.api.split.NumberedFileInputSplit
import org.deeplearning4j.datasets.datavec.SequenceRecordReaderDataSetIterator
import org.deeplearning4j.datasets.datavec.SequenceRecordReaderDataSetIterator.AlignmentMode
import org.deeplearning4j.eval.RegressionEvaluation
import org.deeplearning4j.nn.multilayer.MultiLayerNetwork
import org.nd4j.linalg.dataset.api.iterator.DataSetIterator
import com.sirolf2009.yggdrasil.vor.data.PrepareOrderbook
import com.sirolf2009.yggdrasil.freyr.TestData

class Vor {

	static val log = LogManager.logger
	static val baseDir = new File("data")

	def static void main(String[] args) {
		extension val arguments = new Arguments()
		JCommander.newBuilder().addObject(arguments).build().parse(args)
		log.info("Starting with arguments: " + arguments)
//		LoadersDatabase.getDatapointsLarge('''http://«influxHost»:«influxPort»''', 60*60*24*80, new File(baseDir, "orderbook"), 8)
		train(arguments)
	}

	def static train(extension Arguments arguments) {
		val networkFolder = new File(baseDir, "predict-net")
		networkFolder.mkdirs()
		if(networkFolder.list.size > 0) {
			throw new IllegalStateException("The network folder is not empty!")
		}
		val predictionFolder = new File(baseDir, "predict-csv")
		predictionFolder.mkdirs()
		if(predictionFolder.list.size > 0) {
			throw new IllegalStateException("The prediction folder is not empty!")
		}
//		TrainingData.readDataLargeToCSV(new File("data/orderbook"))
//		extension val format = new PrepareData(baseDir, Files.readAllLines(new File("data/orderbook.csv").toPath()), steps, minibatch).call()
		extension val format = new PrepareOrderbook(baseDir, TestData.orderbookRows, steps, minibatch).call()
		extension val datasets = getData(format)
//		val predictData = TrainingData.getPredictData('''http://«influxHost»:«influxPort»''', 60*15)
//		val predictData = TrainingData.readPredictDataLarge(new File("data/orderbook"))
		val net = new RNN(format).get()
		val epochs = 100
		log.info("Training...")
		(0 ..< epochs).forEach [
			net.fit(trainData)
			trainData.reset()
			new NetToFile(new File(networkFolder, "predict_" + it + ".zip")).accept(net)
//			val prediction = INDArrays.toMatrix.andThen(CSV.matrixToCSV).andThen(CSV.joinAsLines).apply(Predict.predict(net, predictData, 60*15))
//			FileUtils.write(new File(predictionFolder, "predict_" + it + ".csv"), prediction)
		]
	}
	
	def static showPredictions(extension Arguments arguments) {
		val predictData = TrainingData.getPredictData('''http://«influxHost»:«influxPort»''', 5000)
		new File("data/predict").listFiles.forEach[
			val prediction = Predict.predict(LoadersFile.loadNetwork(it), predictData.get(), 60*15)
			val csv = INDArrays.toMatrix.andThen(CSV.matrixToCSV).andThen(CSV.joinAsLines).apply(prediction)
			log.info("Wrote to "+Paths.get("data/predict-csv/"+name+".csv"))
			Files.write(Paths.get("data/predict-csv/"+name+".csv"), csv.bytes)
		]
	}

	def static showRegressionEvaluation(MultiLayerNetwork net, DataSetIterator testDataIter, int numOfVariables, int epoch) {
		val evaluation = new RegressionEvaluation(numOfVariables)
		while(testDataIter.hasNext()) {
			val t = testDataIter.next()
			val features = t.getFeatureMatrix()
			val labels = t.getLabels()
			val predicted = net.output(features, true)
			evaluation.evalTimeSeries(labels, predicted)
		}
		log.info("Epoch: " + epoch + "\n" + evaluation.stats())
		testDataIter.reset()
	}

	def static getData(extension DataFormat format) {
		val trainFeatures = new CSVSequenceRecordReader(1)
		trainFeatures.initialize(new NumberedFileInputSplit('''«featuresDirTrain.absolutePath»/train_%d.csv''', 0, trainSize - 1))
		val trainLabels = new CSVSequenceRecordReader(1)
		trainLabels.initialize(new NumberedFileInputSplit('''«labelsDirTrain.absolutePath»/train_%d.csv''', 0, trainSize - 1))
		val trainData = new SequenceRecordReaderDataSetIterator(trainFeatures, trainLabels, miniBatchSize, -1, true, AlignmentMode.ALIGN_END)

		val testFeatures = new CSVSequenceRecordReader(1)
		testFeatures.initialize(new NumberedFileInputSplit('''«featuresDirTest.absolutePath»/test_%d.csv''', trainSize, trainSize + testSize))
		val testLabels = new CSVSequenceRecordReader(1)
		testLabels.initialize(new NumberedFileInputSplit('''«labelsDirTest.absolutePath»/test_%d.csv''', trainSize, trainSize + testSize))
		val testData = new SequenceRecordReaderDataSetIterator(testFeatures, testLabels, miniBatchSize, -1, true, AlignmentMode.ALIGN_END)

		return new TrainAndTestData(trainData, testData)
	}

}
