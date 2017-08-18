package com.sirolf2009.yggdrasil.sif

import com.sirolf2009.yggdrasil.sif.loader.LoadersDatabase
import com.sirolf2009.yggdrasil.sif.transmutation.OrderPoints
import com.sirolf2009.yggdrasil.sif.transmutation.CSV
import com.sirolf2009.yggdrasil.sif.saver.SaversFile
import com.sirolf2009.yggdrasil.sif.transmutation.INDArrays

class TrainingData {
	
	def static downloadOrderbook(String influx, int orderpoints) {
		LoadersDatabase.getDatapoints(influx, orderpoints).map(OrderPoints.normalize).map(OrderPoints.ordersToMatrix).map(CSV.matrixToCSV).map(CSV.joinAsLines).ifPresent(SaversFile.saveOrderbook)
	}

	def static getPredictData(String influx, int orderpoints) {
		LoadersDatabase.getDatapoints(influx, orderpoints).map(OrderPoints.normalize).map(OrderPoints.ordersToMatrix).map(INDArrays.createRNNDataSet(0))
	}
	
}