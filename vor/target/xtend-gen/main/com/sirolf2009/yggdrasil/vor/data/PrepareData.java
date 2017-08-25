package com.sirolf2009.yggdrasil.vor.data;

import com.sirolf2009.yggdrasil.vor.data.DataFormat;
import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.List;
import java.util.function.BinaryOperator;
import java.util.function.Consumer;
import java.util.function.Function;
import java.util.stream.Collectors;
import java.util.stream.Stream;
import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.tuple.Pair;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.datavec.api.writable.Writable;
import org.eclipse.xtend.lib.annotations.Data;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.ExclusiveRange;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.Functions.Function2;
import org.eclipse.xtext.xbase.lib.IntegerRange;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure2;
import org.eclipse.xtext.xbase.lib.Pure;
import org.eclipse.xtext.xbase.lib.util.ToStringBuilder;
import org.nd4j.linalg.api.ndarray.INDArray;
import org.nd4j.linalg.factory.Nd4j;

@Data
@SuppressWarnings("all")
public class PrepareData {
  private final static Logger log = LogManager.getLogger();
  
  private final int numberOfTimesteps;
  
  private final int miniBatchSize;
  
  private final List<String> data;
  
  private final int numOfVariables;
  
  private final int trainSize;
  
  private final File baseDir;
  
  private final File featuresDirTrain;
  
  private final File labelsDirTrain;
  
  private final File featuresDirTest;
  
  private final File labelsDirTest;
  
  public PrepareData(final File baseDir, final List<String> data, final int numberOfTimesteps, final int miniBatchSize) {
    this.numberOfTimesteps = numberOfTimesteps;
    this.miniBatchSize = miniBatchSize;
    this.data = data;
    this.numOfVariables = PrepareData.getNumOfVariables(data);
    int _size = data.size();
    int _minus = (_size - numberOfTimesteps);
    int _minus_1 = (_minus - numberOfTimesteps);
    final int trainingLines = (_minus_1 - numberOfTimesteps);
    this.trainSize = (trainingLines - (trainingLines % miniBatchSize));
    this.baseDir = baseDir;
    File _file = new File(baseDir, "features_train");
    this.featuresDirTrain = _file;
    File _file_1 = new File(baseDir, "labels_train");
    this.labelsDirTrain = _file_1;
    File _file_2 = new File(baseDir, "features_test");
    this.featuresDirTest = _file_2;
    File _file_3 = new File(baseDir, "labels_test");
    this.labelsDirTest = _file_3;
  }
  
