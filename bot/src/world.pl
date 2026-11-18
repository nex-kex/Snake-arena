:- module(world, [reset_world/0, update_world/1, snake/3, body/4, food/2, me/1, size/2]).

% База фактов о мире (docs/state-model.md):
%   snake(Id, Dir, Alive)   body(Id, Index, X, Y)   food(X, Y)   me(Id)   size(W, H)
:- dynamic snake/3, body/4, food/2, me/1, size/2.

reset_world.                 % TODO(У3): retractall по всем фактам
update_world(_StateTerm).    % TODO(У3): assert из state_update
