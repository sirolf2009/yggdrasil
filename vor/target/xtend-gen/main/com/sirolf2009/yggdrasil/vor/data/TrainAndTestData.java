package com.sirolf2009.yggdrasil.vor.data;

import org.eclipse.xtend.lib.annotations.Data;
import org.eclipse.xtext.xbase.lib.Pure;
import org.eclipse.xtext.xbase.lib.util.ToStringBuilder;
import org.nd4j.linalg.dataset.api.iterator.DataSetIterator;

@Data
@SuppressWarnings("all")
public class TrainAndTestData {
  private final DataSetIterator trainData;
  
  private final DataSetIterator testData;
  
  public TrainAndTestData(final DataSetIterator trainData, final DataSetIterator testData) {
    super();
    this.trainData = trainData;
    this.testData = testData;
  }
  
  @Override
  @Pure
  public int hashCode() {
    final int prime = 31;
    int result = 1;
    result = prime * result + ((this.trainData== null) ? 0 : this.trainData.hashCode());
    result = prime * result + ((this.testData== null) ? 0 : this.testData.hashCode());
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
    TrainAndTestData other = (TrainAndTestData) obj;
    if (this.trainData == null) {
      if (other.trainData != null)
        return false;
    } else if (!this.trainData.equals(other.trainData))
      return false;
    if (this.testData == null) {
      if (other.testData != null)
        return false;
    } else if (!this.testData.equals(other.testData))
      return false;
    return true;
  }
  
  @Override
  @Pure
  public String toString() {
    ToStringBuilder b = new ToStringBuilder(this);
    b.add("trainData", this.trainData);
    b.add("testData", this.testData);
    return b.toString();
  }
  
  @Pure
  public DataSetIterator getTrainData() {
    return this.trainData;
  }
  
  @Pure
  public DataSetIterator getTestData() {
    return this.testData;
  }
}
