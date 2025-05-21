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

# This is primarily a library, but we'll expose a port for potential API usage
EXPOSE 8002

# Command to run the CLI (can be overridden)
CMD ["python", "-m", "shellama.cli"]
