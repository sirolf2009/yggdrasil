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
  
  public static Function<List<OrderPoint>, List<OrderPoint>> normalize = ((Function<List<OrderPoint>, List<OrderPoint>>) (List<OrderPoint> it) -> {
    List<OrderPoint> _xblockexpression = null;
    {
      OrderPoints.log.info("Normalizing");
      final double maxBid = it.get(0).getValue();
      final double minAsk = it.get(30).getValue();
      final double halfPrice = (minAsk - maxBid);
      final Function<OrderPoint, Double> _function = (OrderPoint it_1) -> {
        return Double.valueOf(it_1.getAmount());
      };
      final List<Double> amounts = StreamExtensions.<Double>collect(it.parallelStream().<Double>map(_function));
      final DescriptiveStatistics amountStats = new DescriptiveStatistics(((double[])Conversions.unwrapArray(amounts, double.class)));
      final double amountMean = amountStats.getMean();
      final double amountStdDev = amountStats.getStandardDeviation();
      final Function<OrderPoint, OrderPoint> _function_1 = (OrderPoint it_1) -> {
        Date _timestamp = it_1.getTimestamp();
        String _side = it_1.getSide();
        int _index = it_1.getIndex();
        double _value = it_1.getValue();
        double _minus = (_value - halfPrice);
        double _value_1 = it_1.getValue();
        double _plus = (_value_1 + halfPrice);
        double _divide = (_plus / 2);
        double _divide_1 = (_minus / _divide);
        double _amount = it_1.getAmount();
        double _minus_1 = (_amount - amountMean);
        double _multiply = (_minus_1 * amountStdDev);
        return new OrderPoint(_timestamp, _side, _index, _divide_1, _multiply);
      };
      _xblockexpression = StreamExtensions.<OrderPoint>collect(it.parallelStream().<OrderPoint>map(_function_1));
    }
    return _xblockexpression;
  });
  
  public static Function<List<OrderPoint>, List<List<Double>>> ordersToMatrix = ((Function<List<OrderPoint>, List<List<Double>>>) (List<OrderPoint> it) -> {
    List<List<Double>> _xblockexpression = null;
    {
      final Logger log = LogManager.getLogger();
      log.info("Creating matrix from orders");
      final Function<OrderPoint, Date> _function = (OrderPoint it_1) -> {
        return it_1.getTimestamp();
      };
      final Predicate<Map.Entry<Date, List<OrderPoint>>> _function_1 = (Map.Entry<Date, List<OrderPoint>> it_1) -> {
        int _size = it_1.getValue().size();
        return (_size == 30);
      };
      final Function<Map.Entry<Date, List<OrderPoint>>, Pair<Date, List<Double>>> _function_2 = (Map.Entry<Date, List<OrderPoint>> it_1) -> {
        Date _key = it_1.getKey();
        final Function<OrderPoint, String> _function_3 = (OrderPoint it_2) -> {
          return it_2.getSide();
        };
        final Function<Map.Entry<String, List<OrderPoint>>, Pair<String, List<Double>>> _function_4 = (Map.Entry<String, List<OrderPoint>> it_2) -> {
          String _key_1 = it_2.getKey();
          final Function<OrderPoint, Integer> _function_5 = (OrderPoint it_3) -> {
            return Integer.valueOf(it_3.getIndex());
          };
          final Function<OrderPoint, OrderPoint> _function_6 = (OrderPoint it_3) -> {
            return it_3;
          };
          final Comparator<Map.Entry<Integer, OrderPoint>> _function_7 = (Map.Entry<Integer, OrderPoint> a, Map.Entry<Integer, OrderPoint> b) -> {
            return a.getKey().compareTo(b.getKey());
          };
          final Function<Map.Entry<Integer, OrderPoint>, Stream<Double>> _function_8 = (Map.Entry<Integer, OrderPoint> it_3) -> {
            double _value = it_3.getValue().getValue();
            double _amount = it_3.getValue().getAmount();
            return Collections.<Double>unmodifiableList(CollectionLiterals.<Double>newArrayList(Double.valueOf(_value), Double.valueOf(_amount))).stream();
          };
          List<Double> _collect = StreamExtensions.<Double>collect(it_2.getValue().stream().collect(Collectors.<OrderPoint, Integer, OrderPoint>toMap(_function_5, _function_6)).entrySet().stream().sorted(_function_7).<Double>flatMap(_function_8));
          return Pair.<String, List<Double>>of(_key_1, _collect);
        };
        final Comparator<Pair<String, List<Double>>> _function_5 = (Pair<String, List<Double>> a, Pair<String, List<Double>> b) -> {
          return Integer.valueOf(OrderPoints.bidAskOrder.indexOf(a.getKey())).compareTo(Integer.valueOf(OrderPoints.bidAskOrder.indexOf(b)));
        };
        final Function<Pair<String, List<Double>>, Stream<Double>> _function_6 = (Pair<String, List<Double>> it_2) -> {
          return it_2.getValue().stream();
        };
        List<Double> _collect = StreamExtensions.<Double>collect(it_1.getValue().stream().collect(Collectors.<OrderPoint, String>groupingBy(_function_3)).entrySet().stream().<Pair<String, List<Double>>>map(_function_4).sorted(_function_5).<Double>flatMap(_function_6));
        return Pair.<Date, List<Double>>of(_key, _collect);
      };
      final Comparator<Pair<Date, List<Double>>> _function_3 = (Pair<Date, List<Double>> a, Pair<Date, List<Double>> b) -> {
        return a.getKey().compareTo(b.getKey());
      };
      final Function<Pair<Date, List<Double>>, List<Double>> _function_4 = (Pair<Date, List<Double>> it_1) -> {
        return it_1.getValue();
      };
      _xblockexpression = StreamExtensions.<List<Double>>collect(it.stream().collect(Collectors.<OrderPoint, Date>groupingBy(_function)).entrySet().parallelStream().filter(_function_1).<Pair<Date, List<Double>>>map(_function_2).sorted(_function_3).<List<Double>>map(_function_4));
    }
    return _xblockexpression;
  });
}
