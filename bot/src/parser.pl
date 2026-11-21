% JSON декодируется стандартной библиотекой SWI-Prolog.
% После декодирования DCG проверяет форму семантического сообщения.
:- module(parser, [parse_message/2]).

:- use_module(library(http/json)).

parse_message(Input, Term) :-
    input_atom(Input, JsonAtom),
    atom_json_dict(JsonAtom, Dict, []),
    get_dict(type, Dict, RawType),
    text_atom(RawType, Type),
    dict_to_tokens(Type, Dict, Tokens),
    phrase(server_message(Term), Tokens).

input_atom(Input, Atom) :-
    (   string(Input) -> atom_string(Atom, Input)
    ;   atom(Input) -> Atom = Input
    ).

text_atom(Value, Atom) :-
    (   atom(Value) -> Atom = Value
    ;   string(Value) -> atom_string(Atom, Value)
    ).

dict_to_tokens(welcome, Dict,
               [type(welcome), you(Id), dimensions(Width, Height)]) :-
    get_dict(you, Dict, RawId),
    text_atom(RawId, Id),
    get_dict(config, Dict, Config),
    get_dict(width, Config, Width),
    get_dict(height, Config, Height),
    integer(Width), integer(Height).

dict_to_tokens(state_update, Dict,
               [type(state_update), tick(Tick), snakes(Snakes), food(Food)]) :-
    get_dict(tick, Dict, Tick),
    integer(Tick),
    get_dict(snakes, Dict, RawSnakes),
    normalize_snakes(RawSnakes, Snakes),
    get_dict(food, Dict, RawFood),
    normalize_food(RawFood, Food).

dict_to_tokens(event, Dict,
               [type(event), event_data(Kind, Player, Reason)]) :-
    get_dict(kind, Dict, RawKind),
    text_atom(RawKind, Kind),
    get_dict(player, Dict, RawPlayer),
    text_atom(RawPlayer, Player),
    ( get_dict(reason, Dict, R) -> text_atom(R, Reason)
    ; Reason = none
    ).

dict_to_tokens(error, Dict,
               [type(error), error_data(Code, Message)]) :-
    get_dict(code, Dict, RawCode),
    text_atom(RawCode, Code),
    get_dict(message, Dict, RawMessage),
    ( string(RawMessage) -> Message = RawMessage
    ; atom_string(RawMessage, Message)
    ).

dict_to_tokens(Type, Dict, [type(other), other_data(Type, Dict)]).

% В state-model.md snakes — объект, ключи которого являются ID игроков.
% Дополнительно поддерживаем список объектов на случай согласования другого формата.
normalize_snakes(Raw, Snakes) :-
    (   is_dict(Raw)
    ->  dict_pairs(Raw, _, Pairs),
        maplist(pair_to_snake, Pairs, Snakes)
    ;   is_list(Raw)
    ->  maplist(item_to_snake, Raw, Snakes)
    ).

pair_to_snake(Id0-Data, Snake) :-
    text_atom(Id0, Id),
    snake_data(Id, Data, Snake).

item_to_snake(Data, Snake) :-
    get_dict(id, Data, RawId),
    text_atom(RawId, Id),
    snake_data(Id, Data, Snake).

snake_data(Id, Data, snake(Id, Dir, Alive, Body)) :-
    get_dict(dir, Data, RawDir),
    text_atom(RawDir, Dir),
    ( get_dict('alive?', Data, A0) -> Alive0 = A0
    ; get_dict(alive, Data, Alive0)
    ),
    boolean_value(Alive0, Alive),
    get_dict(body, Data, RawBody),
    maplist(normalize_point, RawBody, Body).

boolean_value(true, true).
boolean_value(false, false).

normalize_food(RawFood, Food) :-
    is_list(RawFood),
    maplist(normalize_point, RawFood, Food).

normalize_point([X, Y], [X, Y]) :-
    integer(X), integer(Y).

% DCG: грамматика уже нормализованных сообщений сервера.
server_message(welcome(Id, Width, Height)) -->
    [type(welcome), you(Id), dimensions(Width, Height)].
server_message(state_update(Tick, Snakes, Food)) -->
    [type(state_update), tick(Tick), snakes(Snakes), food(Food)].
server_message(event(Kind, Player, Reason)) -->
    [type(event), event_data(Kind, Player, Reason)].
server_message(error(Code, Message)) -->
    [type(error), error_data(Code, Message)].
server_message(unknown(Type, Dict)) -->
    [type(other), other_data(Type, Dict)].
