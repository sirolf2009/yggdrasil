package com.sirolf2009.yggdrasil.vor;

import java.util.ArrayList;
import java.util.List;
import org.deeplearning4j.nn.multilayer.MultiLayerNetwork;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.nd4j.linalg.api.ndarray.INDArray;

@SuppressWarnings("all")
public class Predict {
  public static ArrayList<INDArray> predict(final MultiLayerNetwork net, final List<INDArray> data, final int stepsToPredict) {
    net.rnnClearPreviousState();
    INDArray lastTick = null;
    for (int i = 0; (i < ((Object[])Conversions.unwrapArray(data, Object.class)).length); i++) {
      lastTick = net.rnnTimeStep(data.get(i));
    }
    final ArrayList<INDArray> outputs = new ArrayList<INDArray>();
    for (int i = 0; (i < stepsToPredict); i++) {
      {
        lastTick = net.rnnTimeStep(lastTick);
        outputs.add(lastTick);
      }
    }
    return outputs;
  }
}
