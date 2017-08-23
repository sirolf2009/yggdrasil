package com.sirolf2009.yggdrasil.kvasir

import java.awt.Color
import java.awt.Rectangle
import org.eclipse.xtend.lib.annotations.Accessors
import processing.core.PApplet
import processing.event.MouseEvent

@Accessors class Drawable {

	extension val PApplet applet
	
	var Color debugBoundsColorFill = new Color(255, 0, 128, 100)
	var Color debugBoundsColorStroke = new Color(155, 0, 28, 100)
	
	var float x
	var float y
	var float width
	var float height
	var float halfWidth
	var float halfHeight

	new(PApplet applet, float x, float y, float width, float height) {
		this.applet = applet
		this.x = x
		this.y = y
		this.width = width
		this.height = height
		this.halfWidth = width/2
		this.halfHeight = height/2
		applet.registerMethod("pre", this)
		applet.registerMethod("draw", this)
		applet.registerMethod("post", this)
		applet.registerMethod("mouseEvent", this)
	}
	
	def void pre() {
	}
	def void draw() {
	}
	def void post() {
	}
	def void mouseEvent(MouseEvent event) {
	}
	
	def getBounds() {
		return new Rectangle(x as int, y as int, width as int, height as int)
	}

	def drawBounds() {
		matrix [
			fill(debugBoundsColorFill)
			stroke(debugBoundsColorStroke)
			val bounds = getBounds()
			rect(bounds.x, bounds.y, bounds.width, bounds.height)
		]
	}
	
	def mouseOver() {
		return bounds.contains(mouseX, mouseY)
	}
	
	def fill(Color it) {
		fill(RGB, alpha)
	}
	
	def stroke(Color it) {
		fill(RGB, alpha)
	}

	def matrix((PApplet)=>void work) {
		pushMatrix()
		work.apply(applet)
		popMatrix()
	}
	
	def x2() {
		return x+width
	}
	
	def y2() {
		return y+height
	}
	
	def void setWidth(float width) {
		this.width = width
		this.halfWidth = width/2
	}
	
	def void setHeight(float height) {
		this.height = height
		this.halfHeight = height/2
	}
	
	def float getWidth() {
		return width
	}
	
	def float getHeight() {
		return height
	}
	
	def println(Object... objects) {
		println(objects.map[it+""].reduce[a,b| a+", "+b])
	}

}
