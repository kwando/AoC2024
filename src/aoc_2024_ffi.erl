-module(aoc_2024_ffi).
-export([binary_at/2, new_ets_map/2, ets_map_lookup/2, pd_get/1, pt_get/1]).

binary_at(Bin, Index) ->
    try
        {ok, binary:at(Bin, Index)}
    catch
        error:badarg -> {error, nil}
    end.


new_ets_map(Bin, Opts) ->
    ets:new(erlang:binary_to_atom(Bin, utf8), Opts).

ets_map_lookup(Table, Key) ->
    ets:lookup_element(Table, Key, 2).

pd_get(Key) ->
    case erlang:get(Key) of
        undefined -> {error, nil};
        Value -> {ok, Value}
    end.
pt_get(Key) ->
    try
        {ok, persistent_term:get(Key)}
    catch
        _ -> {error, nil}
    end.
