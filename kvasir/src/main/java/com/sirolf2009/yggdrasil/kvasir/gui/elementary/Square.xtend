package com.sirolf2009.yggdrasil.kvasir.gui.elementary

import com.sirolf2009.yggdrasil.kvasir.Drawable
import java.awt.Color
import processing.core.PApplet
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors class Square extends Drawable {

	var Color color = Color.GRAY
	var float radii

	new(PApplet applet, float x, float y, float width, float height) {
		this(applet, x, y, width, height, 0)
	}

	new(PApplet applet, float x, float y, float width, float height, float radii) {
		super(applet, x, y, width, height)
		this.radii = radii
	}

	override draw() {
		matrix [
			fill(color)
			rect(x, y, getWidth(), getHeight(), radii)
		]
	}

}
