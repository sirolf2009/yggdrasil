package com.sirolf2009.yggdrasil.kvasir

import com.sirolf2009.yggdrasil.freyr.Arguments
import com.sirolf2009.yggdrasil.freyr.SupplierOrderbookLive
import com.sirolf2009.yggdrasil.freyr.model.TableOrderbook
import java.time.Duration
import java.util.Optional
import java.util.function.Supplier
import org.knowm.xchange.currency.CurrencyPair
import org.knowm.xchange.gdax.GDAXExchange

class SketchOrderbookLive extends SketchOrderbook {

	static val take = 15
	val Supplier<Optional<TableOrderbook>> supplier

	new(TableOrderbook data, Supplier<Optional<TableOrderbook>> supplier) {
		super(data)
		this.supplier = supplier
		new Thread [
			while(true) {
				val newData = supplier.get()
				newData.ifPresent [
					this.data = it
					updateGraph()
				]
			}
		].start()
	}

	def static create(Supplier<Optional<TableOrderbook>> supplier) {
		runSketch(#[SketchOrderbookLive.name], new SketchOrderbookLive(supplier.first, supplier));
	}

	def static void main(String[] args) {
		create(new SupplierOrderbookLive(new Arguments(), GDAXExchange.canonicalName, CurrencyPair.BTC_EUR, Duration.ofSeconds(1), take))
	}

}
