package com.sirolf2009.yggdrasil.vor;

import com.beust.jcommander.JCommander;
import com.sirolf2009.yggdrasil.sif.TrainingData;
import com.sirolf2009.yggdrasil.sif.loader.LoadersFile;
import com.sirolf2009.yggdrasil.sif.saver.SaversFile;
import com.sirolf2009.yggdrasil.sif.transmutation.CSV;
import com.sirolf2009.yggdrasil.sif.transmutation.INDArrays;
import com.sirolf2009.yggdrasil.vor.Predict;
import com.sirolf2009.yggdrasil.vor.RNN;
import com.sirolf2009.yggdrasil.vor.data.Arguments;
import com.sirolf2009.yggdrasil.vor.data.DataFormat;
import com.sirolf2009.yggdrasil.vor.data.PrepareData;
import com.sirolf2009.yggdrasil.vor.data.TrainAndTestData;
import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.function.Consumer;
import org.apache.commons.io.FileUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.datavec.api.records.reader.impl.csv.CSVSequenceRecordReader;
import org.datavec.api.split.NumberedFileInputSplit;
import org.deeplearning4j.datasets.datavec.SequenceRecordReaderDataSetIterator;
import org.deeplearning4j.eval.RegressionEvaluation;
import org.deeplearning4j.nn.multilayer.MultiLayerNetwork;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.ExclusiveRange;
import org.eclipse.xtext.xbase.lib.Extension;
import org.nd4j.linalg.api.ndarray.INDArray;
import org.nd4j.linalg.dataset.DataSet;
import org.nd4j.linalg.dataset.api.iterator.DataSetIterator;

@SuppressWarnings("all")
public class Vor {
  private final static Logger log = LogManager.getLogger();
  
  private final static File baseDir = new File("data");
  
  public static void main(final String[] args) {
    @Extension
    final Arguments arguments = new Arguments();
    JCommander.newBuilder().addObject(arguments).build().parse(args);
    Vor.log.info(("Starting with arguments: " + arguments));
    Vor.train(arguments);
  }
  
