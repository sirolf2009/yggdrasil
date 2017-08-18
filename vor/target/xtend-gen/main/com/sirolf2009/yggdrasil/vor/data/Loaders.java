package com.sirolf2009.yggdrasil.vor.data;

import com.sirolf2009.yggdrasil.vor.data.Arguments;
import java.io.File;
import java.nio.file.Files;
import java.util.List;
import java.util.function.Supplier;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.deeplearning4j.nn.multilayer.MultiLayerNetwork;
import org.deeplearning4j.util.ModelSerializer;
import org.eclipse.xtend.lib.annotations.Data;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.ExclusiveRange;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.Functions.Function2;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.Pure;
import org.eclipse.xtext.xbase.lib.util.ToStringBuilder;
import org.influxdb.InfluxDB;
import org.influxdb.InfluxDBFactory;
import org.influxdb.dto.Query;
import org.influxdb.dto.QueryResult;

@SuppressWarnings("all")
public class Loaders {
  @Data
  public static class InfluxOrderbook implements Supplier<QueryResult> {
    private final static Logger log = LogManager.getLogger();
    
    @Extension
    private final Arguments arguments;
    
    @Override
    public QueryResult get() {
      QueryResult _xblockexpression = null;
      {
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("http://");
        String _influxHost = this.arguments.getInfluxHost();
        _builder.append(_influxHost);
        _builder.append(":");
        int _influxPort = this.arguments.getInfluxPort();
        _builder.append(_influxPort);
        final String host = _builder.toString();
        StringConcatenation _builder_1 = new StringConcatenation();
        _builder_1.append("Downloading ");
        int _datapoints = this.arguments.getDatapoints();
        _builder_1.append(_datapoints);
        _builder_1.append(" points from ");
        _builder_1.append(host);
        _builder_1.append(" with batch ");
        int _datapointsBatch = this.arguments.getDatapointsBatch();
        _builder_1.append(_datapointsBatch);
        Loaders.InfluxOrderbook.log.info(_builder_1);
        final InfluxDB influx = InfluxDBFactory.connect(host);
        int _datapoints_1 = this.arguments.getDatapoints();
        int _datapointsBatch_1 = this.arguments.getDatapointsBatch();
        int _divide = (_datapoints_1 / _datapointsBatch_1);
        double _ceil = Math.ceil(_divide);
        final int batchesToDownload = ((int) _ceil);
        final Function1<Integer, QueryResult> _function = (Integer it) -> {
          QueryResult _xblockexpression_1 = null;
          {
            StringConcatenation _builder_2 = new StringConcatenation();
            _builder_2.append("SELECT \"value\", \"amount\" FROM \"orderbook\".\"autogen\".\"gdax\" GROUP BY \"side\", \"index\" LIMIT ");
            int _datapointsBatch_2 = this.arguments.getDatapointsBatch();
            _builder_2.append(_datapointsBatch_2);
            _builder_2.append(" OFFSET ");
            int _datapointsBatch_3 = this.arguments.getDatapointsBatch();
            int _multiply = ((it).intValue() * _datapointsBatch_3);
            _builder_2.append(_multiply);
            final String query = _builder_2.toString();
            Loaders.InfluxOrderbook.log.info(query);
            String _database = this.arguments.getDatabase();
            Query _query = new Query(query, _database);
            _xblockexpression_1 = influx.query(_query);
          }
          return _xblockexpression_1;
        };
        final Function1<QueryResult, Boolean> _function_1 = (QueryResult it) -> {
          String _error = it.getError();
          boolean _tripleNotEquals = (_error != null);
          if (_tripleNotEquals) {
            Loaders.InfluxOrderbook.log.error(it.getError());
          }
          return Boolean.valueOf((((it.getResults() != null) && (it.getResults().size() > 0)) && (it.getResults().get(0).getSeries() != null)));
        };
        final Function2<QueryResult, QueryResult, QueryResult> _function_2 = (QueryResult a, QueryResult b) -> {
          QueryResult _xblockexpression_1 = null;
          {
            a.getResults().addAll(b.getResults());
            _xblockexpression_1 = a;
          }
          return _xblockexpression_1;
        };
        _xblockexpression = IterableExtensions.<QueryResult>reduce(IterableExtensions.<QueryResult>filter(IterableExtensions.<Integer, QueryResult>map(new ExclusiveRange(0, batchesToDownload, true), _function), _function_1), _function_2);
      }
      return _xblockexpression;
    }
    
