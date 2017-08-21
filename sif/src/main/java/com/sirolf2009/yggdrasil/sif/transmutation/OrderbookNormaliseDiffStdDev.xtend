package com.sirolf2009.yggdrasil.sif.transmutation

import java.util.Arrays
import java.util.function.Consumer
import org.apache.commons.math3.stat.descriptive.DescriptiveStatistics
import tech.tablesaw.api.DoubleColumn
import tech.tablesaw.api.Table

class OrderbookNormaliseDiffStdDev implements Consumer<Table> {

	override accept(Table it) {
		val priceColumns = columns.filter[name.contains("price")].map[it as DoubleColumn].toList()
		val amountColumns = columns.filter[name.contains("amount")].map[it as DoubleColumn].toList()
		val maxBidColumn = column("bid_price_0") as DoubleColumn
		val minAskColumn = column("ask_price_0") as DoubleColumn
		Arrays.stream(rows).forEach [
			val maxBid = maxBidColumn.get(it)
			val minAsk = minAskColumn.get(it)
			val halfPrice = minAsk - maxBid
			priceColumns.forEach[column|
				column.set(it, percentualDifference(column.get(it), halfPrice))
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
		return (a - b) / ((a + b) / 2)
	}
	
	def static zScore(double value, double mean, double stdDev) {
		return (value - mean) * stdDev
	}

}
