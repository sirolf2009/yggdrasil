package com.sirolf2009.yggdrasil.vor.data;

import com.sirolf2009.yggdrasil.vor.data.PrepareData;
import java.util.Collections;
import java.util.List;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.junit.Test;
import org.nd4j.linalg.api.ndarray.INDArray;

@SuppressWarnings("all")
public class TestPrepareData {
  @Test
  public void testCreatePredict() {
    try {
      final List<String> csv = Collections.<String>unmodifiableList(CollectionLiterals.<String>newArrayList("1,2,3,4", "5,6,7,8", "-1,-2,-3,-4", "-5,-6,-7,-8"));
      List<INDArray> _createDataSet2 = PrepareData.createDataSet2(csv, 1);
      String _plus = ("Output " + _createDataSet2);
      InputOutput.<String>println(_plus);
      List<INDArray> _createDataSet2_1 = PrepareData.createDataSet2(csv, 2);
      String _plus_1 = ("Output " + _createDataSet2_1);
      InputOutput.<String>println(_plus_1);
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
}
