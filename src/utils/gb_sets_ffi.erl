-module(gb_sets_ffi).

-export([insert/2, next/1]).

insert(Set, Element) ->
    gb_sets:insert(Element, Set).

next(Set) ->
    case gb_sets:is_empty(Set) of
        true -> {error, nil};
        false -> {ok, gb_sets:take_smallest(Set)}
    end.
