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
	./run_ansible_tests.sh $(ANSIBLE_OPTS)

# Run Ansible tests without the virtual environment setup
ansible-test-only:
	./run_ansible_tests.sh $(ANSIBLE_OPTS)

# Run Ansible tests directly without any setup
ansible-test-direct:
	@echo "Running Ansible tests directly without virtual environment..."
	ansible-playbook ansible_tests/shellama_test_playbook.yml $(ANSIBLE_OPTS)

# Run Ansible tests without health check (for development)
ansible-test-dev:
	./run_ansible_tests.sh --skip-health-check $(ANSIBLE_OPTS)

# Validate Ansible test syntax without running tests
ansible-test-dry-run:
	./run_ansible_tests.sh --dry-run $(ANSIBLE_OPTS)

# Run specific test files
ansible-test-git:
	./run_ansible_tests.sh --test-file=run_git_tests.yml --skip-health-check $(ANSIBLE_OPTS)

ansible-test-file:
	./run_ansible_tests.sh --test-file=run_file_tests.yml --skip-health-check $(ANSIBLE_OPTS)

ansible-test-dir:
	./run_ansible_tests.sh --test-file=run_dir_tests.yml --skip-health-check $(ANSIBLE_OPTS)

ansible-test-shell:
	./run_ansible_tests.sh --test-file=run_shell_tests.yml --skip-health-check $(ANSIBLE_OPTS)

ansible-test-error:
	./run_ansible_tests.sh --test-file=run_error_tests.yml --skip-health-check $(ANSIBLE_OPTS)

# Direct targets that bypass the script and virtual environment completely
ansible-test-git-direct:
	@echo "Running Git operations tests directly..."
	ansible-playbook ansible_tests/run_git_tests.yml $(ANSIBLE_OPTS)

# Direct targets with dry-run option
ansible-test-git-syntax:
	@echo "Validating Git operations tests syntax..."
	ansible-playbook --syntax-check ansible_tests/run_git_tests.yml

ansible-test-file-direct:
	@echo "Running File operations tests directly..."
	ansible-playbook ansible_tests/run_file_tests.yml $(ANSIBLE_OPTS)

ansible-test-dir-direct:
	@echo "Running Directory operations tests directly..."
	ansible-playbook ansible_tests/run_dir_tests.yml $(ANSIBLE_OPTS)

ansible-test-shell-direct:
	@echo "Running Shell operations tests directly..."
	ansible-playbook ansible_tests/run_shell_tests.yml $(ANSIBLE_OPTS)

ansible-test-error-direct:
	@echo "Running Error handling tests directly..."
	ansible-playbook ansible_tests/run_error_tests.yml $(ANSIBLE_OPTS)

# Clean up
clean:
	rm -rf $(VENV) *.egg-info build/ dist/ __pycache__/ .pytest_cache/ .coverage
	rm -rf ansible_tests/logs/*
