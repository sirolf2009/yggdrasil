package com.sirolf2009.yggdrasil.vor.data;

import com.sirolf2009.yggdrasil.vor.data.OrderPoint;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.function.BinaryOperator;
import java.util.function.Function;
import java.util.function.Predicate;
import java.util.stream.Collectors;
import java.util.stream.Stream;
import org.apache.commons.lang3.time.DateUtils;
import org.apache.commons.math3.stat.descriptive.DescriptiveStatistics;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.datavec.api.writable.DoubleWritable;
import org.datavec.api.writable.Writable;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.ExclusiveRange;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.Functions.Function2;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.ListExtensions;
import org.eclipse.xtext.xbase.lib.Pair;
import org.influxdb.dto.QueryResult;
import org.nd4j.linalg.api.ndarray.INDArray;

@SuppressWarnings("all")
public class Converters {
  private final static List<String> bidAskOrder = Collections.<String>unmodifiableList(CollectionLiterals.<String>newArrayList("bid", "ask"));
  
  public static Function<QueryResult, List<OrderPoint>> parseOrderbook = ((Function<QueryResult, List<OrderPoint>>) (QueryResult it) -> {
    List<OrderPoint> _xblockexpression = null;
    {
      final Logger log = LogManager.getLogger();
      log.info("Parsing the order book");
      final Function<QueryResult.Result, Stream<OrderPoint>> _function = (QueryResult.Result it_1) -> {
        final Function<QueryResult.Series, Stream<OrderPoint>> _function_1 = (QueryResult.Series it_2) -> {
          Stream<OrderPoint> _xblockexpression_1 = null;
          {
            final List<List<Object>> values = it_2.getValues();
            final List<String> columns = it_2.getColumns();
            final int index = Integer.parseInt(it_2.getTags().get("index"));
            final String side = it_2.getTags().get("side");
            int _size = values.size();
            final Function1<Integer, OrderPoint> _function_2 = (Integer it_3) -> {
              try {
                final Date time = DateUtils.parseDate(values.get((it_3).intValue()).get(columns.indexOf("time")).toString(), new String[] { "yyyy-MM-dd\'T\'HH:mm:ss.SSSX", "yyyy-MM-dd\'T\'HH:mm:ss.SSSZ", "yyyy-MM-dd\'T\'HH:mm:ss.SSX", "yyyy-MM-dd\'T\'HH:mm:ss.SX", "yyyy-MM-dd\'T\'HH:mm:ssX" });
                Object _get = values.get((it_3).intValue()).get(columns.indexOf("value"));
                final Double value = ((Double) _get);
                Object _get_1 = values.get((it_3).intValue()).get(columns.indexOf("amount"));
                final Double amount = ((Double) _get_1);
                return new OrderPoint(time, side, index, (value).doubleValue(), (amount).doubleValue());
              } catch (final Throwable _t) {
                if (_t instanceof Exception) {
                  final Exception e = (Exception)_t;
                  log.error(("Failed to parse " + it_3), e);
                  return null;
                } else {
                  throw Exceptions.sneakyThrow(_t);
                }
              }
            };
            final Function1<OrderPoint, Boolean> _function_3 = (OrderPoint it_3) -> {
              return Boolean.valueOf((it_3 != null));
            };
            _xblockexpression_1 = IterableExtensions.<OrderPoint>toList(IterableExtensions.<OrderPoint>filter(IterableExtensions.<Integer, OrderPoint>map(new ExclusiveRange(0, _size, true), _function_2), _function_3)).stream();
          }
          return _xblockexpression_1;
        };
        return it_1.getSeries().parallelStream().<OrderPoint>flatMap(_function_1);
      };
      _xblockexpression = Converters.<OrderPoint>collect(it.getResults().parallelStream().<OrderPoint>flatMap(_function));
    }
    return _xblockexpression;
  });
  
  public static Function<List<OrderPoint>, List<OrderPoint>> normalize = ((Function<List<OrderPoint>, List<OrderPoint>>) (List<OrderPoint> it) -> {
    List<OrderPoint> _xblockexpression = null;
    {
      final Logger log = LogManager.getLogger();
      log.info("Normalizing");
      final double maxBid = it.get(0).getValue();
      final double minAsk = it.get(30).getValue();
      final double halfPrice = (minAsk - maxBid);
      final Function<OrderPoint, Double> _function = (OrderPoint it_1) -> {
        return Double.valueOf(it_1.getAmount());
      };
      final List<Double> amounts = Converters.<Double>collect(it.parallelStream().<Double>map(_function));
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
      _xblockexpression = Converters.<OrderPoint>collect(it.parallelStream().<OrderPoint>map(_function_1));
    }
    return _xblockexpression;
  });
  
