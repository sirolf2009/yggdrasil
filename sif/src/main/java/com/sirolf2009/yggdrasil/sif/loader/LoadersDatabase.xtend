package com.sirolf2009.yggdrasil.sif.loader

import org.apache.logging.log4j.LogManager
import com.datastax.driver.core.Session
import com.datastax.driver.mapping.MappingManager
import com.sirolf2009.yggdrasil.freyr.model.OrderbookTick

import static extension com.sirolf2009.yggdrasil.sif.TableExtensions.*

class LoadersDatabase {

	static val log = LogManager.logger
	
	def static getOrderbook(Session session, long count) {
		val mapper = new MappingManager(session).mapper(OrderbookTick)
		val query = '''SELECT * FROM freyr.orderbook WHERE exchange='GDAX' ORDER BY datetime LIMIT «count»;'''
		log.info(query)
		mapper.map(session.execute(query)).map[toTable()].reduce[a,b|
			a.append(b)
			a
		]
	}

}
