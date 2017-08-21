package com.sirolf2009.yggdrasil.freyr

import java.time.Duration
import java.util.ArrayList
import java.util.List
import java.util.function.Supplier
import java.util.stream.Collectors
import java.util.stream.Stream
import org.knowm.xchange.Exchange
import org.knowm.xchange.ExchangeFactory
import org.knowm.xchange.currency.CurrencyPair
import org.knowm.xchange.dto.marketdata.OrderBook
import org.knowm.xchange.dto.trade.LimitOrder
import tech.tablesaw.api.DateTimeColumn
import tech.tablesaw.api.DoubleColumn
import tech.tablesaw.api.Table
import tech.tablesaw.columns.Column

class SupplierOrderbookLive implements Supplier<Table> {

	val Exchange exchange
	val CurrencyPair pair
	val Duration timeout
	val int take

	new(extension Arguments arguments, String exchangeName, CurrencyPair pair, Duration timeout, int take) {
		exchange = ExchangeFactory.INSTANCE.createExchange(exchangeName)
		this.pair = pair
		this.timeout = timeout
		this.take = take
	}

	override get() {
		Thread.sleep(timeout.toMillis())
		val orderbook = exchange.marketDataService.getOrderBook(pair)
		orderbook.parseOrderbook()
	}

	def parseOrderbook(OrderBook orderbook) {
		val datetimeColumn = new DateTimeColumn("datetime")
		datetimeColumn.append(System.currentTimeMillis())
		val bidColumns = (0 ..< take).toList().parallelStream().flatMap[Stream.of(new DoubleColumn("bid_price_" + it, 1), new DoubleColumn("bid_amount_" + it, 1))].collect()
		val askColumns = (0 ..< take).toList().parallelStream().flatMap[Stream.of(new DoubleColumn("ask_price_" + it, 1), new DoubleColumn("ask_amount_" + it, 1))].collect()
		val columns = new ArrayList<Column>()
		columns += datetimeColumn
		columns += bidColumns
		columns += askColumns
		val bids = orderbook.bids.parseBid()
		val asks = orderbook.asks.parseAsk()
		for (var i = 0; i < take; i++) {
			(bidColumns.get(i * 2) as DoubleColumn).append(bids.get(i).limitPrice.doubleValue())
			(bidColumns.get(i * 2 + 1) as DoubleColumn).append(bids.get(i).tradableAmount.doubleValue())
			(askColumns.get(i * 2) as DoubleColumn).append(asks.get(i).limitPrice.doubleValue())
			(askColumns.get(i * 2 + 1) as DoubleColumn).append(asks.get(i).tradableAmount.doubleValue())
		}
		return Table.create("Orderbook " + exchange, columns)
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
