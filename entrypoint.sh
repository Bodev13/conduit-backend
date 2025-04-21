#!/bin/bash
set -e

echo "Waiting for database to be ready..."

until python manage.py migrate --noinput; do
    echo "Database not ready, retrying in 2 seconds..."
    sleep 2
done


echo "Running collectstatic..."
python manage.py collectstatic --noinput

echo "Migrating database..."
python manage.py migrate

echo "Checking and creating superuser if necessary..."

echo "Creating superuser..."
python manage.py createsuperuser --noinput \
  --email "$DJANGO_SUPERUSER_EMAIL" \
  --username "$DJANGO_SUPERUSER_USERNAME"


echo "Starting Gunicorn server..."

exec gunicorn conduit.wsgi:application --workers=3 --bind 0.0.0.0:8000
