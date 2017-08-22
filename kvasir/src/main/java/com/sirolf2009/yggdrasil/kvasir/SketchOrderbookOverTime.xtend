package com.sirolf2009.yggdrasil.kvasir

import grafica.GPlot
import grafica.GPoint
import grafica.GPointsArray
import java.util.stream.Collectors
import java.util.stream.IntStream
import java.util.stream.Stream
import processing.core.PApplet
import tech.tablesaw.api.DoubleColumn
import tech.tablesaw.api.Table
import com.sirolf2009.yggdrasil.sif.TestData
import com.sirolf2009.yggdrasil.sif.transmutation.OrderbookNormaliseDiffStdDev

class SketchOrderbookOverTime extends PApplet {

	static val take = 15
	val Table data
	var GPlot orderbook
	var row = 0
	
	new(Table data) {
		this.data = data
	}

	override settings() {
		size(1024, 800)
	}

	override setup() {
		orderbook = new GPlot(this)
		orderbook.points = new GPointsArray((0 ..< take * 2).toList().stream().flatMap[Stream.of(new GPoint(it * 2, 0, "price_" + it))].collect(Collectors.toList()))
		orderbook.title.text = "Orderbook"
		orderbook.startHistograms(GPlot.HORIZONTAL)
		orderbook.drawHistLabels = true
		orderbook.setDim(950, 780)
		orderbook.getHistogram().setBgColors(
			Stream.concat(IntStream.range(0, 15).map[color(0, 255, 0, 200)].boxed, IntStream.range(0, 15).map[color(255, 0, 0, 200)].boxed).collect(Collectors.toList())
		)
		frameRate(10)
	}

	override draw() {
		background(255)
		println("mapping")
		orderbook.points.NPoints = 0
		data.columns.stream.skip(1).collect(Collectors.toList()).forEach [ it, index |
			if(name.contains("price")) {
				val value = Math.abs((it as DoubleColumn).get(row).floatValue())
				if(index < 30) {
					val point = new GPoint(value, (15 - index / 2), name)
					orderbook.setPoint(15 - index / 2, point)
				} else {
					val point = new GPoint(value, index / 2, name)
					orderbook.setPoint(index / 2, point)
				}
			}
		]
		println("drawing")
		orderbook => [
			beginDraw()
			drawBackground()
			drawBox()
			drawYAxis()
			drawTitle()
			drawHistograms()
			endDraw()
		]
		row += 1
		if(row >= data.rowCount) {
			row = 0
		}
	}
	
	def static create(Table data) {
		runSketch(#[SketchOrderbookOverTime.name], new SketchOrderbookOverTime(data));
	}

	def static void main(String[] args) {
		val table = TestData.orderbookRows
		new OrderbookNormaliseDiffStdDev().accept(table)
		create(table)
	}

}