  public static Function<List<OrderPoint>, List<String>> convertToCSV = ((Function<List<OrderPoint>, List<String>>) (List<OrderPoint> it) -> {
    List<String> _xblockexpression = null;
    {
      final Logger log = LogManager.getLogger();
      log.info("Converting to csv");
      final Function<OrderPoint, Date> _function = (OrderPoint it_1) -> {
        return it_1.getTimestamp();
      };
      final Predicate<Map.Entry<Date, List<OrderPoint>>> _function_1 = (Map.Entry<Date, List<OrderPoint>> it_1) -> {
        int _size = it_1.getValue().size();
        return (_size == 30);
      };
      final Function<Map.Entry<Date, List<OrderPoint>>, Pair<Date, String>> _function_2 = (Map.Entry<Date, List<OrderPoint>> it_1) -> {
        Date _key = it_1.getKey();
        final Function<OrderPoint, String> _function_3 = (OrderPoint it_2) -> {
          return it_2.getSide();
        };
        final Function<Map.Entry<String, List<OrderPoint>>, Pair<String, String>> _function_4 = (Map.Entry<String, List<OrderPoint>> it_2) -> {
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
          final Function<Map.Entry<Integer, OrderPoint>, String> _function_8 = (Map.Entry<Integer, OrderPoint> it_3) -> {
            double _value = it_3.getValue().getValue();
            String _plus = (Double.valueOf(_value) + ",");
            double _amount = it_3.getValue().getAmount();
            return (_plus + Double.valueOf(_amount));
          };
          final BinaryOperator<String> _function_9 = (String a, String b) -> {
            return ((a + ",") + b);
          };
          String _get = it_2.getValue().stream().collect(Collectors.<OrderPoint, Integer, OrderPoint>toMap(_function_5, _function_6)).entrySet().stream().sorted(_function_7).<String>map(_function_8).reduce(_function_9).get();
          return Pair.<String, String>of(_key_1, _get);
        };
        final Comparator<Pair<String, String>> _function_5 = (Pair<String, String> a, Pair<String, String> b) -> {
          return Integer.valueOf(Converters.bidAskOrder.indexOf(a.getKey())).compareTo(Integer.valueOf(Converters.bidAskOrder.indexOf(b)));
        };
        final Function<Pair<String, String>, String> _function_6 = (Pair<String, String> it_2) -> {
          return it_2.getValue();
        };
        final BinaryOperator<String> _function_7 = (String a, String b) -> {
          return ((a + ",") + b);
        };
        String _get = it_1.getValue().stream().collect(Collectors.<OrderPoint, String>groupingBy(_function_3)).entrySet().stream().<Pair<String, String>>map(_function_4).sorted(_function_5).<String>map(_function_6).reduce(_function_7).get();
        return Pair.<Date, String>of(_key, _get);
      };
      final Comparator<Pair<Date, String>> _function_3 = (Pair<Date, String> a, Pair<Date, String> b) -> {
        return a.getKey().compareTo(b.getKey());
      };
      final Function<Pair<Date, String>, String> _function_4 = (Pair<Date, String> it_1) -> {
        return it_1.getValue();
      };
      _xblockexpression = Converters.<String>collect(it.stream().collect(Collectors.<OrderPoint, Date>groupingBy(_function)).entrySet().parallelStream().filter(_function_1).<Pair<Date, String>>map(_function_2).sorted(_function_3).<String>map(_function_4));
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
          List<Double> _collect = Converters.<Double>collect(it_2.getValue().stream().collect(Collectors.<OrderPoint, Integer, OrderPoint>toMap(_function_5, _function_6)).entrySet().stream().sorted(_function_7).<Double>flatMap(_function_8));
          return Pair.<String, List<Double>>of(_key_1, _collect);
        };
        final Comparator<Pair<String, List<Double>>> _function_5 = (Pair<String, List<Double>> a, Pair<String, List<Double>> b) -> {
          return Integer.valueOf(Converters.bidAskOrder.indexOf(a.getKey())).compareTo(Integer.valueOf(Converters.bidAskOrder.indexOf(b)));
        };
        final Function<Pair<String, List<Double>>, Stream<Double>> _function_6 = (Pair<String, List<Double>> it_2) -> {
          return it_2.getValue().stream();
        };
        List<Double> _collect = Converters.<Double>collect(it_1.getValue().stream().collect(Collectors.<OrderPoint, String>groupingBy(_function_3)).entrySet().stream().<Pair<String, List<Double>>>map(_function_4).sorted(_function_5).<Double>flatMap(_function_6));
        return Pair.<Date, List<Double>>of(_key, _collect);
      };
      final Comparator<Pair<Date, List<Double>>> _function_3 = (Pair<Date, List<Double>> a, Pair<Date, List<Double>> b) -> {
        return a.getKey().compareTo(b.getKey());
      };
      final Function<Pair<Date, List<Double>>, List<Double>> _function_4 = (Pair<Date, List<Double>> it_1) -> {
        return it_1.getValue();
      };
      _xblockexpression = Converters.<List<Double>>collect(it.stream().collect(Collectors.<OrderPoint, Date>groupingBy(_function)).entrySet().parallelStream().filter(_function_1).<Pair<Date, List<Double>>>map(_function_2).sorted(_function_3).<List<Double>>map(_function_4));
    }
    return _xblockexpression;
  });
  
  public static Function<List<INDArray>, List<List<Double>>> indArraysToMatrix = ((Function<List<INDArray>, List<List<Double>>>) (List<INDArray> it) -> {
    List<List<Double>> _xblockexpression = null;
    {
      final Logger log = LogManager.getLogger();
      log.info("Creating matrix from INDArray");
      final Function1<INDArray, List<Double>> _function = (INDArray it_1) -> {
        double[] _asDouble = it_1.data().asDouble();
        return ((List<Double>) Conversions.doWrapArray(_asDouble));
      };
      _xblockexpression = IterableExtensions.<List<Double>>toList(ListExtensions.<INDArray, List<Double>>map(it, _function));
    }
    return _xblockexpression;
  });
  
  public static Function<List<List<Double>>, List<List<Writable>>> matrixToWritables = ((Function<List<List<Double>>, List<List<Writable>>>) (List<List<Double>> it) -> {
    final Function1<List<Double>, List<Writable>> _function = (List<Double> it_1) -> {
      final Function1<Double, Writable> _function_1 = (Double it_2) -> {
        DoubleWritable _doubleWritable = new DoubleWritable((it_2).doubleValue());
        return ((Writable) _doubleWritable);
      };
      return ListExtensions.<Double, Writable>map(it_1, _function_1);
    };
    return ListExtensions.<List<Double>, List<Writable>>map(it, _function);
  });
  
  public static Function<List<List<Writable>>, List<String>> writablesToCSV = ((Function<List<List<Writable>>, List<String>>) (List<List<Writable>> it) -> {
    List<String> _xblockexpression = null;
    {
      final Logger log = LogManager.getLogger();
      log.info("Converting to csv");
      final Function1<List<Writable>, String> _function = (List<Writable> it_1) -> {
        final Function1<Writable, String> _function_1 = (Writable it_2) -> {
          return (it_2 + "");
        };
        final Function2<String, String, String> _function_2 = (String a, String b) -> {
          return ((a + ",") + b);
        };
        return IterableExtensions.<String>reduce(ListExtensions.<Writable, String>map(it_1, _function_1), _function_2);
      };
      _xblockexpression = ListExtensions.<List<Writable>, String>map(it, _function);
    }
    return _xblockexpression;
  });
  
  public static Function<List<String>, String> joinAsLines = ((Function<List<String>, String>) (List<String> it) -> {
    String _xblockexpression = null;
    {
      final Logger log = LogManager.getLogger();
      log.info("Joining lines");
      final BinaryOperator<String> _function = (String a, String b) -> {
        return ((a + "\n") + b);
      };
      _xblockexpression = it.stream().reduce(_function).get();
    }
    return _xblockexpression;
  });
  
  private static <T extends Object> List<T> collect(final Stream<T> stream) {
    return stream.collect(Collectors.<T>toList());
  }
}
