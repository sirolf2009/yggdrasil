package com.sirolf2009.yggdrasil.sif.model;

import java.util.Date;
import org.eclipse.xtend.lib.annotations.Data;
import org.eclipse.xtext.xbase.lib.Pure;
import org.eclipse.xtext.xbase.lib.util.ToStringBuilder;

@Data
@SuppressWarnings("all")
public class OrderPoint {
  private final Date timestamp;
  
  private final String side;
  
  private final int index;
  
  private final double value;
  
  private final double amount;
  
  private final double bought;
  
  private final double sold;
  
  public OrderPoint(final Date timestamp, final String side, final int index, final double value, final double amount, final double bought, final double sold) {
    super();
    this.timestamp = timestamp;
    this.side = side;
    this.index = index;
    this.value = value;
    this.amount = amount;
    this.bought = bought;
    this.sold = sold;
  }
  
  @Override
  @Pure
  public int hashCode() {
    final int prime = 31;
    int result = 1;
    result = prime * result + ((this.timestamp== null) ? 0 : this.timestamp.hashCode());
    result = prime * result + ((this.side== null) ? 0 : this.side.hashCode());
    result = prime * result + this.index;
    result = prime * result + (int) (Double.doubleToLongBits(this.value) ^ (Double.doubleToLongBits(this.value) >>> 32));
    result = prime * result + (int) (Double.doubleToLongBits(this.amount) ^ (Double.doubleToLongBits(this.amount) >>> 32));
    result = prime * result + (int) (Double.doubleToLongBits(this.bought) ^ (Double.doubleToLongBits(this.bought) >>> 32));
    result = prime * result + (int) (Double.doubleToLongBits(this.sold) ^ (Double.doubleToLongBits(this.sold) >>> 32));
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
    OrderPoint other = (OrderPoint) obj;
    if (this.timestamp == null) {
      if (other.timestamp != null)
        return false;
    } else if (!this.timestamp.equals(other.timestamp))
      return false;
    if (this.side == null) {
      if (other.side != null)
        return false;
    } else if (!this.side.equals(other.side))
      return false;
    if (other.index != this.index)
      return false;
    if (Double.doubleToLongBits(other.value) != Double.doubleToLongBits(this.value))
      return false; 
    if (Double.doubleToLongBits(other.amount) != Double.doubleToLongBits(this.amount))
      return false; 
    if (Double.doubleToLongBits(other.bought) != Double.doubleToLongBits(this.bought))
      return false; 
    if (Double.doubleToLongBits(other.sold) != Double.doubleToLongBits(this.sold))
      return false; 
    return true;
  }
  
  @Override
  @Pure
  public String toString() {
    ToStringBuilder b = new ToStringBuilder(this);
    b.add("timestamp", this.timestamp);
    b.add("side", this.side);
    b.add("index", this.index);
    b.add("value", this.value);
    b.add("amount", this.amount);
    b.add("bought", this.bought);
    b.add("sold", this.sold);
    return b.toString();
  }
  
  @Pure
  public Date getTimestamp() {
    return this.timestamp;
  }
  
  @Pure
  public String getSide() {
    return this.side;
  }
  
  @Pure
  public int getIndex() {
    return this.index;
  }
  
  @Pure
  public double getValue() {
    return this.value;
  }
  
  @Pure
  public double getAmount() {
    return this.amount;
  }
  
  @Pure
  public double getBought() {
    return this.bought;
  }
  
  @Pure
  public double getSold() {
    return this.sold;
  }
}
