package com.sirolf2009.yggdrasil.kvasir

import com.sirolf2009.yggdrasil.freyr.TestData
import com.sirolf2009.yggdrasil.freyr.model.TableOrderbook
import com.sirolf2009.yggdrasil.sif.transmutation.OrderbookNormaliseDiffStdDev
import controlP5.ControlP5
import controlP5.ControlP5Constants
import controlP5.Slider
import grafica.GPlot
import grafica.GPoint
import grafica.GPointsArray
import java.util.stream.Collectors
import java.util.stream.IntStream
import java.util.stream.Stream
import processing.core.PApplet
import tech.tablesaw.api.DoubleColumn

class SketchOrderbookOverTime extends PApplet {

	static val take = 15
	static val color = ControlP5Constants.THEME_CP52014 => [
		foreground = ControlP5Constants.BLUE
		background = ControlP5Constants.WHITE
		valueLabel = ControlP5Constants.FUCHSIA
	]
	val TableOrderbook data
	var GPlot orderbook
	var ControlP5 cp5
	var Slider slider
	var scroll = 0

	new(TableOrderbook data) {
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
		orderbook.setDim(900, 700)
		orderbook.setPos(0, 0)
		orderbook.getHistogram().setBgColors(
			Stream.concat(IntStream.range(0, 15).map[color(0, 255, 0, 200)].boxed, IntStream.range(0, 15).map[color(255, 0, 0, 200)].boxed).collect(Collectors.toList())
		)

		cp5 = new ControlP5(this)
		slider = cp5.addSlider("scroll").setPosition(40, 760).setRange(0, data.rowCount - 1).setWidth(950).setHeight(20).setColor(color)
		frameRate(10)
	}

	override draw() {
		background(255)
		println("mapping")
		orderbook.points.NPoints = 0
		data.columns.stream.skip(1).collect(Collectors.toList()).forEach [ it, index |
			if(name.contains("price")) {
				val value = Math.abs((it as DoubleColumn).get(scroll).floatValue())
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
			rect(39, 760+8, 951, 12)
			beginDraw()
			drawBackground()
			drawBox()
			drawYAxis()
			drawTitle()
			drawHistograms()
			endDraw()
		]
	}

	def static create(TableOrderbook data) {
		runSketch(#[SketchOrderbookOverTime.name], new SketchOrderbookOverTime(data));
	}

	def static void main(String[] args) {
		val table = TestData.orderbookRows
		new OrderbookNormaliseDiffStdDev().accept(table)
		create(table)
	}

}
