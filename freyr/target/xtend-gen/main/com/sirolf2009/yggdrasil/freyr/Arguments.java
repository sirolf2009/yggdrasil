package com.sirolf2009.yggdrasil.freyr;

import com.beust.jcommander.Parameter;
import org.eclipse.xtend.lib.annotations.Accessors;
import org.eclipse.xtend.lib.annotations.EqualsHashCode;
import org.eclipse.xtend.lib.annotations.ToString;
import org.eclipse.xtext.xbase.lib.Pure;
import org.eclipse.xtext.xbase.lib.util.ToStringBuilder;

@Accessors
@EqualsHashCode
@ToString
@SuppressWarnings("all")
public class Arguments {
  @Parameter(names = "-influxHost", description = "The ip of the influxdb")
  private String influxHost = "freyr";
  
  @Parameter(names = "-influxPort", description = "The port of the influxdb")
  private int influxPort = 8086;
  
  @Parameter(names = "-database", description = "The name of the database")
  private String database = "gdax";
  
  @Pure
  public String getInfluxHost() {
    return this.influxHost;
  }
  
  public void setInfluxHost(final String influxHost) {
    this.influxHost = influxHost;
  }
  
  @Pure
  public int getInfluxPort() {
    return this.influxPort;
  }
  
  public void setInfluxPort(final int influxPort) {
    this.influxPort = influxPort;
  }
  
  @Pure
  public String getDatabase() {
    return this.database;
  }
  
  public void setDatabase(final String database) {
    this.database = database;
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
    Arguments other = (Arguments) obj;
    if (this.influxHost == null) {
      if (other.influxHost != null)
        return false;
    } else if (!this.influxHost.equals(other.influxHost))
      return false;
    if (other.influxPort != this.influxPort)
      return false;
    if (this.database == null) {
      if (other.database != null)
        return false;
    } else if (!this.database.equals(other.database))
      return false;
    return true;
  }
  
  @Override
  @Pure
  public int hashCode() {
    final int prime = 31;
    int result = 1;
    result = prime * result + ((this.influxHost== null) ? 0 : this.influxHost.hashCode());
    result = prime * result + this.influxPort;
    result = prime * result + ((this.database== null) ? 0 : this.database.hashCode());
    return result;
  }
  
  @Override
  @Pure
  public String toString() {
    ToStringBuilder b = new ToStringBuilder(this);
    b.add("influxHost", this.influxHost);
    b.add("influxPort", this.influxPort);
    b.add("database", this.database);
    return b.toString();
  }
}
