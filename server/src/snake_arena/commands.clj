(ns snake-arena.commands
  "Разбор фраз-команд (docs/controls.md) в структуры.")

;; TODO(У1): (defn parse [text] ...)
;; Результат: {:cmd :go :dir :up} | {:cmd :turn :side :left}
;;            | {:cmd :scores} | {:cmd :players} | {:cmd :respawn} | {:cmd :help}
;;            | {:error :unknown_command}
