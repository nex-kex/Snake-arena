:- module(parser, [parse_message/2]).

% DCG-разбор сообщений сервера (docs/protocol.md) в термы.
% TODO(У3): phrase//1 для state_update, event, error, welcome
% Результат, например: state_update(Tick, Snakes, Food)

parse_message(_Line, _Term) :- fail.   % TODO
