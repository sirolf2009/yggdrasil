package com.sirolf2009.yggdrasil.freyr

import com.beust.jcommander.JCommander
import java.time.Duration
import java.util.List
import java.util.stream.Collectors
import java.util.stream.Stream
import org.apache.logging.log4j.LogManager
import org.influxdb.InfluxDB.ConsistencyLevel
import org.influxdb.InfluxDBFactory
import org.influxdb.dto.BatchPoints
import org.influxdb.dto.Point
import org.knowm.xchange.ExchangeFactory
import org.knowm.xchange.currency.CurrencyPair
import org.knowm.xchange.dto.marketdata.OrderBook
import org.knowm.xchange.dto.trade.LimitOrder
import org.knowm.xchange.gdax.GDAXExchange
import java.util.concurrent.TimeUnit

class Freyr {

	static val log = LogManager.logger

	def static void main(String[] args) {
		extension val arguments = new Arguments()
		JCommander.newBuilder().addObject(arguments).build().parse(args)
		log.info("Starting with arguments: " + arguments)

		val exchange = ExchangeFactory.INSTANCE.createExchange(GDAXExchange.getCanonicalName())
		val influx = InfluxDBFactory.connect("http://" + influxHost + ":" + influxPort)
		influx.createDatabase(database)
		while(true) {
			try {
				val orderbook = exchange.marketDataService.getOrderBook(CurrencyPair.BTC_EUR)
				influx.write(orderbook.parseOrderbook(database))
				Thread.sleep(Duration.ofSeconds(1).toMillis())
			} catch(Exception e) {
				log.error("Failed to retrieve orderbook from " + exchange, e)
			}
		}
	}

	def static parseOrderbook(OrderBook orderbook, String database) {
		val time = System.currentTimeMillis()
		val points = BatchPoints.database(database).consistency(ConsistencyLevel.ALL).build()
		orderbook.bids.parseBid(time).forEach[points.point(it)]
		orderbook.asks.parseAsk(time).forEach[points.point(it)]
		return points
	}

	def static parseBid(List<LimitOrder> bids, long time) {
		return bids.stream().sorted[a, b|b.limitPrice.compareTo(a.limitPrice)].collect().parse("bid", time)
	}

	def static parseAsk(List<LimitOrder> asks, long time) {
		return asks.stream().sorted[a, b|a.limitPrice.compareTo(b.limitPrice)].collect().parse("ask", time)
	}

	def static parse(List<LimitOrder> orders, String side, long time) {
		return orders.stream().limit(15).flatMap [
			Stream.of(
				Point.measurement("gdax").time(time, TimeUnit.MILLISECONDS).tag("index", orders.indexOf(it) + "").tag("side", side).addField("value", limitPrice.doubleValue()).addField("amount", tradableAmount.doubleValue()).build()
			)
		].collect()
	}

	def static <T> List<T> collect(Stream<T> stream) {
		return stream.collect(Collectors.toList())
	}

}
