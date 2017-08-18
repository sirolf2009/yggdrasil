package com.sirolf2009.yggdrasil.kvasir

import java.io.File
import java.io.FileReader
import java.util.ArrayList
import java.util.HashMap
import java.util.List
import org.apache.commons.csv.CSVFormat
import org.knowm.xchart.SwingWrapper
import org.knowm.xchart.XYChartBuilder
import org.knowm.xchart.XYSeries.XYSeriesRenderStyle
import org.knowm.xchart.style.markers.SeriesMarkers

class Kvasir {

	def public static void main(String[] args) {
		new File("/home/floris/eclipse-workspace/yggdrasil/vor/data/orderbook.csv").showChart(#[
			"bid" -> 0,
			"ask" -> 30
		])
	}

	def static showChart(File file, List<Pair<String, Integer>> series) {
		new SwingWrapper(file.getChart(series)).displayChart();
	}

	def static showCharts(File file, List<Pair<String, Integer>> series) {
		new SwingWrapper(file.listFiles.sortInplace[a,b|a.name.compareTo(b.name)].map[getChart(series)]).displayChartMatrix();
	}
	
	def private static getChart(File file, List<Pair<String, Integer>> series) {
		val reader = new FileReader(file)
		val records = CSVFormat.DEFAULT.parse(reader)
		val seriesMap = new HashMap<String, Pair<List<Integer>, List<Double>>>()
		series.forEach[seriesMap.put(key, new ArrayList() -> new ArrayList())]
		records.forEach [ record, index |
			series.forEach [
				seriesMap.get(key).key.add(index)
				seriesMap.get(key).value.add(Double.parseDouble(record.get(value)))
			]
		]
		val chart = new XYChartBuilder().width(600).height(400).title(file.name).xAxisTitle("X").yAxisTitle("Y").build()
    	chart.getStyler().setDefaultSeriesRenderStyle(XYSeriesRenderStyle.Line);
		seriesMap.entrySet.forEach [
			val added = chart.addSeries(key, value.key, value.value)
			added.marker = SeriesMarkers.NONE
		]
		return chart
	}

}
