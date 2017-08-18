package com.sirolf2009.yggdrasil.vor.data

import org.eclipse.xtend.lib.annotations.Data
import org.nd4j.linalg.dataset.api.iterator.DataSetIterator

@Data class TrainAndTestData {
	DataSetIterator trainData
	DataSetIterator testData
}
