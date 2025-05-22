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

.PHONY: all setup venv clean test lint format run ansible-test

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
cli: setup
	$(VENV)/bin/shellama

# Run the REST API server
run: setup
	$(VENV)/bin/python -m shellama.app --port $(PORT) --host $(HOST)

# Run Ansible tests
ansible-test: setup
	./run_ansible_tests.sh

# Clean up
clean:
	rm -rf $(VENV) *.egg-info build/ dist/ __pycache__/ .pytest_cache/ .coverage
	rm -rf ansible_tests/logs/*
