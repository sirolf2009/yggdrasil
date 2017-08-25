package com.sirolf2009.yggdrasil.sif

import com.sirolf2009.yggdrasil.freyr.TestData
import java.io.File
import java.time.LocalDateTime
import junit.framework.Assert
import org.apache.commons.io.FileUtils
import org.junit.Test
import org.nd4j.linalg.factory.Nd4j

import static extension com.sirolf2009.yggdrasil.sif.TableExtensions.*

class TestTableExtensions {
	
	@Test
	def void testToMatrixToTable() {
		val data = TestData.orderbookRows
		val matrix = data.toMatrix()
		val reconstructed = matrix.toTable(data.date.get(0), data.name)
		Assert.assertEquals(data.columnNames, reconstructed.columnNames)
		Assert.assertEquals(data.date.get(0), reconstructed.date.get(0))
		data.columnNames.filter[!it.equals("datetime")].forEach[
			Assert.assertEquals(data.doubleColumn(it).get(0), reconstructed.doubleColumn(it).get(0), 0.00001)
		]
	}
	
	@Test
	def void testToMatrix() {
		val data = TestData.orderbookRows
		val matrix = data.toMatrix()
		Assert.assertEquals(FileUtils.readFileToString(new File("src/test/resources/TestTableExtensions/TestToMatrix")).trim(), matrix.toString().trim())
	}
	
	@Test
	def void testRowArrayToTable() {
		val data = TestData.orderbookSimple
		val array = data.toArray(0)
		val reconstructed = array.toTable(data.date.get(0), data.name)
		Assert.assertEquals(data.columnNames, reconstructed.columnNames)
		Assert.assertEquals(data.date.get(0), reconstructed.date.get(0))
		data.columnNames.filter[!it.equals("datetime")].forEach[
			Assert.assertEquals(data.doubleColumn(it).get(0), reconstructed.doubleColumn(it).get(0), 0.00001)
		]
	}
	
	@Test
	def void testToTable() {
		val array = Nd4j.create(#[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62].map[Double.valueOf(it)].toList())
		val newYear = LocalDateTime.of(2017, 1, 1, 0, 0, 0, 0)
		val data = array.toTable(newYear, "Unit Test")
		Assert.assertEquals(FileUtils.readFileToString(new File("src/test/resources/TestTableExtensions/TestToTable")).trim(), data.toString().trim())
	}
	
	@Test
	def void testToArray() {
		val data = TestData.orderbookRows
		val sliced = data.toArray(0)
		Assert.assertEquals(FileUtils.readFileToString(new File("src/test/resources/TestTableExtensions/TestToArray")).trim(), sliced.toString().trim())
	}
	
	@Test
	def void testRows() {
		val data = TestData.orderbookRows
		val sliced = data.rows(0, 2)
		Assert.assertEquals(FileUtils.readFileToString(new File("src/test/resources/TestTableExtensions/TestRows")).trim(), sliced.toString().trim())
	}
	
	@Test
	def void testRow() {
		val data = TestData.orderbookRows
		val sliced = data.row(0)
		Assert.assertEquals(FileUtils.readFileToString(new File("src/test/resources/TestTableExtensions/TestRow")).trim(), sliced.toString().trim())
	}
	
}
	