package com.sirolf2009.yggdrasil.vor

import com.beust.jcommander.JCommander
import com.datastax.driver.core.Cluster
import com.sirolf2009.yggdrasil.sif.loader.LoadersDatabase
import com.sirolf2009.yggdrasil.sif.saver.SaversFile.NetToFile
import com.sirolf2009.yggdrasil.vor.data.Arguments
import com.sirolf2009.yggdrasil.vor.data.DataFormat
import com.sirolf2009.yggdrasil.vor.data.PrepareOrderbook
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
import com.sirolf2009.yggdrasil.sif.transmutation.OrderbookNormaliseDiffStdDev
import java.net.InetSocketAddress
import java.time.Duration
import java.time.temporal.ChronoUnit

class Vor {

	static val log = LogManager.logger
	static val baseDir = new File("data")

	def static void main(String[] args) {
		extension val arguments = new Arguments()
		JCommander.newBuilder().addObject(arguments).build().parse(args)
		log.info("Starting with arguments: " + arguments)
		train(arguments)
	}

	def static train(extension Arguments arguments) {
		val networkFolder = new File(baseDir, networkFolder)
		networkFolder.mkdirs()
		if(networkFolder.list.size > 0) {
			throw new IllegalStateException("The network folder is not empty!")
		}

		val cluster = Cluster.builder.addContactPointsWithPorts(new InetSocketAddress("freyr", 80), new InetSocketAddress("freyr", 9042)).build()
		val session = cluster.connect()
		val data = LoadersDatabase.getOrderbook(session, Duration.ofHours(hoursOfData).get(ChronoUnit.SECONDS))
		session.close()
		cluster.close()
		new OrderbookNormaliseDiffStdDev().accept(data)
		extension val format = new PrepareOrderbook(baseDir, data, steps, minibatch).call()
		extension val datasets = getData(format)
		val net = new RNN(numOfVariables).get()
		log.info("Training...")
		(0 ..< epochs).forEach [
			net.fit(trainData)
			trainData.reset()
			new NetToFile(new File(networkFolder, "predict_" + it + ".zip")).accept(net)
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
