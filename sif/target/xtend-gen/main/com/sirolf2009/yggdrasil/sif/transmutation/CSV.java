package com.sirolf2009.yggdrasil.sif.transmutation;

import java.util.List;
import java.util.function.BinaryOperator;
import java.util.function.Function;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.Functions.Function2;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.ListExtensions;

@SuppressWarnings("all")
public class CSV {
  private final static Logger log = LogManager.getLogger();
  
  public static Function<List<List<Double>>, List<String>> matrixToCSV = new Function<List<List<Double>>, List<String>>() {
    @Override
    public List<String> apply(final List<List<Double>> it) {
      List<String> _xblockexpression = null;
      {
        CSV.log.info("Converting to csv");
        final Function1<List<Double>, String> _function = new Function1<List<Double>, String>() {
          @Override
          public String apply(final List<Double> it) {
            final Function1<Double, String> _function = new Function1<Double, String>() {
              @Override
              public String apply(final Double it) {
                return (it + "");
              }
            };
            final Function2<String, String, String> _function_1 = new Function2<String, String, String>() {
              @Override
              public String apply(final String a, final String b) {
                return ((a + ",") + b);
              }
            };
            return IterableExtensions.<String>reduce(ListExtensions.<Double, String>map(it, _function), _function_1);
          }
        };
        _xblockexpression = ListExtensions.<List<Double>, String>map(it, _function);
      }
      return _xblockexpression;
    }
  };
  
  public static Function<List<String>, String> joinAsLines = new Function<List<String>, String>() {
    @Override
    public String apply(final List<String> it) {
      String _xblockexpression = null;
      {
        CSV.log.info("Joining lines");
        final BinaryOperator<String> _function = new BinaryOperator<String>() {
          @Override
          public String apply(final String a, final String b) {
            return ((a + "\n") + b);
          }
        };
        _xblockexpression = it.stream().reduce(_function).get();
      }
      return _xblockexpression;
    }
  };
}