  public DataFormat call() throws Exception {
    PrepareData.log.info("Preparing train and test data");
    PrepareData.clean(this.featuresDirTrain);
    PrepareData.clean(this.labelsDirTrain);
    PrepareData.clean(this.featuresDirTest);
    PrepareData.clean(this.labelsDirTest);
    final Consumer<Integer> _function = new Consumer<Integer>() {
      @Override
      public void accept(final Integer it) {
        try {
          StringConcatenation _builder = new StringConcatenation();
          String _absolutePath = PrepareData.this.featuresDirTrain.getAbsolutePath();
          _builder.append(_absolutePath);
          _builder.append("/train_");
          _builder.append(it);
          _builder.append(".csv");
          final Path featuresPath = Paths.get(_builder.toString());
          StringConcatenation _builder_1 = new StringConcatenation();
          String _absolutePath_1 = PrepareData.this.labelsDirTrain.getAbsolutePath();
          _builder_1.append(_absolutePath_1);
          _builder_1.append("/train_");
          _builder_1.append(it);
          _builder_1.append(".csv");
          final Path labelsPath = Paths.get(_builder_1.toString());
          final Consumer<Integer> _function = new Consumer<Integer>() {
            @Override
            public void accept(final Integer step) {
              try {
                Files.write(featuresPath, PrepareData.this.data.get(((it).intValue() + (step).intValue())).concat("\n").getBytes(), StandardOpenOption.APPEND, StandardOpenOption.CREATE);
              } catch (Throwable _e) {
                throw Exceptions.sneakyThrow(_e);
              }
            }
          };
          new IntegerRange(0, PrepareData.this.numberOfTimesteps).forEach(_function);
          Files.write(labelsPath, PrepareData.this.data.get(((it).intValue() + PrepareData.this.numberOfTimesteps)).concat("\n").getBytes(), StandardOpenOption.APPEND, StandardOpenOption.CREATE);
        } catch (Throwable _e) {
          throw Exceptions.sneakyThrow(_e);
        }
      }
    };
    IterableExtensions.<Integer>toList(new IntegerRange(0, this.trainSize)).parallelStream().forEach(_function);
    final Consumer<Integer> _function_1 = new Consumer<Integer>() {
      @Override
      public void accept(final Integer it) {
        try {
          StringConcatenation _builder = new StringConcatenation();
          String _absolutePath = PrepareData.this.featuresDirTest.getAbsolutePath();
          _builder.append(_absolutePath);
          _builder.append("/test_");
          _builder.append(it);
          _builder.append(".csv");
          final Path featuresPath = Paths.get(_builder.toString());
          StringConcatenation _builder_1 = new StringConcatenation();
          String _absolutePath_1 = PrepareData.this.labelsDirTest.getAbsolutePath();
          _builder_1.append(_absolutePath_1);
          _builder_1.append("/test_");
          _builder_1.append(it);
          _builder_1.append(".csv");
          final Path labelsPath = Paths.get(_builder_1.toString());
          final Consumer<Integer> _function = new Consumer<Integer>() {
            @Override
            public void accept(final Integer step) {
              try {
                Files.write(featuresPath, PrepareData.this.data.get(((it).intValue() + (step).intValue())).concat("\n").getBytes(), StandardOpenOption.APPEND, StandardOpenOption.CREATE);
              } catch (Throwable _e) {
                throw Exceptions.sneakyThrow(_e);
              }
            }
          };
          new IntegerRange(0, PrepareData.this.numberOfTimesteps).forEach(_function);
          Files.write(labelsPath, PrepareData.this.data.get(((it).intValue() + PrepareData.this.numberOfTimesteps)).concat("\n").getBytes(), StandardOpenOption.APPEND, StandardOpenOption.CREATE);
        } catch (Throwable _e) {
          throw Exceptions.sneakyThrow(_e);
        }
      }
    };
    IterableExtensions.<Integer>toList(new IntegerRange(this.trainSize, (this.numberOfTimesteps + this.trainSize))).parallelStream().forEach(_function_1);
    return new DataFormat(this.trainSize, this.numberOfTimesteps, this.numberOfTimesteps, this.numOfVariables, this.miniBatchSize, this.baseDir, this.featuresDirTrain, this.labelsDirTrain, this.featuresDirTest, this.labelsDirTest);
  }
  
  public static INDArray createDataSet(final List<String> orders, final int numberOfTimesteps) throws Exception {
    INDArray _xblockexpression = null;
    {
      PrepareData.log.info("Preparing test data");
      int _size = orders.size();
      int _minus = (_size - numberOfTimesteps);
      final Function<Integer, Stream<INDArray>> _function = new Function<Integer, Stream<INDArray>>() {
        @Override
        public Stream<INDArray> apply(final Integer it) {
          final Function<Integer, INDArray> _function = new Function<Integer, INDArray>() {
            @Override
            public INDArray apply(final Integer step) {
              INDArray _xblockexpression = null;
              {
                final String[] data = orders.get(((it).intValue() + (step).intValue())).split(",");
                final Function<String, Double> _function = new Function<String, Double>() {
                  @Override
                  public Double apply(final String it) {
                    return Double.valueOf(Double.parseDouble(it));
                  }
                };
                _xblockexpression = Nd4j.create(((double[])Conversions.unwrapArray(((List<String>)Conversions.doWrapArray(data)).stream().<Double>map(_function).collect(Collectors.<Double>toList()), double.class)));
              }
              return _xblockexpression;
            }
          };
          return IterableExtensions.<Integer>toList(new IntegerRange(0, numberOfTimesteps)).stream().<INDArray>map(_function);
        }
      };
      final BinaryOperator<INDArray> _function_1 = new BinaryOperator<INDArray>() {
        @Override
        public INDArray apply(final INDArray a, final INDArray b) {
          return Nd4j.vstack(a, b);
        }
      };
      _xblockexpression = IterableExtensions.<Integer>toList(new ExclusiveRange(0, _minus, true)).parallelStream().<INDArray>flatMap(_function).reduce(_function_1).get();
    }
    return _xblockexpression;
  }
  
