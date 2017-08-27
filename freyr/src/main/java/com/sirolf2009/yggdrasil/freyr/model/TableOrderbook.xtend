package com.sirolf2009.yggdrasil.freyr.model

import java.util.List
import java.util.stream.Stream
import org.eclipse.xtend.lib.annotations.Data
import tech.tablesaw.api.ColumnType
import tech.tablesaw.api.DateTimeColumn
import tech.tablesaw.api.DoubleColumn
import tech.tablesaw.api.Table
import tech.tablesaw.columns.Column

import static tech.tablesaw.api.ColumnType.*
import java.util.stream.Collectors

class TableOrderbook extends Table {
	
	new(String name, Column... columns) {
		super(name, columns.validOrThrow)
	}
	new(Table table) {
		super(table.name, table.validOrThrow)
	}
	
	def DateTimeColumn getDate() {
		return dateTimeColumn("datetime") //TODO do I want this? I cannot convert to and from INDArray and keep it, also not really *that* useful for charting
	}
	
	def DoubleColumn getLast() {
		return doubleColumn("last")
	}
	
	def DoubleColumn getBought() {
		return doubleColumn("bought")
	}
	
	def DoubleColumn getSold() {
		return doubleColumn("sold")
	}
	
	def List<DoubleColumn> getBids() {
		return columns.filter[name.contains("bid")].map[it as DoubleColumn].toList()
	}
	
	def List<DoubleColumn> getBidPrices() {
		return columns.filter[name.contains("bid_price")].map[it as DoubleColumn].toList()
	}
	
	def List<DoubleColumn> getBidAmounts() {
		return columns.filter[name.contains("bid_amount")].map[it as DoubleColumn].toList()
	}
	
	def List<DoubleColumn> getAsks() {
		return columns.filter[name.contains("ask")].map[it as DoubleColumn].toList()
	}
	
	def List<DoubleColumn> getAskPrices() {
		return columns.filter[name.contains("ask_price")].map[it as DoubleColumn].toList()
	}
	
	def List<DoubleColumn> getAskAmounts() {
		return columns.filter[name.contains("ask_amount")].map[it as DoubleColumn].toList()
	}
	
	override TableOrderbook fullCopy() {
      return new TableOrderbook(super.fullCopy())
	}
	
	def private static validOrThrow(Table table) {
		return table.columns.validOrThrow()
	}
	
	def private static validOrThrow(List<Column> columns) {
		if(columns.size != OrderbookColumns.size) {
			throw new IllegalArgumentException("The table does not have the correct amount of columns. Got "+columns.size+", expected "+OrderbookColumns.size())
		} 
		columns.forEach[it, index|
			if(type != OrderbookColumns.get(index).getType()) {
				throw new IllegalArgumentException('''Column «name» at index «index» is of type «type». Expected type is «OrderbookColumns.get(index)»''')
			}
		]
		return columns
	}
	
	def static dateTimeColumn() {
		return new DateTimeColumn("datetime")
	}
	
	def static lastColumn() {
		return new DoubleColumn("last")
	}
	
	def static boughtColumn() {
		return new DoubleColumn("bought")
	}
	
	def static soldColumn() {
		return new DoubleColumn("sold")
	}
	
	def static bidColumns() {
		(0 ..< 15).toList().stream().flatMap[Stream.of(bidPriceColumn(it), bidAmountColumn(it))].collect(Collectors.toList)
	}
	
	def static askColumns() {
		(0 ..< 15).toList().stream().flatMap[Stream.of(askPriceColumn(it), askAmountColumn(it))].collect(Collectors.toList)
	}
	
	def static bidPriceColumn(int index) {
		return new DoubleColumn('''bid_price_«index»''')
	}
	
	def static bidAmountColumn(int index) {
		return new DoubleColumn('''bid_amount_«index»''')
	}
	
	def static askPriceColumn(int index) {
		return new DoubleColumn('''ask_price_«index»''')
	}
	
	def static askAmountColumn(int index) {
		return new DoubleColumn('''ask_amount_«index»''')
	}
	
