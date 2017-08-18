package com.sirolf2009.yggdrasil.sif

import java.util.List
import java.util.stream.Stream
import java.util.stream.Collectors

class StreamExtensions {

	def public static <A> List<A> collect(Stream<A> stream) {
		stream.collect(Collectors.toList())
	}

}