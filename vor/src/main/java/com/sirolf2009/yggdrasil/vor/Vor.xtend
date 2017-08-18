package com.sirolf2009.yggdrasil.vor

import com.sirolf2009.yggdrasil.sif.TrainingData
import com.sirolf2009.yggdrasil.vor.data.Arguments
import com.sirolf2009.yggdrasil.vor.data.DataFormat
import com.sirolf2009.yggdrasil.vor.data.Loaders.FileLines
import com.sirolf2009.yggdrasil.vor.data.PrepareData
import com.sirolf2009.yggdrasil.vor.data.Savers.NetToFile
import com.sirolf2009.yggdrasil.vor.data.TrainAndTestData
import java.io.File
import org.apache.logging.log4j.LogManager
import org.datavec.api.records.reader.impl.csv.CSVSequenceRecordReader
import org.datavec.api.split.NumberedFileInputSplit
import org.deeplearning4j.datasets.datavec.SequenceRecordReaderDataSetIterator
import org.deeplearning4j.datasets.datavec.SequenceRecordReaderDataSetIterator.AlignmentMode
import org.deeplearning4j.eval.RegressionEvaluation
import org.deeplearning4j.nn.multilayer.MultiLayerNetwork
import org.nd4j.linalg.dataset.api.iterator.DataSetIterator

class Vor {

	static val log = LogManager.logger
	static val baseDir = new File("data")

	def static void main(String[] args) {
	}

	def static train(extension Arguments arguments) {
		extension val format = new PrepareData(baseDir, new FileLines(new File("data/orderbook.csv")).get(), 60*15, 5).call()
		extension val datasets = getData(format)
		val predictData = TrainingData.getPredictData('''http://«influxHost»:«influxPort»''', 60*15)
		val net = new RNN(format).get()
		val epochs = 100
		log.info("Training...")
		(0 ..< epochs).forEach [
			net.fit(trainData)
			trainData.reset()
			new NetToFile(new File("data/predict/predict_" + it + ".zip")).accept(net)
			predictData.ifPresent[Predict.predict(net, it, 60*15)]
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
		val trainFeatures = new CSVSequenceRecordReader()
		trainFeatures.initialize(new NumberedFileInputSplit('''«featuresDirTrain.absolutePath»/train_%d.csv''', 0, trainSize - 1))
		val trainLabels = new CSVSequenceRecordReader()
		trainLabels.initialize(new NumberedFileInputSplit('''«labelsDirTrain.absolutePath»/train_%d.csv''', 0, trainSize - 1))
		val trainData = new SequenceRecordReaderDataSetIterator(trainFeatures, trainLabels, miniBatchSize, -1, true, AlignmentMode.ALIGN_END)

		val testFeatures = new CSVSequenceRecordReader()
		testFeatures.initialize(new NumberedFileInputSplit('''«featuresDirTest.absolutePath»/test_%d.csv''', trainSize, trainSize + testSize))
		val testLabels = new CSVSequenceRecordReader()
		testLabels.initialize(new NumberedFileInputSplit('''«labelsDirTest.absolutePath»/test_%d.csv''', trainSize, trainSize + testSize))
		val testData = new SequenceRecordReaderDataSetIterator(testFeatures, testLabels, miniBatchSize, -1, true, AlignmentMode.ALIGN_END)

		return new TrainAndTestData(trainData, testData)
	}

}
