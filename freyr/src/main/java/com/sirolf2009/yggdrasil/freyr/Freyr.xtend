package com.sirolf2009.yggdrasil.freyr

import com.beust.jcommander.JCommander
import com.datastax.driver.core.Cluster
import com.datastax.driver.mapping.MappingManager
import com.sirolf2009.yggdrasil.freyr.model.OrderbookTick
import java.time.Duration
import org.apache.logging.log4j.LogManager
import org.knowm.xchange.currency.CurrencyPair
import org.knowm.xchange.gdax.GDAXExchange

class Freyr {

	static val log = LogManager.logger

	def static void main(String[] args) {
		extension val arguments = new Arguments()
		JCommander.newBuilder().addObject(arguments).build().parse(args)
		log.info("Starting with arguments: " + arguments)
		
		val session = Cluster.builder.addContactPoint("freyr").build().connect()
		val mapper = new MappingManager(session).mapper(OrderbookTick)
		val supplier = new SupplierOrderbookTick(GDAXExchange.canonicalName, CurrencyPair.BTC_EUR, Duration.ofSeconds(1), 15)
		while(true) {
			val data = supplier.get()
			log.info(data)
			data.ifPresent[mapper.save(it)]
		}
	}

}