  public static List<INDArray> createDataSet2(final List<String> orders, final int numberOfTimesteps) throws Exception {
    List<INDArray> _xblockexpression = null;
    {
      PrepareData.log.info("Preparing test data2");
      int _size = orders.size();
      int _minus = (_size - numberOfTimesteps);
      final Function<Integer, INDArray> _function = new Function<Integer, INDArray>() {
        @Override
        public INDArray apply(final Integer it) {
          final Function<Integer, double[]> _function = new Function<Integer, double[]>() {
            @Override
            public double[] apply(final Integer step) {
              double[] _xblockexpression = null;
              {
                final String[] data = orders.get(((it).intValue() + (step).intValue())).split(",");
                final Function<String, Double> _function = new Function<String, Double>() {
                  @Override
                  public Double apply(final String it) {
                    return Double.valueOf(Double.parseDouble(it));
                  }
                };
                List<Double> _collect = ((List<String>)Conversions.doWrapArray(data)).stream().<Double>map(_function).collect(Collectors.<Double>toList());
                _xblockexpression = ((double[]) ((double[])Conversions.unwrapArray(_collect, double.class)));
              }
              return _xblockexpression;
            }
          };
          List<double[]> _collect = IterableExtensions.<Integer>toList(new IntegerRange(0, numberOfTimesteps)).stream().<double[]>map(_function).collect(Collectors.<double[]>toList());
          return Nd4j.create(((double[][]) ((double[][])Conversions.unwrapArray(_collect, double[].class))), 'c');
        }
      };
      _xblockexpression = IterableExtensions.<Integer>toList(new ExclusiveRange(0, _minus, true)).parallelStream().<INDArray>map(_function).collect(Collectors.<INDArray>toList());
    }
    return _xblockexpression;
  }
  
  /**
   * orders, ahead -> dataset
   */
  public final static Function<Pair<List<List<Double>>, Integer>, List<INDArray>> createDataSet = new Function<Pair<List<List<Double>>, Integer>, List<INDArray>>() {
    @Override
    public List<INDArray> apply(final Pair<List<List<Double>>, Integer> it) {
      int _size = it.getLeft().size();
      Integer _right = it.getRight();
      int _minus = (_size - (_right).intValue());
      final Function<Integer, INDArray> _function = new Function<Integer, INDArray>() {
        @Override
        public INDArray apply(final Integer example) {
          Integer _right = it.getRight();
          final Function<Integer, List<Double>> _function = new Function<Integer, List<Double>>() {
            @Override
            public List<Double> apply(final Integer step) {
              return it.getLeft().get(((example).intValue() + (step).intValue()));
            }
          };
          List<List<Double>> _collect = IterableExtensions.<Integer>toList(new IntegerRange(0, (_right).intValue())).stream().<List<Double>>map(_function).collect(Collectors.<List<Double>>toList());
          return Nd4j.create(((double[][]) ((double[][])Conversions.unwrapArray(_collect, double[].class))), 'c');
        }
      };
      return IterableExtensions.<Integer>toList(new ExclusiveRange(0, _minus, true)).parallelStream().<INDArray>map(_function).collect(Collectors.<INDArray>toList());
    }
  };
  
