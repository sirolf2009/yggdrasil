package com.sirolf2009.yggdrasil.sif.loader;

import java.io.File;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.deeplearning4j.nn.multilayer.MultiLayerNetwork;
import org.deeplearning4j.util.ModelSerializer;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Exceptions;

@SuppressWarnings("all")
public class LoadersFile {
  private final static Logger log = LogManager.getLogger();
  
  public static MultiLayerNetwork loadNetwork(final String file) {
    File _file = new File(file);
    return LoadersFile.loadNetwork(_file);
  }
  
  public static MultiLayerNetwork loadNetwork(final File file) {
    try {
      MultiLayerNetwork _xblockexpression = null;
      {
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("Loading network from ");
        _builder.append(file);
        LoadersFile.log.info(_builder);
        _xblockexpression = ModelSerializer.restoreMultiLayerNetwork(file);
      }
      return _xblockexpression;
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
}
