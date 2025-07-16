#!/bin/bash
set -e

echo "Waiting for PostgreSQL to be available..."

# Checking availability of PostgreSQL on port 5432
while ! nc -z db 5432; do
  sleep 0.1
done

echo "PostgreSQL is up..."

echo "Running collectstatic..."
python manage.py collectstatic --noinput

echo "Migrating database..."
python manage.py makemigrations
python manage.py migrate

echo "Checking and creating superuser if necessary..."

echo "Creating superuser..."
python manage.py createsuperuser --noinput \
  --email "$DJANGO_SUPERUSER_EMAIL" \
  --username "$DJANGO_SUPERUSER_USERNAME" || echo "Superuser already exists"


echo "Starting Gunicorn server..."

exec gunicorn conduit.wsgi:application --worker-class gthread --bind 0.0.0.0:8000
