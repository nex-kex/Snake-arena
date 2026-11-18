#!/usr/bin/env bash
# Запускает сервер, клиент и бота (TODO: дождаться готовности сервера перед ботом).
cd "$(dirname "$0")"
./run-server.sh & sleep 5
./run-client.sh & ./run-bot.sh
wait
