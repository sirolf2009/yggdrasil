package com.sirolf2009.yggdrasil.vor.data

import java.io.File
import java.nio.file.Files
import java.nio.file.Paths
import java.nio.file.StandardOpenOption
import java.util.List
import java.util.stream.Collectors
import org.apache.logging.log4j.LogManager
import org.datavec.api.writable.Writable
import org.eclipse.xtend.lib.annotations.Data
import org.nd4j.linalg.api.ndarray.INDArray
import org.nd4j.linalg.factory.Nd4j
import org.apache.commons.lang3.tuple.Pair

import static extension org.apache.commons.io.FileUtils.*
import java.util.function.Function

@Data public class PrepareData {

	static val log = LogManager.logger

	val int numberOfTimesteps
	val int miniBatchSize
	val List<String> data
	val int numOfVariables
	val int trainSize
	val File baseDir
	val File featuresDirTrain
	val File labelsDirTrain
	val File featuresDirTest
	val File labelsDirTest

	new(File baseDir, List<String> data, int numberOfTimesteps, int miniBatchSize) {
		this.numberOfTimesteps = numberOfTimesteps
		this.miniBatchSize = miniBatchSize
		this.data = data
		numOfVariables = data.numOfVariables
		val trainingLines = data.size() - numberOfTimesteps - numberOfTimesteps - numberOfTimesteps
		trainSize = trainingLines - (trainingLines % miniBatchSize)

		this.baseDir = baseDir
		featuresDirTrain = new File(baseDir, "features_train")
		labelsDirTrain = new File(baseDir, "labels_train")
		featuresDirTest = new File(baseDir, "features_test")
		labelsDirTest = new File(baseDir, "labels_test")
	}

	def call() throws Exception {
		log.info("Preparing train and test data")
		featuresDirTrain.clean()
		labelsDirTrain.clean()
		featuresDirTest.clean()
		labelsDirTest.clean()
		(0 .. trainSize).toList.parallelStream.forEach [
			val featuresPath = Paths.get('''«featuresDirTrain.absolutePath»/train_«it».csv''')
			val labelsPath = Paths.get('''«labelsDirTrain.absolutePath»/train_«it».csv''')
			(0 .. numberOfTimesteps).forEach [ step |
				Files.write(featuresPath, data.get(it + step).concat("\n").bytes, StandardOpenOption.APPEND, StandardOpenOption.CREATE)
			]
			Files.write(labelsPath, data.get(it + numberOfTimesteps).concat("\n").bytes, StandardOpenOption.APPEND, StandardOpenOption.CREATE)
		]

		(trainSize .. (numberOfTimesteps + trainSize)).toList.parallelStream.forEach [
			val featuresPath = Paths.get('''«featuresDirTest.absolutePath»/test_«it».csv''')
			val labelsPath = Paths.get('''«labelsDirTest.absolutePath»/test_«it».csv''')
			(0 .. numberOfTimesteps).forEach [ step |
				Files.write(featuresPath, data.get(it + step).concat("\n").bytes, StandardOpenOption.APPEND, StandardOpenOption.CREATE)
			]
			Files.write(labelsPath, data.get(it + numberOfTimesteps).concat("\n").bytes, StandardOpenOption.APPEND, StandardOpenOption.CREATE)
		]

		return new DataFormat(trainSize, numberOfTimesteps, numberOfTimesteps, numOfVariables, miniBatchSize, baseDir, featuresDirTrain, labelsDirTrain, featuresDirTest, labelsDirTest)
	}

	def static createDataSet(List<String> orders, int numberOfTimesteps) throws Exception {
		log.info("Preparing test data")
		(0 ..< orders.size() - numberOfTimesteps).toList.parallelStream.flatMap [
			(0 .. numberOfTimesteps).toList().stream().map [ step |
				val data = orders.get(it + step).split(",")
				Nd4j.create(data.stream().map[Double.parseDouble(it)].collect(Collectors.toList()))
			]
		].reduce[a, b|Nd4j.vstack(a, b)].get()
	}

	def static createDataSet2(List<String> orders, int numberOfTimesteps) throws Exception {
		log.info("Preparing test data2")
		(0 ..< orders.size() - numberOfTimesteps).toList.parallelStream.map [
			Nd4j.create((0 .. numberOfTimesteps).toList().stream().map [ step |
				val data = orders.get(it + step).split(",")
				data.stream().map[Double.parseDouble(it)].collect(Collectors.toList()) as double[]
			].collect(Collectors.toList()) as double[][], 'c')
		].collect(Collectors.toList())
	}
	
	/** orders, ahead -> dataset */
	public static val Function<Pair<List<List<Double>>, Integer>, List<INDArray>> createDataSet = [
		(0 ..< left.size() - right).toList.parallelStream.map [example|
			Nd4j.create((0 .. right).toList().stream().map [ step |
				left.get(example + step)
			].collect(Collectors.toList()) as double[][], 'c')
		].collect(Collectors.toList())
	]  

	def static List<INDArray> createData(List<List<Writable>> orders, int numberOfTimesteps) throws Exception {
		log.info("Preparing test data")
		(0 ..< orders.size() - numberOfTimesteps).toList.parallelStream.flatMap [
			(0 .. numberOfTimesteps).toList().stream().map [ step |
				Nd4j.create(orders.get(it + step).stream().map[it.toDouble()].collect(Collectors.toList()))
			]
		].collect(Collectors.toList())
	}

	def static List<INDArray> createDataSetFast(List<List<Writable>> orders, int numberOfTimesteps) throws Exception {
		log.info("Preparing test data")
		(0 ..< orders.size() - numberOfTimesteps).toList.parallelStream.map [
			(0 .. numberOfTimesteps).map [ step |
				Nd4j.create(orders.get(it + step).stream().map[it.toDouble()].collect(Collectors.toList()))
			].reduce[a, b|Nd4j.vstack(a, b)].get()
		].collect(Collectors.toList())
	}

	def static INDArray createDataSetFlat(List<List<Writable>> orders, int numberOfTimesteps) throws Exception {
		log.info("Preparing test data")
		(0 ..< orders.size() - numberOfTimesteps).toList.parallelStream.flatMap [
			(0 .. numberOfTimesteps).toList().stream().map [ step |
				Nd4j.create(orders.get(it + step).stream().map[it.toDouble()].collect(Collectors.toList()))
			]
		].reduce[a, b|Nd4j.vstack(a, b)].get()
	}

	def static createIndArrayFromStringList(List<String> rawString, int numOfVariables, int start, int length) {
		val stringList = rawString.subList(start, start + length)
		val double[][] primitives = Matrix.new2DDoubleArrayOfSize(numOfVariables, stringList.size())
		stringList.forEach [ it, i |
			val vals = split(",")
			vals.forEach [ it, j |
				primitives.get(j).set(i, Double.valueOf(vals.get(j)))
			]
		]
		return Nd4j.create(#[1, length], primitives)
	}

	def static clean(File folder) {
		folder.mkdirs()
		folder.cleanDirectory()
	}

	def static getNumOfVariables(List<String> rawStrings) {
		return rawStrings.get(0).split(",").length
	}
}
