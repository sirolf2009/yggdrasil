package com.sirolf2009.yggdrasil.freyr.model

import java.util.List
import tech.tablesaw.api.DateTimeColumn
import tech.tablesaw.api.DoubleColumn
import tech.tablesaw.api.Table
import tech.tablesaw.columns.Column

import static tech.tablesaw.api.ColumnType.*

class TableOrderbook extends Table {
	
	new(String name, Column... columns) {
		super(name, columns.validOrThrow)
	}
	new(Table table) {
		super(table.name, table.validOrThrow)
	}
	
	def DateTimeColumn getDate() {
		return column(0) as DateTimeColumn
	}
	
	def DoubleColumn getBought() {
		return column(1) as DoubleColumn
	}
	
	def DoubleColumn getSold() {
		return column(2) as DoubleColumn
	}
	
	def List<DoubleColumn> getBids() {
		return (3 ..< 33).map[column(it) as DoubleColumn].toList()
	}
	
	def List<DoubleColumn> getBidPrices() {
		return (3 ..< 33).filter[it % 2 == 1].map[column(it) as DoubleColumn].toList() //prices are uneven indices
	}
	
	def List<DoubleColumn> getBidAmounts() {
		return (3 ..< 33).filter[it % 2 == 0].map[column(it) as DoubleColumn].toList() //amounts are even indices
	}
	
	def List<DoubleColumn> getAsks() {
		return (33 ..< 63).map[column(it) as DoubleColumn].toList()
	}
	
	def List<DoubleColumn> getAskPrices() {
		return (33 ..< 63).filter[it % 2 == 1].map[column(it) as DoubleColumn].toList() //prices are uneven indices
	}
	
	def List<DoubleColumn> getAskAmounts() {
		return (33 ..< 63).filter[it % 2 == 0].map[column(it) as DoubleColumn].toList() //amounts are even indices
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
			if(type != OrderbookColumns.get(index)) {
				throw new IllegalArgumentException('''Column «name» at index «index» is of type «type». Expected type is «OrderbookColumns.get(index)»''')
			}
		]
		return columns
	}
	
	public static val OrderbookColumns = #[
			LOCAL_DATE_TIME, // 0     datetime   
			DOUBLE, // 1     bought
			DOUBLE, // 2     sold
			DOUBLE, // 3     bid_price_0   
			DOUBLE, // 4     bid_amount_0  
			DOUBLE, // 5     bid_price_1   
			DOUBLE, // 6     bid_amount_1  
			DOUBLE, // 7     bid_price_2   
			DOUBLE, // 8     bid_amount_2  
			DOUBLE, // 9     bid_price_3   
			DOUBLE, // 10    bid_amount_3  
			DOUBLE, // 11    bid_price_4   
			DOUBLE, // 12    bid_amount_4  
			DOUBLE, // 13    bid_price_5   
			DOUBLE, // 14    bid_amount_5  
			DOUBLE, // 15    bid_price_6   
			DOUBLE, // 16    bid_amount_6  
			DOUBLE, // 17    bid_price_7   
			DOUBLE, // 18    bid_amount_7  
			DOUBLE, // 19    bid_price_8   
			DOUBLE, // 20    bid_amount_8  
			DOUBLE, // 21    bid_price_9   
			DOUBLE, // 22    bid_amount_9  
			DOUBLE, // 23    bid_price_10  
			DOUBLE, // 24    bid_amount_10 
			DOUBLE, // 25    bid_price_11  
			DOUBLE, // 26    bid_amount_11 
			DOUBLE, // 27    bid_price_12  
			DOUBLE, // 28    bid_amount_12 
			DOUBLE, // 29    bid_price_13  
			DOUBLE, // 30    bid_amount_13 
			DOUBLE, // 31    bid_price_14  
			DOUBLE, // 32    bid_amount_14 
			DOUBLE, // 33    ask_price_0  
			DOUBLE, // 34    ask_amount_0 
			DOUBLE, // 35    ask_price_1   
			DOUBLE, // 36    ask_amount_1  
			DOUBLE, // 37    ask_price_2   
			DOUBLE, // 38    ask_amount_2  
			DOUBLE, // 39    ask_price_3   
			DOUBLE, // 40    ask_amount_3  
			DOUBLE, // 41    ask_price_4   
			DOUBLE, // 42    ask_amount_4  
			DOUBLE, // 43    ask_price_5   
			DOUBLE, // 44    ask_amount_5  
			DOUBLE, // 45    ask_price_6   
			DOUBLE, // 46    ask_amount_6  
			DOUBLE, // 47    ask_price_7   
			DOUBLE, // 48    ask_amount_7  
			DOUBLE, // 49    ask_price_8   
			DOUBLE, // 50    ask_amount_8  
			DOUBLE, // 51    ask_price_9   
			DOUBLE, // 52    ask_amount_9  
			DOUBLE, // 53    ask_price_10  
			DOUBLE, // 54    ask_amount_10 
			DOUBLE, // 55    ask_price_11  
			DOUBLE, // 56    ask_amount_11 
			DOUBLE, // 57    ask_price_12  
			DOUBLE, // 58    ask_amount_12 
			DOUBLE, // 59    ask_price_13  
			DOUBLE, // 60    ask_amount_13 
			DOUBLE, // 61    ask_price_14
			DOUBLE  // 62    ask_amount_14
		]
	
}