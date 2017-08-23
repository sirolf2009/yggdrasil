package com.sirolf2009.yggdrasil.sif.transmutation;

import com.sirolf2009.yggdrasil.sif.StreamExtensions;
import com.sirolf2009.yggdrasil.sif.model.OrderPoint;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.function.Predicate;
import java.util.stream.Collectors;
import java.util.stream.Stream;
import org.apache.commons.math3.stat.descriptive.DescriptiveStatistics;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Pair;

@SuppressWarnings("all")
public class OrderPoints {
  private final static Logger log = LogManager.getLogger();
  
  private final static List<String> bidAskOrder = Collections.<String>unmodifiableList(CollectionLiterals.<String>newArrayList("bid", "ask"));
  
  public static Function<List<OrderPoint>, List<OrderPoint>> normalize = new Function<List<OrderPoint>, List<OrderPoint>>() {
    @Override
    public List<OrderPoint> apply(final List<OrderPoint> it) {
      List<OrderPoint> _xblockexpression = null;
      {
        OrderPoints.log.info("Normalizing");
        final double maxBid = it.get(0).getValue();
        final double minAsk = it.get(30).getValue();
        final double halfPrice = (minAsk - maxBid);
        final Function<OrderPoint, Double> _function = new Function<OrderPoint, Double>() {
          @Override
          public Double apply(final OrderPoint it) {
            return Double.valueOf(it.getAmount());
          }
        };
        final List<Double> amounts = StreamExtensions.<Double>collect(it.parallelStream().<Double>map(_function));
        final DescriptiveStatistics amountStats = new DescriptiveStatistics(((double[])Conversions.unwrapArray(amounts, double.class)));
        final double amountMean = amountStats.getMean();
        final double amountStdDev = amountStats.getStandardDeviation();
        final Function<OrderPoint, OrderPoint> _function_1 = new Function<OrderPoint, OrderPoint>() {
          @Override
          public OrderPoint apply(final OrderPoint it) {
            Date _timestamp = it.getTimestamp();
            String _side = it.getSide();
            int _index = it.getIndex();
            double _value = it.getValue();
            double _minus = (_value - halfPrice);
            double _value_1 = it.getValue();
            double _plus = (_value_1 + halfPrice);
            double _divide = (_plus / 2);
            double _divide_1 = (_minus / _divide);
            double _amount = it.getAmount();
            double _minus_1 = (_amount - amountMean);
            double _multiply = (_minus_1 * amountStdDev);
            return new OrderPoint(_timestamp, _side, _index, _divide_1, _multiply);
          }
        };
        _xblockexpression = StreamExtensions.<OrderPoint>collect(it.parallelStream().<OrderPoint>map(_function_1));
      }
      return _xblockexpression;
    }
  };
  
