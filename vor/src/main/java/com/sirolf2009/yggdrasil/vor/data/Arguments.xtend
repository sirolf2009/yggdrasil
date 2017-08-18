package com.sirolf2009.yggdrasil.vor.data

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
	@Parameter(names = "-n", description="The amount of datapoints to download")
	var int datapoints = 50000
	@Parameter(names = "-b", description="The amount of datapoints to download per batch")
	var int datapointsBatch = 5000
	@Parameter(names = "-np", description="The amount of datapoints to download for predictions")
	var int datapointsPrediction = 5000
	
}
