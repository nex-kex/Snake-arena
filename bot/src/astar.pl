:- module(astar, [find_path/3, legal_moves/2]).

% Поиск пути до еды. Учитывает: границы, тела, запрет разворота на 180°.
% TODO(У3): legal_moves(+State, -Dirs), find_path(+Start, +Goal, -Path), эвристика Манхэттена

legal_moves(_Dir, []).        % TODO
find_path(_S, _G, []) :- fail.% TODO