  public static List<INDArray> createData(final List<List<Writable>> orders, final int numberOfTimesteps) throws Exception {
    List<INDArray> _xblockexpression = null;
    {
      PrepareData.log.info("Preparing test data");
      int _size = orders.size();
      int _minus = (_size - numberOfTimesteps);
      final Function<Integer, Stream<INDArray>> _function = new Function<Integer, Stream<INDArray>>() {
        @Override
        public Stream<INDArray> apply(final Integer it) {
          final Function<Integer, INDArray> _function = new Function<Integer, INDArray>() {
            @Override
            public INDArray apply(final Integer step) {
              final Function<Writable, Double> _function = new Function<Writable, Double>() {
                @Override
                public Double apply(final Writable it) {
                  return Double.valueOf(it.toDouble());
                }
              };
              return Nd4j.create(((double[])Conversions.unwrapArray(orders.get(((it).intValue() + (step).intValue())).stream().<Double>map(_function).collect(Collectors.<Double>toList()), double.class)));
            }
          };
          return IterableExtensions.<Integer>toList(new IntegerRange(0, numberOfTimesteps)).stream().<INDArray>map(_function);
        }
      };
      _xblockexpression = IterableExtensions.<Integer>toList(new ExclusiveRange(0, _minus, true)).parallelStream().<INDArray>flatMap(_function).collect(Collectors.<INDArray>toList());
    }
    return _xblockexpression;
  }
  
  public static List<INDArray> createDataSetFast(final List<List<Writable>> orders, final int numberOfTimesteps) throws Exception {
    List<INDArray> _xblockexpression = null;
    {
      PrepareData.log.info("Preparing test data");
      int _size = orders.size();
      int _minus = (_size - numberOfTimesteps);
      final Function<Integer, INDArray> _function = new Function<Integer, INDArray>() {
        @Override
        public INDArray apply(final Integer it) {
          final Function1<Integer, INDArray> _function = new Function1<Integer, INDArray>() {
            @Override
            public INDArray apply(final Integer step) {
              final Function<Writable, Double> _function = new Function<Writable, Double>() {
                @Override
                public Double apply(final Writable it) {
                  return Double.valueOf(it.toDouble());
                }
              };
              return Nd4j.create(((double[])Conversions.unwrapArray(orders.get(((it).intValue() + (step).intValue())).stream().<Double>map(_function).collect(Collectors.<Double>toList()), double.class)));
            }
          };
          final Function2<INDArray, INDArray, INDArray> _function_1 = new Function2<INDArray, INDArray, INDArray>() {
            @Override
            public INDArray apply(final INDArray a, final INDArray b) {
              return Nd4j.vstack(a, b);
            }
          };
          return IterableExtensions.<INDArray>reduce(IterableExtensions.<Integer, INDArray>map(new IntegerRange(0, numberOfTimesteps), _function), _function_1).get();
        }
      };
      _xblockexpression = IterableExtensions.<Integer>toList(new ExclusiveRange(0, _minus, true)).parallelStream().<INDArray>map(_function).collect(Collectors.<INDArray>toList());
    }
    return _xblockexpression;
  }
  
