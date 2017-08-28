package com.sirolf2009.yggdrasil.kvasir

import com.sirolf2009.yggdrasil.freyr.Arguments
import com.sirolf2009.yggdrasil.freyr.SupplierOrderbookLive
import com.sirolf2009.yggdrasil.freyr.model.TableOrderbook
import com.sirolf2009.yggdrasil.sif.loader.LoadersFile
import com.sirolf2009.yggdrasil.sif.transmutation.OrderbookNormaliseDiffStdDev
import com.sirolf2009.yggdrasil.vor.Predict
import controlP5.ControlP5
import controlP5.ControlP5Constants
import controlP5.Slider
import grafica.GPlot
import grafica.GPoint
import grafica.GPointsArray
import java.time.Duration
import java.util.Optional
import java.util.concurrent.atomic.AtomicBoolean
import java.util.function.Supplier
import java.util.stream.Collectors
import java.util.stream.IntStream
import java.util.stream.Stream
import org.deeplearning4j.nn.multilayer.MultiLayerNetwork
import org.knowm.xchange.currency.CurrencyPair
import org.knowm.xchange.gdax.GDAXExchange
import org.nd4j.linalg.factory.Nd4j
import processing.core.PApplet
import processing.core.PFont
import tech.tablesaw.api.DoubleColumn

import static extension com.sirolf2009.yggdrasil.sif.TableExtensions.*

class SketchOrderbookHistoryPredict extends PApplet {

	static val color = ControlP5Constants.THEME_CP52014 => [
		foreground = ControlP5Constants.BLUE
		background = ControlP5Constants.WHITE
		valueLabel = ControlP5Constants.FUCHSIA
	]
	val Supplier<Optional<TableOrderbook>> supplier
	var TableOrderbook data
	var TableOrderbook predictionData
	val int take
	val MultiLayerNetwork net
	var GPlot orderbook
	var GPlot prediction
	var ControlP5 cp5
	var Slider sliderZoom
	var zoom = 60
	var PFont font

	new(TableOrderbook data, Supplier<Optional<TableOrderbook>> supplier, int take, MultiLayerNetwork net) {
		this.supplier = supplier
		this.take = take
		this.data = data
		this.net = net
		this.predictionData = data.predict()
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
		this.predictionData = this.data.predict()
	}

	override settings() {
		size(1024, 800)
	}

	override setup() {
		surface.resizable = true
		surface.title = this.getClass().asSubclass(this.getClass()).simpleName
		orderbook = new GPlot(this)
		orderbook.title.text = "Orderbook"
		orderbook.setOuterDim(width/2, 680)
		orderbook.setPos(0, 0)
		orderbook.pointColors = Stream.concat(IntStream.range(0, take).map[color(0, 255, 0, 200)].boxed, IntStream.range(0, take).map[color(255, 0, 0, 200)].boxed).collect(Collectors.toList())

		prediction = new GPlot(this)
		prediction.title.text = "Orderbook Predicted"
		prediction.setOuterDim(width/2, 680)
		prediction.setPos(width/2, 0)
		prediction.pointColors = Stream.concat(IntStream.range(0, take).map[color(0, 255, 0, 200)].boxed, IntStream.range(0, take).map[color(255, 0, 0, 200)].boxed).collect(Collectors.toList())

		cp5 = new ControlP5(this)
		sliderZoom = cp5.addSlider("zoom").setPosition(40, 770).setRange(1, 60 * 15).setWidth(950).setHeight(20).setColor(color).setValue(60).setLabelVisible(true)

		font = createFont("Arial", 16, true)

		frameRate(1)
	}

	override synchronized draw() {
		background(255)
		orderbook.setOuterDim(width/2, 680)
		orderbook.setPos(0, 0)
		prediction.setOuterDim(width/2, 680)
		prediction.setPos(width/2, 0)
		
		{
			val points = new GPointsArray(zoom * take * 2)
			(0 ..< Math.min(data.rowCount - 1, zoom)).forEach [ indexInScreen |
				data.columns.stream.skip(1).collect(Collectors.toList()).forEach [ it, indexInFrame |
					if(name.contains("price")) {
						val value = Math.abs((it as DoubleColumn).get(data.rowCount - 1 - indexInScreen).floatValue()) * if(name.contains("bid")) -1 else 1
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
		
		prediction.setYLim(orderbook.YLim.get(0), orderbook.YLim.get(1));

		{
			val hasNaN = new AtomicBoolean(false)
			val predictions = new GPointsArray(zoom * take * 2)
			(0 ..< Math.min(predictionData.rowCount - 1, zoom)).forEach [ indexInScreen |
				predictionData.columns.stream.skip(1).collect(Collectors.toList()).forEach [ it, indexInFrame |
					if(name.contains("price")) {
						val value = Math.abs((it as DoubleColumn).get(predictionData.rowCount - 1 - indexInScreen).floatValue()) * if(name.contains("bid")) -1 else 1
						predictions.add(new GPoint(zoom - indexInScreen, value, name))
						if(value.isNaN) {
							hasNaN.set(true)
						}
					}
				]
			]
			prediction.points = predictions
			prediction => [
				beginDraw()
				drawBackground()
				drawBox()
				drawYAxis()
				drawXAxis()
				drawTitle()
				drawPoints()
				endDraw()
			]
			if(hasNaN.get) {
				textFont(font, 16)
				fill(255, 0, 0) 
				text("NaN issues!", 700, 340)
			}
		}
	}

	def static create(TableOrderbook data, Supplier<Optional<TableOrderbook>> supplier, int take, MultiLayerNetwork net) {
		runSketch(#[SketchOrderbookHistoryPredict.name], new SketchOrderbookHistoryPredict(data, supplier, take, net));
	}

	def synchronized void zoom(float zoom) {
		this.zoom = Math.ceil(zoom) as int
	}

	def predict(TableOrderbook data) {
		val date = data.date.get(data.date.size - 1)
		return Nd4j.vstack(Predict.predictMultiStep(net, data, zoom)).toTable(date, data.name + "-predicted")
	}

	def static void main(String[] args) {
		val take = 15
		val supplier = new SupplierOrderbookLive(new Arguments(), GDAXExchange.canonicalName, CurrencyPair.BTC_EUR, Duration.ofSeconds(1), take)
		create(supplier.first, supplier.normalised, take, LoadersFile.loadNetwork("network3.zip"))
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
			val data = supplier.get()
			data.ifPresent(normalise)
			data
		]
	}
}
