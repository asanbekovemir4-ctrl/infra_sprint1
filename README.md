# Kittygram — деплой на сервер

Kittygram — социальная сеть для обмена фотографиями котиков: бэкенд на
Django REST Framework + фронтенд на React. Проект развёрнут на том же
сервере, что и Taski: Gunicorn (порт 8080) + Nginx + HTTPS (certbot).

Конфиги, использованные на сервере, лежат в `infra/`:
- `infra/default` — конфигурация Nginx (`/etc/nginx/sites-enabled/default`), два блока `server`: Taski и Kittygram;
- `infra/gunicorn_kittygram.service` — systemd-юнит Gunicorn (`/etc/systemd/system/`);
- `infra/kittygram_site.txt` — IP, ссылки на проекты, логин/пароль для проверки.

## Пошаговый деплой

```bash
# 1. Клонировать проект на сервер
cd ~ && git clone git@github.com:<аккаунт>/infra_sprint1.git

# 2. Бэкенд
cd infra_sprint1
python3 -m venv venv && source venv/bin/activate
pip install -r requirements.txt
cd backend
cp .env.example .env && nano .env      # SECRET_KEY, ALLOWED_HOSTS и т.д.
python manage.py migrate
python manage.py createsuperuser
python manage.py collectstatic
sudo mkdir -p /var/www/kittygram/media
sudo cp -r static_backend/ /var/www/kittygram/
sudo chown -R $USER /var/www/kittygram/media/

# 3. Фронтенд
cd ../frontend
npm install && npm run build
sudo cp -r build/* /var/www/kittygram/

# 4. Gunicorn
sudo cp ../infra/gunicorn_kittygram.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now gunicorn_kittygram

# 5. Nginx (добавить блок server для Kittygram)
sudo nano /etc/nginx/sites-enabled/default   # см. infra/default
sudo nginx -t && sudo systemctl reload nginx

# 6. HTTPS
sudo certbot --nginx                           # выбрать домен Kittygram
```

Стек: Python 3.12, Django 5.1, DRF, Djoser, Gunicorn, Nginx, React.
