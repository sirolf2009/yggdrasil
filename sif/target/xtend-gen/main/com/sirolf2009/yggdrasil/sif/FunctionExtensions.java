package com.sirolf2009.yggdrasil.sif;

import java.util.function.Consumer;
import java.util.function.Function;
import java.util.function.Supplier;
import org.apache.commons.lang3.tuple.Pair;
import org.eclipse.xtext.xbase.lib.Functions.Function1;

@SuppressWarnings("all")
public class FunctionExtensions {
  public static <A extends Object> void operator_mappedTo(final Supplier<A> supplier, final Consumer<A> consumer) {
    consumer.accept(supplier.get());
  }
  
  public static <A extends Object, B extends Object> Supplier<B> operator_mappedTo(final Supplier<A> supplier, final Function<A, B> function) {
    final Supplier<B> _function = () -> {
      return function.apply(supplier.get());
    };
    return _function;
  }
  
  public static <A extends Object, B extends Object> Supplier<B> operator_mappedTo(final A object, final Function<A, B> function) {
    final Supplier<B> _function = () -> {
      return function.apply(object);
    };
    return _function;
  }
  
  public static <A extends Object> void operator_mappedTo(final A object, final Consumer<A> consumer) {
    consumer.accept(object);
  }
  
  public static <A extends Object> Supplier<A> operator_not(final Function1<? super Object, ? extends A> supplier) {
    final Supplier<A> _function = () -> {
      return supplier.apply(null);
    };
    return _function;
  }
  
  public static <A extends Object, B extends Object> Supplier<Pair<A, B>> operator_and(final Supplier<A> a, final Supplier<B> b) {
    final Supplier<Pair<A, B>> _function = () -> {
      return Pair.<A, B>of(a.get(), b.get());
    };
    return _function;
  }
}
