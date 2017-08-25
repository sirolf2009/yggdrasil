package com.sirolf2009.yggdrasil.vor;

import com.sirolf2009.yggdrasil.freyr.model.TableOrderbook;
import com.sirolf2009.yggdrasil.sif.TableExtensions;
import java.util.ArrayList;
import java.util.List;
import org.deeplearning4j.nn.multilayer.MultiLayerNetwork;
import org.eclipse.xtext.xbase.lib.ExclusiveRange;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.nd4j.linalg.api.ndarray.INDArray;

@SuppressWarnings("all")
public class Predict {
  public static ArrayList<INDArray> predictMultiStep(final MultiLayerNetwork net, final TableOrderbook table, final int stepsToPredict) {
    net.rnnClearPreviousState();
    final List<INDArray> data = Predict.preparePredictData(table, 1);
    INDArray previous = IterableExtensions.<INDArray>last(data);
    for (int i = 0; (i < data.size()); i++) {
      previous = net.rnnTimeStep(data.get(i));
    }
    final ArrayList<INDArray> predictions = new ArrayList<INDArray>();
    for (int i = 0; (i < stepsToPredict); i++) {
      {
        previous = net.rnnTimeStep(previous);
        predictions.add(previous);
      }
    }
    return predictions;
  }
  
  public static List<INDArray> preparePredictData(final TableOrderbook table, final int steps) {
    int _rowCount = table.rowCount();
    int _minus = (_rowCount - (steps - 1));
    final Function1<Integer, INDArray> _function = (Integer it) -> {
      return TableExtensions.toMatrix(TableExtensions.rows(table, (it).intValue(), ((it).intValue() + steps)));
    };
    return IterableExtensions.<INDArray>toList(IterableExtensions.<Integer, INDArray>map(new ExclusiveRange(0, _minus, true), _function));
  }
}
