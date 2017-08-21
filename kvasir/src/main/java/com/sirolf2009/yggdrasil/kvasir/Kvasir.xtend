package com.sirolf2009.yggdrasil.kvasir

import it.unimi.dsi.fastutil.ints.IntArrayList
import java.io.File
import java.io.FileNotFoundException
import java.io.FileReader
import java.util.ArrayList
import java.util.HashMap
import java.util.List
import org.apache.commons.csv.CSVFormat
import org.knowm.xchart.SwingWrapper
import org.knowm.xchart.XYChartBuilder
import org.knowm.xchart.XYSeries.XYSeriesRenderStyle
import org.knowm.xchart.style.markers.SeriesMarkers
import tech.tablesaw.api.IntColumn
import tech.tablesaw.api.Table
import tech.tablesaw.api.plot.Line

class Kvasir {
	
	//bid_0,bidvol_0
	/**
	 * bid_price_0,bid_amount_0,bid_price_1,bid_amount_1,bid_price_2,bid_amount_2,bid_price_3,bid_amount_3,bid_price_4,bid_amount_4,bid_price_5,bid_amount_5,bid_price_6,bid_amount_6,bid_price_7,bid_amount_7,bid_price_8,bid_amount_8,bid_price_9,bid_amount_9,bid_price_10,bid_amount_10,bid_price_11,bid_amount_11,bid_price_12,bid_amount_12,bid_price_13,bid_amount_13,bid_price_14,bid_amount_14,ask_price_0,ask_amount_0,ask_price_1,ask_amount_1,ask_price_2,ask_amount_2,ask_price_3,ask_amount_3,ask_price_4,ask_amount_4,ask_price_5,ask_amount_5,ask_price_6,ask_amount_6,ask_price_7,ask_amount_7,ask_price_8,ask_amount_8,ask_price_9,ask_amount_9,ask_price_10,ask_amount_10,ask_price_11,ask_amount_11,ask_price_12,ask_amount_12,ask_price_13,ask_amount_13,ask_price_14,ask_amount_14
	 
	 */

	def public static void main(String[] args) {
//		smileChart("/home/sirolf2009/git/yggdrasil/vor/data/predict-csv/predict_0.csv")
//		smileChart("/home/sirolf2009/git/yggdrasil/vor/data/predict-csv/predict_1.csv")
//		smileChart("/home/sirolf2009/git/yggdrasil/vor/data/predict-csv/predict_2.csv")
		new File("/home/sirolf2009/git/yggdrasil/vor/data/predict-csv").showCharts(#[
			"bid" -> 0,
			"ask" -> 29
		])
	}
	
	def static smileChart(String file) {
		val orderbook = Table.createFromCsv(file)
		println(orderbook.columnNames)
		val indexColumn = new IntColumn("index", new IntArrayList((0 ..< orderbook.rowCount).toList()))
		val bid = orderbook.nCol("bid_price_0")
		val ask = orderbook.nCol("ask_price_0")
		Line.show("Bid", indexColumn, bid)
		Line.show("Ask", indexColumn, ask)
	}

	def static showChart(File file, List<Pair<String, Integer>> series) {
		new SwingWrapper(file.getChart(series)).displayChart();
	}

	def static showCharts(File file, List<Pair<String, Integer>> series) {
		if(!file.exists) {
			throw new FileNotFoundException(file.absolutePath)
		}
		new SwingWrapper(file.listFiles.sortInplace[a, b|a.name.compareTo(b.name)].map[getChart(series)]).displayChartMatrix();
	}

	def private static getChart(File file, List<Pair<String, Integer>> series) {
		val reader = new FileReader(file)
		val records = CSVFormat.EXCEL.parse(reader)
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
