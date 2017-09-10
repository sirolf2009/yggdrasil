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
  
  public static Function<List<List<Double>>, List<String>> matrixToCSV = ((Function<List<List<Double>>, List<String>>) (List<List<Double>> it) -> {
    List<String> _xblockexpression = null;
    {
      CSV.log.info("Converting to csv");
      final Function1<List<Double>, String> _function = (List<Double> it_1) -> {
        final Function1<Double, String> _function_1 = (Double it_2) -> {
          return (it_2 + "");
        };
        final Function2<String, String, String> _function_2 = (String a, String b) -> {
          return ((a + ",") + b);
        };
        return IterableExtensions.<String>reduce(ListExtensions.<Double, String>map(it_1, _function_1), _function_2);
      };
      _xblockexpression = ListExtensions.<List<Double>, String>map(it, _function);
    }
    return _xblockexpression;
  });
  
  public static Function<List<String>, String> joinAsLines = ((Function<List<String>, String>) (List<String> it) -> {
    String _xblockexpression = null;
    {
      CSV.log.info("Joining lines");
      final BinaryOperator<String> _function = (String a, String b) -> {
        return ((a + "\n") + b);
      };
      _xblockexpression = it.stream().reduce(_function).get();
    }
    return _xblockexpression;
  });
}
