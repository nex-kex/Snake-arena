% Разбор сообщений серверного протокола Snake Arena v1.
:- module(parser, [parse_message/2]).

:- use_module(library(http/json)).

parse_message(Input, Term) :-
    input_atom(Input, JsonAtom),
    atom_json_dict(JsonAtom, Dict, []),
    is_dict(Dict),
    get_dict(type, Dict, RawType),
    text_atom(RawType, Type),
    parse_type(Type, Dict, Term).

input_atom(Input, Atom) :-
    ( string(Input) -> atom_string(Atom, Input)
    ; atom(Input) -> Atom = Input
    ).

text_atom(Value, Atom) :-
    ( atom(Value) -> Atom = Value
    ; string(Value) -> atom_string(Atom, Value)
    ).

json_null(null).
json_null(@(null)).

parse_type(hello, Dict, hello(Version, Config)) :-
    get_dict(protocol_version, Dict, Version), integer(Version),
    get_dict(config, Dict, Config), validate_config(Config).
parse_type(welcome, Dict, welcome(Version, Id, Width, Height)) :-
    get_dict(protocol_version, Dict, Version), integer(Version),
    get_dict(you, Dict, RawId), text_atom(RawId, Id),
    get_dict(config, Dict, Config), validate_config(Config),
    get_dict(width, Config, Width), get_dict(height, Config, Height).
parse_type(entry_result, Dict, entry_result(Player, Status, Remaining)) :-
    get_dict(player, Dict, RawPlayer), text_atom(RawPlayer, Player),
    get_dict(status, Dict, RawStatus), text_atom(RawStatus, Status),
    memberchk(Status, [alive, spawning, ready]),
    get_dict(spawn_remaining_ms, Dict, RawRemaining),
    ( Status == spawning -> integer(RawRemaining), RawRemaining >= 0, Remaining = RawRemaining
    ; json_null(RawRemaining), Remaining = none
    ).
parse_type(state_update, Dict,
           state_update(Tick, Phase, Remaining, Players, Snakes, Food, Scores, Self, Retry, LastResult)) :-
    get_dict(server_time_ms, Dict, ServerTime), integer(ServerTime), ServerTime >= 0,
    get_dict(tick, Dict, Tick), integer(Tick), Tick >= 0,
    get_dict(round, Dict, Round), is_dict(Round),
    get_dict(phase, Round, RawPhase), text_atom(RawPhase, Phase),
    memberchk(Phase, [waiting, playing, intermission]),
    get_dict(remaining_ms, Round, RawRemaining),
    ( Phase == waiting -> json_null(RawRemaining), Remaining = none
    ; integer(RawRemaining), RawRemaining >= 0, Remaining = RawRemaining
    ),
    get_dict(players, Dict, RawPlayers), maplist(normalize_player, RawPlayers, Players),
    get_dict(snakes, Dict, RawSnakes), maplist(item_to_snake, RawSnakes, Snakes),
    get_dict(food, Dict, RawFood), normalize_food(RawFood, Food),
    get_dict(scores, Dict, RawScores), normalize_scores(RawScores, Scores),
    get_dict(self, Dict, SelfDict), is_dict(SelfDict),
    get_dict(player, SelfDict, RawSelf),
    ( json_null(RawSelf) -> Self = none ; text_atom(RawSelf, Self) ),
    get_dict(join_retry_after_ms, SelfDict, Retry), integer(Retry), Retry >= 0,
    get_dict(last_result, Dict, LastResult).
parse_type(event, Dict, event(Kind, Player, Reason)) :-
    get_dict(kind, Dict, RawKind), text_atom(RawKind, Kind),
    memberchk(Kind, [join, spawn, respawn, death, leave]),
    get_dict(player, Dict, RawPlayer), text_atom(RawPlayer, Player),
    get_dict(reason, Dict, RawReason),
    ( json_null(RawReason) -> Reason = none ; text_atom(RawReason, Reason) ).
parse_type(error, Dict, error(Code, Message, Retry, Disconnect)) :-
    get_dict(code, Dict, RawCode), text_atom(RawCode, Code),
    get_dict(message, Dict, Message), string(Message),
    get_dict(retry_after_ms, Dict, Retry), integer(Retry), Retry >= 0,
    get_dict(disconnect, Dict, Disconnect), boolean_value(Disconnect, _).
parse_type(Type, Dict, unknown(Type, Dict)) :-
    \+ memberchk(Type, [hello, welcome, entry_result, state_update, event, error]).

validate_config(Config) :-
    is_dict(Config),
    get_dict(width, Config, W), integer(W), W > 0,
    get_dict(height, Config, H), integer(H), H > 0,
    get_dict(tick_ms, Config, Tick), integer(Tick), Tick > 0,
    get_dict(round_ms, Config, Round), integer(Round), Round > 0,
    get_dict(intermission_ms, Config, Intermission), integer(Intermission), Intermission >= 0,
    get_dict(spawn_wait_ms, Config, Spawn), integer(Spawn), Spawn >= 0,
    get_dict(join_cooldown_ms, Config, Cooldown), integer(Cooldown), Cooldown >= 0,
    get_dict(max_players, Config, MaxPlayers), integer(MaxPlayers), MaxPlayers > 0,
    get_dict(max_name_length, Config, MaxName), integer(MaxName), MaxName > 0,
    get_dict(min_food, Config, MinFood), integer(MinFood), MinFood >= 0,
    get_dict(max_queued_turns, Config, MaxTurns), integer(MaxTurns), MaxTurns >= 0.

normalize_player(Data, player(Id, Name, Kind, Status, Ready, SpawnRemaining)) :-
    is_dict(Data),
    get_dict(id, Data, RawId), text_atom(RawId, Id),
    get_dict(name, Data, RawName), text_atom(RawName, Name),
    get_dict(kind, Data, RawKind), text_atom(RawKind, Kind),
    get_dict(status, Data, RawStatus), text_atom(RawStatus, Status),
    memberchk(Status, [alive, dead, spawning, ready]),
    get_dict(ready, Data, RawReady), boolean_value(RawReady, Ready),
    get_dict(spawn_remaining_ms, Data, RawSpawn),
    ( Status == spawning -> integer(RawSpawn), RawSpawn >= 0, SpawnRemaining = RawSpawn
    ; json_null(RawSpawn), SpawnRemaining = none
    ).

item_to_snake(Data, snake(Id, Dir, true, Body)) :-
    is_dict(Data),
    get_dict(id, Data, RawId), text_atom(RawId, Id),
    get_dict(dir, Data, RawDir), text_atom(RawDir, Dir),
    memberchk(Dir, [up, down, left, right]),
    get_dict(alive, Data, true),
    get_dict(body, Data, RawBody), maplist(normalize_point, RawBody, Body),
    length(Body, Length), Length >= 3.

normalize_food(RawFood, Food) :- is_list(RawFood), maplist(normalize_point, RawFood, Food).
normalize_scores(RawScores, Scores) :-
    is_dict(RawScores), dict_pairs(RawScores, _, Pairs),
    maplist(normalize_score, Pairs, Scores).
normalize_score(RawId-Score, Id-Score) :- text_atom(RawId, Id), integer(Score), Score >= 0.

boolean_value(true, true).
boolean_value(false, false).

normalize_point([X, Y], [X, Y]) :- integer(X), integer(Y).
