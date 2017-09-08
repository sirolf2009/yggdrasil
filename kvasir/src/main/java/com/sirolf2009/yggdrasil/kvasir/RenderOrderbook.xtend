package com.sirolf2009.yggdrasil.kvasir

import com.sirolf2009.yggdrasil.freyr.model.TableOrderbook
import grafica.GPlot
import grafica.GPoint
import grafica.GPointsArray
import tech.tablesaw.api.DoubleColumn

class RenderOrderbook {

	def static renderTrades(TableOrderbook data, GPlot plot, int zoom) {
		plot.points = data.getTradePointsArray(zoom)
		plot => [
			beginDraw()
			drawBackground()
			drawBox()
			drawYAxis()
			drawXAxis()
			drawTitle()
			drawLines()
			endDraw()
		]
	}
	
	def static getTradePointsArray(TableOrderbook data, int zoom) {
		val points = new GPointsArray(zoom)
		(0 ..< Math.min(data.rowCount - 1, zoom)).forEach [
			points.add(new GPoint(zoom - it, data.getLast().get(data.rowCount - 1 - it).floatValue, "last"))
		]
		return points
	}

	def static renderOrderbook(TableOrderbook data, GPlot plot, int zoom, int take) {
		plot.points = data.getOrderbookPointsArray(zoom, take)
		plot => [
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
	
	def static getOrderbookPointsArray(TableOrderbook data, int zoom, int take) {
		val points = new GPointsArray(zoom * take * 2)
		(0 ..< Math.min(data.rowCount - 1, zoom)).forEach [ indexInScreen |
			data.prices.forEach [ it, indexInFrame |
				val value = Math.abs((it as DoubleColumn).get(data.rowCount - 1 - indexInScreen).floatValue()) * if(name.contains("bid")) -1 else 1
				points.add(new GPoint(zoom - indexInScreen, value, name))
			]
		]
		return points
	}

}
