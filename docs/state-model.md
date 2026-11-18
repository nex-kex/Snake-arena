# Модель состояния

Черновик. Единая модель для сервера (Clojure), клиента (TS) и бота (Prolog-факты).

## Мир (на сервере хранится в одном `ref`)
```clojure
{:tick    0
 :config  {:width 40 :height 30}
 :players {"p1" {:name "Alice" :kind :human :score 0}}
 :snakes  {"p1" {:body   [[5 5] [4 5] [3 5]]  ; голова — первый элемент
                 :dir    :right
                 :queue  []                    ; не более 2 отложенных поворотов
                 :alive? true
                 :grace  3}}                   ; тиков неуязвимости
 :food    #{[10 10]}}
```

## Представление в других языках
- TypeScript: интерфейсы в `client/src/types.ts`.
- Prolog-факты (в `bot/src/world.pl`):
  `snake(Id, Dir, Alive)`, `body(Id, Index, X, Y)`, `food(X, Y)`, `me(Id)`, `size(W, H)`.

## Инварианты
- Клетка занята не более чем одним телом (кроме момента коллизии внутри тика).
- Минимум одна змейка в `:snakes` на игрока; мёртвые не хранятся.
- `:queue` не длиннее 2.