  public static void train(@Extension final Arguments arguments) {
    try {
      final File networkFolder = new File(Vor.baseDir, "predict-net");
      networkFolder.mkdirs();
      int _size = ((List<String>)Conversions.doWrapArray(networkFolder.list())).size();
      boolean _greaterThan = (_size > 0);
      if (_greaterThan) {
        throw new IllegalStateException("The network folder is not empty!");
      }
      final File predictionFolder = new File(Vor.baseDir, "predict-csv");
      predictionFolder.mkdirs();
      int _size_1 = ((List<String>)Conversions.doWrapArray(predictionFolder.list())).size();
      boolean _greaterThan_1 = (_size_1 > 0);
      if (_greaterThan_1) {
        throw new IllegalStateException("The prediction folder is not empty!");
      }
      List<String> _readAllLines = Files.readAllLines(new File("data/orderbook.csv").toPath());
      int _steps = arguments.getSteps();
      int _minibatch = arguments.getMinibatch();
      @Extension
      final DataFormat format = new PrepareData(Vor.baseDir, _readAllLines, _steps, _minibatch).call();
      @Extension
      final TrainAndTestData datasets = Vor.getData(format);
      File _file = new File("data/orderbook");
      final List<INDArray> predictData = TrainingData.readPredictDataLarge(_file);
      final MultiLayerNetwork net = new RNN(format).get();
      final int epochs = 100;
      Vor.log.info("Training...");
      final Consumer<Integer> _function = (Integer it) -> {
        try {
          net.fit(datasets.getTrainData());
          datasets.getTrainData().reset();
          File _file_1 = new File(networkFolder, (("predict_" + it) + ".zip"));
          new SaversFile.NetToFile(_file_1).accept(net);
          final String prediction = INDArrays.toMatrix().<List<String>>andThen(CSV.matrixToCSV).<String>andThen(CSV.joinAsLines).apply(Predict.predict(net, predictData, (60 * 15)));
          File _file_2 = new File(predictionFolder, (("predict_" + it) + ".csv"));
          FileUtils.write(_file_2, prediction);
        } catch (Throwable _e) {
          throw Exceptions.sneakyThrow(_e);
        }
      };
      new ExclusiveRange(0, epochs, true).forEach(_function);
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  public static void showPredictions(@Extension final Arguments arguments) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("http://");
    String _influxHost = arguments.getInfluxHost();
    _builder.append(_influxHost);
    _builder.append(":");
    int _influxPort = arguments.getInfluxPort();
    _builder.append(_influxPort);
    final Optional<List<INDArray>> predictData = TrainingData.getPredictData(_builder.toString(), 5000);
    final Consumer<File> _function = (File it) -> {
      try {
        final ArrayList<INDArray> prediction = Predict.predict(LoadersFile.loadNetwork(it), predictData.get(), (60 * 15));
        final String csv = INDArrays.toMatrix().<List<String>>andThen(CSV.matrixToCSV).<String>andThen(CSV.joinAsLines).apply(prediction);
        String _name = it.getName();
        String _plus = ("data/predict-csv/" + _name);
        String _plus_1 = (_plus + ".csv");
        Path _get = Paths.get(_plus_1);
        String _plus_2 = ("Wrote to " + _get);
        Vor.log.info(_plus_2);
        String _name_1 = it.getName();
        String _plus_3 = ("data/predict-csv/" + _name_1);
        String _plus_4 = (_plus_3 + ".csv");
        Files.write(Paths.get(_plus_4), csv.getBytes());
      } catch (Throwable _e) {
        throw Exceptions.sneakyThrow(_e);
      }
    };
    ((List<File>)Conversions.doWrapArray(new File("data/predict").listFiles())).forEach(_function);
  }
  
  public static void showRegressionEvaluation(final MultiLayerNetwork net, final DataSetIterator testDataIter, final int numOfVariables, final int epoch) {
    final RegressionEvaluation evaluation = new RegressionEvaluation(numOfVariables);
    while (testDataIter.hasNext()) {
      {
        final DataSet t = testDataIter.next();
        final INDArray features = t.getFeatureMatrix();
        final INDArray labels = t.getLabels();
        final INDArray predicted = net.output(features, true);
        evaluation.evalTimeSeries(labels, predicted);
      }
    }
    String _stats = evaluation.stats();
    String _plus = ((("Epoch: " + Integer.valueOf(epoch)) + "\n") + _stats);
    Vor.log.info(_plus);
    testDataIter.reset();
  }
  
  public static TrainAndTestData getData(@Extension final DataFormat format) {
    try {
      final CSVSequenceRecordReader trainFeatures = new CSVSequenceRecordReader();
      StringConcatenation _builder = new StringConcatenation();
      String _absolutePath = format.getFeaturesDirTrain().getAbsolutePath();
      _builder.append(_absolutePath);
      _builder.append("/train_%d.csv");
      int _trainSize = format.getTrainSize();
      int _minus = (_trainSize - 1);
      NumberedFileInputSplit _numberedFileInputSplit = new NumberedFileInputSplit(_builder.toString(), 0, _minus);
      trainFeatures.initialize(_numberedFileInputSplit);
      final CSVSequenceRecordReader trainLabels = new CSVSequenceRecordReader();
      StringConcatenation _builder_1 = new StringConcatenation();
      String _absolutePath_1 = format.getLabelsDirTrain().getAbsolutePath();
      _builder_1.append(_absolutePath_1);
      _builder_1.append("/train_%d.csv");
      int _trainSize_1 = format.getTrainSize();
      int _minus_1 = (_trainSize_1 - 1);
      NumberedFileInputSplit _numberedFileInputSplit_1 = new NumberedFileInputSplit(_builder_1.toString(), 0, _minus_1);
      trainLabels.initialize(_numberedFileInputSplit_1);
      int _miniBatchSize = format.getMiniBatchSize();
      final SequenceRecordReaderDataSetIterator trainData = new SequenceRecordReaderDataSetIterator(trainFeatures, trainLabels, _miniBatchSize, (-1), true, SequenceRecordReaderDataSetIterator.AlignmentMode.ALIGN_END);
      final CSVSequenceRecordReader testFeatures = new CSVSequenceRecordReader();
      StringConcatenation _builder_2 = new StringConcatenation();
      String _absolutePath_2 = format.getFeaturesDirTest().getAbsolutePath();
      _builder_2.append(_absolutePath_2);
      _builder_2.append("/test_%d.csv");
      int _trainSize_2 = format.getTrainSize();
      int _trainSize_3 = format.getTrainSize();
      int _testSize = format.getTestSize();
      int _plus = (_trainSize_3 + _testSize);
      NumberedFileInputSplit _numberedFileInputSplit_2 = new NumberedFileInputSplit(_builder_2.toString(), _trainSize_2, _plus);
      testFeatures.initialize(_numberedFileInputSplit_2);
      final CSVSequenceRecordReader testLabels = new CSVSequenceRecordReader();
      StringConcatenation _builder_3 = new StringConcatenation();
      String _absolutePath_3 = format.getLabelsDirTest().getAbsolutePath();
      _builder_3.append(_absolutePath_3);
      _builder_3.append("/test_%d.csv");
      int _trainSize_4 = format.getTrainSize();
      int _trainSize_5 = format.getTrainSize();
      int _testSize_1 = format.getTestSize();
      int _plus_1 = (_trainSize_5 + _testSize_1);
      NumberedFileInputSplit _numberedFileInputSplit_3 = new NumberedFileInputSplit(_builder_3.toString(), _trainSize_4, _plus_1);
      testLabels.initialize(_numberedFileInputSplit_3);
      int _miniBatchSize_1 = format.getMiniBatchSize();
      final SequenceRecordReaderDataSetIterator testData = new SequenceRecordReaderDataSetIterator(testFeatures, testLabels, _miniBatchSize_1, (-1), true, SequenceRecordReaderDataSetIterator.AlignmentMode.ALIGN_END);
      return new TrainAndTestData(trainData, testData);
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
}
