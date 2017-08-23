package com.sirolf2009.yggdrasil.sif.transmutation

import com.sirolf2009.yggdrasil.freyr.model.TableOrderbook
import java.util.Arrays
import java.util.function.Consumer
import org.apache.commons.math3.stat.descriptive.DescriptiveStatistics

class OrderbookNormaliseDiffStdDev implements Consumer<TableOrderbook> {

	override accept(TableOrderbook it) {
		val priceColumns = bidPrices + askPrices
		val amountColumns =  askPrices + bidPrices
		val maxBidColumn = bidPrices.get(0)
		val minAskColumn = askPrices.get(0)
		Arrays.stream(rows).forEach [
			val maxBid = maxBidColumn.get(it)
			val minAsk = minAskColumn.get(it)
			val halfPrice = maxBid + (minAsk - maxBid)/2
			println(halfPrice)
			priceColumns.forEach[column|
				println('''«column.name» «column.get(it)» -> «percentualDifference(column.get(it), halfPrice)»''')
				column.set(it, percentualDifference(column.get(it), halfPrice))
			]
			
			val amounts = amountColumns.map[col|col.get(it)].toList()
			val amountStats = new DescriptiveStatistics(amounts)
			val amountMean = amountStats.mean
			val amountStdDev = amountStats.standardDeviation
			amountColumns.forEach[column|
				println('''«column.name» «column.get(it)» -> «zScore(column.get(it), amountMean, amountStdDev)»''')
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
