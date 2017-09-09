package com.sirolf2009.yggdrasil.sif

import com.sirolf2009.yggdrasil.freyr.model.TableOrderbook
import java.time.LocalDateTime
import java.time.temporal.ChronoUnit
import java.util.ArrayList
import java.util.Arrays
import org.nd4j.linalg.api.ndarray.INDArray
import org.nd4j.linalg.factory.Nd4j
import tech.tablesaw.api.DateTimeColumn
import tech.tablesaw.api.DoubleColumn
import tech.tablesaw.api.Table
import tech.tablesaw.columns.Column
import tech.tablesaw.util.BitmapBackedSelection
import com.sirolf2009.yggdrasil.freyr.model.OrderbookTick
import java.time.ZoneId

class TableExtensions {
	
	def static toTable(OrderbookTick tick) {
		val datetimeColumn = TableOrderbook.newDateTimeColumn()
		val lastColumn = TableOrderbook.newLastColumn()
		val boughtColumn = TableOrderbook.newBoughtColumn()
		val soldColumn = TableOrderbook.newSoldColumn()
		val bidColumns = TableOrderbook.newBidColumns()
		val askColumns = TableOrderbook.newAskColumns()
		tick => [
			datetimeColumn.append(LocalDateTime.ofInstant(datetime.toInstant(), ZoneId.of("Europe/Amsterdam")))
			lastColumn.append(lastPrice)
			boughtColumn.append(boughtVolume)
			soldColumn.append(soldVolume)
			
			bidColumns.get(0).append(bidPrice0)
			bidColumns.get(1).append(bidVolume0)
			bidColumns.get(2).append(bidPrice1)
			bidColumns.get(3).append(bidVolume1)
			bidColumns.get(4).append(bidPrice2)
			bidColumns.get(5).append(bidVolume2)
			bidColumns.get(6).append(bidPrice3)
			bidColumns.get(7).append(bidVolume3)
			bidColumns.get(8).append(bidPrice4)
			bidColumns.get(9).append(bidVolume4)
			bidColumns.get(10).append(bidPrice5)
			bidColumns.get(11).append(bidVolume5)
			bidColumns.get(12).append(bidPrice6)
			bidColumns.get(13).append(bidVolume6)
			bidColumns.get(14).append(bidPrice7)
			bidColumns.get(15).append(bidVolume7)
			bidColumns.get(16).append(bidPrice8)
			bidColumns.get(17).append(bidVolume8)
			bidColumns.get(18).append(bidPrice9)
			bidColumns.get(19).append(bidVolume9)
			bidColumns.get(20).append(bidPrice10)
			bidColumns.get(21).append(bidVolume10)
			bidColumns.get(22).append(bidPrice11)
			bidColumns.get(23).append(bidVolume11)
			bidColumns.get(24).append(bidPrice12)
			bidColumns.get(25).append(bidVolume12)
			bidColumns.get(26).append(bidPrice13)
			bidColumns.get(27).append(bidVolume13)
			bidColumns.get(28).append(bidPrice14)
			bidColumns.get(29).append(bidVolume14)
			
			askColumns.get(0).append(askPrice0)
			askColumns.get(1).append(askVolume0)
			askColumns.get(2).append(askPrice1)
			askColumns.get(3).append(askVolume1)
			askColumns.get(4).append(askPrice2)
			askColumns.get(5).append(askVolume2)
			askColumns.get(6).append(askPrice3)
			askColumns.get(7).append(askVolume3)
			askColumns.get(8).append(askPrice4)
			askColumns.get(9).append(askVolume4)
			askColumns.get(10).append(askPrice5)
			askColumns.get(11).append(askVolume5)
			askColumns.get(12).append(askPrice6)
			askColumns.get(13).append(askVolume6)
			askColumns.get(14).append(askPrice7)
			askColumns.get(15).append(askVolume7)
			askColumns.get(16).append(askPrice8)
			askColumns.get(17).append(askVolume8)
			askColumns.get(18).append(askPrice9)
			askColumns.get(19).append(askVolume9)
			askColumns.get(20).append(askPrice10)
			askColumns.get(21).append(askVolume10)
			askColumns.get(22).append(askPrice11)
			askColumns.get(23).append(askVolume11)
			askColumns.get(24).append(askPrice12)
			askColumns.get(25).append(askVolume12)
			askColumns.get(26).append(askPrice13)
			askColumns.get(27).append(askVolume13)
			askColumns.get(28).append(askPrice14)
			askColumns.get(29).append(askVolume14)
		]
		val allColumns = new ArrayList()
		allColumns += #[datetimeColumn, lastColumn, boughtColumn, soldColumn]
		allColumns += bidColumns
		allColumns += askColumns
		return new TableOrderbook("Orderbook", allColumns)
	}
	
	def static toMatrix(TableOrderbook table) {
		return Nd4j.vstack((0 ..< table.rowCount).map[table.toArray(it)].toList())
	}
	
	def static toTable(INDArray array, LocalDateTime time, String name) {
		val shape = array.shape
		if(shape.length != 2 || shape.get(1) != 63) {
			throw new IllegalArgumentException('''Not an orderbook! Expected shape [rows,63], actual shape "+«Arrays.toString(shape)»''')
		} else {
			val datetimeColumn = new DateTimeColumn("datetime")
			val columns = (0 ..< shape.get(1)).map[
				val desc = TableOrderbook.OrderbookColumns.get(it+1)
				return new DoubleColumn(desc.name)
			].toList()
			(0 ..< shape.get(0)).forEach[row|
				datetimeColumn.add(time.plus(row, ChronoUnit.SECONDS))
				(0 ..< shape.get(1)).forEach[col|
					columns.get(col).append(array.getDouble(row, col))
				]
			]
			val allColumns = new ArrayList<Column>()
			allColumns += datetimeColumn
			allColumns += columns
			return new TableOrderbook(name, allColumns)
		}
	}
	
	def static INDArray toArray(TableOrderbook table, int index) {
		val row = table.row(index)
		Nd4j.create(row.doubleColumns.map[(it as DoubleColumn).get(0)].toList())
	}
	
	def static row(TableOrderbook table, int index) {
		new TableOrderbook(table.selectWhere(index(index)))
	}
	
	def static rows(TableOrderbook table, int from, int to) {
		new TableOrderbook(table.selectWhere(range(from, to)))
	}
	
	def static index(int index) {
		val selection = new BitmapBackedSelection()
		selection.add(index)
		return selection
	}
	
	def static range(int from, int to) {
		val selection = new BitmapBackedSelection()
		selection.addRange(from, to)
		return selection
	}
	
	def static doubleColumns(Table table) {
		table.columns.filter[it instanceof DoubleColumn].map[it as DoubleColumn].toList()
	}
	
}