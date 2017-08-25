package com.sirolf2009.yggdrasil.kvasir

import com.sirolf2009.yggdrasil.freyr.Arguments
import com.sirolf2009.yggdrasil.freyr.SupplierOrderbookLive
import com.sirolf2009.yggdrasil.freyr.model.TableOrderbook
import com.sirolf2009.yggdrasil.sif.transmutation.OrderbookNormaliseDiffStdDev
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
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors class SketchOrderbook extends PApplet {

	val TableOrderbook data
	var GPlot orderbook

	new(TableOrderbook data) {
		this.data = data
	}

	override settings() {
		size(940, 800)
	}

	override setup() {
		surface.resizable = true
		surface.title = this.getClass().asSubclass(this.getClass()).simpleName
		orderbook = new GPlot(this)
		orderbook.points = new GPointsArray((0 ..< data.bidPrices.size + data.askPrices.size).toList().stream().flatMap[Stream.of(new GPoint(it * 2, 0, "price_" + it))].collect(Collectors.toList()))
		orderbook.title.text = data.name
		orderbook.startHistograms(GPlot.HORIZONTAL)
		orderbook.drawHistLabels = true
		orderbook.setDim(850, 700)
		orderbook.getHistogram().setBgColors(
			Stream.concat(IntStream.range(0, 15).map[color(0, 255, 0, 200)].boxed, IntStream.range(0, 15).map[color(255, 0, 0, 200)].boxed).collect(Collectors.toList())
		)
		updateGraph()
	}

	override draw() {
		background(255)
		drawGraph()
	}
	
	def drawGraph() {
		orderbook => [
			beginDraw()
			drawBackground()
			drawBox()
			drawYAxis()
			drawXAxis()
			drawTitle()
			drawHistograms()
			endDraw()
		]
	}
	
	def updateGraph() {
		data.bidPrices.reverse.forEach [ it, index |
			val value = get(0).floatValue()
			val point = new GPoint(value, index, name)
			orderbook.setPoint(index, point)
		]
		data.askPrices.forEach [ it, index |
			val value = get(0).floatValue()
			val point = new GPoint(value, index+15, name)
			orderbook.setPoint(index+15, point)
		]
	}

	def static create(TableOrderbook data) {
		runSketch(#[SketchOrderbook.name], new SketchOrderbook(data));
	}

	def static void main(String[] args) {
		val data = new SupplierOrderbookLive(new Arguments(), GDAXExchange.canonicalName, CurrencyPair.BTC_EUR, Duration.ofSeconds(1), 15).first
		create(new TableOrderbook(data))
		Thread.sleep(1000)
		new OrderbookNormaliseDiffStdDev().accept(data)
		data.name = data.name+"-Normalized"
		create(data)
	}

	def static getFirst(Supplier<Optional<TableOrderbook>> supplier) {
		while(true) {
			val data = supplier.get()
			if(data.present) {
				return data.get()
			}
		}
	}

}
