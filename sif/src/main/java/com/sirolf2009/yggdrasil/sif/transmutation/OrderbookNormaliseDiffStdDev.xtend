package com.sirolf2009.yggdrasil.sif.transmutation

import com.sirolf2009.yggdrasil.freyr.model.TableOrderbook
import java.util.Arrays
import java.util.function.Consumer
import org.apache.commons.math3.stat.descriptive.DescriptiveStatistics

class OrderbookNormaliseDiffStdDev implements Consumer<TableOrderbook> {

	override accept(TableOrderbook it) {
		val priceColumns = bidPrices + askPrices
		val amountColumns =  askAmounts + bidAmounts
		val lastColumn = getLast()
		Arrays.stream(rows).forEach [
			val lastPrice = lastColumn.get(it)
			priceColumns.forEach[column|
				println("lastPrice: "+lastPrice+" "+column.name+": "+column.get(it) +" -> "+percentualDifference(column.get(it), lastPrice))
				column.set(it, percentualDifference(column.get(it), lastPrice))
			]
			
			val amounts = amountColumns.map[col|col.get(it)].toList()
			val amountStats = new DescriptiveStatistics(amounts)
			val amountMean = amountStats.mean
			val amountStdDev = amountStats.standardDeviation
			amountColumns.forEach[column|
				column.set(it, zScore(column.get(it), amountMean, amountStdDev))
			]
		]
	}
	
	def static percentualDifference(double a, double b) {
		return Math.abs(a - b) / ((a + b) / 2)
	}
	
	def static zScore(double value, double mean, double stdDev) {
		return (value - mean) * stdDev
	}

}