	public static val OrderbookColumns = #[
			new ColumnDescriptor(LOCAL_DATE_TIME, "datetime"),
			new ColumnDescriptor(DOUBLE, "last"),
			new ColumnDescriptor(DOUBLE, "bought"),
			new ColumnDescriptor(DOUBLE, "sold"),
			new ColumnDescriptor(DOUBLE, "bid_price_0"),   
			new ColumnDescriptor(DOUBLE, "bid_amount_0"),
			new ColumnDescriptor(DOUBLE, "bid_price_1"),
			new ColumnDescriptor(DOUBLE, "bid_amount_1"),
			new ColumnDescriptor(DOUBLE, "bid_price_2"),
			new ColumnDescriptor(DOUBLE, "bid_amount_2"),
			new ColumnDescriptor(DOUBLE, "bid_price_3"),
			new ColumnDescriptor(DOUBLE, "bid_amount_3"),
			new ColumnDescriptor(DOUBLE, "bid_price_4"),
			new ColumnDescriptor(DOUBLE, "bid_amount_4"),
			new ColumnDescriptor(DOUBLE, "bid_price_5"),
			new ColumnDescriptor(DOUBLE, "bid_amount_5"),
			new ColumnDescriptor(DOUBLE, "bid_price_6"),
			new ColumnDescriptor(DOUBLE, "bid_amount_6"),
			new ColumnDescriptor(DOUBLE, "bid_price_7"),
			new ColumnDescriptor(DOUBLE, "bid_amount_7"),
			new ColumnDescriptor(DOUBLE, "bid_price_8"),
			new ColumnDescriptor(DOUBLE, "bid_amount_8"),
			new ColumnDescriptor(DOUBLE, "bid_price_9"),
			new ColumnDescriptor(DOUBLE, "bid_amount_9"),
			new ColumnDescriptor(DOUBLE, "bid_price_10"),
			new ColumnDescriptor(DOUBLE, "bid_amount_10"),
			new ColumnDescriptor(DOUBLE, "bid_price_11"),  
			new ColumnDescriptor(DOUBLE, "bid_amount_11"), 
			new ColumnDescriptor(DOUBLE, "bid_price_12"),
			new ColumnDescriptor(DOUBLE, "bid_amount_12"),
			new ColumnDescriptor(DOUBLE, "bid_price_13"),
			new ColumnDescriptor(DOUBLE, "bid_amount_13"),
			new ColumnDescriptor(DOUBLE, "bid_price_14"),
			new ColumnDescriptor(DOUBLE, "bid_amount_14"),
			new ColumnDescriptor(DOUBLE, "ask_price_0"),
			new ColumnDescriptor(DOUBLE, "ask_amount_0"),
			new ColumnDescriptor(DOUBLE, "ask_price_1"),
			new ColumnDescriptor(DOUBLE, "ask_amount_1"),
			new ColumnDescriptor(DOUBLE, "ask_price_2"),
			new ColumnDescriptor(DOUBLE, "ask_amount_2"),
			new ColumnDescriptor(DOUBLE, "ask_price_3"),
			new ColumnDescriptor(DOUBLE, "ask_amount_3"),
			new ColumnDescriptor(DOUBLE, "ask_price_4"),
			new ColumnDescriptor(DOUBLE, "ask_amount_4"),
			new ColumnDescriptor(DOUBLE, "ask_price_5"),
			new ColumnDescriptor(DOUBLE, "ask_amount_5"),
			new ColumnDescriptor(DOUBLE, "ask_price_6"),
			new ColumnDescriptor(DOUBLE, "ask_amount_6"),
			new ColumnDescriptor(DOUBLE, "ask_price_7"),
			new ColumnDescriptor(DOUBLE, "ask_amount_7"),
			new ColumnDescriptor(DOUBLE, "ask_price_8"),
			new ColumnDescriptor(DOUBLE, "ask_amount_8"),
			new ColumnDescriptor(DOUBLE, "ask_price_9"),
			new ColumnDescriptor(DOUBLE, "ask_amount_9"),
			new ColumnDescriptor(DOUBLE, "ask_price_10"),
			new ColumnDescriptor(DOUBLE, "ask_amount_10"),
			new ColumnDescriptor(DOUBLE, "ask_price_11"),
			new ColumnDescriptor(DOUBLE, "ask_amount_11"),
			new ColumnDescriptor(DOUBLE, "ask_price_12"),
			new ColumnDescriptor(DOUBLE, "ask_amount_12"),
			new ColumnDescriptor(DOUBLE, "ask_price_13"),
			new ColumnDescriptor(DOUBLE, "ask_amount_13"),
			new ColumnDescriptor(DOUBLE, "ask_price_14"),
			new ColumnDescriptor(DOUBLE, "ask_amount_14")
		]
		
		@Data public static class ColumnDescriptor {
			ColumnType type
			String name
		} 
	
}