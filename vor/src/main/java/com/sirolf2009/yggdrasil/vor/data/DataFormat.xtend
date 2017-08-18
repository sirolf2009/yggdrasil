package com.sirolf2009.yggdrasil.vor.data

import java.io.File
import org.eclipse.xtend.lib.annotations.Data
import org.nd4j.linalg.api.ndarray.INDArray

@Data class DataFormat {

	val int trainSize
	val int testSize
	val int numberOfTimesteps
	val int numOfVariables
	val int miniBatchSize
	val INDArray trainingArray
	val INDArray testingArray
	val File baseDir
	val File featuresDirTrain
	val File labelsDirTrain
	val File featuresDirTest
	val File labelsDirTest

}
