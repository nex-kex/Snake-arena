(ns snake-arena.tick
  "Один шаг мира: world -> world (чистая функция)."
  (:require [snake-arena.rules :as rules]))

;; TODO(У1): (defn step [world] ...)
;;   1. применить по одному повороту из очереди
;;   2. сдвинуть головы
;;   3. съеденная еда, рост
;;   4. столкновения → смерть → еда
;;   5. дополнить еду до min-food, tick+1
