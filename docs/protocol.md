# Протокол

**Меняется только по согласованию всех троих участников.**

Транспорт:
- клиент ↔ сервер: WebSocket, одно JSON-сообщение на кадр;
- бот ↔ сервер: TCP, одна строка = одно JSON-сообщение (`\n` в конце).

Поле `type` обязательно в каждом сообщении.

## Клиент → сервер

### `join`
```json
{"type":"join","name":"Alice","kind":"human"}
```
`kind`: `human` | `bot`.

### `command`
```json
{"type":"command","text":"go up"}
```

## Сервер → клиент

### `welcome`
```json
{"type":"welcome","you":"p1","config":{"width":40,"height":30,"tick_ms":150}}
```

### `state_update`
Присылается после каждого тика и изменения состава игроков. Структура — см. `state-model.md`.
```json
{"type":"state_update","tick":1234,"snakes":[...],"food":[[3,4]],"scores":{"p1":5}}
```

### `players`, `scores`
Ответы на команды «кто играет» / «покажи счёт».

### `event`
```json
{"type":"event","kind":"death","player":"p1","reason":"wall"}
```
`kind`: `death` | `respawn` | `join` | `leave`.

### `error`
```json
{"type":"error","code":"unknown_command","message":"Не понял: «..."}
```
Коды: `unknown_command`, `bad_json`, `not_joined`, `already_alive`, `not_dead`.

## TODO (неделя 1)
- [ ] согласовать формат `snakes` (см. state-model.md)
- [ ] нужен ли `reason` в сообщениях бота (лог решения A*)
- [ ] версия протокола в `welcome`
