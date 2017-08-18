package com.sirolf2009.yggdrasil.sif

import java.util.function.Consumer
import java.util.function.Function
import java.util.function.Supplier
import org.junit.Assert
import org.junit.Test
import org.apache.commons.lang3.tuple.Pair

import static extension com.sirolf2009.yggdrasil.sif.FunctionExtensions.*

class TestFunctionExtensions {
	
	public static var number = 0
	
	@Test
	def void testObjectConsumer() {
		1 -> consumer
		Assert.assertEquals(1, number)
	}
	
	@Test
	def void testSupplierConsumer() {
		supplier -> consumer
		Assert.assertEquals(2, number)
	}
	
	@Test
	def void testSupplierFunctionConsumer() {
		supplier -> timesTwo -> consumer
		Assert.assertEquals(4, number)
	}
	
	@Test
	def void testDeriveSupplier() {
		![8] -> consumer
		Assert.assertEquals(8, number)
	}
	
	@Test
	def void test2Params() {
		(![8] && ![8]) -> multiply -> consumer
		Assert.assertEquals(16, number)
	}
	
	@Test
	def void testObjectFunctionConsumer() {
		16 -> timesTwo -> consumer
		Assert.assertEquals(32, number)
	}
	
	static val supplier = new Supplier<Integer>() {
		override get() {
			return 2
		}
	}
	
	static val consumer = new Consumer<Integer>() {
		override accept(Integer t) {
			number = t 
		}
	}
	
	static val timesTwo = new Function<Integer, Integer>() {
		override apply(Integer t) {
			return t*2
		}
	}
	
	static val multiply = new Function<Pair<Integer, Integer>, Integer>() {
		override apply(Pair<Integer, Integer> t) {
			println(t.key)
			println(t.value)
			return t.key*t.value
		}
	}
	
}
