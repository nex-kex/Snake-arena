% Точка входа Prolog-бота Snake Arena.
% Запуск из каталога bot/: swipl bot.pl

:- use_module(src/net).
:- use_module(src/parser).
:- use_module(src/world).
:- use_module(src/astar).
:- use_module(src/strategy).

:- initialization(main, main).

main :-
    format("Snake Arena Prolog bot~n"),
    format("Connecting to localhost:9090...~n"),
    catch(run_bot, Error,
          ( print_message(error, Error),
            net:disconnect,
            halt(1)
          )).

run_bot :-
    setup_call_cleanup(
        net:connect(localhost, 9090),
        bot_session,
        net:disconnect
    ).

bot_session :-
    Join = _{type:join, name:"SnakeBot", kind:bot},
    net:send_line(Join),
    format("Join message sent. Waiting for server...~n"),
    message_loop.

message_loop :-
    (   net:read_line_msg(Line)
    ->  handle_line(Line),
        message_loop
    ;   format("Server closed the connection.~n")
    ).

handle_line(Line) :-
    catch(parser:parse_message(Line, Term), Error,
          ( print_message(warning, Error), fail )),
    !,
    handle_term(Term).
handle_line(_Line) :-
    format("Warning: ignored an invalid server message.~n").

handle_term(welcome(Id, Width, Height)) :-
    !,
    world:update_world(welcome(Id, Width, Height)),
    format("Joined as ~w; field: ~wx~w~n", [Id, Width, Height]).
handle_term(state_update(Tick, Snakes, Food)) :-
    !,
    State = state_update(Tick, Snakes, Food),
    world:update_world(State),
    strategy:choose_command(State, command(Text, Reason)),
    format("tick ~w: ~w (~w)~n", [Tick, Text, Reason]),
    net:send_line(_{type:command, text:Text}).
handle_term(event(death, Player, _Reason)) :-
    !,
    (   world:me(Player)
    ->  format("Bot died. Requesting respawn.~n"),
        net:send_line(_{type:command, text:"respawn"})
    ;   true
    ).
handle_term(event(_Kind, _Player, _Reason)) :-
    !.
handle_term(error(Code, Message)) :-
    !,
    format("Server error ~w: ~s~n", [Code, Message]).
handle_term(Other) :-
    format("Server message: ~q~n", [Other]).
