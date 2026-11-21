% TCP-транспорт: одно JSON-сообщение на одну строку.
:- module(net, [
    connect/2,
    send_line/1,
    read_line_msg/1,
    disconnect/0
]).

:- use_module(library(socket)).
:- use_module(library(http/json)).
:- use_module(library(readutil)).

:- dynamic connection/3.

connect(Host, Port) :-
    disconnect,
    tcp_socket(Socket),
    catch(
        ( tcp_connect(Socket, Host:Port, StreamPair),
          stream_pair(StreamPair, In, Out),
          set_stream(In, encoding(utf8)),
          set_stream(Out, encoding(utf8)),
          assertz(connection(Socket, In, Out))
        ),
        Error,
        ( tcp_close_socket(Socket), throw(Error) )
    ).

send_line(Message) :-
    connection(_Socket, _In, Out),
    is_dict(Message),
    json_write_dict(Out, Message, [width(0)]),
    nl(Out),
    flush_output(Out).

% Возвращает исходную строку JSON. Разбор выполняет parser.pl.
% При EOF предикат завершается неуспешно.
read_line_msg(Line) :-
    connection(_Socket, In, _Out),
    read_line_to_string(In, Line),
    Line \== end_of_file.

disconnect :-
    (   retract(connection(Socket, In, Out))
    ->  catch(close(In), _, true),
        catch(close(Out), _, true),
        catch(tcp_close_socket(Socket), _, true)
    ;   true
    ).
