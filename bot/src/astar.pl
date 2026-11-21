% Допустимые направления и геометрия поля.
:- module(astar, [find_path/3, legal_moves/2, manhattan/3]).

:- use_module(world).

% Запрет разворота на 180 градусов.
legal_moves(up,    [up, left, right]).
legal_moves(down,  [down, left, right]).
legal_moves(left,  [left, up, down]).
legal_moves(right, [right, up, down]).

manhattan([X1, Y1], [X2, Y2], Distance) :-
    Distance is abs(X1 - X2) + abs(Y1 - Y2).

% Учебный базовый маршрут без обхода препятствий.
% Path содержит клетки после Start, включая Goal.
% Это НЕ полноценный A*: препятствия будут добавлены на следующем этапе.
find_path([X, Y], [GX, GY], Path) :-
    integer(X), integer(Y), integer(GX), integer(GY),
    horizontal_steps(X, GX, Y, Horizontal),
    vertical_steps(Y, GY, GX, Vertical),
    append(Horizontal, Vertical, Path).

horizontal_steps(X, X, _Y, []) :- !.
horizontal_steps(X, GX, Y, [[NextX, Y] | Rest]) :-
    ( GX > X -> NextX is X + 1 ; NextX is X - 1 ),
    horizontal_steps(NextX, GX, Y, Rest).

vertical_steps(Y, Y, _X, []) :- !.
vertical_steps(Y, GY, X, [[X, NextY] | Rest]) :-
    ( GY > Y -> NextY is Y + 1 ; NextY is Y - 1 ),
    vertical_steps(NextY, GY, X, Rest).