    public InfluxOrderbook(final Arguments arguments) {
      super();
      this.arguments = arguments;
    }
    
    @Override
    @Pure
    public int hashCode() {
      final int prime = 31;
      int result = 1;
      result = prime * result + ((this.arguments== null) ? 0 : this.arguments.hashCode());
      return result;
    }
    
    @Override
    @Pure
    public boolean equals(final Object obj) {
      if (this == obj)
        return true;
      if (obj == null)
        return false;
      if (getClass() != obj.getClass())
        return false;
      Loaders.InfluxOrderbook other = (Loaders.InfluxOrderbook) obj;
      if (this.arguments == null) {
        if (other.arguments != null)
          return false;
      } else if (!this.arguments.equals(other.arguments))
        return false;
      return true;
    }
    
    @Override
    @Pure
    public String toString() {
      ToStringBuilder b = new ToStringBuilder(this);
      b.add("arguments", this.arguments);
      return b.toString();
    }
    
    @Pure
    public Arguments getArguments() {
      return this.arguments;
    }
  }
  
  @Data
  public static class FileLines implements Supplier<List<String>> {
    private final static Logger log = LogManager.getLogger();
    
    private final File file;
    
    @Override
    public List<String> get() {
      try {
        List<String> _xblockexpression = null;
        {
          StringConcatenation _builder = new StringConcatenation();
          _builder.append("Loading ");
          _builder.append(this.file);
          Loaders.FileLines.log.info(_builder);
          _xblockexpression = Files.readAllLines(this.file.toPath());
        }
        return _xblockexpression;
      } catch (Throwable _e) {
        throw Exceptions.sneakyThrow(_e);
      }
    }
    
    public FileLines(final File file) {
      super();
      this.file = file;
    }
    
    @Override
    @Pure
    public int hashCode() {
      final int prime = 31;
      int result = 1;
      result = prime * result + ((this.file== null) ? 0 : this.file.hashCode());
      return result;
    }
    
    @Override
    @Pure
    public boolean equals(final Object obj) {
      if (this == obj)
        return true;
      if (obj == null)
        return false;
      if (getClass() != obj.getClass())
        return false;
      Loaders.FileLines other = (Loaders.FileLines) obj;
      if (this.file == null) {
        if (other.file != null)
          return false;
      } else if (!this.file.equals(other.file))
        return false;
      return true;
    }
    
    @Override
    @Pure
    public String toString() {
      ToStringBuilder b = new ToStringBuilder(this);
      b.add("file", this.file);
      return b.toString();
    }
    
    @Pure
    public File getFile() {
      return this.file;
    }
  }
  
  @Data
  public static class Network implements Supplier<MultiLayerNetwork> {
    private final static Logger log = LogManager.getLogger();
    
    private final File file;
    
    @Override
    public MultiLayerNetwork get() {
      try {
        MultiLayerNetwork _xblockexpression = null;
        {
          StringConcatenation _builder = new StringConcatenation();
          _builder.append("Loading network from ");
          _builder.append(this.file);
          Loaders.Network.log.info(_builder);
          _xblockexpression = ModelSerializer.restoreMultiLayerNetwork(this.file);
        }
        return _xblockexpression;
      } catch (Throwable _e) {
        throw Exceptions.sneakyThrow(_e);
      }
    }
    
    public Network(final File file) {
      super();
      this.file = file;
    }
    
    @Override
    @Pure
    public int hashCode() {
      final int prime = 31;
      int result = 1;
      result = prime * result + ((this.file== null) ? 0 : this.file.hashCode());
      return result;
    }
    
    @Override
    @Pure
    public boolean equals(final Object obj) {
      if (this == obj)
        return true;
      if (obj == null)
        return false;
      if (getClass() != obj.getClass())
        return false;
      Loaders.Network other = (Loaders.Network) obj;
      if (this.file == null) {
        if (other.file != null)
          return false;
      } else if (!this.file.equals(other.file))
        return false;
      return true;
    }
    
    @Override
    @Pure
    public String toString() {
      ToStringBuilder b = new ToStringBuilder(this);
      b.add("file", this.file);
      return b.toString();
    }
    
    @Pure
    public File getFile() {
      return this.file;
    }
  }
}
