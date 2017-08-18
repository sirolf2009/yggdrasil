package com.sirolf2009.yggdrasil.sif

import java.util.function.Consumer
import java.util.function.Function
import java.util.function.Supplier
import org.apache.commons.lang3.tuple.Pair

class FunctionExtensions {

	def static <A> void ->(Supplier<A> supplier, Consumer<A> consumer) {
		consumer.accept(supplier.get())
	}

	def static <A, B> Supplier<B> ->(Supplier<A> supplier, Function<A, B> function) {
		return [function.apply(supplier.get())]
	}

	def static <A, B> Supplier<B> ->(A object, Function<A, B> function) {
		return [function.apply(object)]
	}

	def static <A> void ->(A object, Consumer<A> consumer) {
		consumer.accept(object)
	}

	def static <A> Supplier<A> !((Object) => A supplier) {
		return [supplier.apply(null)]
	}
	
	def static <A, B> Supplier<Pair<A, B>> &&(Supplier<A> a, Supplier<B> b) {
		return [Pair.of(a.get(), b.get())]
	}
	
}
