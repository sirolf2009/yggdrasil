package com.sirolf2009.yggdrasil.freyr

import com.beust.jcommander.Parameter
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.EqualsHashCode
import org.eclipse.xtend.lib.annotations.ToString

@Accessors @EqualsHashCode @ToString class Arguments {
	
	@Parameter(names = "-influxHost", description="The ip of the influxdb")
	var String influxHost = "freyr"
	@Parameter(names = "-influxPort", description="The port of the influxdb")
	var int influxPort = 8086
	@Parameter(names = "-database", description="The name of the database")
	var String database = "orderbook"
	
}