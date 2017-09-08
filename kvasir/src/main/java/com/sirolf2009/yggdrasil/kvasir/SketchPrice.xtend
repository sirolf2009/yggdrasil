package com.sirolf2009.yggdrasil.kvasir

import com.sirolf2009.yggdrasil.freyr.TestData
import com.sirolf2009.yggdrasil.freyr.model.TableOrderbook
import com.sirolf2009.yggdrasil.sif.loader.LoadersFile
import com.sirolf2009.yggdrasil.sif.transmutation.OrderbookNormaliseDiffStdDev
import grafica.GPlot
import org.deeplearning4j.nn.multilayer.MultiLayerNetwork
import processing.core.PApplet

import static extension com.sirolf2009.yggdrasil.kvasir.RenderOrderbook.*
import static extension com.sirolf2009.yggdrasil.vor.Predict.*
import grafica.GPointsArray
import me.tongfei.progressbar.ProgressBar

class SketchPrice extends PApplet {
	
	val MultiLayerNetwork net
	val TableOrderbook data
	val GPointsArray trades
	val GPointsArray tradesPredicted
	var GPlot tradesPlot
	var GPlot tradesPredictedPlot
	
	new(TableOrderbook data, MultiLayerNetwork net) {
		this.data = data
		this.net = net
		this.trades = data.getTradePointsArray(data.rowCount-1)
		this.tradesPredicted = predict()
	}
	
	override settings() {
		size(1024, 800)
	}
	
	override setup() {
		surface.resizable = true
		surface.title = this.getClass().asSubclass(this.getClass()).simpleName

		tradesPlot = new GPlot(this)
		tradesPlot.title.text = "Trades"
		tradesPlot.setOuterDim(width, height)
		tradesPlot.setPos(0, 0)
		tradesPlot.points = trades

		tradesPredictedPlot = new GPlot(this)
		tradesPredictedPlot.title.text = "Trades Predicted"
		tradesPredictedPlot.setOuterDim(width, height)
		tradesPredictedPlot.setPos(0, 0)
		tradesPredictedPlot.points = tradesPredicted
		
		val yLim = #[Math.min(tradesPlot.YLim.get(0), tradesPredictedPlot.YLim.get(0)), Math.max(tradesPlot.YLim.get(1), tradesPredictedPlot.YLim.get(1))]
		val xLim = #[Math.min(tradesPlot.XLim.get(0), tradesPredictedPlot.XLim.get(0)), Math.max(tradesPlot.XLim.get(1), tradesPredictedPlot.XLim.get(1))]
		tradesPlot.YLim = yLim
		tradesPlot.XLim = xLim
		tradesPredictedPlot.YLim = yLim
		tradesPredictedPlot.XLim = xLim
	}
	
	override draw() {
		background(255)
		tradesPlot.setOuterDim(width, height)
		tradesPredictedPlot.setOuterDim(width, height)
		
		tradesPlot => [
			beginDraw()
			drawBackground()
			drawBox()
			drawYAxis()
			drawXAxis()
			drawLines()
			endDraw()
		]
		
		tradesPredictedPlot => [
			beginDraw()
			drawPoints()
			endDraw()
		]
	}
	
	def predict() {
		val steps = data.asSteps()
		val progressBar = new ProgressBar("Predicting", steps.length).start()
		val predictions = data.asSteps.map[
			val prediction = predict(it)
			progressBar.step()
			return prediction
		].map[getTradePointsArray(it.rowCount-1)].reduce[a,b|
			a.add(b)
			return a
		]
		progressBar.stop()
		return predictions
	}
	
	def predict(TableOrderbook data) {
		net.predictMultiStepTable(data, data.rowCount-1)
	}
	
	def static asSteps(TableOrderbook data) {
		(60 ..< data.rowCount).map[
			new TableOrderbook(data.first(it))
		].toList()
	}
	
	def static create(TableOrderbook data, MultiLayerNetwork net) {
		runSketch(#[SketchPrice.name], new SketchPrice(data, net));
	}
	
	def static void main(String[] args) {
		val normalizer = new OrderbookNormaliseDiffStdDev()
		val data = TestData.orderbookRealLarge
		normalizer.accept(data)
		create(data, LoadersFile.loadNetwork("predict_100.zip"))
	}
	
}