  public static INDArray createDataSetFlat(final List<List<Writable>> orders, final int numberOfTimesteps) throws Exception {
    INDArray _xblockexpression = null;
    {
      PrepareData.log.info("Preparing test data");
      int _size = orders.size();
      int _minus = (_size - numberOfTimesteps);
      final Function<Integer, Stream<INDArray>> _function = new Function<Integer, Stream<INDArray>>() {
        @Override
        public Stream<INDArray> apply(final Integer it) {
          final Function<Integer, INDArray> _function = new Function<Integer, INDArray>() {
            @Override
            public INDArray apply(final Integer step) {
              final Function<Writable, Double> _function = new Function<Writable, Double>() {
                @Override
                public Double apply(final Writable it) {
                  return Double.valueOf(it.toDouble());
                }
              };
              return Nd4j.create(((double[])Conversions.unwrapArray(orders.get(((it).intValue() + (step).intValue())).stream().<Double>map(_function).collect(Collectors.<Double>toList()), double.class)));
            }
          };
          return IterableExtensions.<Integer>toList(new IntegerRange(0, numberOfTimesteps)).stream().<INDArray>map(_function);
        }
      };
      final BinaryOperator<INDArray> _function_1 = new BinaryOperator<INDArray>() {
        @Override
        public INDArray apply(final INDArray a, final INDArray b) {
          return Nd4j.vstack(a, b);
        }
      };
      _xblockexpression = IterableExtensions.<Integer>toList(new ExclusiveRange(0, _minus, true)).parallelStream().<INDArray>flatMap(_function).reduce(_function_1).get();
    }
    return _xblockexpression;
  }
  
  public static INDArray createIndArrayFromStringList(final List<String> rawString, final int numOfVariables, final int start, final int length) {
    final List<String> stringList = rawString.subList(start, (start + length));
    final double[][] primitives = new double[numOfVariables][stringList.size()];
    final Procedure2<String, Integer> _function = new Procedure2<String, Integer>() {
      @Override
      public void apply(final String it, final Integer i) {
        final String[] vals = it.split(",");
        final Procedure2<String, Integer> _function = new Procedure2<String, Integer>() {
          @Override
          public void apply(final String it, final Integer j) {
            primitives[(j).intValue()][(i).intValue()] = (Double.valueOf(vals[(j).intValue()])).doubleValue();
          }
        };
        IterableExtensions.<String>forEach(((Iterable<String>)Conversions.doWrapArray(vals)), _function);
      }
    };
    IterableExtensions.<String>forEach(stringList, _function);
    return Nd4j.create(new int[] { 1, length }, primitives);
  }
  
  public static void clean(final File folder) {
    try {
      folder.mkdirs();
      FileUtils.cleanDirectory(folder);
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  public static int getNumOfVariables(final List<String> rawStrings) {
    return rawStrings.get(0).split(",").length;
  }
  
  @Override
  @Pure
  public int hashCode() {
    final int prime = 31;
    int result = 1;
    result = prime * result + this.numberOfTimesteps;
    result = prime * result + this.miniBatchSize;
    result = prime * result + ((this.data== null) ? 0 : this.data.hashCode());
    result = prime * result + this.numOfVariables;
    result = prime * result + this.trainSize;
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
    PrepareData other = (PrepareData) obj;
    if (other.numberOfTimesteps != this.numberOfTimesteps)
      return false;
    if (other.miniBatchSize != this.miniBatchSize)
      return false;
    if (this.data == null) {
      if (other.data != null)
        return false;
    } else if (!this.data.equals(other.data))
      return false;
    if (other.numOfVariables != this.numOfVariables)
      return false;
    if (other.trainSize != this.trainSize)
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
    b.add("numberOfTimesteps", this.numberOfTimesteps);
    b.add("miniBatchSize", this.miniBatchSize);
    b.add("data", this.data);
    b.add("numOfVariables", this.numOfVariables);
    b.add("trainSize", this.trainSize);
    b.add("baseDir", this.baseDir);
    b.add("featuresDirTrain", this.featuresDirTrain);
    b.add("labelsDirTrain", this.labelsDirTrain);
    b.add("featuresDirTest", this.featuresDirTest);
    b.add("labelsDirTest", this.labelsDirTest);
    return b.toString();
  }
  
  @Pure
  public int getNumberOfTimesteps() {
    return this.numberOfTimesteps;
  }
  
  @Pure
  public int getMiniBatchSize() {
    return this.miniBatchSize;
  }
  
  @Pure
  public List<String> getData() {
    return this.data;
  }
  
  @Pure
  public int getNumOfVariables() {
    return this.numOfVariables;
  }
  
  @Pure
  public int getTrainSize() {
    return this.trainSize;
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
