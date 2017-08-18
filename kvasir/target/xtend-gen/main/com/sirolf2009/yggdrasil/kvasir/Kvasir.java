package com.sirolf2009.yggdrasil.kvasir;

import java.io.File;
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
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.ListExtensions;
import org.eclipse.xtext.xbase.lib.Pair;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure2;
import org.knowm.xchart.SwingWrapper;
import org.knowm.xchart.XYChart;
import org.knowm.xchart.XYChartBuilder;
import org.knowm.xchart.XYSeries;
import org.knowm.xchart.style.markers.SeriesMarkers;

@SuppressWarnings("all")
public class Kvasir {
  public static void main(final String[] args) {
    Pair<String, Integer> _mappedTo = Pair.<String, Integer>of("bid", Integer.valueOf(0));
    Pair<String, Integer> _mappedTo_1 = Pair.<String, Integer>of("ask", Integer.valueOf(30));
    Kvasir.showChart(new File("/home/floris/eclipse-workspace/yggdrasil/vor/data/orderbook.csv"), 
      Collections.<Pair<String, Integer>>unmodifiableList(CollectionLiterals.<Pair<String, Integer>>newArrayList(_mappedTo, _mappedTo_1)));
  }
  
  public static JFrame showChart(final File file, final List<Pair<String, Integer>> series) {
    XYChart _chart = Kvasir.getChart(file, series);
    return new SwingWrapper<XYChart>(_chart).displayChart();
  }
  
  public static JFrame showCharts(final File file, final List<Pair<String, Integer>> series) {
    final Comparator<File> _function = (File a, File b) -> {
      return a.getName().compareTo(b.getName());
    };
    final Function1<File, XYChart> _function_1 = (File it) -> {
      return Kvasir.getChart(it, series);
    };
    List<XYChart> _map = ListExtensions.<File, XYChart>map(ListExtensions.<File>sortInplace(((List<File>)Conversions.doWrapArray(file.listFiles())), _function), _function_1);
    return new SwingWrapper<XYChart>(_map).displayChartMatrix();
  }
  
  private static XYChart getChart(final File file, final List<Pair<String, Integer>> series) {
    try {
      final FileReader reader = new FileReader(file);
      final CSVParser records = CSVFormat.DEFAULT.parse(reader);
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
