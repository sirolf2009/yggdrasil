package com.sirolf2009.yggdrasil.sif.transmutation

import com.sirolf2009.yggdrasil.sif.model.OrderPoint
import java.util.List
import java.util.function.Function
import org.apache.commons.math3.stat.descriptive.DescriptiveStatistics
import org.apache.logging.log4j.LogManager

import static extension com.sirolf2009.yggdrasil.sif.StreamExtensions.*
import static java.util.stream.Collectors.*

class OrderPoints {

	static val log = LogManager.logger
	static val bidAskOrder = #["bid", "ask"]

	public static Function<List<OrderPoint>, List<OrderPoint>> normalize = [
		log.info("Normalizing")
		val maxBid = get(0).value
		val minAsk = get(30).value
		val halfPrice = minAsk - maxBid
		val amounts = parallelStream().map[amount].collect()
		val amountStats = new DescriptiveStatistics(amounts)
		val amountMean = amountStats.mean
		val amountStdDev = amountStats.standardDeviation
		parallelStream().map [
			new OrderPoint(timestamp, side, index, (value - halfPrice) / ((value + halfPrice) / 2), (amount - amountMean) * amountStdDev)
		].collect()
	]
	
	public static Function<List<OrderPoint>, List<List<Double>>> ordersToMatrix = [
		val log = LogManager.logger
		log.info("Creating matrix from orders")
		stream().collect(groupingBy[timestamp]).entrySet().parallelStream().filter[value.size() == 30].map [
			key -> value.stream().collect(groupingBy[side]).entrySet().stream().map [
				key -> value.stream().collect(toMap([index], [it])).entrySet().stream().sorted[a, b|a.key.compareTo(b.key)].flatMap[#[value.value, value.amount].stream()].collect()
			].sorted[a, b|bidAskOrder.indexOf(a.key).compareTo(bidAskOrder.indexOf(b))].flatMap[value.stream()].collect()
		].sorted[a, b|a.key.compareTo(b.key)].map[value].collect()
	]

}
