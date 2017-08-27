package com.sirolf2009.yggdrasil.freyr

import com.google.common.util.concurrent.AtomicDouble
import com.sirolf2009.yggdrasil.freyr.model.OrderbookTick
import java.time.Duration
import java.util.Date
import java.util.List
import java.util.Optional
import java.util.concurrent.atomic.AtomicLong
import java.util.function.Supplier
import java.util.stream.Collectors
import java.util.stream.Stream
import org.knowm.xchange.Exchange
import org.knowm.xchange.ExchangeFactory
import org.knowm.xchange.currency.CurrencyPair
import org.knowm.xchange.dto.Order.OrderType
import org.knowm.xchange.dto.marketdata.OrderBook
import org.knowm.xchange.dto.trade.LimitOrder
import org.knowm.xchange.service.marketdata.MarketDataService

class SupplierOrderbookTick implements Supplier<Optional<OrderbookTick>> {

	val Exchange exchange
	val MarketDataService marketData
	val CurrencyPair pair
	val Duration timeout
	val int take
	val lastIDReference = new AtomicLong(-1)
	val lastPriceReference = new AtomicDouble(-1)

	new(String exchangeName, CurrencyPair pair, Duration timeout, int take) {
		exchange = ExchangeFactory.INSTANCE.createExchange(exchangeName)
		marketData = exchange.marketDataService
		this.pair = pair
		this.timeout = timeout
		this.take = take
	}

	override get() {
		Thread.sleep(timeout.toMillis())
		val trades = marketData.getTrades(pair)
		val lastID = lastIDReference.get()
		var result = Optional.empty()
		if(lastID != -1) {
			val orderbook = marketData.getOrderBook(pair)
			val newTrades = trades.trades.filter[trade|Long.parseLong(trade.id) > lastID].toList()
			val last = newTrades.stream().sorted[a, b|b.timestamp.compareTo(a.timestamp)].findFirst.map[price.doubleValue].orElse(lastPriceReference.get())
			val boughtAmount = newTrades.stream().filter[type.equals(OrderType.BID)].map[tradableAmount].count
			val boughtVolume = newTrades.stream().filter[type.equals(OrderType.BID)].map[tradableAmount].reduce[a, b|a.add(b)].map[doubleValue].orElse(0d)
			val soldAmount = newTrades.stream().filter[type.equals(OrderType.ASK)].map[tradableAmount].count
			val soldVolume = newTrades.stream().filter[type.equals(OrderType.ASK)].map[tradableAmount].reduce[a, b|a.add(b)].map[doubleValue].orElse(0d)
			if(last != -1) {
				result = Optional.of(orderbook.parseOrderbook(last, boughtAmount, boughtVolume, soldAmount, soldVolume))
				lastPriceReference.set(last)
			}
		}
		lastIDReference.set(trades.getlastID)
		return result
	}

