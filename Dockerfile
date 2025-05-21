FROM python:3.10-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY setup.py ./
COPY README.md ./
RUN pip install --no-cache-dir -e .

# Copy the package files
COPY . .

# Install the package in development mode
RUN pip install --no-cache-dir -e .

# Environment variables
ENV PORT=8002
ENV HOST=0.0.0.0
ENV DEBUG=False

# Expose the REST API port
EXPOSE 8002

# Install Flask and Flask-CORS for the REST API
RUN pip install --no-cache-dir flask flask-cors

# Command to run the REST API server
CMD ["python", "-m", "shellama.app", "--port", "8002", "--host", "0.0.0.0"]