  public static Function<List<OrderPoint>, List<List<Double>>> ordersToMatrix = new Function<List<OrderPoint>, List<List<Double>>>() {
    @Override
    public List<List<Double>> apply(final List<OrderPoint> it) {
      List<List<Double>> _xblockexpression = null;
      {
        final Logger log = LogManager.getLogger();
        log.info("Creating matrix from orders");
        final Function<OrderPoint, Date> _function = new Function<OrderPoint, Date>() {
          @Override
          public Date apply(final OrderPoint it) {
            return it.getTimestamp();
          }
        };
        final Predicate<Map.Entry<Date, List<OrderPoint>>> _function_1 = new Predicate<Map.Entry<Date, List<OrderPoint>>>() {
          @Override
          public boolean test(final Map.Entry<Date, List<OrderPoint>> it) {
            int _size = it.getValue().size();
            return (_size == 30);
          }
        };
        final Function<Map.Entry<Date, List<OrderPoint>>, Pair<Date, List<Double>>> _function_2 = new Function<Map.Entry<Date, List<OrderPoint>>, Pair<Date, List<Double>>>() {
          @Override
          public Pair<Date, List<Double>> apply(final Map.Entry<Date, List<OrderPoint>> it) {
            Date _key = it.getKey();
            final Function<OrderPoint, String> _function = new Function<OrderPoint, String>() {
              @Override
              public String apply(final OrderPoint it) {
                return it.getSide();
              }
            };
            final Function<Map.Entry<String, List<OrderPoint>>, Pair<String, List<Double>>> _function_1 = new Function<Map.Entry<String, List<OrderPoint>>, Pair<String, List<Double>>>() {
              @Override
              public Pair<String, List<Double>> apply(final Map.Entry<String, List<OrderPoint>> it) {
                String _key = it.getKey();
                final Function<OrderPoint, Integer> _function = new Function<OrderPoint, Integer>() {
                  @Override
                  public Integer apply(final OrderPoint it) {
                    return Integer.valueOf(it.getIndex());
                  }
                };
                final Function<OrderPoint, OrderPoint> _function_1 = new Function<OrderPoint, OrderPoint>() {
                  @Override
                  public OrderPoint apply(final OrderPoint it) {
                    return it;
                  }
                };
                final Comparator<Map.Entry<Integer, OrderPoint>> _function_2 = new Comparator<Map.Entry<Integer, OrderPoint>>() {
                  @Override
                  public int compare(final Map.Entry<Integer, OrderPoint> a, final Map.Entry<Integer, OrderPoint> b) {
                    return a.getKey().compareTo(b.getKey());
                  }
                };
                final Function<Map.Entry<Integer, OrderPoint>, Stream<Double>> _function_3 = new Function<Map.Entry<Integer, OrderPoint>, Stream<Double>>() {
                  @Override
                  public Stream<Double> apply(final Map.Entry<Integer, OrderPoint> it) {
                    double _value = it.getValue().getValue();
                    double _amount = it.getValue().getAmount();
                    return Collections.<Double>unmodifiableList(CollectionLiterals.<Double>newArrayList(Double.valueOf(_value), Double.valueOf(_amount))).stream();
                  }
                };
                List<Double> _collect = StreamExtensions.<Double>collect(it.getValue().stream().collect(Collectors.<OrderPoint, Integer, OrderPoint>toMap(_function, _function_1)).entrySet().stream().sorted(_function_2).<Double>flatMap(_function_3));
                return Pair.<String, List<Double>>of(_key, _collect);
              }
            };
            final Comparator<Pair<String, List<Double>>> _function_2 = new Comparator<Pair<String, List<Double>>>() {
              @Override
              public int compare(final Pair<String, List<Double>> a, final Pair<String, List<Double>> b) {
                return Integer.valueOf(OrderPoints.bidAskOrder.indexOf(a.getKey())).compareTo(Integer.valueOf(OrderPoints.bidAskOrder.indexOf(b)));
              }
            };
            final Function<Pair<String, List<Double>>, Stream<Double>> _function_3 = new Function<Pair<String, List<Double>>, Stream<Double>>() {
              @Override
              public Stream<Double> apply(final Pair<String, List<Double>> it) {
                return it.getValue().stream();
              }
            };
            List<Double> _collect = StreamExtensions.<Double>collect(it.getValue().stream().collect(Collectors.<OrderPoint, String>groupingBy(_function)).entrySet().stream().<Pair<String, List<Double>>>map(_function_1).sorted(_function_2).<Double>flatMap(_function_3));
            return Pair.<Date, List<Double>>of(_key, _collect);
          }
        };
        final Comparator<Pair<Date, List<Double>>> _function_3 = new Comparator<Pair<Date, List<Double>>>() {
          @Override
          public int compare(final Pair<Date, List<Double>> a, final Pair<Date, List<Double>> b) {
            return a.getKey().compareTo(b.getKey());
          }
        };
        final Function<Pair<Date, List<Double>>, List<Double>> _function_4 = new Function<Pair<Date, List<Double>>, List<Double>>() {
          @Override
          public List<Double> apply(final Pair<Date, List<Double>> it) {
            return it.getValue();
          }
        };
        _xblockexpression = StreamExtensions.<List<Double>>collect(it.stream().collect(Collectors.<OrderPoint, Date>groupingBy(_function)).entrySet().parallelStream().filter(_function_1).<Pair<Date, List<Double>>>map(_function_2).sorted(_function_3).<List<Double>>map(_function_4));
      }
      return _xblockexpression;
    }
  };
}
