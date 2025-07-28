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
python << END
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'conduit.settings')
django.setup()

from django.contrib.auth import get_user_model

User = get_user_model()

email = os.environ.get('DJANGO_SUPERUSER_EMAIL')
username = os.environ.get('DJANGO_SUPERUSER_USERNAME', 'admin')
password = os.environ.get('DJANGO_SUPERUSER_PASSWORD')

if email and password:
    try:
        user = User.objects.get(email=email)
        print(f"Superuser with email {email} already exists.")
    except User.DoesNotExist:
        print(f"Creating superuser: {email}")
        User.objects.create_superuser(
            username=username,
            email=email,
            password=password
        )
else:
    print("Missing DJANGO_SUPERUSER_EMAIL or DJANGO_SUPERUSER_PASSWORD")
END

#python manage.py createsuperuser --noinput \
#  --email "$DJANGO_SUPERUSER_EMAIL" \
#  --username "$DJANGO_SUPERUSER_USERNAME" || echo "Superuser already exists"




echo "Starting Gunicorn server..."

#exec gunicorn conduit.wsgi:application --worker-class gthread --bind 0.0.0.0:8000
exec gunicorn conduit.wsgi:application --workers 3 --preload --bind 0.0.0.0:8000
