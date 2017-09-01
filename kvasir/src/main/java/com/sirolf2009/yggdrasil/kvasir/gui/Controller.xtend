package com.sirolf2009.yggdrasil.kvasir.gui

import org.apache.logging.log4j.LogManager
import processing.core.PApplet

abstract class Controller extends Drawable {

	private val log = LogManager.logger
	private Object lock = new Object()

	new(PApplet applet, float x, float y, float width, float height) {
		super(applet, x, y, width, height)
		new Thread [
			synchronized(lock) {
				lock.wait()
			}
			while(true) {
				try {
					work()
				} catch(Exception e) {
					log.error("Failed to work", e)
				}
			}
		].start()
	}

	override pre() {
		synchronized(lock) {
			lock.notify()
		}
	}

	def abstract void work()

}
