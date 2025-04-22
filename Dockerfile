# Use Python 3.6 slim image as the base
FROM python:3.6-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the requirements.txt file to the container
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the entire backend project to the container
COPY . .

# Copy the entrypoint script into the container
COPY entrypoint.sh /app/entrypoint.sh

# Make entrypoint.sh executable
RUN chmod +x /app/entrypoint.sh

# Expose the port that the app will run on
EXPOSE 8000

# Set the entrypoint to the entrypoint.sh script
ENTRYPOINT ["sh", "entrypoint.sh"]
