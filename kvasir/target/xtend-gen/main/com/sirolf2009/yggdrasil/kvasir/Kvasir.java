package com.sirolf2009.yggdrasil.kvasir;

import it.unimi.dsi.fastutil.ints.IntArrayList;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.function.Consumer;
import javax.swing.JFrame;
import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVParser;
import org.apache.commons.csv.CSVRecord;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.ExclusiveRange;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.ListExtensions;
import org.eclipse.xtext.xbase.lib.Pair;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure2;
import org.knowm.xchart.SwingWrapper;
import org.knowm.xchart.XYChart;
import org.knowm.xchart.XYChartBuilder;
import org.knowm.xchart.XYSeries;
import org.knowm.xchart.style.markers.SeriesMarkers;
import tech.tablesaw.api.IntColumn;
import tech.tablesaw.api.NumericColumn;
import tech.tablesaw.api.Table;
import tech.tablesaw.api.plot.Line;

@SuppressWarnings("all")
public class Kvasir {
  /**
   * bid_price_0,bid_amount_0,bid_price_1,bid_amount_1,bid_price_2,bid_amount_2,bid_price_3,bid_amount_3,bid_price_4,bid_amount_4,bid_price_5,bid_amount_5,bid_price_6,bid_amount_6,bid_price_7,bid_amount_7,bid_price_8,bid_amount_8,bid_price_9,bid_amount_9,bid_price_10,bid_amount_10,bid_price_11,bid_amount_11,bid_price_12,bid_amount_12,bid_price_13,bid_amount_13,bid_price_14,bid_amount_14,ask_price_0,ask_amount_0,ask_price_1,ask_amount_1,ask_price_2,ask_amount_2,ask_price_3,ask_amount_3,ask_price_4,ask_amount_4,ask_price_5,ask_amount_5,ask_price_6,ask_amount_6,ask_price_7,ask_amount_7,ask_price_8,ask_amount_8,ask_price_9,ask_amount_9,ask_price_10,ask_amount_10,ask_price_11,ask_amount_11,ask_price_12,ask_amount_12,ask_price_13,ask_amount_13,ask_price_14,ask_amount_14
   */
  public static void main(final String[] args) {
    Pair<String, Integer> _mappedTo = Pair.<String, Integer>of("bid", Integer.valueOf(0));
    Pair<String, Integer> _mappedTo_1 = Pair.<String, Integer>of("ask", Integer.valueOf(29));
    Kvasir.showCharts(new File("/home/sirolf2009/git/yggdrasil/vor/data/predict-csv"), 
      Collections.<Pair<String, Integer>>unmodifiableList(CollectionLiterals.<Pair<String, Integer>>newArrayList(_mappedTo, _mappedTo_1)));
  }
  
  public static void smileChart(final String file) {
    try {
      final Table orderbook = Table.createFromCsv(file);
      InputOutput.<List<String>>println(orderbook.columnNames());
      int _rowCount = orderbook.rowCount();
      List<Integer> _list = IterableExtensions.<Integer>toList(new ExclusiveRange(0, _rowCount, true));
      IntArrayList _intArrayList = new IntArrayList(_list);
      final IntColumn indexColumn = new IntColumn("index", _intArrayList);
      final NumericColumn bid = orderbook.nCol("bid_price_0");
      final NumericColumn ask = orderbook.nCol("ask_price_0");
      Line.show("Bid", indexColumn, bid);
      Line.show("Ask", indexColumn, ask);
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  public static JFrame showChart(final File file, final List<Pair<String, Integer>> series) {
    XYChart _chart = Kvasir.getChart(file, series);
    return new SwingWrapper<XYChart>(_chart).displayChart();
  }
  
  public static JFrame showCharts(final File file, final List<Pair<String, Integer>> series) {
    try {
      JFrame _xblockexpression = null;
      {
        boolean _exists = file.exists();
        boolean _not = (!_exists);
        if (_not) {
          String _absolutePath = file.getAbsolutePath();
          throw new FileNotFoundException(_absolutePath);
        }
        final Comparator<File> _function = (File a, File b) -> {
          return a.getName().compareTo(b.getName());
        };
        final Function1<File, XYChart> _function_1 = (File it) -> {
          return Kvasir.getChart(it, series);
        };
        List<XYChart> _map = ListExtensions.<File, XYChart>map(ListExtensions.<File>sortInplace(((List<File>)Conversions.doWrapArray(file.listFiles())), _function), _function_1);
        _xblockexpression = new SwingWrapper<XYChart>(_map).displayChartMatrix();
      }
      return _xblockexpression;
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  private static XYChart getChart(final File file, final List<Pair<String, Integer>> series) {
    try {
      final FileReader reader = new FileReader(file);
      final CSVParser records = CSVFormat.EXCEL.parse(reader);
      final HashMap<String, Pair<List<Integer>, List<Double>>> seriesMap = new HashMap<String, Pair<List<Integer>, List<Double>>>();
      final Consumer<Pair<String, Integer>> _function = (Pair<String, Integer> it) -> {
        ArrayList<Integer> _arrayList = new ArrayList<Integer>();
        ArrayList<Double> _arrayList_1 = new ArrayList<Double>();
        Pair<List<Integer>, List<Double>> _mappedTo = Pair.<List<Integer>, List<Double>>of(_arrayList, _arrayList_1);
        seriesMap.put(it.getKey(), _mappedTo);
      };
      series.forEach(_function);
      final Procedure2<CSVRecord, Integer> _function_1 = (CSVRecord record, Integer index) -> {
        final Consumer<Pair<String, Integer>> _function_2 = (Pair<String, Integer> it) -> {
          seriesMap.get(it.getKey()).getKey().add(index);
          seriesMap.get(it.getKey()).getValue().add(Double.valueOf(Double.parseDouble(record.get((it.getValue()).intValue()))));
        };
        series.forEach(_function_2);
      };
      IterableExtensions.<CSVRecord>forEach(records, _function_1);
      final XYChart chart = new XYChartBuilder().width(600).height(400).title(file.getName()).xAxisTitle("X").yAxisTitle("Y").build();
      chart.getStyler().setDefaultSeriesRenderStyle(XYSeries.XYSeriesRenderStyle.Line);
      final Consumer<Map.Entry<String, Pair<List<Integer>, List<Double>>>> _function_2 = (Map.Entry<String, Pair<List<Integer>, List<Double>>> it) -> {
        final XYSeries added = chart.addSeries(it.getKey(), it.getValue().getKey(), it.getValue().getValue());
        added.setMarker(SeriesMarkers.NONE);
      };
      seriesMap.entrySet().forEach(_function_2);
      return chart;
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
}
