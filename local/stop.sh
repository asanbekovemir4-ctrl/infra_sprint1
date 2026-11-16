#!/bin/bash
# Останавливает локальные Nginx и Gunicorn Kittygram.
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
[ -f "$ROOT/local/run/nginx.pid" ] && nginx -c "$ROOT/local/run/nginx.conf" -s stop
[ -f "$ROOT/local/run/gunicorn.pid" ] && kill "$(cat "$ROOT/local/run/gunicorn.pid")"
echo "Kittygram остановлен."
