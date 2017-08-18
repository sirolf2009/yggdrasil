package com.sirolf2009.yggdrasil.sif.transmutation;

import com.sirolf2009.yggdrasil.sif.StreamExtensions;
import java.util.List;
import java.util.function.Function;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.ExclusiveRange;
import org.eclipse.xtext.xbase.lib.IntegerRange;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.nd4j.linalg.api.ndarray.INDArray;
import org.nd4j.linalg.factory.Nd4j;

@SuppressWarnings("all")
public class INDArrays {
  private final static Logger log = LogManager.getLogger();
  
  public static Function<List<List<Double>>, List<INDArray>> createRNNDataSet(final int numberOfTimesteps) {
    final Function<List<List<Double>>, List<INDArray>> _function = (List<List<Double>> it) -> {
      List<INDArray> _xblockexpression = null;
      {
        INDArrays.log.info("Creating dataset");
        int _size = it.size();
        int _minus = (_size - numberOfTimesteps);
        final Function<Integer, INDArray> _function_1 = (Integer example) -> {
          final Function<Integer, double[]> _function_2 = (Integer step) -> {
            List<Double> _get = it.get(((example).intValue() + (step).intValue()));
            return ((double[]) ((double[])Conversions.unwrapArray(_get, double.class)));
          };
          List<double[]> _collect = StreamExtensions.<double[]>collect(IterableExtensions.<Integer>toList(new IntegerRange(0, numberOfTimesteps)).stream().<double[]>map(_function_2));
          return Nd4j.create(((double[][]) ((double[][])Conversions.unwrapArray(_collect, double[].class))), 'c');
        };
        _xblockexpression = StreamExtensions.<INDArray>collect(IterableExtensions.<Integer>toList(new ExclusiveRange(0, _minus, true)).parallelStream().<INDArray>map(_function_1));
      }
      return _xblockexpression;
    };
    return _function;
  }
}
