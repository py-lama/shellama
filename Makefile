# SheLLama Makefile

# Default port for CLI server if needed
PORT ?= 8002
HOST ?= 127.0.0.1

# Python virtual environment
VENV := venv
PYTHON := python3
PIP := $(VENV)/bin/pip
PYTEST := $(VENV)/bin/pytest
BLACK := $(VENV)/bin/black
FLAKE8 := $(VENV)/bin/flake8

.PHONY: all setup venv clean test lint format run

all: setup

# Create virtual environment and install dependencies
venv:
	$(PYTHON) -m venv $(VENV)

setup: venv
	$(PIP) install -e .
	$(PIP) install -e ".[dev]"

# Run tests
test: setup
	$(PYTEST) tests/

# Lint code
lint: setup
	$(FLAKE8) shellama/ tests/

# Format code
format: setup
	$(BLACK) shellama/ tests/

# Run the CLI tool
run: setup
	$(VENV)/bin/shellama

# Clean up
clean:
	rm -rf $(VENV) *.egg-info build/ dist/ __pycache__/ .pytest_cache/ .coverage
