package com.sirolf2009.yggdrasil.sif.saver

import java.io.File
import java.io.FileOutputStream
import java.util.function.Consumer
import org.apache.commons.io.IOUtils
import org.apache.logging.log4j.LogManager
import org.deeplearning4j.nn.multilayer.MultiLayerNetwork
import org.deeplearning4j.util.ModelSerializer
import org.eclipse.xtend.lib.annotations.Data

class SaversFile {
	
	public static val Consumer<String> saveOrderbook = new StringToFile(new File("data/orderbook.csv"))

	@Data static class StringToFile implements Consumer<String> {

		static val log = LogManager.logger

		val File file

		override accept(String t) {
			log.info('''saving «t.bytes.length.humanReadableByteCount(false)» bytes to «file»''')
			val out = new FileOutputStream(file)
			IOUtils.write(t, out)
			out.close()
		}

		def static String humanReadableByteCount(long bytes, boolean si) {
			val unit = if(si) 1000 else 1024;
			if(bytes < unit) return bytes + " B";
			val exp = (Math.log(bytes) / Math.log(unit)) as int
			val pre = (if(si) "kMGTPE" else "KMGTPE").charAt(exp - 1) + (if(si) "" else "i");
			return String.format("%.1f %sB", bytes / Math.pow(unit, exp), pre);
		}

	}

	@Data static class NetToFile implements Consumer<MultiLayerNetwork> {

		static val log = LogManager.logger

		val File file

		override accept(MultiLayerNetwork net) {
			log.info('''saving network to «file»''')
			val saveUpdater = true
			ModelSerializer.writeModel(net, file, saveUpdater)
		}

	}
	
}