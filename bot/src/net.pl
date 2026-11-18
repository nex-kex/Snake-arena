:- module(net, [connect/2, send_line/1, read_line_msg/1, disconnect/0]).

% TCP-клиент: одна строка = одно JSON-сообщение.
% TODO(У3): tcp_connect/3, streams, json_write_dict/json_read_dict

connect(_Host, _Port) :- fail.   % TODO
send_line(_Msg) :- fail.         % TODO
read_line_msg(_Msg) :- fail.     % TODO
disconnect.                      % TODO
