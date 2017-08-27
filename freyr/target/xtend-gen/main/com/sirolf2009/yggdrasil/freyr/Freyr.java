package com.sirolf2009.yggdrasil.freyr;

import com.beust.jcommander.JCommander;
import com.datastax.driver.core.Cluster;
import com.datastax.driver.core.Session;
import com.datastax.driver.mapping.Mapper;
import com.datastax.driver.mapping.MappingManager;
import com.sirolf2009.yggdrasil.freyr.Arguments;
import com.sirolf2009.yggdrasil.freyr.SupplierOrderbookTick;
import com.sirolf2009.yggdrasil.freyr.model.OrderbookTick;
import java.time.Duration;
import java.util.Optional;
import java.util.function.Consumer;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.eclipse.xtext.xbase.lib.Extension;
import org.knowm.xchange.currency.CurrencyPair;
import org.knowm.xchange.gdax.GDAXExchange;

@SuppressWarnings("all")
public class Freyr {
  private final static Logger log = LogManager.getLogger();
  
  public static void main(final String[] args) {
    @Extension
    final Arguments arguments = new Arguments();
    JCommander.newBuilder().addObject(arguments).build().parse(args);
    Freyr.log.info(("Starting with arguments: " + arguments));
    final Session session = Cluster.builder().addContactPoint("freyr").build().connect();
    final Mapper<OrderbookTick> mapper = new MappingManager(session).<OrderbookTick>mapper(OrderbookTick.class);
    String _canonicalName = GDAXExchange.class.getCanonicalName();
    Duration _ofSeconds = Duration.ofSeconds(1);
    final SupplierOrderbookTick supplier = new SupplierOrderbookTick(_canonicalName, CurrencyPair.BTC_EUR, _ofSeconds, 15);
    while (true) {
      {
        final Optional<OrderbookTick> data = supplier.get();
        Freyr.log.info(data);
        final Consumer<OrderbookTick> _function = (OrderbookTick it) -> {
          mapper.save(it);
        };
        data.ifPresent(_function);
      }
    }
  }
}
