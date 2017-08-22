package com.sirolf2009.yggdrasil.sif

import com.sirolf2009.yggdrasil.sif.loader.LoadersDatabase
import com.sirolf2009.yggdrasil.sif.transmutation.OrderPoints
import com.sirolf2009.yggdrasil.sif.transmutation.CSV
import com.sirolf2009.yggdrasil.sif.saver.SaversFile
import com.sirolf2009.yggdrasil.sif.transmutation.INDArrays
import java.io.File

class TrainingData {
	
	def static downloadOrderbook(String influx, int orderpoints) {
		LoadersDatabase.getDatapoints(influx, orderpoints).map(OrderPoints.normalize).map(OrderPoints.ordersToMatrix).map(CSV.matrixToCSV).map(CSV.joinAsLines).ifPresent(SaversFile.saveOrderbook)
	}

	def static getPredictData(String influx, int orderpoints) {
		LoadersDatabase.getDatapoints(influx, orderpoints).map(OrderPoints.normalize).map(OrderPoints.ordersToMatrix).map(INDArrays.createRNNDataSet(0))
	}

	def static getPredictDataLarge(String influx, int orderpoints, File folder) {
		OrderPoints.normalize.andThen(OrderPoints.ordersToMatrix).andThen(INDArrays.createRNNDataSet(0)).apply(LoadersDatabase.getDatapointsLarge(influx, orderpoints, folder))
	}

	def static readPredictDataLarge(File folder) {
		OrderPoints.normalize.andThen(OrderPoints.ordersToMatrix).andThen(INDArrays.createRNNDataSet(0)).apply(LoadersDatabase.parseDatapoints(folder))
	}

	def static readDataLargeToCSV(File folder) {
		SaversFile.saveOrderbook.accept(OrderPoints.normalize.andThen(OrderPoints.ordersToMatrix).andThen(CSV.matrixToCSV).andThen(CSV.joinAsLines).apply(LoadersDatabase.parseDatapoints(folder)))
	}
	
}