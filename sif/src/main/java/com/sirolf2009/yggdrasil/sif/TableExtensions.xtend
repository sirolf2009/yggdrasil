package com.sirolf2009.yggdrasil.sif

import com.sirolf2009.yggdrasil.freyr.model.TableOrderbook
import java.time.LocalDateTime
import java.util.ArrayList
import org.nd4j.linalg.api.ndarray.INDArray
import org.nd4j.linalg.factory.Nd4j
import tech.tablesaw.api.DateTimeColumn
import tech.tablesaw.api.DoubleColumn
import tech.tablesaw.api.Table
import tech.tablesaw.columns.Column
import tech.tablesaw.util.BitmapBackedSelection
import tech.tablesaw.api.ColumnType
import java.util.Arrays
import java.time.temporal.ChronoUnit

class TableExtensions {
	
	def static toTable(INDArray array, LocalDateTime time, String name) {
		val shape = array.shape //60,63
		if(shape.length != 2 || shape.get(1) != 63) {
			throw new IllegalArgumentException("Not an orderbook! Expected shape [60,63], actual shape "+Arrays.toString(shape))
		} else {
			val datetimeColumn = new DateTimeColumn("datetime")
			val columns = (0 ..< shape.get(1)).map[
				val desc = TableOrderbook.OrderbookColumns.get(it+1)
				new DoubleColumn(desc.name)
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
	
	def static INDArray rowArray(TableOrderbook table, int index) {
		val row = table.row(index)
		Nd4j.create(row.columns.filter[type != ColumnType.LOCAL_DATE_TIME].map[(it as DoubleColumn).get(0)].toList())
	}
	
	def static row(Table table, int index) {
		table.selectWhere(index(index))
	}
	
	def static rows(Table table, int from, int to) {
		table.selectWhere(range(from, to))
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
	
}