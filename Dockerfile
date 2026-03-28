# Use official lightweight Python runtime as a base image
FROM python:3.11-slim

# Set the working directory in the container
WORKDIR /app

# Copy only the requirements file first to leverage Docker cache
COPY requirements.txt .

# Install dependencies
# We also install 'gunicorn' here directly so we don't break Windows users
# who might try to pip install requirements.txt locally.
RUN pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir gunicorn==21.2.0

# Copy the rest of the application code
COPY . .

# Expose port 5000 for the Flask application
EXPOSE 5000

# Set required environment variables
ENV FLASK_APP=app.py
ENV FLASK_ENV=production
ENV PYTHONUNBUFFERED=1

# Command to run the application using gunicorn for production readiness
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "3", "app:app"]
