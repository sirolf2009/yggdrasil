package com.sirolf2009.yggdrasil.sif.transmutation

import org.apache.logging.log4j.LogManager
import java.util.List

import static extension com.sirolf2009.yggdrasil.sif.StreamExtensions.*
import org.nd4j.linalg.factory.Nd4j
import java.util.function.Function
import org.nd4j.linalg.api.ndarray.INDArray

class INDArrays {

	static val log = LogManager.logger

	def static Function<List<List<Double>>, List<INDArray>> createRNNDataSet(int numberOfTimesteps) {
		return [
			log.info("Creating dataset")
			(0 ..< size() - numberOfTimesteps).toList().parallelStream.map [ example |
				Nd4j.create((0 .. numberOfTimesteps).toList().stream().map [ step |
					get(example + step) as double[]
				].collect() as double[][], 'c')
			].collect()
		]
	}

	def static Function<List<INDArray>, List<List<Double>>> toMatrix() {
		return [
			map[
				data.asDouble as List<Double>
			].toList()
		]
	}
}
