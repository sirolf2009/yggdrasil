package com.sirolf2009.yggdrasil.freyr.model

import com.datastax.driver.mapping.annotations.PartitionKey
import com.datastax.driver.mapping.annotations.Table
import java.util.Date
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.EqualsHashCode
import org.eclipse.xtend.lib.annotations.ToString

@Table(keyspace = "freyr", name = "orderbook")
@Accessors @ToString @EqualsHashCode class OrderbookTick {
	
	@PartitionKey
	private var String exchange
	private var Date datetime
	private var double lastPrice
	private var double boughtAmount
	private var double boughtVolume
	private var double soldAmount
	private var double soldVolume
	private var double bidPrice0
	private var double bidVolume0
	private var double bidPrice1
	private var double bidVolume1
	private var double bidPrice2
	private var double bidVolume2
	private var double bidPrice3
	private var double bidVolume3
	private var double bidPrice4
	private var double bidVolume4
	private var double bidPrice5
	private var double bidVolume5
	private var double bidPrice6
	private var double bidVolume6
	private var double bidPrice7
	private var double bidVolume7
	private var double bidPrice8
	private var double bidVolume8
	private var double bidPrice9
	private var double bidVolume9
	private var double bidPrice10
	private var double bidVolume10
	private var double bidPrice11
	private var double bidVolume11
	private var double bidPrice12
	private var double bidVolume12
	private var double bidPrice13
	private var double bidVolume13
	private var double bidPrice14
	private var double bidVolume14
	private var double askPrice0
	private var double askVolume0
	private var double askPrice1
	private var double askVolume1
	private var double askPrice2
	private var double askVolume2
	private var double askPrice3
	private var double askVolume3
	private var double askPrice4
	private var double askVolume4
	private var double askPrice5
	private var double askVolume5
	private var double askPrice6
	private var double askVolume6
	private var double askPrice7
	private var double askVolume7
	private var double askPrice8
	private var double askVolume8
	private var double askPrice9
	private var double askVolume9
	private var double askPrice10
	private var double askVolume10
	private var double askPrice11
	private var double askVolume11
	private var double askPrice12
	private var double askVolume12
	private var double askPrice13
	private var double askVolume13
	private var double askPrice14
	private var double askVolume14
	
	
}