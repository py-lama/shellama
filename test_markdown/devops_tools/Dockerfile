# Example Dockerfile for SheLLama DevOps tools testing

# Use a Python base image
FROM python:3.9-slim

# Set metadata
LABEL maintainer="PyLama Team <info@example.com>"
LABEL version="1.0.0"
LABEL description="SheLLama API service for shell command execution"

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    SHELLAMA_PORT=5000 \
    SHELLAMA_HOST=0.0.0.0 \
    SHELLAMA_DEBUG=false

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements file
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create a non-root user and switch to it
RUN groupadd -r shellama && \
    useradd -r -g shellama shellama && \
    chown -R shellama:shellama /app

USER shellama

# Expose the application port
EXPOSE ${SHELLAMA_PORT}

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:${SHELLAMA_PORT}/api/shellama/health || exit 1

# Set the entrypoint
ENTRYPOINT ["python"]

# Set default command
CMD ["app.py"]
