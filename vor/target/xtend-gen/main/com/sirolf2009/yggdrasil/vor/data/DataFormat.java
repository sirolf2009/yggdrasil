package com.sirolf2009.yggdrasil.vor.data;

import java.io.File;
import org.eclipse.xtend.lib.annotations.Data;
import org.eclipse.xtext.xbase.lib.Pure;
import org.eclipse.xtext.xbase.lib.util.ToStringBuilder;

@Data
@SuppressWarnings("all")
public class DataFormat {
  private final int trainSize;
  
  private final int testSize;
  
  private final int numberOfTimesteps;
  
  private final int numOfVariables;
  
  private final int miniBatchSize;
  
  private final File baseDir;
  
  private final File featuresDirTrain;
  
  private final File labelsDirTrain;
  
  private final File featuresDirTest;
  
  private final File labelsDirTest;
  
  public DataFormat(final int trainSize, final int testSize, final int numberOfTimesteps, final int numOfVariables, final int miniBatchSize, final File baseDir, final File featuresDirTrain, final File labelsDirTrain, final File featuresDirTest, final File labelsDirTest) {
    super();
    this.trainSize = trainSize;
    this.testSize = testSize;
    this.numberOfTimesteps = numberOfTimesteps;
    this.numOfVariables = numOfVariables;
    this.miniBatchSize = miniBatchSize;
    this.baseDir = baseDir;
    this.featuresDirTrain = featuresDirTrain;
    this.labelsDirTrain = labelsDirTrain;
    this.featuresDirTest = featuresDirTest;
    this.labelsDirTest = labelsDirTest;
  }
  
  @Override
  @Pure
  public int hashCode() {
    final int prime = 31;
    int result = 1;
    result = prime * result + this.trainSize;
    result = prime * result + this.testSize;
    result = prime * result + this.numberOfTimesteps;
    result = prime * result + this.numOfVariables;
    result = prime * result + this.miniBatchSize;
    result = prime * result + ((this.baseDir== null) ? 0 : this.baseDir.hashCode());
    result = prime * result + ((this.featuresDirTrain== null) ? 0 : this.featuresDirTrain.hashCode());
    result = prime * result + ((this.labelsDirTrain== null) ? 0 : this.labelsDirTrain.hashCode());
    result = prime * result + ((this.featuresDirTest== null) ? 0 : this.featuresDirTest.hashCode());
    result = prime * result + ((this.labelsDirTest== null) ? 0 : this.labelsDirTest.hashCode());
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
    DataFormat other = (DataFormat) obj;
    if (other.trainSize != this.trainSize)
      return false;
    if (other.testSize != this.testSize)
      return false;
    if (other.numberOfTimesteps != this.numberOfTimesteps)
      return false;
    if (other.numOfVariables != this.numOfVariables)
      return false;
    if (other.miniBatchSize != this.miniBatchSize)
      return false;
    if (this.baseDir == null) {
      if (other.baseDir != null)
        return false;
    } else if (!this.baseDir.equals(other.baseDir))
      return false;
    if (this.featuresDirTrain == null) {
      if (other.featuresDirTrain != null)
        return false;
    } else if (!this.featuresDirTrain.equals(other.featuresDirTrain))
      return false;
    if (this.labelsDirTrain == null) {
      if (other.labelsDirTrain != null)
        return false;
    } else if (!this.labelsDirTrain.equals(other.labelsDirTrain))
      return false;
    if (this.featuresDirTest == null) {
      if (other.featuresDirTest != null)
        return false;
    } else if (!this.featuresDirTest.equals(other.featuresDirTest))
      return false;
    if (this.labelsDirTest == null) {
      if (other.labelsDirTest != null)
        return false;
    } else if (!this.labelsDirTest.equals(other.labelsDirTest))
      return false;
    return true;
  }
  
  @Override
  @Pure
  public String toString() {
    ToStringBuilder b = new ToStringBuilder(this);
    b.add("trainSize", this.trainSize);
    b.add("testSize", this.testSize);
    b.add("numberOfTimesteps", this.numberOfTimesteps);
    b.add("numOfVariables", this.numOfVariables);
    b.add("miniBatchSize", this.miniBatchSize);
    b.add("baseDir", this.baseDir);
    b.add("featuresDirTrain", this.featuresDirTrain);
    b.add("labelsDirTrain", this.labelsDirTrain);
    b.add("featuresDirTest", this.featuresDirTest);
    b.add("labelsDirTest", this.labelsDirTest);
    return b.toString();
  }
  
  @Pure
  public int getTrainSize() {
    return this.trainSize;
  }
  
  @Pure
  public int getTestSize() {
    return this.testSize;
  }
  
  @Pure
  public int getNumberOfTimesteps() {
    return this.numberOfTimesteps;
  }
  
  @Pure
  public int getNumOfVariables() {
    return this.numOfVariables;
  }
  
  @Pure
  public int getMiniBatchSize() {
    return this.miniBatchSize;
  }
  
  @Pure
  public File getBaseDir() {
    return this.baseDir;
  }
  
  @Pure
  public File getFeaturesDirTrain() {
    return this.featuresDirTrain;
  }
  
  @Pure
  public File getLabelsDirTrain() {
    return this.labelsDirTrain;
  }
  
  @Pure
  public File getFeaturesDirTest() {
    return this.featuresDirTest;
  }
  
  @Pure
  public File getLabelsDirTest() {
    return this.labelsDirTest;
  }
}
