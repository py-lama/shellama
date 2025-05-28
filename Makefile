# SheLLama Makefile

# Default port for CLI server if needed
PORT ?= 8002
HOST ?= 127.0.0.1

# Python virtual environment
# Use VENV_DIR environment variable to override the virtual environment location
# Example: make setup VENV_DIR=~/.virtualenvs/shellama
VENV_DIR ?= venv
VENV := $(VENV_DIR)
PYTHON := python3
PIP := $(VENV)/bin/pip
PYTEST := $(VENV)/bin/pytest
BLACK := $(VENV)/bin/black
FLAKE8 := $(VENV)/bin/flake8

# Check if we can create the virtual environment
CHECK_VENV := $(shell mkdir -p $(VENV_DIR) 2>/dev/null && echo 1 || echo 0)

# Define colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m # No Color

.PHONY: all setup venv clean test lint format run ansible-test stop build test-package update-version publish publish-test

all: setup

# Create virtual environment and install dependencies
venv:
	@if [ "$(CHECK_VENV)" = "1" ]; then \
		echo -e "$(GREEN)Creating virtual environment in $(VENV)...$(NC)"; \
		$(PYTHON) -m venv $(VENV) || (echo -e "$(RED)Error creating virtual environment. Using direct commands instead.$(NC)" && exit 1); \
		echo -e "$(GREEN)Virtual environment created successfully.$(NC)"; \
	else \
		echo -e "$(YELLOW)Warning: Cannot create virtual environment in $(VENV).$(NC)"; \
		echo -e "$(YELLOW)Please specify a different location with VENV_DIR or use direct targets.$(NC)"; \
		echo -e "$(YELLOW)Example: make setup VENV_DIR=~/.virtualenvs/shellama$(NC)"; \
		echo -e "$(YELLOW)Or use direct targets: make ansible-test-direct, make ansible-test-git-mock$(NC)"; \
		exit 1; \
	fi

setup: venv
	@echo -e "$(GREEN)Installing dependencies...$(NC)"
	@$(PIP) install -e . || (echo -e "$(RED)Error installing package. Try using direct targets.$(NC)" && exit 1)
	@$(PIP) install -e ".[dev]" || echo -e "$(YELLOW)Warning: Dev dependencies not installed. Some features may not work.$(NC)"
	@echo -e "$(GREEN)Setup completed successfully.$(NC)"

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

ansible-test-file-syntax:
	@echo "Validating File operations tests syntax..."
	ansible-playbook --syntax-check ansible_tests/run_file_tests.yml

ansible-test-dir-direct:
	@echo "Running Directory operations tests directly..."
	ansible-playbook ansible_tests/run_dir_tests.yml $(ANSIBLE_OPTS)

ansible-test-dir-syntax:
	@echo "Validating Directory operations tests syntax..."
	ansible-playbook --syntax-check ansible_tests/run_dir_tests.yml

ansible-test-shell-direct:
	@echo "Running Shell operations tests directly..."
	ansible-playbook ansible_tests/run_shell_tests.yml $(ANSIBLE_OPTS)

ansible-test-shell-syntax:
	@echo "Validating Shell operations tests syntax..."
	ansible-playbook --syntax-check ansible_tests/run_shell_tests.yml

ansible-test-error-direct:
	@echo "Running Error handling tests directly..."
	ansible-playbook ansible_tests/run_error_tests.yml $(ANSIBLE_OPTS)

ansible-test-error-syntax:
	@echo "Validating Error handling tests syntax..."
	ansible-playbook --syntax-check ansible_tests/run_error_tests.yml

# Validate all test playbooks syntax
ansible-test-all-syntax:
	@echo "Validating all test playbooks syntax..."
	ansible-playbook --syntax-check ansible_tests/shellama_test_playbook.yml

# Run mock tests that don't require actual services
# These targets can be used without setting up a virtual environment

ansible-test-git-mock:
	@echo -e "$(GREEN)Running mock Git operations tests (no services required)...$(NC)"
	ansible-playbook ansible_tests/mock_git_tests.yml $(ANSIBLE_OPTS)

ansible-test-file-mock:
	@echo -e "$(GREEN)Running mock File operations tests (no services required)...$(NC)"
	ansible-playbook ansible_tests/mock_file_tests.yml $(ANSIBLE_OPTS)

ansible-test-shell-mock:
	@echo -e "$(GREEN)Running mock Shell operations tests (no services required)...$(NC)"
	ansible-playbook ansible_tests/mock_shell_tests.yml $(ANSIBLE_OPTS)

# Run all mock tests
ansible-test-all-mock: ansible-test-git-mock ansible-test-file-mock ansible-test-shell-mock
	@echo -e "$(GREEN)All mock tests completed successfully.$(NC)"

# Verify test markdown directory
verify-test-markdown: setup
	@echo -e "$(GREEN)Verifying test markdown directory structure...$(NC)"
	$(VENV)/bin/python test_markdown/verify_test_files.py

# Verify test markdown directory without virtual environment
verify-test-markdown-direct:
	@echo -e "$(GREEN)Verifying test markdown directory structure (direct)...$(NC)"
	python test_markdown/verify_test_files.py

# Run all direct tests without virtual environment
test-direct: ansible-test-all-mock verify-test-markdown-direct
	@echo -e "$(GREEN)All direct tests completed successfully.$(NC)"

# Poetry targets
poetry-install:
	@echo -e "$(GREEN)Installing dependencies with Poetry...$(NC)"
	poetry install

