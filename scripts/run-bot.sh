#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/../bot" && swipl bot.pl
