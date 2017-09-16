package com.sirolf2009.yggdrasil.vor.arbiter

import org.nd4j.linalg.dataset.api.iterator.DataSetIteratorFactory
import com.sirolf2009.yggdrasil.vor.Vor

class OrderbookDataSetIteratorFactory  implements DataSetIteratorFactory {

	override create() {
		return Vor.loadNewData(24, 60, 1024).trainData
	}

}
