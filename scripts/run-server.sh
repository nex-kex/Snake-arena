#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/../server" && clojure -M:run
