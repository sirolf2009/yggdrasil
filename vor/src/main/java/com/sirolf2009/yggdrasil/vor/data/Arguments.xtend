package com.sirolf2009.yggdrasil.vor.data

import com.beust.jcommander.Parameter
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.EqualsHashCode
import org.eclipse.xtend.lib.annotations.ToString

@Accessors @EqualsHashCode @ToString class Arguments {
	
	//FOLDERS
	@Parameter(names = "-n", description="The folder to save the networks in")
	var String networkFolder = "predict-net"
	
	//TRAINING
	@Parameter(names = "-h", description="The amount of hours of data")
	var int hoursOfData = 24
	@Parameter(names = "-e", description="The amount of epochs")
	var int epochs = 100
	@Parameter(names = "-s", description="The amount of steps to use before making a prediction")
	var int steps = 60 //1 minute
	@Parameter(names = "-mb", description="The size of the mini batches")
	var int minibatch = 100
	
}
