package com.sirolf2009.yggdrasil.freyr;

import com.beust.jcommander.JCommander;
import com.sirolf2009.yggdrasil.freyr.Arguments;
import java.time.Duration;
import java.util.Comparator;
import java.util.List;
import java.util.concurrent.TimeUnit;
import java.util.function.Consumer;
import java.util.function.Function;
import java.util.stream.Collectors;
import java.util.stream.Stream;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.Extension;
import org.influxdb.InfluxDB;
import org.influxdb.InfluxDBFactory;
import org.influxdb.dto.BatchPoints;
import org.influxdb.dto.Point;
import org.knowm.xchange.Exchange;
import org.knowm.xchange.ExchangeFactory;
import org.knowm.xchange.currency.CurrencyPair;
import org.knowm.xchange.dto.marketdata.OrderBook;
import org.knowm.xchange.dto.trade.LimitOrder;
import org.knowm.xchange.gdax.GDAXExchange;

@SuppressWarnings("all")
public class Freyr {
  private final static Logger log = LogManager.getLogger();
  
  public static void main(final String[] args) {
    @Extension
    final Arguments arguments = new Arguments();
    JCommander.newBuilder().addObject(arguments).build().parse(args);
    Freyr.log.info(("Starting with arguments: " + arguments));
    final Exchange exchange = ExchangeFactory.INSTANCE.createExchange(GDAXExchange.class.getCanonicalName());
    String _influxHost = arguments.getInfluxHost();
    String _plus = ("http://" + _influxHost);
    String _plus_1 = (_plus + ":");
    int _influxPort = arguments.getInfluxPort();
    String _plus_2 = (_plus_1 + Integer.valueOf(_influxPort));
    final InfluxDB influx = InfluxDBFactory.connect(_plus_2);
    influx.createDatabase(arguments.getDatabase());
    while (true) {
      try {
        final OrderBook orderbook = exchange.getMarketDataService().getOrderBook(CurrencyPair.BTC_EUR);
        influx.write(Freyr.parseOrderbook(orderbook, arguments.getDatabase()));
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
  
  public static BatchPoints parseOrderbook(final OrderBook orderbook, final String database) {
    final long time = System.currentTimeMillis();
    final BatchPoints points = BatchPoints.database(database).consistency(InfluxDB.ConsistencyLevel.ALL).build();
    final Consumer<Point> _function = (Point it) -> {
      points.point(it);
    };
    Freyr.parseBid(orderbook.getBids(), time).forEach(_function);
    final Consumer<Point> _function_1 = (Point it) -> {
      points.point(it);
    };
    Freyr.parseAsk(orderbook.getAsks(), time).forEach(_function_1);
    return points;
  }
  
  public static List<Point> parseBid(final List<LimitOrder> bids, final long time) {
    final Comparator<LimitOrder> _function = (LimitOrder a, LimitOrder b) -> {
      return b.getLimitPrice().compareTo(a.getLimitPrice());
    };
    return Freyr.parse(Freyr.<LimitOrder>collect(bids.stream().sorted(_function)), "bid", time);
  }
  
  public static List<Point> parseAsk(final List<LimitOrder> asks, final long time) {
    final Comparator<LimitOrder> _function = (LimitOrder a, LimitOrder b) -> {
      return a.getLimitPrice().compareTo(b.getLimitPrice());
    };
    return Freyr.parse(Freyr.<LimitOrder>collect(asks.stream().sorted(_function)), "ask", time);
  }
  
  public static List<Point> parse(final List<LimitOrder> orders, final String side, final long time) {
    final Function<LimitOrder, Stream<Point>> _function = (LimitOrder it) -> {
      Point.Builder _time = Point.measurement("gdax").time(time, TimeUnit.MILLISECONDS);
      int _indexOf = orders.indexOf(it);
      String _plus = (Integer.valueOf(_indexOf) + "");
      return Stream.<Point>of(
        _time.tag("index", _plus).tag("side", side).addField("value", it.getLimitPrice().doubleValue()).addField("amount", it.getTradableAmount().doubleValue()).build());
    };
    return Freyr.<Point>collect(orders.stream().limit(15).<Point>flatMap(_function));
  }
  
  public static <T extends Object> List<T> collect(final Stream<T> stream) {
    return stream.collect(Collectors.<T>toList());
  }
}
