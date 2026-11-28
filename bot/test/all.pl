% Запуск из каталога bot: swipl -g run_tests -t halt test/all.pl
:- use_module(library(plunit)).
:- use_module('../src/parser').
:- use_module('../src/world').
:- use_module('../src/astar').
:- use_module('../src/strategy').

sample_state('{"type":"state_update","server_time_ms":1800000000000,"tick":12,"round":{"phase":"playing","remaining_ms":168000},"players":[{"id":"p1","name":"Alice","kind":"human","status":"alive","ready":false,"spawn_remaining_ms":null}],"snakes":[{"id":"p1","name":"Alice","body":[[5,5],[4,5],[3,5]],"dir":"right","alive":true}],"food":[[10,10],[20,20]],"scores":{"p1":2},"self":{"player":"p1","join_retry_after_ms":0},"last_result":null}').

:- begin_tests(parser).

test(hello_v1) :-
    parse_message('{"type":"hello","protocol_version":1,"config":{"width":40,"height":30,"tick_ms":150,"round_ms":180000,"intermission_ms":5000,"spawn_wait_ms":5000,"join_cooldown_ms":5000,"max_players":7,"max_name_length":16,"min_food":5,"max_queued_turns":2}}',
                 hello(1, _)).

test(welcome_v1) :-
    parse_message('{"type":"welcome","protocol_version":1,"you":"p1","config":{"width":40,"height":30,"tick_ms":150,"round_ms":180000,"intermission_ms":5000,"spawn_wait_ms":5000,"join_cooldown_ms":5000,"max_players":7,"max_name_length":16,"min_food":5,"max_queued_turns":2}}',
                 welcome(1, p1, 40, 30)).

test(entry_result) :-
    parse_message('{"type":"entry_result","player":"p1","status":"spawning","spawn_remaining_ms":2400}',
                 entry_result(p1, spawning, 2400)).

test(state_update_v1) :-
    sample_state(Json),
    parse_message(Json,
        state_update(12, playing, 168000,
          [player(p1, 'Alice', human, alive, false, none)],
          [snake(p1, right, true, [[5,5],[4,5],[3,5]])],
          [[10,10],[20,20]], [p1-2], p1, 0, null)).

test(initial_state_null_self) :-
    parse_message('{"type":"state_update","server_time_ms":1800000000000,"tick":0,"round":{"phase":"waiting","remaining_ms":null},"players":[],"snakes":[],"food":[],"scores":{},"self":{"player":null,"join_retry_after_ms":0},"last_result":null}',
        state_update(0, waiting, none, [], [], [], [], none, 0, null)).

test(event_with_reason) :-
    parse_message('{"type":"event","kind":"death","player":"p1","reason":"wall"}',
                 event(death, p1, wall)).

test(event_null_reason) :-
    parse_message('{"type":"event","kind":"spawn","player":"p1","reason":null}',
                 event(spawn, p1, none)).

test(error_v1) :-
    parse_message('{"type":"error","code":"arena_full","message":"Full","retry_after_ms":5000,"disconnect":false}',
                 error(arena_full, "Full", 5000, false)).

test(unknown_type) :-
    parse_message('{"type":"players","players":[]}', unknown(players, _)).

:- end_tests(parser).

:- begin_tests(world).

test(update_and_query, [setup(reset_world), cleanup(reset_world)]) :-
    update_world(welcome(1, p1, 40, 30)),
    parse_message('{"type":"state_update","server_time_ms":1800000000000,"tick":12,"round":{"phase":"playing","remaining_ms":168000},"players":[{"id":"p1","name":"Alice","kind":"bot","status":"alive","ready":false,"spawn_remaining_ms":null}],"snakes":[{"id":"p1","name":"Alice","body":[[5,5],[4,5],[3,5]],"dir":"right","alive":true}],"food":[[10,10]],"scores":{"p1":2},"self":{"player":"p1","join_retry_after_ms":0},"last_result":null}', Term),
    update_world(Term),
    me(p1), size(40,30), phase(playing), tick(12),
    player_status(p1, alive), score(p1,2), snake(p1,right,true),
    body(p1,0,5,5), body(p1,1,4,5), food(10,10).

:- end_tests(world).

:- begin_tests(path_basics).
test(no_reverse) :- legal_moves(right, Moves), \+ member(left, Moves).
test(manhattan_distance) :- manhattan([5,5], [10,8], 8).
test(baseline_path) :- find_path([1,1], [3,2], [[2,1],[3,1],[3,2]]).
:- end_tests(path_basics).

:- begin_tests(strategy).

test(no_respawn_outside_playing, [setup(reset_world), cleanup(reset_world)]) :-
    parse_message('{"type":"state_update","server_time_ms":1800000000000,"tick":0,"round":{"phase":"waiting","remaining_ms":null},"players":[],"snakes":[],"food":[],"scores":{},"self":{"player":null,"join_retry_after_ms":0},"last_result":null}', State),
    update_world(State),
    choose_command(State, none).

:- end_tests(strategy).