	def parseOrderbook(OrderBook orderbook, double last, double boughtAmount, double boughtVolume, double soldAmount, double soldVolume) {
		val date = new Date()
		val bids = orderbook.bids.parseBid()
		val asks = orderbook.asks.parseAsk()
		new OrderbookTick() => [
			it.exchange = "GDAX"
			datetime = date
			lastPrice = last
			it.boughtAmount = boughtAmount
			it.boughtVolume = boughtVolume
			it.soldAmount = soldAmount
			it.soldVolume = soldVolume
			bidPrice0 = bids.get(0).limitPrice.doubleValue
			bidVolume0 = bids.get(0).tradableAmount.doubleValue
			bidPrice1 = bids.get(1).limitPrice.doubleValue     
			bidVolume1 = bids.get(1).tradableAmount.doubleValue
			bidPrice2  = bids.get(2).limitPrice.doubleValue     
			bidVolume2  = bids.get(2).tradableAmount.doubleValue
			bidPrice3 = bids.get(3).limitPrice.doubleValue     
			bidVolume3 = bids.get(3).tradableAmount.doubleValue
			bidPrice4 = bids.get(4).limitPrice.doubleValue     
			bidVolume4 = bids.get(4).tradableAmount.doubleValue
			bidPrice5 = bids.get(5).limitPrice.doubleValue     
			bidVolume5 = bids.get(5).tradableAmount.doubleValue
			bidPrice6 = bids.get(6).limitPrice.doubleValue     
			bidVolume6 = bids.get(6).tradableAmount.doubleValue
			bidPrice7 = bids.get(7).limitPrice.doubleValue     
			bidVolume7 = bids.get(7).tradableAmount.doubleValue
			bidPrice8 = bids.get(8).limitPrice.doubleValue     
			bidVolume8 = bids.get(8).tradableAmount.doubleValue
			bidPrice9 = bids.get(9).limitPrice.doubleValue     
			bidVolume9 = bids.get(9).tradableAmount.doubleValue
			bidPrice10 = bids.get(10).limitPrice.doubleValue     
			bidVolume10 = bids.get(10).tradableAmount.doubleValue
			bidPrice11 = bids.get(11).limitPrice.doubleValue     
			bidVolume11 = bids.get(11).tradableAmount.doubleValue
			bidPrice12 = bids.get(12).limitPrice.doubleValue     
			bidVolume12 = bids.get(12).tradableAmount.doubleValue
			bidPrice13 = bids.get(13).limitPrice.doubleValue     
			bidVolume13 = bids.get(13).tradableAmount.doubleValue
			bidPrice14 = bids.get(14).limitPrice.doubleValue     
			bidVolume14 = bids.get(14).tradableAmount.doubleValue
			askPrice0 = asks.get(0).limitPrice.doubleValue
			askVolume0 = asks.get(0).tradableAmount.doubleValue  
			askPrice1 = asks.get(1).limitPrice.doubleValue       
			askVolume1 = asks.get(1).tradableAmount.doubleValue  
			askPrice2  = asks.get(2).limitPrice.doubleValue      
			askVolume2  = asks.get(2).tradableAmount.doubleValue 
			askPrice3 = asks.get(3).limitPrice.doubleValue       
			askVolume3 = asks.get(3).tradableAmount.doubleValue  
			askPrice4 = asks.get(4).limitPrice.doubleValue       
			askVolume4 = asks.get(4).tradableAmount.doubleValue  
			askPrice5 = asks.get(5).limitPrice.doubleValue       
			askVolume5 = asks.get(5).tradableAmount.doubleValue  
			askPrice6 = asks.get(6).limitPrice.doubleValue       
			askVolume6 = asks.get(6).tradableAmount.doubleValue  
			askPrice7 = asks.get(7).limitPrice.doubleValue       
			askVolume7 = asks.get(7).tradableAmount.doubleValue  
			askPrice8 = asks.get(8).limitPrice.doubleValue       
			askVolume8 = asks.get(8).tradableAmount.doubleValue  
			askPrice9 = asks.get(9).limitPrice.doubleValue       
			askVolume9 = asks.get(9).tradableAmount.doubleValue  
			askPrice10 = asks.get(10).limitPrice.doubleValue     
			askVolume10 = asks.get(10).tradableAmount.doubleValue
			askPrice11 = asks.get(11).limitPrice.doubleValue     
			askVolume11 = asks.get(11).tradableAmount.doubleValue
			askPrice12 = asks.get(12).limitPrice.doubleValue     
			askVolume12 = asks.get(12).tradableAmount.doubleValue
			askPrice13 = asks.get(13).limitPrice.doubleValue     
			askVolume13 = asks.get(13).tradableAmount.doubleValue
			askPrice14 = asks.get(14).limitPrice.doubleValue     
			askVolume14 = asks.get(14).tradableAmount.doubleValue
		]
	}

	def parseBid(List<LimitOrder> bids) {
		return bids.stream().sorted[a, b|b.limitPrice.compareTo(a.limitPrice)].limit(take).collect()
	}

	def parseAsk(List<LimitOrder> asks) {
		return asks.stream().sorted[a, b|a.limitPrice.compareTo(b.limitPrice)].limit(take).collect()
	}

	def static <T> List<T> collect(Stream<T> stream) {
		return stream.collect(Collectors.toList())
	}

}
