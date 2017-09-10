package com.sirolf2009.yggdrasil.vor.optimize

import com.sirolf2009.yggdrasil.sif.saver.SaversFile.NetToFile
import com.sirolf2009.yggdrasil.vor.data.TrainAndTestData
import java.io.File
import java.util.List
import org.deeplearning4j.nn.multilayer.MultiLayerNetwork
import java.text.SimpleDateFormat
import java.util.Date
import com.sirolf2009.yggdrasil.vor.Vor
import org.apache.logging.log4j.LogManager

class Optimizer {
	
	static val log = LogManager.logger 

	def static run(List<Parameters> params, File dataFolder, TrainAndTestData datasets, int epochs) {
		val networks = params.map[it -> NetworkGenerator.createNetwork(it, datasets.format.numOfVariables)].toList()
		log.info('''Epoch	Key	r2	mse''')
		(0 ..< epochs).forEach [epoch|
			networks.forEach[
				value.fit(datasets.trainData)
				datasets.trainData.reset()
				new NetToFile(new File(dataFolder, key + "_" + epoch + ".zip")).accept(value)

				val evaluation = new org.deeplearning4j.eval.RegressionEvaluation(datasets.format.numOfVariables)
				while(datasets.testData.hasNext()) {
					val t = datasets.testData.next()
					val features = t.getFeatureMatrix()
					val labels = t.getLabels()
					val predicted = (value as MultiLayerNetwork).output(features, true)
					evaluation.evalTimeSeries(labels, predicted)
				}

				log.info('''«epoch»	«key»	«evaluation.correlationR2(0)»	«evaluation.meanSquaredError(0)»''')
				datasets.testData.reset()
			]
		]
	}
	
	def static void main(String[] args) {
		val params = ParameterGenerator.get(1, 10, 1, 0.0005, 0.5, 0.0005, 10, 630, 10)
		val dataFolder = new File("data/optimize/"+new SimpleDateFormat("yyyy-MM-dd'T'HH_mm_ss").format(new Date()))
		dataFolder.mkdirs()
		val data = Vor.loadNewData(24, 60, 1024)
		run(params, dataFolder, data, 10)
	}

}
