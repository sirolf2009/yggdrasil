package com.sirolf2009.yggdrasil.sif.saver;

import java.io.File;
import java.io.FileOutputStream;
import java.util.function.Consumer;
import org.apache.commons.io.IOUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.deeplearning4j.nn.multilayer.MultiLayerNetwork;
import org.deeplearning4j.util.ModelSerializer;
import org.eclipse.xtend.lib.annotations.Data;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.Pure;
import org.eclipse.xtext.xbase.lib.util.ToStringBuilder;

@SuppressWarnings("all")
public class SaversFile {
  @Data
  public static class StringToFile implements Consumer<String> {
    private final static Logger log = LogManager.getLogger();
    
    private final File file;
    
    @Override
    public void accept(final String t) {
      try {
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("saving ");
        String _humanReadableByteCount = SaversFile.StringToFile.humanReadableByteCount(t.getBytes().length, false);
        _builder.append(_humanReadableByteCount);
        _builder.append(" bytes to ");
        _builder.append(this.file);
        SaversFile.StringToFile.log.info(_builder);
        final FileOutputStream out = new FileOutputStream(this.file);
        IOUtils.write(t, out);
        out.close();
      } catch (Throwable _e) {
        throw Exceptions.sneakyThrow(_e);
      }
    }
    
    public static String humanReadableByteCount(final long bytes, final boolean si) {
      int _xifexpression = (int) 0;
      if (si) {
        _xifexpression = 1000;
      } else {
        _xifexpression = 1024;
      }
      final int unit = _xifexpression;
      if ((bytes < unit)) {
        return (Long.valueOf(bytes) + " B");
      }
      double _log = Math.log(bytes);
      double _log_1 = Math.log(unit);
      double _divide = (_log / _log_1);
      final int exp = ((int) _divide);
      String _xifexpression_1 = null;
      if (si) {
        _xifexpression_1 = "kMGTPE";
      } else {
        _xifexpression_1 = "KMGTPE";
      }
      char _charAt = _xifexpression_1.charAt((exp - 1));
      String _xifexpression_2 = null;
      if (si) {
        _xifexpression_2 = "";
      } else {
        _xifexpression_2 = "i";
      }
      final String pre = (Character.valueOf(_charAt) + _xifexpression_2);
      double _pow = Math.pow(unit, exp);
      double _divide_1 = (bytes / _pow);
      return String.format("%.1f %sB", Double.valueOf(_divide_1), pre);
    }
    
    public StringToFile(final File file) {
      super();
      this.file = file;
    }
    
    @Override
    @Pure
    public int hashCode() {
      final int prime = 31;
      int result = 1;
      result = prime * result + ((this.file== null) ? 0 : this.file.hashCode());
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
      SaversFile.StringToFile other = (SaversFile.StringToFile) obj;
      if (this.file == null) {
        if (other.file != null)
          return false;
      } else if (!this.file.equals(other.file))
        return false;
      return true;
    }
    
    @Override
    @Pure
    public String toString() {
      ToStringBuilder b = new ToStringBuilder(this);
      b.add("file", this.file);
      return b.toString();
    }
    
    @Pure
    public File getFile() {
      return this.file;
    }
  }
  
  @Data
  public static class NetToFile implements Consumer<MultiLayerNetwork> {
    private final static Logger log = LogManager.getLogger();
    
    private final File file;
    
    @Override
    public void accept(final MultiLayerNetwork net) {
      try {
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("saving network to ");
        _builder.append(this.file);
        SaversFile.NetToFile.log.info(_builder);
        final boolean saveUpdater = true;
        ModelSerializer.writeModel(net, this.file, saveUpdater);
      } catch (Throwable _e) {
        throw Exceptions.sneakyThrow(_e);
      }
    }
    
    public NetToFile(final File file) {
      super();
      this.file = file;
    }
    
    @Override
    @Pure
    public int hashCode() {
      final int prime = 31;
      int result = 1;
      result = prime * result + ((this.file== null) ? 0 : this.file.hashCode());
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
      SaversFile.NetToFile other = (SaversFile.NetToFile) obj;
      if (this.file == null) {
        if (other.file != null)
          return false;
      } else if (!this.file.equals(other.file))
        return false;
      return true;
    }
    
    @Override
    @Pure
    public String toString() {
      ToStringBuilder b = new ToStringBuilder(this);
      b.add("file", this.file);
      return b.toString();
    }
    
    @Pure
    public File getFile() {
      return this.file;
    }
  }
  
  public final static Consumer<String> saveOrderbook = new SaversFile.StringToFile(new File("data/orderbook.csv"));
}
