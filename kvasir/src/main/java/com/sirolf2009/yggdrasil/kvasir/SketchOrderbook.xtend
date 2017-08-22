package com.sirolf2009.yggdrasil.kvasir

import com.sirolf2009.yggdrasil.freyr.Arguments
import com.sirolf2009.yggdrasil.freyr.SupplierOrderbookLive
import com.sirolf2009.yggdrasil.sif.transmutation.OrderbookNormaliseDiffStdDev
import grafica.GPlot
import grafica.GPoint
import grafica.GPointsArray
import java.time.Duration
import java.util.function.Supplier
import java.util.stream.Collectors
import java.util.stream.IntStream
import java.util.stream.Stream
import org.knowm.xchange.currency.CurrencyPair
import org.knowm.xchange.gdax.GDAXExchange
import processing.core.PApplet
import tech.tablesaw.api.DoubleColumn
import tech.tablesaw.api.Table

class SketchOrderbook extends PApplet {

	static val take = 15
	val Supplier<Table> supplier
	var GPlot orderbook
	
	new(Supplier<Table> supplier) {
		this.supplier = supplier
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
	}

	override draw() {
		background(255)
		println("getting data")
		val data = supplier.get()
		println("normalising")
		new OrderbookNormaliseDiffStdDev().accept(data)
		println("mapping")
		orderbook.points.NPoints = 0
		data.columns.stream.skip(1).collect(Collectors.toList()).forEach [ it, index |
			if(name.contains("price")) {
				val value = Math.abs((it as DoubleColumn).get(0).floatValue())
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
	}
	
	def static create(Supplier<Table> supplier) {
		runSketch(#[SketchOrderbook.name], new SketchOrderbook(supplier));
	}

	def static void main(String[] args) {
		create(new SupplierOrderbookLive(new Arguments(), GDAXExchange.canonicalName, CurrencyPair.BTC_EUR, Duration.ofSeconds(1), take))
	}

}
