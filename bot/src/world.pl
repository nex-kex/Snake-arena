% Последний полный снимок мира, полученный от сервера.
:- module(world, [
    reset_world/0, update_world/1,
    snake/3, body/4, food/2, me/1, size/2,
    phase/1, tick/1, player_status/2, score/2, join_retry_after/1
]).

:- dynamic snake/3, body/4, food/2, me/1, size/2.
:- dynamic phase/1, tick/1, player_status/2, score/2, join_retry_after/1.

reset_world :-
    retractall(snake(_, _, _)), retractall(body(_, _, _, _)), retractall(food(_, _)),
    retractall(me(_)), retractall(size(_, _)), retractall(phase(_)), retractall(tick(_)),
    retractall(player_status(_, _)), retractall(score(_, _)), retractall(join_retry_after(_)).

update_world(welcome(_Version, Id, Width, Height)) :-
    retractall(me(_)), retractall(size(_, _)),
    assertz(me(Id)), assertz(size(Width, Height)).
update_world(state_update(Tick, Phase, _Remaining, Players, Snakes, Food, Scores, Self, Retry, _LastResult)) :-
    retractall(snake(_, _, _)), retractall(body(_, _, _, _)), retractall(food(_, _)),
    retractall(phase(_)), retractall(tick(_)), retractall(player_status(_, _)),
    retractall(score(_, _)), retractall(join_retry_after(_)),
    assertz(phase(Phase)), assertz(tick(Tick)), assertz(join_retry_after(Retry)),
    retractall(me(_)),
    ( Self == none -> true ; assertz(me(Self)) ),
    maplist(assert_player, Players), maplist(assert_snake, Snakes),
    maplist(assert_food, Food), maplist(assert_score, Scores).

assert_player(player(Id, _Name, _Kind, Status, _Ready, _SpawnRemaining)) :-
    assertz(player_status(Id, Status)).
assert_snake(snake(Id, Dir, Alive, Cells)) :-
    assertz(snake(Id, Dir, Alive)), assert_body_cells(Id, Cells, 0).
assert_body_cells(_, [], _).
assert_body_cells(Id, [[X,Y]|Rest], Index) :-
    assertz(body(Id, Index, X, Y)), Next is Index + 1,
    assert_body_cells(Id, Rest, Next).
assert_food([X,Y]) :- assertz(food(X,Y)).
assert_score(Id-Value) :- assertz(score(Id, Value)).
