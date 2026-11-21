% Простая безопасная стратегия выбирает соседнюю свободную клетку,
% уменьшающую расстояние до еды.
% Полноценный поиск A* и прогноз столкновений будут позднее.
:- module(strategy, [choose_command/2]).

:- use_module(world).
:- use_module(astar).

choose_command(_World, command("respawn", "snake is not alive")) :-
    world:me(Id),
    \+ world:snake(Id, _, true),
    !.

choose_command(_World, command(Text, Reason)) :-
    world:me(Id),
    world:snake(Id, CurrentDir, true),
    world:body(Id, 0, X, Y),
    astar:legal_moves(CurrentDir, Directions),
    findall(Score-Direction,
            ( member(Direction, Directions),
              next_cell(X, Y, Direction, NX, NY),
              safe_cell(NX, NY),
              nearest_food_distance(NX, NY, Score)
            ),
            Candidates),
    Candidates \= [],
    keysort(Candidates, [_-BestDirection | _]),
    direction_text(BestDirection, Text),
    format(string(Reason), "safe neighbor; direction ~w", [BestDirection]),
    !.

choose_command(_World, command(Text, "no safe neighbor found; keep current direction")) :-
    world:me(Id),
    world:snake(Id, CurrentDir, true),
    !,
    direction_text(CurrentDir, Text).

choose_command(_World, command("respawn", "no active snake information")).

next_cell(X, Y, up, X, NY)    :- NY is Y - 1.
next_cell(X, Y, down, X, NY)  :- NY is Y + 1.
next_cell(X, Y, left, NX, Y)  :- NX is X - 1.
next_cell(X, Y, right, NX, Y) :- NX is X + 1.

safe_cell(X, Y) :-
    world:size(Width, Height),
    X >= 0, X < Width,
    Y >= 0, Y < Height,
    \+ world:body(_OtherId, _Index, X, Y).

nearest_food_distance(X, Y, Distance) :-
    findall(D,
            ( world:food(FX, FY),
              astar:manhattan([X, Y], [FX, FY], D)
            ),
            Distances),
    ( Distances = [] -> Distance = 100000
    ; min_list(Distances, Distance)
    ).

direction_text(up, "go up").
direction_text(down, "go down").
direction_text(left, "go left").
direction_text(right, "go right").
