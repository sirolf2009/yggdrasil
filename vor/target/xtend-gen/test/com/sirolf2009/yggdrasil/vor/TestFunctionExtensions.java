package com.sirolf2009.yggdrasil.vor;

import com.sirolf2009.yggdrasil.vor.FunctionExtensions;
import java.util.function.Consumer;
import java.util.function.Function;
import java.util.function.Supplier;
import org.apache.commons.lang3.tuple.Pair;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.junit.Assert;
import org.junit.Test;

@SuppressWarnings("all")
public class TestFunctionExtensions {
  public static int number = 0;
  
  @Test
  public void testObjectConsumer() {
    FunctionExtensions.<Integer>operator_mappedTo(
      Integer.valueOf(1), TestFunctionExtensions.consumer);
    Assert.assertEquals(1, TestFunctionExtensions.number);
  }
  
  @Test
  public void testSupplierConsumer() {
    FunctionExtensions.<Integer>operator_mappedTo(
      TestFunctionExtensions.supplier, TestFunctionExtensions.consumer);
    Assert.assertEquals(2, TestFunctionExtensions.number);
  }
  
  @Test
  public void testSupplierFunctionConsumer() {
    Supplier<Integer> _mappedTo = FunctionExtensions.<Integer, Integer>operator_mappedTo(
      TestFunctionExtensions.supplier, TestFunctionExtensions.timesTwo);
    FunctionExtensions.<Integer>operator_mappedTo(_mappedTo, TestFunctionExtensions.consumer);
    Assert.assertEquals(4, TestFunctionExtensions.number);
  }
  
  @Test
  public void testDeriveSupplier() {
    final Function1<Object, Integer> _function = (Object it) -> {
      return Integer.valueOf(8);
    };
    Supplier<Integer> _not = FunctionExtensions.<Integer>operator_not(_function);
    FunctionExtensions.<Integer>operator_mappedTo(_not, TestFunctionExtensions.consumer);
    Assert.assertEquals(8, TestFunctionExtensions.number);
  }
  
  @Test
  public void test2Params() {
    final Function1<Object, Integer> _function = (Object it) -> {
      return Integer.valueOf(8);
    };
    Supplier<Integer> _not = FunctionExtensions.<Integer>operator_not(_function);
    final Function1<Object, Integer> _function_1 = (Object it) -> {
      return Integer.valueOf(8);
    };
    Supplier<Integer> _not_1 = FunctionExtensions.<Integer>operator_not(_function_1);
    Supplier<Pair<Integer, Integer>> _and = FunctionExtensions.<Integer, Integer>operator_and(_not, _not_1);
    Supplier<Integer> _mappedTo = FunctionExtensions.<Pair<Integer, Integer>, Integer>operator_mappedTo(_and, TestFunctionExtensions.multiply);
    FunctionExtensions.<Integer>operator_mappedTo(_mappedTo, TestFunctionExtensions.consumer);
    Assert.assertEquals(16, TestFunctionExtensions.number);
  }
  
  @Test
  public void testObjectFunctionConsumer() {
    Supplier<Integer> _mappedTo = FunctionExtensions.<Integer, Integer>operator_mappedTo(
      Integer.valueOf(16), TestFunctionExtensions.timesTwo);
    FunctionExtensions.<Integer>operator_mappedTo(_mappedTo, TestFunctionExtensions.consumer);
    Assert.assertEquals(32, TestFunctionExtensions.number);
  }
  
  private final static Supplier<Integer> supplier = new Supplier<Integer>() {
    @Override
    public Integer get() {
      return Integer.valueOf(2);
    }
  };
  
  private final static Consumer<Integer> consumer = new Consumer<Integer>() {
    @Override
    public void accept(final Integer t) {
      TestFunctionExtensions.number = (t).intValue();
    }
  };
  
  private final static Function<Integer, Integer> timesTwo = new Function<Integer, Integer>() {
    @Override
    public Integer apply(final Integer t) {
      return Integer.valueOf(((t).intValue() * 2));
    }
  };
  
  private final static Function<Pair<Integer, Integer>, Integer> multiply = new Function<Pair<Integer, Integer>, Integer>() {
    @Override
    public Integer apply(final Pair<Integer, Integer> t) {
      InputOutput.<Integer>println(t.getKey());
      InputOutput.<Integer>println(t.getValue());
      Integer _key = t.getKey();
      Integer _value = t.getValue();
      return Integer.valueOf(((_key).intValue() * (_value).intValue()));
    }
  };
}
