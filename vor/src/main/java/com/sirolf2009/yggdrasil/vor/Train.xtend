package com.sirolf2009.yggdrasil.vor

import java.util.function.Consumer
import org.apache.logging.log4j.LogManager
import org.deeplearning4j.nn.multilayer.MultiLayerNetwork
import org.eclipse.xtend.lib.annotations.Data
import org.nd4j.linalg.dataset.api.iterator.DataSetIterator
import com.sirolf2009.yggdrasil.sif.saver.SaversFile.NetToFile
import java.io.File

@Data class Train implements Consumer<MultiLayerNetwork> {
	
	static val log = LogManager.logger
	
	val DataSetIterator trainData
	val int epochs

	override accept(MultiLayerNetwork net) {
		log.info("Training...")
		(0 ..< epochs).forEach [
			net.fit(trainData)
			new NetToFile(new File("~/network"+it+".zip")).accept(net)
			trainData.reset()
		]
	}
	
}
