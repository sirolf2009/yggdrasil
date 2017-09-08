package com.sirolf2009.yggdrasil.kvasir

import com.sirolf2009.yggdrasil.freyr.Arguments
import com.sirolf2009.yggdrasil.freyr.SupplierOrderbookLive
import com.sirolf2009.yggdrasil.freyr.model.TableOrderbook
import com.sirolf2009.yggdrasil.sif.loader.LoadersFile
import com.sirolf2009.yggdrasil.sif.transmutation.OrderbookNormaliseDiffStdDev
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
import processing.core.PApplet
import processing.core.PFont
import tech.tablesaw.api.DoubleColumn

import static extension com.sirolf2009.yggdrasil.vor.Predict.*

class SketchOrderbookHistoryPredict extends PApplet {

	val Supplier<Optional<TableOrderbook>> supplier
	var TableOrderbook data
	var TableOrderbook predictionData
	val int take
	val MultiLayerNetwork net
	var GPlot orderbook
	var GPlot prediction
	var GPlot trades
	var GPlot tradesPredicted
//	var Slider sliderZoom
	var zoom = 60
	var PFont font

	new(TableOrderbook data, Supplier<Optional<TableOrderbook>> supplier, int take, MultiLayerNetwork net) {
		this.supplier = supplier
		this.take = take
		this.data = data
		this.net = net
		this.predictionData = net.predictMultiStepTable(data, zoom)
		new Thread [
			while(true) {
				val newData = supplier.get()
				newData.ifPresent [
					this.data = it
					this.predictionData = net.predictMultiStepTable(this.data, zoom)
				]
			}
		].start()
	}

	def synchronized void appendData(TableOrderbook data) {
		this.data.append(data)
		this.predictionData = net.predictMultiStepTable(this.data, zoom)
	}

	override settings() {
		size(1024, 800)
	}

	override setup() {
		surface.resizable = true
		surface.title = this.getClass().asSubclass(this.getClass()).simpleName
		orderbook = new GPlot(this)
		orderbook.title.text = "Orderbook"
		orderbook.setOuterDim(width / 2, height / 2)
		orderbook.setPos(0, 0)
		orderbook.pointColors = Stream.concat(IntStream.range(0, take).map[color(20, 245, 20, 200)].boxed, IntStream.range(0, take).map[color(255, 40, 40, 200)].boxed).collect(Collectors.toList())

		prediction = new GPlot(this)
		prediction.title.text = "Orderbook Predicted"
		prediction.setOuterDim(width / 2, height / 2)
		prediction.setPos(width / 2, 0)
		prediction.pointColors = Stream.concat(IntStream.range(0, take).map[color(20, 245, 20, 200)].boxed, IntStream.range(0, take).map[color(255, 40, 40, 200)].boxed).collect(Collectors.toList())

		trades = new GPlot(this)
		trades.title.text = "Trades"
		trades.setOuterDim(width / 2, height / 2)
		trades.setPos(0, height / 2)

		tradesPredicted = new GPlot(this)
		tradesPredicted.title.text = "Trades Predicted"
		tradesPredicted.setOuterDim(width / 2, height / 2)
		tradesPredicted.setPos(width / 2, height / 2)

//		sliderZoom = new Slider(this, 50, 700, 924, 20, 0, 60 * 16)
//		sliderZoom.current = 60
		font = createFont("Arial", 16, true)
	}

	override synchronized draw() {
		background(255)
		orderbook.setOuterDim(width / 2, height / 2)
		orderbook.setPos(0, 0)
		prediction.setOuterDim(width / 2, height / 2)
		prediction.setPos(width / 2, 0)
		trades.setOuterDim(width / 2, height / 2)
		trades.setPos(0, height / 2)
		tradesPredicted.setOuterDim(width / 2, height / 2)
		tradesPredicted.setPos(width / 2, height / 2)

		zoom = round(60 as float)

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

		{
			val points = new GPointsArray(zoom)
			(0 ..< Math.min(data.rowCount - 1, zoom)).forEach [
				points.add(new GPoint(zoom - it, data.getLast().get(data.rowCount - 1 - it).floatValue, "last"))
			]
			trades.points = points
			trades => [
				beginDraw()
				drawBackground()
				drawBox()
				drawYAxis()
				drawXAxis()
				drawTitle()
				drawLines()
				endDraw()
			]
			trades.activatePointLabels()
		}

		{
			val points = new GPointsArray(zoom)
			(0 ..< Math.min(predictionData.rowCount - 1, zoom)).forEach [
				points.add(
					new GPoint(zoom - it, predictionData.getLast().get(predictionData.rowCount - 1 - it).floatValue, "last")
				)
			]
			tradesPredicted.points = points
			tradesPredicted => [
				beginDraw()
				drawBackground()
				drawBox()
				drawYAxis()
				drawXAxis()
				drawTitle()
				drawLines()
				endDraw()
			]
			tradesPredicted.activatePointLabels()
		}
	}

	def static create(TableOrderbook data, Supplier<Optional<TableOrderbook>> supplier, int take, MultiLayerNetwork net) {
		runSketch(#[SketchOrderbookHistoryPredict.name], new SketchOrderbookHistoryPredict(data, supplier, take, net));
	}

	def static void main(String[] args) {
		val take = 15
		val supplier = new SupplierOrderbookLive(new Arguments(), GDAXExchange.canonicalName, CurrencyPair.BTC_EUR, Duration.ofSeconds(1), take)
		create(supplier.first, supplier.normalised, take, LoadersFile.loadNetwork("network_158.zip"))
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
		val table = new TableOrderbook("Raw")
		return [
			val data = supplier.get()
			return data.map [
				table.append(it)
				val copy = table.fullCopy()
				normalise.accept(copy)
				copy
			]
		]
	}
}
