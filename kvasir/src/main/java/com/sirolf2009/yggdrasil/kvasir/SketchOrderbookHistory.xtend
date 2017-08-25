package com.sirolf2009.yggdrasil.kvasir

import com.sirolf2009.yggdrasil.freyr.Arguments
import com.sirolf2009.yggdrasil.freyr.SupplierOrderbookLive
import com.sirolf2009.yggdrasil.freyr.model.TableOrderbook
import com.sirolf2009.yggdrasil.sif.transmutation.OrderbookNormaliseDiffStdDev
import controlP5.ControlP5
import controlP5.ControlP5Constants
import controlP5.Slider
import grafica.GPlot
import grafica.GPoint
import grafica.GPointsArray
import java.time.Duration
import java.util.Optional
import java.util.function.Supplier
import java.util.stream.Collectors
import java.util.stream.IntStream
import java.util.stream.Stream
import org.knowm.xchange.currency.CurrencyPair
import org.knowm.xchange.gdax.GDAXExchange
import processing.core.PApplet
import tech.tablesaw.api.DoubleColumn

class SketchOrderbookHistory extends PApplet {

	static val color = ControlP5Constants.THEME_CP52014 => [
		foreground = ControlP5Constants.BLUE
		background = ControlP5Constants.WHITE
		valueLabel = ControlP5Constants.FUCHSIA
	]
	val Supplier<Optional<TableOrderbook>> supplier
	var TableOrderbook data
	val int take
	var GPlot orderbook
	var ControlP5 cp5
	var Slider sliderScroll
	var Slider sliderZoom
	var scroll = 0
	var zoom = 60

	new(TableOrderbook data, Supplier<Optional<TableOrderbook>> supplier, int take) {
		this.supplier = supplier
		this.take = take
		this.data = data
		new Thread [
			while(true) {
				val newData = supplier.get()
				newData.ifPresent [
					appendData()
				]
			}
		].start()
	}

	def synchronized appendData(TableOrderbook data) {
		this.data.append(data)
	}

	override settings() {
		size(1024, 800)
	}

	override setup() {
		surface.resizable = true
		surface.title = this.getClass().asSubclass(this.getClass()).simpleName
		orderbook = new GPlot(this)
		orderbook.title.text = "Orderbook"
		orderbook.setDim(900, 680)
		orderbook.setPos(0, 0)
		orderbook.pointColors = Stream.concat(IntStream.range(0, take).map[color(0, 255, 0, 200)].boxed, IntStream.range(0, take).map[color(255, 0, 0, 200)].boxed).collect(Collectors.toList())

		cp5 = new ControlP5(this)
		sliderScroll = cp5.addSlider("scroll").setPosition(40, 750).setRange(0, Math.max(1, data.rowCount - 1 - zoom)).setWidth(950).setHeight(20).setColor(color).setLabelVisible(true)
		sliderZoom = cp5.addSlider("zoom").setPosition(40, 770).setRange(1, 60 * 15).setWidth(950).setHeight(20).setColor(color).setValue(60).setLabelVisible(true)
	}

	override synchronized draw() {
		background(255)
		val points = new GPointsArray(zoom * take * 2)
		(scroll ..< Math.min(data.rowCount - 1, zoom + scroll)).forEach [ indexInScreen |
			data.columns.stream.skip(1).collect(Collectors.toList()).forEach [ it, indexInFrame |
				if(name.contains("price")) {
					val value = Math.abs((it as DoubleColumn).get(data.rowCount - 1 - indexInScreen).floatValue())
					points.add(new GPoint(zoom - indexInScreen, value, name))
				}
			]
		]
		orderbook.points = points
		orderbook => [
			beginDraw()
			drawBackground()
			drawBox()
			drawYAxis()
			drawXAxis()
			drawTitle()
			drawPoints()
			endDraw()
		]
	}

	def static create(TableOrderbook data, Supplier<Optional<TableOrderbook>> supplier, int take) {
		runSketch(#[SketchOrderbookHistory.name], new SketchOrderbookHistory(data, supplier, take));
	}

	def synchronized void zoom(float zoom) {
		this.zoom = Math.ceil(zoom) as int
		sliderScroll.setRange(0, Math.max(1, data.rowCount - 1 - zoom))
	}

	def static void main(String[] args) {
		val take = 15
		val supplier = new SupplierOrderbookLive(new Arguments(), GDAXExchange.canonicalName, CurrencyPair.BTC_EUR, Duration.ofSeconds(1), take)
		create(supplier.first, supplier.normalised, take)
	}
	
	def static getFirst(Supplier<Optional<TableOrderbook>> supplier) {
		while(true) {
			val data = supplier.get()
			if(data.present) {
				return data.get()
			}
		}
	}

	def static Supplier<Optional<TableOrderbook>> normalised(Supplier<Optional<TableOrderbook>> supplier) {
		val normalise = new OrderbookNormaliseDiffStdDev()
		return [
			val data =  supplier.get()
			data.ifPresent(normalise)
			data
		]
	}
}
