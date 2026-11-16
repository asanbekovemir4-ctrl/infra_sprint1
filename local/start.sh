#!/bin/bash
# Локальный запуск Kittygram так же, как на сервере: Gunicorn (8080) + Nginx (8081).
# Запуск:   bash local/start.sh      Остановка: bash local/stop.sh
# Сайт:     http://localhost:8081    Админка: http://localhost:8081/admin/
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NGINX_PREFIX="$(brew --prefix)/etc/nginx"
cd "$ROOT"

# Если Kittygram уже запущен — сначала останавливаем, чтобы освободить порты.
bash local/stop.sh > /dev/null 2>&1 || true
sleep 1

mkdir -p local/run local/www/media local/www/static_backend

export SECRET_KEY="local-demo-secret-key"
export DEBUG=False
export ALLOWED_HOSTS="localhost,127.0.0.1"
export MEDIA_ROOT="$ROOT/local/www/media"

# Бэкенд: миграции и статика админки
cd backend
../venv/bin/python manage.py migrate --noinput
../venv/bin/python manage.py collectstatic --noinput > /dev/null
cp -r static_backend/. "$ROOT/local/www/static_backend/"

# Фронтенд: собранный React кладём в «/var/www/kittygram»
cp -r "$ROOT/frontend/build/." "$ROOT/local/www/"

# Gunicorn (аналог gunicorn_kittygram.service)
../venv/bin/gunicorn --bind 127.0.0.1:8080 --daemon \
    --pid "$ROOT/local/run/gunicorn.pid" \
    --error-logfile "$ROOT/local/run/gunicorn.log" \
    kittygram_backend.wsgi
cd "$ROOT"

# Nginx с конфигом, в который подставлены локальные пути
sed -e "s|__ROOT__|$ROOT|g" -e "s|__NGINX_PREFIX__|$NGINX_PREFIX|g" \
    local/nginx.conf > local/run/nginx.conf
nginx -c "$ROOT/local/run/nginx.conf"

echo "Kittygram запущен: http://localhost:8081  (админка: /admin/)"
