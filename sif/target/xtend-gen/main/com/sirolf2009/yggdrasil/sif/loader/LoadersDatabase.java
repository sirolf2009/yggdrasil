package com.sirolf2009.yggdrasil.sif.loader;

import com.google.gson.Gson;
import com.sirolf2009.yggdrasil.sif.StreamExtensions;
import com.sirolf2009.yggdrasil.sif.model.OrderPoint;
import java.io.File;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Date;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.TimeUnit;
import java.util.function.BinaryOperator;
import java.util.function.Consumer;
import java.util.function.Function;
import java.util.function.Predicate;
import java.util.stream.Stream;
import net.jodah.failsafe.ExecutionContext;
import net.jodah.failsafe.Failsafe;
import net.jodah.failsafe.RetryPolicy;
import net.jodah.failsafe.function.ContextualCallable;
import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.time.DateUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.ExclusiveRange;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.Functions.Function2;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.ListExtensions;
import org.influxdb.InfluxDB;
import org.influxdb.InfluxDBFactory;
import org.influxdb.InfluxDBIOException;
import org.influxdb.dto.Query;
import org.influxdb.dto.QueryResult;

@SuppressWarnings("all")
public class LoadersDatabase {
  private final static Logger log = LogManager.getLogger();
  
  private final static int batch = 1000;
  
  public static Optional<List<OrderPoint>> getDatapoints(final String influx, final int orderPoints) {
    Optional<List<OrderPoint>> _xblockexpression = null;
    {
      final InfluxDB database = InfluxDBFactory.connect(influx);
      double _ceil = Math.ceil((orderPoints / LoadersDatabase.batch));
      final int batchesToDownload = ((int) _ceil);
      final Function<Integer, QueryResult> _function = (Integer it) -> {
        QueryResult _xblockexpression_1 = null;
        {
          StringConcatenation _builder = new StringConcatenation();
          _builder.append("(");
          _builder.append(it);
          _builder.append("/");
          _builder.append(batchesToDownload);
          _builder.append(") SELECT \"value\", \"amount\" FROM \"orderbook\".\"autogen\".\"gdax\" GROUP BY \"side\", \"index\" LIMIT ");
          _builder.append(LoadersDatabase.batch);
          _builder.append(" OFFSET ");
          _builder.append(((it).intValue() * LoadersDatabase.batch));
          LoadersDatabase.log.info(_builder);
          StringConcatenation _builder_1 = new StringConcatenation();
          _builder_1.append("SELECT \"value\", \"amount\" FROM \"orderbook\".\"autogen\".\"gdax\" GROUP BY \"side\", \"index\" LIMIT ");
          _builder_1.append(LoadersDatabase.batch);
          _builder_1.append(" OFFSET ");
          _builder_1.append(((it).intValue() * LoadersDatabase.batch));
          Query _query = new Query(_builder_1.toString(), "orderbook");
          _xblockexpression_1 = database.query(_query);
        }
        return _xblockexpression_1;
      };
      _xblockexpression = IterableExtensions.<Integer>toList(new ExclusiveRange(0, batchesToDownload, true)).stream().<QueryResult>map(_function).filter(LoadersDatabase.hasData).reduce(LoadersDatabase.combine).<List<OrderPoint>>map(LoadersDatabase.parseOrderbook);
    }
    return _xblockexpression;
  }
  
  public static List<OrderPoint> getDatapointsLarge(final String influx, final int orderPoints, final File dataFolder) {
    final Consumer<File> _function = (File it) -> {
      it.delete();
    };
    ((List<File>)Conversions.doWrapArray(dataFolder.listFiles())).forEach(_function);
    final InfluxDB database = InfluxDBFactory.connect(influx);
    double _ceil = Math.ceil((orderPoints / LoadersDatabase.batch));
    final int batchesToDownload = ((int) _ceil);
    final RetryPolicy policy = new RetryPolicy().retryOn(InfluxDBIOException.class).withBackoff(1, 10, TimeUnit.MINUTES).withMaxRetries(10);
    final Function<Integer, QueryResult> _function_1 = (Integer it) -> {
      QueryResult _xblockexpression = null;
      {
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("SELECT \"value\", \"amount\" FROM \"orderbook\".\"autogen\".\"gdax\" GROUP BY \"side\", \"index\" LIMIT ");
        _builder.append(LoadersDatabase.batch);
        _builder.append(" OFFSET ");
        _builder.append(((it).intValue() * LoadersDatabase.batch));
        final String query = _builder.toString();
        LoadersDatabase.log.info(query);
        final ContextualCallable<QueryResult> _function_2 = (ExecutionContext it_1) -> {
          Query _query = new Query(query, "orderbook");
          return database.query(_query);
        };
        _xblockexpression = Failsafe.<Object>with(policy).<QueryResult>get(_function_2);
      }
      return _xblockexpression;
    };
    final Consumer<QueryResult> _function_2 = (QueryResult it) -> {
      try {
        Files.write(Paths.get(dataFolder.getAbsolutePath(), UUID.randomUUID().toString()), new Gson().toJson(it).getBytes());
      } catch (Throwable _e) {
        throw Exceptions.sneakyThrow(_e);
      }
    };
    IterableExtensions.<Integer>toList(new ExclusiveRange(0, batchesToDownload, true)).stream().<QueryResult>map(_function_1).filter(LoadersDatabase.hasData).forEach(_function_2);
    return LoadersDatabase.parseDatapoints(dataFolder);
  }
  
  public static List<OrderPoint> parseDatapoints(final File folder) {
    final Function1<File, QueryResult> _function = (File it) -> {
      try {
        QueryResult _xblockexpression = null;
        {
          LoadersDatabase.log.info(("Parsing " + it));
          _xblockexpression = new Gson().<QueryResult>fromJson(FileUtils.readFileToString(it), QueryResult.class);
        }
        return _xblockexpression;
      } catch (Throwable _e) {
        throw Exceptions.sneakyThrow(_e);
      }
    };
    final Function2<QueryResult, QueryResult, QueryResult> _function_1 = (QueryResult a, QueryResult b) -> {
      return LoadersDatabase.combine.apply(a, b);
    };
    final QueryResult result = IterableExtensions.<QueryResult>reduce(ListExtensions.<File, QueryResult>map(((List<File>)Conversions.doWrapArray(folder.listFiles())), _function), _function_1);
    return LoadersDatabase.parseOrderbook.apply(result);
  }
  
  public static Function<QueryResult, List<OrderPoint>> parseOrderbook = ((Function<QueryResult, List<OrderPoint>>) (QueryResult it) -> {
    List<OrderPoint> _xblockexpression = null;
    {
      LoadersDatabase.log.info("Parsing the order book");
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
                  LoadersDatabase.log.error(("Failed to parse " + it_3), e);
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
      _xblockexpression = StreamExtensions.<OrderPoint>collect(it.getResults().parallelStream().<OrderPoint>flatMap(_function));
    }
    return _xblockexpression;
  });
  
  public static Predicate<QueryResult> hasData = ((Predicate<QueryResult>) (QueryResult it) -> {
    if (((it != null) && (it.getError() != null))) {
      LoadersDatabase.log.error(it.getError());
    }
    return (((it.getResults() != null) && (it.getResults().size() > 0)) && (it.getResults().get(0).getSeries() != null));
  });
  
  public static BinaryOperator<QueryResult> combine = ((BinaryOperator<QueryResult>) (QueryResult a, QueryResult b) -> {
    QueryResult _xblockexpression = null;
    {
      a.getResults().addAll(b.getResults());
      _xblockexpression = a;
    }
    return _xblockexpression;
  });
}