poetry-run:
	@echo -e "$(GREEN)Running SheLLama with Poetry on port $(PORT)...$(NC)"
	poetry run python -m shellama.app --port $(PORT) --host $(HOST)

poetry-test:
	@echo -e "$(GREEN)Running tests with Poetry...$(NC)"
	poetry run pytest tests/

poetry-lint:
	@echo -e "$(GREEN)Linting code with Poetry...$(NC)"
	poetry run flake8 shellama/ tests/

poetry-format:
	@echo -e "$(GREEN)Formatting code with Poetry...$(NC)"
	poetry run black shellama/ tests/

# Pipenv targets
pipenv-install:
	@echo -e "$(GREEN)Installing dependencies with Pipenv...$(NC)"
	pipenv install --dev

pipenv-run:
	@echo -e "$(GREEN)Running SheLLama with Pipenv on port $(PORT)...$(NC)"
	pipenv run python -m shellama.app --port $(PORT) --host $(HOST)

pipenv-test:
	@echo -e "$(GREEN)Running tests with Pipenv...$(NC)"
	pipenv run pytest tests/

pipenv-lint:
	@echo -e "$(GREEN)Linting code with Pipenv...$(NC)"
	pipenv run flake8 shellama/ tests/

pipenv-format:
	@echo -e "$(GREEN)Formatting code with Pipenv...$(NC)"
	pipenv run black shellama/ tests/

# Docker-based Ansible testing environment
ansible-test-env-build:
	@echo -e "$(GREEN)Building Ansible testing environment...$(NC)"
	cd test_markdown/devops_tools && docker-compose -f ansible_test_docker_compose.yml build

ansible-test-env-up:
	@echo -e "$(GREEN)Starting Ansible testing environment...$(NC)"
	cd test_markdown/devops_tools && docker-compose -f ansible_test_docker_compose.yml up -d

ansible-test-env-down:
	@echo -e "$(GREEN)Stopping Ansible testing environment...$(NC)"
	cd test_markdown/devops_tools && docker-compose -f ansible_test_docker_compose.yml down

ansible-test-env-run:
	@echo -e "$(GREEN)Running tests in Ansible testing environment...$(NC)"
	docker exec -it devlama-ansible-controller ansible-playbook /app/ansible_tests/shellama_test_playbook.yml $(ANSIBLE_OPTS)

ansible-test-env-shell:
	@echo -e "$(GREEN)Opening shell in Ansible testing environment...$(NC)"
	docker exec -it devlama-ansible-controller bash

# Clean up
clean:
	rm -rf $(VENV) *.egg-info build/ dist/ __pycache__/ .pytest_cache/ .coverage
	rm -rf ansible_tests/logs/*

# Stop all services, Docker containers, and free up ports
stop:
	@echo -e "$(GREEN)Stopping all services and Docker containers...$(NC)"
	@echo -e "$(YELLOW)Stopping Ansible testing environment...$(NC)"
	cd test_markdown/devops_tools && docker-compose -f ansible_test_docker_compose.yml down || true
	@echo -e "$(YELLOW)Stopping any running Python processes on ports 8002, 8080, 9002, 9080, 19002, 19080...$(NC)"
	-pkill -f "python -m shellama.app --port $(PORT)" || true
	-pkill -f "python -m shellama.app --port 8002" || true
	-pkill -f "python -m shellama.app --port 9002" || true
	-pkill -f "python -m shellama.app --port 19002" || true
	-pkill -f "python -m apilama.app --port 8080" || true
	-pkill -f "python -m apilama.app --port 9080" || true
	-pkill -f "python -m apilama.app --port 19080" || true
	@echo -e "$(YELLOW)Stopping any Docker containers related to PyLama ecosystem...$(NC)"
	-docker stop $(shell docker ps -q --filter name="py-lama-*") 2>/dev/null || true
	-docker stop $(shell docker ps -q --filter name="shellama-*") 2>/dev/null || true
	-docker stop $(shell docker ps -q --filter name="apilama-*") 2>/dev/null || true
	-docker stop $(shell docker ps -q --filter name="devlama-*") 2>/dev/null || true
	-docker stop $(shell docker ps -q --filter name="getllm-*") 2>/dev/null || true
	-docker stop $(shell docker ps -q --filter name="bexy-*") 2>/dev/null || true
	@echo -e "$(YELLOW)Checking if any processes are still using the ports...$(NC)"
	-lsof -i :8002 || true
	-lsof -i :8080 || true
	-lsof -i :9002 || true
	-lsof -i :9080 || true
	-lsof -i :19002 || true
	-lsof -i :19080 || true
	-lsof -i :19000 || true
	-lsof -i :19001 || true
	-lsof -i :19003 || true
	@echo -e "$(GREEN)All services and Docker containers have been stopped.$(NC)"


# Build package
build: setup
	@echo "Building package..."
	@. venv/bin/activate && pip install -e . && pip install wheel twine build
	@. venv/bin/activate && rm -rf dist/* && python setup.py sdist bdist_wheel

# Update version
update-version:
	@echo "Updating package version..."
	@python ../scripts/update_version.py

# Publish package to PyPI
publish: build update-version
	@echo "Publishing package to PyPI..."
	@. venv/bin/activate && twine check dist/* && twine upload dist/*

# Publish package to TestPyPI
publish-test: build update-version
	@echo "Publishing package to TestPyPI..."
	@. venv/bin/activate && twine check dist/* && twine upload --repository testpypi dist/*
