package com.sirolf2009.yggdrasil.sif.loader;

import com.datastax.driver.core.Session;
import com.datastax.driver.mapping.Mapper;
import com.datastax.driver.mapping.MappingManager;
import com.sirolf2009.yggdrasil.freyr.model.OrderbookTick;
import com.sirolf2009.yggdrasil.freyr.model.TableOrderbook;
import com.sirolf2009.yggdrasil.sif.TableExtensions;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.Functions.Function2;
import org.eclipse.xtext.xbase.lib.IterableExtensions;

@SuppressWarnings("all")
public class LoadersDatabase {
  private final static Logger log = LogManager.getLogger();
  
  public static TableOrderbook getOrderbook(final Session session, final long count) {
    TableOrderbook _xblockexpression = null;
    {
      final Mapper<OrderbookTick> mapper = new MappingManager(session).<OrderbookTick>mapper(OrderbookTick.class);
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("SELECT * FROM freyr.orderbook WHERE exchange=\'GDAX\' ORDER BY datetime LIMIT ");
      _builder.append(count);
      _builder.append(";");
      final String query = _builder.toString();
      LoadersDatabase.log.info(query);
      final Function1<OrderbookTick, TableOrderbook> _function = (OrderbookTick it) -> {
        return TableExtensions.toTable(it);
      };
      final Function2<TableOrderbook, TableOrderbook, TableOrderbook> _function_1 = (TableOrderbook a, TableOrderbook b) -> {
        TableOrderbook _xblockexpression_1 = null;
        {
          a.append(b);
          _xblockexpression_1 = a;
        }
        return _xblockexpression_1;
      };
      _xblockexpression = IterableExtensions.<TableOrderbook>reduce(IterableExtensions.<OrderbookTick, TableOrderbook>map(mapper.map(session.execute(query)), _function), _function_1);
    }
    return _xblockexpression;
  }
}
