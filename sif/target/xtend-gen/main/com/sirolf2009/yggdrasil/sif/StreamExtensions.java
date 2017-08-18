package com.sirolf2009.yggdrasil.sif;

import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

@SuppressWarnings("all")
public class StreamExtensions {
  public static <A extends Object> List<A> collect(final Stream<A> stream) {
    return stream.collect(Collectors.<A>toList());
  }
}
