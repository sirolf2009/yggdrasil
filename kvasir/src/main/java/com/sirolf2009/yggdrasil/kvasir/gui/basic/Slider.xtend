package com.sirolf2009.yggdrasil.kvasir.gui.basic

import com.sirolf2009.yggdrasil.kvasir.Drawable
import com.sirolf2009.yggdrasil.kvasir.gui.elementary.Circle
import com.sirolf2009.yggdrasil.kvasir.gui.elementary.Square
import java.awt.Color
import org.eclipse.xtend.lib.annotations.Accessors
import processing.core.PApplet
import processing.event.MouseEvent

@Accessors class Slider extends Drawable {

	val double min
	val double max
	var double current
	var MouseEvent lastMouseEvent
	val Drawable background
	val Drawable meter
	val Drawable knob

	new(PApplet applet, float x, float y, float width, float height, double min, double max) {
		super(applet, x, y, width, height)
		this.min = min
		this.max = max
		this.background = new Square(applet, x, y + height / 2 - (height/2/2), width, height/2, 16) => [
			color = Color.LIGHT_GRAY
		]
		this.meter = new Square(applet, x, y + height / 2 - (height/2/2), 0, height/2, 16) => [
			color = Color.BLUE.brighter()
		]
		this.knob = new Circle(applet, x, y, height, height)
	}

	override pre() {
		matrix [
			if(mouseOver() && (mouseDragging() || mouseClicking())) {
				current = PApplet.map(mouseX, x, x+getWidth(), min.floatValue, max.floatValue)
			}
			correctKnobPosition()
			correctMeterPosition()
		]
	}
	
	override draw() {
		drawBounds
	}

	def void correctKnobPosition() {
		val xRelative = PApplet.map(current.floatValue, min.floatValue, max.floatValue, x, x+getWidth())
		val yRelative = getHeight() / 2
		knob.x = xRelative
		knob.y = y + yRelative
	}

	def void correctMeterPosition() {
		meter.width = PApplet.map(current.floatValue, min.floatValue, max.floatValue, x, x+getWidth())-x
	}

	override mouseEvent(MouseEvent event) {
		this.lastMouseEvent = event
	}

	def mouseClicking() {
		return lastMouseEvent !== null && lastMouseEvent.action == MouseEvent.CLICK
	}

	def mouseDragging() {
		return lastMouseEvent !== null && lastMouseEvent.action == MouseEvent.DRAG
	}

}
