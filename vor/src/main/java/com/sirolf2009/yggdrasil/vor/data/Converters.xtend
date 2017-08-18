package com.sirolf2009.yggdrasil.vor.data

import java.util.List
import java.util.function.Function
import java.util.stream.Collectors
import java.util.stream.Stream
import org.apache.commons.lang3.time.DateUtils
import org.apache.commons.math3.stat.descriptive.DescriptiveStatistics
import org.apache.logging.log4j.LogManager
import org.datavec.api.writable.DoubleWritable
import org.datavec.api.writable.Writable
import org.influxdb.dto.QueryResult

import static java.util.stream.Collectors.*
import org.nd4j.linalg.api.ndarray.INDArray

class Converters {

	static val bidAskOrder = #["bid", "ask"]

	public static Function<QueryResult, List<OrderPoint>> parseOrderbook = [
		val log = LogManager.logger
		log.info("Parsing the order book")
		results.parallelStream().flatMap [
			it.series.parallelStream().flatMap [
				val values = values
				val columns = columns

				val index = Integer.parseInt(tags.get("index"))
				val side = tags.get("side")
				(0 ..< values.size()).map [
					try {
						val time = DateUtils.parseDate(values.get(it).get(columns.indexOf("time")).toString(), #["yyyy-MM-dd'T'HH:mm:ss.SSSX", "yyyy-MM-dd'T'HH:mm:ss.SSSZ", "yyyy-MM-dd'T'HH:mm:ss.SSX", "yyyy-MM-dd'T'HH:mm:ss.SX", "yyyy-MM-dd'T'HH:mm:ssX"])
						val value = values.get(it).get(columns.indexOf("value")) as Double
						val amount = values.get(it).get(columns.indexOf("amount")) as Double
						return new OrderPoint(time, side, index, value, amount)
					} catch(Exception e) {
						log.error("Failed to parse " + it, e)
						return null
					}
				].filter[it !== null].toList().stream()
			]
		].collect()
	]

	public static Function<List<OrderPoint>, List<OrderPoint>> normalize = [
		val log = LogManager.logger
		log.info("Normalizing")
		val maxBid = get(0).value
		val minAsk = get(30).value
		val halfPrice = minAsk-maxBid
		val amounts = parallelStream().map[amount].collect()
		val amountStats = new DescriptiveStatistics(amounts)
		val amountMean = amountStats.mean
		val amountStdDev = amountStats.standardDeviation
		parallelStream().map[
			new OrderPoint(timestamp, side, index, (value-halfPrice)/((value+halfPrice)/2), (amount-amountMean)*amountStdDev)
		].collect()
	]

	public static Function<List<OrderPoint>, List<String>> convertToCSV = [
		val log = LogManager.logger
		log.info("Converting to csv")
		stream().collect(groupingBy[timestamp]).entrySet().parallelStream().filter[value.size() == 30].map [
			key -> value.stream().collect(groupingBy[side]).entrySet().stream().map [
				key -> value.stream().collect(toMap([index], [it])).entrySet().stream().sorted[a, b|a.key.compareTo(b.key)].map[value.value + "," + value.amount].reduce[a, b|a + "," + b].get()
			].sorted[a, b|bidAskOrder.indexOf(a.key).compareTo(bidAskOrder.indexOf(b))].map[value].reduce[a, b|a + "," + b].get()
		].sorted[a, b|a.key.compareTo(b.key)].map[value].collect()
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

	public static Function<List<INDArray>, List<List<Double>>> indArraysToMatrix = [
		val log = LogManager.logger
		log.info("Creating matrix from INDArray")
		map[
			data.asDouble() as List<Double>
		].toList()
	]
	
	public static Function<List<List<Double>>, List<List<Writable>>> matrixToWritables = [
		map [
			map[
				new DoubleWritable(it) as Writable
			]
		]
	]

	public static Function<List<List<Writable>>, List<String>> writablesToCSV = [
		val log = LogManager.logger
		log.info("Converting to csv")
		map[
			map[it+""].reduce[a,b|a+","+b]
		]
	]

	public static Function<List<String>, String> joinAsLines = [
		val log = LogManager.logger
		log.info("Joining lines")
		stream().reduce[a, b|a + "\n" + b].get()
	]

	def private static <T> List<T> collect(Stream<T> stream) {
		stream.collect(Collectors.toList())
	}

}
