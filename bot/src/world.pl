% Динамическая база фактов, отражающая последнее известное состояние игры.
:- module(world, [
    reset_world/0,
    update_world/1,
    snake/3,
    body/4,
    food/2,
    me/1,
    size/2
]).

:- dynamic snake/3, body/4, food/2, me/1, size/2.

reset_world :-
    retractall(snake(_, _, _)),
    retractall(body(_, _, _, _)),
    retractall(food(_, _)),
    retractall(me(_)),
    retractall(size(_, _)).

% welcome сообщает ID нашего игрока и размеры поля.
update_world(welcome(Id, Width, Height)) :-
    retractall(me(_)),
    retractall(size(_, _)),
    assertz(me(Id)),
    assertz(size(Width, Height)).

% Каждый state_update заменяет старую динамическую картину мира новой.
update_world(state_update(_Tick, Snakes, Food)) :-
    retractall(snake(_, _, _)),
    retractall(body(_, _, _, _)),
    retractall(food(_, _)),
    maplist(assert_snake, Snakes),
    maplist(assert_food, Food).

assert_snake(snake(Id, Dir, Alive, BodyCells)) :-
    assertz(snake(Id, Dir, Alive)),
    assert_body_cells(Id, BodyCells, 0).

assert_body_cells(_Id, [], _Index).
assert_body_cells(Id, [[X, Y] | Rest], Index) :-
    assertz(body(Id, Index, X, Y)),
    Next is Index + 1,
    assert_body_cells(Id, Rest, Next).

assert_food([X, Y]) :-
    assertz(food(X, Y)).
