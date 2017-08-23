package com.sirolf2009.yggdrasil.sif

import tech.tablesaw.api.Table

import static tech.tablesaw.api.ColumnType.*

class TestData {

	def static getOrderbookSimple() {
		Table.createFromCsv(TestData.classLoader.getResourceAsStream("orderbook-simple.csv"), "Orderbook-Simple", OrderbookColumns, true)
	}

	def static getOrderbookRows() {
		Table.createFromCsv(TestData.classLoader.getResourceAsStream("orderbook-rows.csv"), "Orderbook-Rows", OrderbookColumns, true)
	}
	
	public static val OrderbookColumns = #[
			LOCAL_DATE_TIME, // 0     datetime      
			DOUBLE, // 1     bid_price_0   
			DOUBLE, // 2     bid_amount_0  
			DOUBLE, // 3     bid_price_1   
			DOUBLE, // 4     bid_amount_1  
			DOUBLE, // 5     bid_price_2   
			DOUBLE, // 6     bid_amount_2  
			DOUBLE, // 7     bid_price_3   
			DOUBLE, // 8     bid_amount_3  
			DOUBLE, // 9     bid_price_4   
			DOUBLE, // 10    bid_amount_4  
			DOUBLE, // 11    bid_price_5   
			DOUBLE, // 12    bid_amount_5  
			DOUBLE, // 13    bid_price_6   
			DOUBLE, // 14    bid_amount_6  
			DOUBLE, // 15    bid_price_7   
			DOUBLE, // 16    bid_amount_7  
			DOUBLE, // 17    bid_price_8   
			DOUBLE, // 18    bid_amount_8  
			DOUBLE, // 19    bid_price_9   
			DOUBLE, // 20    bid_amount_9  
			DOUBLE, // 21    bid_price_10  
			DOUBLE, // 22    bid_amount_10 
			DOUBLE, // 23    bid_price_11  
			DOUBLE, // 24    bid_amount_11 
			DOUBLE, // 25    bid_price_12  
			DOUBLE, // 26    bid_amount_12 
			DOUBLE, // 27    bid_price_13  
			DOUBLE, // 28    bid_amount_13 
			DOUBLE, // 29    bid_price_14  
			DOUBLE, // 30    bid_amount_14 
			DOUBLE, // 31    ask_price_0  
			DOUBLE, // 32    ask_amount_0 
			DOUBLE, // 33    ask_price_1   
			DOUBLE, // 34    ask_amount_1  
			DOUBLE, // 35    ask_price_2   
			DOUBLE, // 36    ask_amount_2  
			DOUBLE, // 37    ask_price_3   
			DOUBLE, // 38    ask_amount_3  
			DOUBLE, // 39    ask_price_4   
			DOUBLE, // 40    ask_amount_4  
			DOUBLE, // 41    ask_price_5   
			DOUBLE, // 42    ask_amount_5  
			DOUBLE, // 43    ask_price_6   
			DOUBLE, // 44    ask_amount_6  
			DOUBLE, // 45    ask_price_7   
			DOUBLE, // 46    ask_amount_7  
			DOUBLE, // 47    ask_price_8   
			DOUBLE, // 48    ask_amount_8  
			DOUBLE, // 49    ask_price_9   
			DOUBLE, // 50    ask_amount_9  
			DOUBLE, // 51    ask_price_10  
			DOUBLE, // 52    ask_amount_10 
			DOUBLE, // 53    ask_price_11  
			DOUBLE, // 54    ask_amount_11 
			DOUBLE, // 55    ask_price_12  
			DOUBLE, // 56    ask_amount_12 
			DOUBLE, // 57    ask_price_13  
			DOUBLE, // 58    ask_amount_13 
			DOUBLE, // 59    ask_price_14
			DOUBLE  // 60    ask_amount_14
		]

}
