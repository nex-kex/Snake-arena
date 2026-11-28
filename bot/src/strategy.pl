% Простая эвристика для живой змейки. Полноценный A* и прогноз столкновений
% намеренно остаются следующей задачей.
:- module(strategy, [choose_command/2]).

:- use_module(world).
:- use_module(astar).

% Никаких игровых команд вне playing или без подтверждённой живой змейки.
choose_command(_World, none) :-
    ( \+ world:phase(playing)
    ; \+ world:me(Id)
    ; \+ world:snake(Id, _, true)
    ), !.

choose_command(_World, command(Text, Reason)) :-
    world:me(Id), world:snake(Id, CurrentDir, true),
    world:body(Id, 0, X, Y),
    astar:legal_moves(CurrentDir, Directions),
    findall(Score-Direction,
            ( member(Direction, Directions),
              next_cell(X, Y, Direction, NX, NY),
              safe_cell(NX, NY), nearest_food_distance(NX, NY, Score)
            ), Candidates),
    Candidates \= [],
    keysort(Candidates, [_-BestDirection|_]),
    direction_text(BestDirection, Text),
    format(string(Reason), "safe neighbor; direction ~w", [BestDirection]), !.
choose_command(_World, command(Text, "no safe neighbor found; keep current direction")) :-
    world:me(Id), world:snake(Id, CurrentDir, true), !,
    direction_text(CurrentDir, Text).

next_cell(X,Y,up,X,NY) :- NY is Y-1.
next_cell(X,Y,down,X,NY) :- NY is Y+1.
next_cell(X,Y,left,NX,Y) :- NX is X-1.
next_cell(X,Y,right,NX,Y) :- NX is X+1.

safe_cell(X,Y) :-
    world:size(W,H), X >= 0, X < W, Y >= 0, Y < H,
    \+ world:body(_Other, _Index, X, Y).

nearest_food_distance(X,Y,D) :-
    findall(Distance,
            (world:food(FX,FY), astar:manhattan([X,Y],[FX,FY],Distance)), Ds),
    (Ds = [] -> D = 100000 ; min_list(Ds,D)).

direction_text(up, "go up").
direction_text(down, "go down").
direction_text(left, "go left").
direction_text(right, "go right").
