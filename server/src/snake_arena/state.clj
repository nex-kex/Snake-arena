(ns snake-arena.state
  "Общее состояние мира в STM. Только здесь живёт ref и dosync."
  (:require [snake-arena.config :as config]))

;; TODO(У1): (defonce world (ref (initial-world)))
;; Формат мира: docs/state-model.md

(defn initial-world
  "Пустой мир. TODO(У1)."
  []
  {:tick 0 :players {} :snakes {} :food #{}})

;; TODO(У1): (defn join-player! [id name kind] (dosync ...))
;; TODO(У1): (defn leave-player! [id] (dosync ...))
;; TODO(У1): (defn apply-command! [id command] (dosync ...))
;; TODO(У1): (defn advance-world! [] (dosync ...))
