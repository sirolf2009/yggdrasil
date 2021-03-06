package com.sirolf2009.yggdrasil.vor.data

import com.sirolf2009.yggdrasil.freyr.model.TableOrderbook
import java.io.File
import java.nio.file.Paths
import java.util.Collections
import java.util.List
import org.apache.logging.log4j.LogManager
import org.eclipse.xtend.lib.annotations.Data

import static extension com.sirolf2009.yggdrasil.sif.TableExtensions.*
import static extension org.apache.commons.io.FileUtils.*
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit

@Data public class PrepareOrderbook {

	static val log = LogManager.logger

	val int numberOfTimesteps
	val int miniBatchSize
	val TableOrderbook data
	val int trainSize
	val File baseDir
	val File featuresDirTrain
	val File labelsDirTrain
	val File featuresDirTest
	val File labelsDirTest

	new(File baseDir, TableOrderbook data, int numberOfTimesteps, int miniBatchSize) {
		this.numberOfTimesteps = numberOfTimesteps
		this.miniBatchSize = miniBatchSize
		this.data = data
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
		val executor = Executors.newFixedThreadPool(Runtime.runtime.availableProcessors)
		(0 .. trainSize).toList.shuffle.forEach [ indexInTable, it |
			executor.submit [
				val featuresPath = Paths.get('''«featuresDirTrain.absolutePath»/train_«it».csv''')
				val labelsPath = Paths.get('''«labelsDirTrain.absolutePath»/train_«it».csv''')
				val set = data.rows(indexInTable, indexInTable + numberOfTimesteps)
				set.removeColumns("datetime")
//				set.removeColumns("bid_price_15", "bid_amount_15", "bid_price_14", "bid_amount_14", "bid_price_13", "bid_amount_13", "bid_price_12", "bid_amount_12")
//				set.removeColumns("ask_price_15", "ask_amount_15", "ask_price_14", "ask_amount_14", "ask_price_13", "ask_amount_13", "ask_price_12", "ask_amount_12")
				set.write().csv(featuresPath.toString())
				val outcome = data.selectWhere(index(indexInTable + numberOfTimesteps))
				outcome.removeColumns("datetime")
				outcome.write().csv(labelsPath.toString())
			]
		]
		executor.shutdown()
		executor.awaitTermination(10, TimeUnit.MINUTES)

		(trainSize .. (numberOfTimesteps + trainSize)).toList.parallelStream.forEach [
			val featuresPath = Paths.get('''«featuresDirTest.absolutePath»/test_«it».csv''')
			val labelsPath = Paths.get('''«labelsDirTest.absolutePath»/test_«it».csv''')
			val set = data.rows(it, it + numberOfTimesteps)
			set.removeColumns("datetime")
			set.write().csv(featuresPath.toString())
			val outcome = data.selectWhere(index(it + numberOfTimesteps))
			outcome.removeColumns("datetime")
			outcome.write().csv(labelsPath.toString())
		]

		return new DataFormat(trainSize, numberOfTimesteps, numberOfTimesteps, data.columnCount - 1, miniBatchSize, baseDir, featuresDirTrain, labelsDirTrain, featuresDirTest, labelsDirTest)
	}

	def static clean(File folder) {
		folder.mkdirs()
		folder.cleanDirectory()
	}

	def static <T> shuffle(List<T> list) {
		Collections.shuffle(list)
		return list
	}

}
