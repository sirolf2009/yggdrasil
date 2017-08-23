package com.sirolf2009.yggdrasil.freyr;

import com.beust.jcommander.JCommander;
import com.sirolf2009.yggdrasil.freyr.Arguments;
import java.math.BigDecimal;
import java.time.Duration;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.TimeUnit;
import java.util.function.BinaryOperator;
import java.util.function.Consumer;
import java.util.function.Function;
import java.util.function.Predicate;
import java.util.stream.Collectors;
import java.util.stream.Stream;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.influxdb.InfluxDB;
import org.influxdb.InfluxDBFactory;
import org.influxdb.dto.BatchPoints;
import org.influxdb.dto.Point;
import org.knowm.xchange.Exchange;
import org.knowm.xchange.ExchangeFactory;
import org.knowm.xchange.currency.CurrencyPair;
import org.knowm.xchange.dto.Order;
import org.knowm.xchange.dto.marketdata.OrderBook;
import org.knowm.xchange.dto.marketdata.Trade;
import org.knowm.xchange.dto.marketdata.Trades;
import org.knowm.xchange.dto.trade.LimitOrder;
import org.knowm.xchange.gdax.GDAXExchange;
import org.knowm.xchange.service.marketdata.MarketDataService;

@SuppressWarnings("all")
public class Freyr {
  private final static Logger log = LogManager.getLogger();
  
  public static void main(final String[] args) {
    @Extension
    final Arguments arguments = new Arguments();
    JCommander.newBuilder().addObject(arguments).build().parse(args);
    Freyr.log.info(("Starting with arguments: " + arguments));
    final Exchange exchange = ExchangeFactory.INSTANCE.createExchange(GDAXExchange.class.getCanonicalName());
    final MarketDataService marketData = exchange.getMarketDataService();
    String _influxHost = arguments.getInfluxHost();
    String _plus = ("http://" + _influxHost);
    String _plus_1 = (_plus + ":");
    int _influxPort = arguments.getInfluxPort();
    String _plus_2 = (_plus_1 + Integer.valueOf(_influxPort));
    final InfluxDB influx = InfluxDBFactory.connect(_plus_2);
    influx.createDatabase(arguments.getDatabase());
    Optional<Long> lastID = Optional.<Long>empty();
    while (true) {
      try {
        final Trades trades = marketData.getTrades(CurrencyPair.BTC_EUR);
        final Consumer<Long> _function = new Consumer<Long>() {
          @Override
          public void accept(final Long it) {
            try {
              final OrderBook orderbook = marketData.getOrderBook(CurrencyPair.BTC_EUR);
              final long time = System.currentTimeMillis();
              final Function1<Trade, Boolean> _function = new Function1<Trade, Boolean>() {
                @Override
                public Boolean apply(final Trade trade) {
                  long _parseLong = Long.parseLong(trade.getId());
                  return Boolean.valueOf((_parseLong > (it).longValue()));
                }
              };
              final List<Trade> newTrades = IterableExtensions.<Trade>toList(IterableExtensions.<Trade>filter(trades.getTrades(), _function));
              final Predicate<Trade> _function_1 = new Predicate<Trade>() {
                @Override
                public boolean test(final Trade it) {
                  return it.getType().equals(Order.OrderType.BID);
                }
              };
              final Function<Trade, BigDecimal> _function_2 = new Function<Trade, BigDecimal>() {
                @Override
                public BigDecimal apply(final Trade it) {
                  return it.getTradableAmount();
                }
              };
              final BinaryOperator<BigDecimal> _function_3 = new BinaryOperator<BigDecimal>() {
                @Override
                public BigDecimal apply(final BigDecimal a, final BigDecimal b) {
                  return a.add(b);
                }
              };
              final Function<BigDecimal, Double> _function_4 = new Function<BigDecimal, Double>() {
                @Override
                public Double apply(final BigDecimal it) {
                  return Double.valueOf(it.doubleValue());
                }
              };
              final Double bought = newTrades.stream().filter(_function_1).<BigDecimal>map(_function_2).reduce(_function_3).<Double>map(_function_4).orElse(Double.valueOf(0d));
              final Predicate<Trade> _function_5 = new Predicate<Trade>() {
                @Override
                public boolean test(final Trade it) {
                  return it.getType().equals(Order.OrderType.ASK);
                }
              };
              final Function<Trade, BigDecimal> _function_6 = new Function<Trade, BigDecimal>() {
                @Override
                public BigDecimal apply(final Trade it) {
                  return it.getTradableAmount();
                }
              };
              final BinaryOperator<BigDecimal> _function_7 = new BinaryOperator<BigDecimal>() {
                @Override
                public BigDecimal apply(final BigDecimal a, final BigDecimal b) {
                  return a.add(b);
                }
              };
              final Function<BigDecimal, Double> _function_8 = new Function<BigDecimal, Double>() {
                @Override
                public Double apply(final BigDecimal it) {
                  return Double.valueOf(it.doubleValue());
                }
              };
              final Double sold = newTrades.stream().filter(_function_5).<BigDecimal>map(_function_6).reduce(_function_7).<Double>map(_function_8).orElse(Double.valueOf(0d));
              final BatchPoints batch = Freyr.parseOrderbook(orderbook, time, arguments.getDatabase());
              batch.point(Point.measurement("gdax").time(time, TimeUnit.MILLISECONDS).addField("bought", bought).addField("sold", sold).build());
              influx.write(batch);
            } catch (Throwable _e) {
              throw Exceptions.sneakyThrow(_e);
            }
          }
        };
        lastID.ifPresent(_function);
        lastID = Optional.<Long>of(Long.valueOf(trades.getlastID()));
        Thread.sleep(Duration.ofSeconds(1).toMillis());
      } catch (final Throwable _t) {
        if (_t instanceof Exception) {
          final Exception e = (Exception)_t;
          Freyr.log.error(("Failed to retrieve orderbook from " + exchange), e);
        } else {
          throw Exceptions.sneakyThrow(_t);
        }
      }
    }
  }
  
