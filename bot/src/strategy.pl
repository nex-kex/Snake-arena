:- module(strategy, [choose_command/2]).

% Выбор действия: ближайшая достижимая еда -> первый шаг пути -> фраза-команда.
% Если мёртв — "respawn". Если пути нет — безопасный ход.
% TODO(У3): choose_command(+World, -command(Text, Reason))

choose_command(_World, command("go up", "TODO")).
