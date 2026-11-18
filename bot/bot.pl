% Точка входа бота. Запуск: swipl bot.pl
% Бот подключается к серверу как обычный игрок (kind = bot).

:- use_module(src/net).
:- use_module(src/parser).
:- use_module(src/world).
:- use_module(src/astar).
:- use_module(src/strategy).

:- initialization(main, main).

main :-
    format("snake-arena bot: TODO~n").
    % TODO(У3): connect(localhost, 9090) -> join -> цикл:
    %   читать строку -> parse_message -> обновить факты -> выбрать команду -> отправить