  public static BatchPoints parseOrderbook(final OrderBook orderbook, final long time, final String database) {
    final BatchPoints points = BatchPoints.database(database).consistency(InfluxDB.ConsistencyLevel.ALL).build();
    final Consumer<Point> _function = new Consumer<Point>() {
      @Override
      public void accept(final Point it) {
        points.point(it);
      }
    };
    Freyr.parseBid(orderbook.getBids(), time).forEach(_function);
    final Consumer<Point> _function_1 = new Consumer<Point>() {
      @Override
      public void accept(final Point it) {
        points.point(it);
      }
    };
    Freyr.parseAsk(orderbook.getAsks(), time).forEach(_function_1);
    return points;
  }
  
  public static List<Point> parseBid(final List<LimitOrder> bids, final long time) {
    final Comparator<LimitOrder> _function = new Comparator<LimitOrder>() {
      @Override
      public int compare(final LimitOrder a, final LimitOrder b) {
        return b.getLimitPrice().compareTo(a.getLimitPrice());
      }
    };
    return Freyr.parse(Freyr.<LimitOrder>collect(bids.stream().sorted(_function)), "bid", time);
  }
  
  public static List<Point> parseAsk(final List<LimitOrder> asks, final long time) {
    final Comparator<LimitOrder> _function = new Comparator<LimitOrder>() {
      @Override
      public int compare(final LimitOrder a, final LimitOrder b) {
        return a.getLimitPrice().compareTo(b.getLimitPrice());
      }
    };
    return Freyr.parse(Freyr.<LimitOrder>collect(asks.stream().sorted(_function)), "ask", time);
  }
  
  public static List<Point> parse(final List<LimitOrder> orders, final String side, final long time) {
    final Function<LimitOrder, Stream<Point>> _function = new Function<LimitOrder, Stream<Point>>() {
      @Override
      public Stream<Point> apply(final LimitOrder it) {
        Point.Builder _time = Point.measurement("gdax").time(time, TimeUnit.MILLISECONDS);
        int _indexOf = orders.indexOf(it);
        String _plus = (Integer.valueOf(_indexOf) + "");
        return Stream.<Point>of(
          _time.tag("index", _plus).tag("side", side).addField("value", it.getLimitPrice().doubleValue()).addField("amount", it.getTradableAmount().doubleValue()).build());
      }
    };
    return Freyr.<Point>collect(orders.stream().limit(15).<Point>flatMap(_function));
  }
  
  public static <T extends Object> List<T> collect(final Stream<T> stream) {
    return stream.collect(Collectors.<T>toList());
  }
}
