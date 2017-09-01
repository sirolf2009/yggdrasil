package com.sirolf2009.yggdrasil.kvasir.gui.elementary

import com.sirolf2009.yggdrasil.kvasir.gui.Drawable
import java.awt.Color
import processing.core.PApplet
import processing.core.PFont

class Label extends Drawable {
	
	var PFont font
	var Color color = new Color(100, 100, 100)
	var String text
	
	new(PApplet applet, float x, float y, String text) {
		this(applet, x, y, text, applet.createFont("Arial", 13, true))
	}
	
	new(PApplet applet, float x, float y, String text, PFont font) {
		super(applet, x, y, applet.textWidth(text), font.size)
		this.font = font
		setText(text)
	}
	
	override draw() {
		matrix[
			fill(color)
			textFont(font)
			text(text, x, y+font.size)
		]
	}
	
	def void setText(String text) {
		this.text = text
		updateBounds()
	}
	
	def private updateBounds() {
		val shape = getTextShape(text)
		this.width = Math.ceil(shape.key) as float
		this.height = shape.value
	}
	
	def void setFont(PFont font) {
		this.font = font
		updateBounds()
	}
	
	def private Pair<Float, Float> getTextShape(String text) {
		text.chars.mapToObj[font.getShape(it as char)].map[width -> font.size as float].reduce[a,b|
			a.key+b.key -> Math.max(a.value, b.value)
		].orElse(0f -> 0f)
	}
	
}