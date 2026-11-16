#!/bin/bash
# Останавливает локальные Nginx и Gunicorn Kittygram.
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
RUN="$ROOT/local/run"

if [ -f "$RUN/nginx.pid" ]; then
    kill "$(cat "$RUN/nginx.pid")" 2>/dev/null
    rm -f "$RUN/nginx.pid"
fi
if [ -f "$RUN/gunicorn.pid" ]; then
    kill "$(cat "$RUN/gunicorn.pid")" 2>/dev/null
    rm -f "$RUN/gunicorn.pid"
fi
echo "Kittygram остановлен."
