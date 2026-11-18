(ns snake-arena.config
  "Константы игры. TODO(У1): при желании читать из env/edn.")

(def width 40)
(def height 30)
(def tick-ms 150)
(def min-food 5)
(def max-queued-turns 2)
(def spawn-grace-ticks 3)
(def ws-port 8080)
(def tcp-port 9090)
