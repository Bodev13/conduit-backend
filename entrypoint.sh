#!/bin/bash
set -e

echo "Running collectstatic..."
python manage.py collectstatic --noinput

echo "Migrating database..."
python manage.py makemigrations
python manage.py migrate

echo "Checking and creating superuser if necessary..."

echo "Creating superuser..."
python manage.py createsuperuser --noinput \
  --email "$DJANGO_SUPERUSER_EMAIL" \
  --username "$DJANGO_SUPERUSER_USERNAME"


echo "Starting Gunicorn server..."

exec gunicorn conduit.wsgi:application --worker-class gthread --bind 0.0.0.0:8000
