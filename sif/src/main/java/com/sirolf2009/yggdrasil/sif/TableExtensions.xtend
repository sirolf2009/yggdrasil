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

class TableExtensions {
	
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