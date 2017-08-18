package com.sirolf2009.yggdrasil.vor.data;

import com.sirolf2009.yggdrasil.vor.data.Converters;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.influxdb.InfluxDB;
import org.influxdb.InfluxDBFactory;
import org.influxdb.dto.Query;
import org.influxdb.dto.QueryResult;
import org.junit.Test;

@SuppressWarnings("all")
public class TestConverters {
  @Test
  public void testParseOrderbook() {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("http://freyr:8086");
    final InfluxDB influx = InfluxDBFactory.connect(_builder.toString());
    StringConcatenation _builder_1 = new StringConcatenation();
    _builder_1.append("SELECT \"value\", \"amount\" FROM \"orderbook\".\"autogen\".\"gdax\" GROUP BY \"side\", \"index\" LIMIT 100");
    Query _query = new Query(_builder_1.toString(), "orderbook");
    final QueryResult result = influx.query(_query);
    Converters.parseOrderbook.apply(result);
  }
}
