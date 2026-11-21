% Запуск из каталога bot:
% swipl -g run_tests -t halt test/all.pl

:- use_module(library(plunit)).
:- use_module('../src/parser').
:- use_module('../src/world').
:- use_module('../src/astar').
:- use_module('../src/strategy').

:- begin_tests(parser).

test(welcome_message) :-
    parse_message(
        "{\"type\":\"welcome\",\"you\":\"p1\",\"config\":{\"width\":40,\"height\":30,\"tick_ms\":150}}",
        welcome(p1, 40, 30)
    ).

test(state_update_message) :-
    parse_message(
        "{\"type\":\"state_update\",\"tick\":12,\"snakes\":{\"p1\":{\"body\":[[5,5],[4,5]],\"dir\":\"right\",\"alive?\":true}},\"food\":[[10,10]]}",
        state_update(12, [snake(p1, right, true, [[5,5],[4,5]])], [[10,10]])
    ).

test(event_message) :-
    parse_message(
        "{\"type\":\"event\",\"kind\":\"death\",\"player\":\"p1\",\"reason\":\"wall\"}",
        event(death, p1, wall)
    ).

:- end_tests(parser).

:- begin_tests(world).

test(update_and_query, [setup(reset_world), cleanup(reset_world)]) :-
    update_world(welcome(p1, 40, 30)),
    update_world(state_update(1,
        [snake(p1, right, true, [[5,5],[4,5]])],
        [[10,10]])),
    me(p1),
    size(40, 30),
    snake(p1, right, true),
    body(p1, 0, 5, 5),
    body(p1, 1, 4, 5),
    food(10, 10).

:- end_tests(world).

:- begin_tests(path_basics).

test(no_reverse) :-
    legal_moves(right, Moves),
    \+ member(left, Moves).

test(manhattan_distance) :-
    manhattan([5,5], [10,8], 8).

test(baseline_path) :-
    find_path([1,1], [3,2], [[2,1],[3,1],[3,2]]).

:- end_tests(path_basics).
