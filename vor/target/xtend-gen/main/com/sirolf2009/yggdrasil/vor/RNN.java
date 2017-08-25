package com.sirolf2009.yggdrasil.vor;

import java.util.function.Supplier;
import org.deeplearning4j.nn.api.OptimizationAlgorithm;
import org.deeplearning4j.nn.conf.MultiLayerConfiguration;
import org.deeplearning4j.nn.conf.NeuralNetConfiguration;
import org.deeplearning4j.nn.conf.Updater;
import org.deeplearning4j.nn.conf.layers.GravesLSTM;
import org.deeplearning4j.nn.conf.layers.RnnOutputLayer;
import org.deeplearning4j.nn.multilayer.MultiLayerNetwork;
import org.deeplearning4j.nn.weights.WeightInit;
import org.eclipse.xtend.lib.annotations.Data;
import org.eclipse.xtext.xbase.lib.ObjectExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.eclipse.xtext.xbase.lib.Pure;
import org.eclipse.xtext.xbase.lib.util.ToStringBuilder;
import org.nd4j.linalg.activations.Activation;
import org.nd4j.linalg.lossfunctions.LossFunctions;

@Data
@SuppressWarnings("all")
public class RNN implements Supplier<MultiLayerNetwork> {
  private final int numOfVariables;
  
  @Override
  public MultiLayerNetwork get() {
    NeuralNetConfiguration.Builder _builder = new NeuralNetConfiguration.Builder();
    final Procedure1<NeuralNetConfiguration.Builder> _function = (NeuralNetConfiguration.Builder it) -> {
      it.setSeed(123);
      it.setOptimizationAlgo(OptimizationAlgorithm.STOCHASTIC_GRADIENT_DESCENT);
      it.iterations(1);
      it.setWeightInit(WeightInit.XAVIER);
      it.setUpdater(Updater.NESTEROVS);
      it.setLearningRate(0.1);
      it.l2(0.001);
      it.setUseRegularization(true);
    };
    final NeuralNetConfiguration.Builder builder = ObjectExtensions.<NeuralNetConfiguration.Builder>operator_doubleArrow(_builder, _function);
    NeuralNetConfiguration.ListBuilder _list = builder.list();
    final Procedure1<NeuralNetConfiguration.ListBuilder> _function_1 = (NeuralNetConfiguration.ListBuilder it) -> {
      it.layer(0, new GravesLSTM.Builder().rmsDecay(0.95).activation(Activation.TANH).updater(Updater.RMSPROP).nIn(this.numOfVariables).nOut((this.numOfVariables * 3)).build());
      it.layer(1, new RnnOutputLayer.Builder(LossFunctions.LossFunction.MSE).momentum(0.9).activation(Activation.IDENTITY).nIn((this.numOfVariables * 3)).nOut(this.numOfVariables).build());
    };
    final NeuralNetConfiguration.ListBuilder config = ObjectExtensions.<NeuralNetConfiguration.ListBuilder>operator_doubleArrow(_list, _function_1);
    MultiLayerConfiguration _build = config.build();
    final MultiLayerNetwork net = new MultiLayerNetwork(_build);
    net.init();
    return net;
  }
  
  public RNN(final int numOfVariables) {
    super();
    this.numOfVariables = numOfVariables;
  }
  
  @Override
  @Pure
  public int hashCode() {
    final int prime = 31;
    int result = 1;
    result = prime * result + this.numOfVariables;
    return result;
  }
  
  @Override
  @Pure
  public boolean equals(final Object obj) {
    if (this == obj)
      return true;
    if (obj == null)
      return false;
    if (getClass() != obj.getClass())
      return false;
    RNN other = (RNN) obj;
    if (other.numOfVariables != this.numOfVariables)
      return false;
    return true;
  }
  
  @Override
  @Pure
  public String toString() {
    ToStringBuilder b = new ToStringBuilder(this);
    b.add("numOfVariables", this.numOfVariables);
    return b.toString();
  }
  
  @Pure
  public int getNumOfVariables() {
    return this.numOfVariables;
  }
}
