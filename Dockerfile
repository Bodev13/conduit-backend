# Use Python 3.6 slim image as the base
FROM python:3.6-slim

# Install system dependencies (libpq-dev for PostgreSQL)
RUN apt-get update && apt-get install -y \
    netcat \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory inside the container
WORKDIR /app

# Copy the entire backend project to the container
COPY . .
# Install dependencies
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt &&  chmod +x /app/entrypoint.sh

# Expose the port that the app will run on
EXPOSE 8000

# Set the entrypoint to the entrypoint.sh script
ENTRYPOINT ["sh", "entrypoint.sh"]
