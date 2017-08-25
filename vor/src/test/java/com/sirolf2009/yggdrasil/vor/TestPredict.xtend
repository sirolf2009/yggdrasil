package com.sirolf2009.yggdrasil.vor

import com.sirolf2009.yggdrasil.freyr.TestData
import java.io.File
import org.apache.commons.io.FileUtils
import org.junit.Assert
import org.junit.Test

import static extension com.sirolf2009.yggdrasil.sif.TableExtensions.*
import org.junit.Ignore

class TestPredict {
	
	@Test
	@Ignore // apparently this doesn't work on other machines
	def void testPredictMultiStep() {
		val net = new RNN(63).get()
		val data = TestData.orderbookRows
		val stepsToPredict = 5
		
		val prediction = Predict.predictMultiStep(net, data, stepsToPredict).map[toString()].reduce[a,b|a+"\n"+b]
		Assert.assertEquals(FileUtils.readFileToString(new File("src/test/resources/TestPredict/TestPredictMultiStep")).trim(), prediction.trim())
		
		//Sanity check, if you remove the first row, the prediction should be different (i.e. it's state was used previously)
		val prediction2 = Predict.predictMultiStep(net, data.rows(1, data.rowCount-1), stepsToPredict).map[toString()].reduce[a,b|a+"\n"+b]
		Assert.assertEquals(FileUtils.readFileToString(new File("src/test/resources/TestPredict/TestPredictMultiStep2")).trim(), prediction2.trim())
		
		//Sanity check, put the first row back and everything is normal again (i.e. the results aren't random)
		val prediction3 = Predict.predictMultiStep(net, data, stepsToPredict).map[toString()].reduce[a,b|a+"\n"+b]
		Assert.assertEquals(FileUtils.readFileToString(new File("src/test/resources/TestPredict/TestPredictMultiStep")).trim(), prediction3.trim())
	}
	
	@Test
	def void testPreparePredictData() {
		val data = TestData.orderbookRows
		val predict = Predict.preparePredictData(data, 1).map[toString()].reduce[a,b|a+"\n"+b]
		Assert.assertEquals(FileUtils.readFileToString(new File("src/test/resources/TestPredict/TestPreparePredictData")).trim(), predict.trim())
		
		val predict2 = Predict.preparePredictData(data, 2).map[toString()].reduce[a,b|a+"\n"+b]
		Assert.assertEquals(FileUtils.readFileToString(new File("src/test/resources/TestPredict/TestPreparePredictData2")).trim(), predict2.trim())
		
		val predict3 = Predict.preparePredictData(data, 3).map[toString()].reduce[a,b|a+"\n"+b]
		Assert.assertEquals(FileUtils.readFileToString(new File("src/test/resources/TestPredict/TestPreparePredictData3")).trim(), predict3.trim())
	}
	
}
