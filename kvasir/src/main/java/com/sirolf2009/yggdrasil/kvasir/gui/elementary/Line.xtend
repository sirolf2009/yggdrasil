package com.sirolf2009.yggdrasil.kvasir.gui.elementary

import com.sirolf2009.yggdrasil.kvasir.gui.Drawable
import processing.core.PApplet
import java.awt.Color
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors class Line extends Drawable {
	
	var Color color
	
	new(PApplet applet, float x, float y, float width, float height) {
		this(applet, x, y, width, height, Color.BLACK)
	}
	
	new(PApplet applet, float x, float y, float width, float height, Color color) {
		super(applet, x, y, width, height)
		this.color = color
	}
	
	override draw() {
		matrix[
			stroke(color)
			line(x, y, getWidth(), getHeight())
		]
	}
	
}