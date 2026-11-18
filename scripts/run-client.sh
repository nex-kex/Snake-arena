#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/../client" && npm install && npm run dev
