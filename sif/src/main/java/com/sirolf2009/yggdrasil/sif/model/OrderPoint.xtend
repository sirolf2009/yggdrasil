package com.sirolf2009.yggdrasil.sif.model

import java.util.Date
import org.eclipse.xtend.lib.annotations.Data

@Data
class OrderPoint {
	
	val Date timestamp
	val String side
	val int index
	val double value
	val double amount
	val double bought
	val double sold
	
}
