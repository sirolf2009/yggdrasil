package com.sirolf2009.yggdrasil.kvasir.gui.elementary

import com.sirolf2009.yggdrasil.kvasir.Drawable
import java.awt.Color
import processing.core.PApplet
import java.awt.Rectangle

class Circle extends Drawable {

	var Color color = Color.GRAY

	new(PApplet applet, float x, float y, float width, float height) {
		super(applet, x, y, width, height)
	}

	override draw() {
		matrix [
			fill(color)
			ellipse(x, y, getWidth(), getHeight())
		]
	}

	override getBounds() {
		return new Rectangle((x-halfWidth) as int, (y - halfHeight) as int, width as int, height as int)
	}

}
