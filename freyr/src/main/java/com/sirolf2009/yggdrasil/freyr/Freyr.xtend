package com.sirolf2009.yggdrasil.freyr

import com.beust.jcommander.JCommander
import com.google.common.util.concurrent.AtomicDouble
import java.time.Duration
import java.util.List
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicLong
import java.util.stream.Collectors
import java.util.stream.Stream
import org.apache.logging.log4j.LogManager
import org.influxdb.InfluxDB.ConsistencyLevel
import org.influxdb.InfluxDBFactory
import org.influxdb.dto.BatchPoints
import org.influxdb.dto.Point
import org.knowm.xchange.ExchangeFactory
import org.knowm.xchange.currency.CurrencyPair
import org.knowm.xchange.dto.Order.OrderType
import org.knowm.xchange.dto.marketdata.OrderBook
import org.knowm.xchange.dto.trade.LimitOrder
import org.knowm.xchange.gdax.GDAXExchange

class Freyr {

	static val log = LogManager.logger
	static val executor = Executors.newFixedThreadPool(1)
	
	//FIXME I need to start using SupplierOrderbookLive

	def static void main(String[] args) {
		extension val arguments = new Arguments()
		JCommander.newBuilder().addObject(arguments).build().parse(args)
		log.info("Starting with arguments: " + arguments)

		val exchange = ExchangeFactory.INSTANCE.createExchange(GDAXExchange.getCanonicalName())
		val marketData = exchange.marketDataService
		val influx = InfluxDBFactory.connect("http://" + influxHost + ":" + influxPort)
		influx.createDatabase(database)
		val lastIDReference = new AtomicLong(-1)
		val lastPriceReference = new AtomicDouble(-1)
		while(true) {
			try {
				executor.submit [
					val trades = marketData.getTrades(CurrencyPair.BTC_EUR)
					val lastID = lastIDReference.get()
					if(lastID != -1) {
						val orderbook = marketData.getOrderBook(CurrencyPair.BTC_EUR)
						val time = System.currentTimeMillis()
						val newTrades = trades.trades.filter[trade|Long.parseLong(trade.id) > lastID].toList()
						val boughtAmount = newTrades.stream().filter[type.equals(OrderType.BID)].count()
						val soldAmount = newTrades.stream().filter[type.equals(OrderType.ASK)].count()
						val boughtVolume = newTrades.stream().filter[type.equals(OrderType.BID)].map[tradableAmount].reduce[a, b|a.add(b)].map[doubleValue].orElse(0d)
						val soldVolume = newTrades.stream().filter[type.equals(OrderType.ASK)].map[tradableAmount].reduce[a, b|a.add(b)].map[doubleValue].orElse(0d)
						val last = newTrades.stream().sorted[a, b|b.timestamp.compareTo(a.timestamp)].findFirst.map[price.doubleValue].orElse(lastPriceReference.get())
						lastPriceReference.set(last)
						val batch = orderbook.parseOrderbook(time, database)
						batch.point(Point.measurement("trades").addField("boughAmount", boughtAmount).addField("soldAmount", soldAmount).addField("boughtVolume", boughtVolume).addField("soldVolume", soldVolume).addField("previous", last).build())
						influx.write(batch)
						log.info(batch)
					}
					lastIDReference.set(trades.getlastID)
				]
				Thread.sleep(Duration.ofSeconds(1).toMillis())
			} catch(Exception e) {
				log.error("Failed to retrieve orderbook from " + exchange, e)
			}
		}
	}
	
	def static parseOrderbook(OrderBook orderbook, long time, String database) {
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
				Point.measurement("limitorder").time(time, TimeUnit.MILLISECONDS).tag("index", orders.indexOf(it) + "").tag("side", side).addField("value", limitPrice.doubleValue()).addField("amount", tradableAmount.doubleValue()).build()
			)
		].collect()
	}

	def static <T> List<T> collect(Stream<T> stream) {
		return stream.collect(Collectors.toList())
	}

}
