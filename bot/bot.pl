% Точка входа Prolog-бота. Запуск из каталога bot/: swipl bot.pl
:- use_module(src/net).
:- use_module(src/parser).
:- use_module(src/world).
:- use_module(src/strategy).
:- initialization(main, main).

protocol_version(1).
bot_name("SnakeBot").

main :-
    format("Snake Arena Prolog bot~nConnecting to localhost:9090...~n"),
    catch(run_bot, Error,
          (print_message(error, Error), net:disconnect, halt(1))).

run_bot :-
    setup_call_cleanup(net:connect(localhost, 9090), bot_session, net:disconnect).

% По контракту сервер сначала присылает hello и полный начальный снимок.
% Только после них клиент отправляет join.
bot_session :-
    world:reset_world,
    receive_required(Hello),
    ( Hello = hello(Version, _Config) -> true
    ; throw(error(unexpected_handshake_message(Hello), _)) ),
    protocol_version(Expected),
    ( Version =:= Expected -> true
    ; throw(error(protocol_version_mismatch(Version, Expected), _)) ),
    receive_required(InitialState),
    ( InitialState = state_update(_, _, _, _, _, _, _, Self, _, _) -> true
    ; throw(error(unexpected_handshake_message(InitialState), _)) ),
    world:update_world(InitialState),
    ( Self == none -> true
    ; format("Unexpected pre-join identity: ~w~n", [Self]) ),
    bot_name(Name),
    net:send_line(_{type:join, name:Name, kind:bot}),
    format("Join request sent as ~s.~n", [Name]),
    message_loop.

receive_required(Term) :-
    ( net:read_line_msg(Line)
    -> ( parse_line(Line, Term) -> true
       ; throw(error(invalid_handshake_message, _)) )
    ; throw(error(server_closed_during_handshake, _))
    ).

message_loop :-
    ( net:read_line_msg(Line) -> handle_line(Line), message_loop
    ; format("Server closed the connection.~n") ).

parse_line(Line, Term) :-
    catch(parser:parse_message(Line, Term), Error,
          (print_message(warning, Error), fail)).

handle_line(Line) :-
    ( parse_line(Line, Term) -> handle_term(Term)
    ; format("Warning: ignored an invalid server message.~n") ).

handle_term(welcome(Version, Id, Width, Height)) :-
    !, protocol_version(Expected),
    (Version =:= Expected -> true ; throw(error(protocol_version_mismatch(Version, Expected), _))),
    world:update_world(welcome(Version, Id, Width, Height)),
    format("Joined as ~w; field: ~wx~w~n", [Id, Width, Height]).
handle_term(entry_result(Player, Status, Remaining)) :-
    !, format("Entry result for ~w: ~w (~w)~n", [Player, Status, Remaining]).
handle_term(Term) :-
    Term = state_update(Tick, Phase, _Remaining, _Players, _Snakes, _Food, _Scores, _Self, _Retry, _LastResult),
    !, world:update_world(Term),
    ( strategy:choose_command(Term, Decision),
      Decision = command(Text, Reason)
    -> format("tick ~w [~w]: ~s (~s)~n", [Tick, Phase, Text, Reason]),
       net:send_line(_{type:command, text:Text, reason:Reason})
    ; true ).
handle_term(event(death, Player, Reason)) :-
    !, format("Player ~w died: ~w~n", [Player, Reason]).
handle_term(event(_Kind, _Player, _Reason)) :- !.
handle_term(error(Code, Message, Retry, Disconnect)) :-
    !, format("Server error ~w: ~s (retry ~w ms, disconnect=~w)~n",
              [Code, Message, Retry, Disconnect]).
handle_term(unknown(Type, _Dict)) :- !, format("Ignoring unknown server message type: ~w~n", [Type]).
