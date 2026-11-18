:- use_module(library(plunit)).

:- begin_tests(parser).
test(todo, [true]) :- true.   % TODO(У3): разбор state_update
:- end_tests(parser).

:- begin_tests(astar).
test(todo, [true]) :- true.   % TODO(У3): путь без столкновений, нет разворота
:- end_tests(astar).
