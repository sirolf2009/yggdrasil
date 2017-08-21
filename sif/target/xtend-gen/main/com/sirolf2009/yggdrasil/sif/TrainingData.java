package com.sirolf2009.yggdrasil.sif;

import com.sirolf2009.yggdrasil.sif.loader.LoadersDatabase;
import com.sirolf2009.yggdrasil.sif.model.OrderPoint;
import com.sirolf2009.yggdrasil.sif.saver.SaversFile;
import com.sirolf2009.yggdrasil.sif.transmutation.CSV;
import com.sirolf2009.yggdrasil.sif.transmutation.INDArrays;
import com.sirolf2009.yggdrasil.sif.transmutation.OrderPoints;
import java.io.File;
import java.util.List;
import java.util.Optional;
import org.nd4j.linalg.api.ndarray.INDArray;

@SuppressWarnings("all")
public class TrainingData {
  public static void downloadOrderbook(final String influx, final int orderpoints) {
    LoadersDatabase.getDatapoints(influx, orderpoints).<List<OrderPoint>>map(OrderPoints.normalize).<List<List<Double>>>map(OrderPoints.ordersToMatrix).<List<String>>map(CSV.matrixToCSV).<String>map(CSV.joinAsLines).ifPresent(SaversFile.saveOrderbook);
  }
  
  public static Optional<List<INDArray>> getPredictData(final String influx, final int orderpoints) {
    return LoadersDatabase.getDatapoints(influx, orderpoints).<List<OrderPoint>>map(OrderPoints.normalize).<List<List<Double>>>map(OrderPoints.ordersToMatrix).<List<INDArray>>map(INDArrays.createRNNDataSet(0));
  }
  
  public static List<INDArray> getPredictDataLarge(final String influx, final int orderpoints, final File folder) {
    return OrderPoints.normalize.<List<List<Double>>>andThen(OrderPoints.ordersToMatrix).<List<INDArray>>andThen(INDArrays.createRNNDataSet(0)).apply(LoadersDatabase.getDatapointsLarge(influx, orderpoints, folder));
  }
  
  public static List<INDArray> readPredictDataLarge(final File folder) {
    return OrderPoints.normalize.<List<List<Double>>>andThen(OrderPoints.ordersToMatrix).<List<INDArray>>andThen(INDArrays.createRNNDataSet(0)).apply(LoadersDatabase.parseDatapoints(folder));
  }
}
