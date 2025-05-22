# Docker Testing Environment for SheLLama Ansible Tests

This document describes how to use the Docker testing environment for SheLLama Ansible tests. The environment provides a complete setup with a mock SheLLama API service and example files and Git repositories for testing.

## Overview

The Docker testing environment consists of two containers:

1. **shellama-mock-api**: Runs a mock SheLLama API service that responds to all the API endpoints used by the Ansible tests.
2. **shellama-ansible-tests**: Runs the Ansible tests against the mock API service.

## Prerequisites

- Docker
- Docker Compose

## Setup and Usage

### Building and Starting the Environment

```bash
# Build and start the containers
docker-compose -f docker-compose.ansible-test.yml up --build
```

This will:
1. Build the Docker images
2. Start the mock API service
3. Run the Ansible tests against the mock API

### Running Tests Manually

If you want to run tests manually, you can start just the mock API service and then run tests as needed:

```bash
# Start only the mock API service
docker-compose -f docker-compose.ansible-test.yml up -d shellama-mock-api

# Connect to the container
docker exec -it shellama_shellama-mock-api_1 bash

# Inside the container, you can run tests using make targets
cd /app
make ansible-test-git
make ansible-test-file
make ansible-test-dir
make ansible-test-shell
make ansible-test-error
```

### Available Test Categories

The following test categories are available:

- **Git Operations**: `make ansible-test-git`
- **File Operations**: `make ansible-test-file`
- **Directory Operations**: `make ansible-test-dir`
- **Shell Operations**: `make ansible-test-shell`
- **Error Handling**: `make ansible-test-error`

### Mock Git Repository

The Docker environment includes a pre-configured Git repository at `/app/example_git` with:

- Multiple branches (main/master and feature-branch)
- Commits in each branch
- Example files

You can use this repository for testing Git operations or create new repositories as needed.

### Example Markdown Files

Example markdown files are available in `/app/example_markdown` for testing file operations.

## Customizing the Environment

### Modifying the Mock API

The mock API service is implemented in `/app/mock_api/mock_shellama_api.py`. You can modify this file to change the behavior of the API endpoints.

### Adding Test Files

You can add additional test files by mounting volumes in the Docker Compose file or by creating files inside the container.

## Troubleshooting

### Checking API Status

You can check if the mock API is running by accessing the health check endpoint:

```bash
curl http://localhost:5000/api/shellama/health
```

Expected response:
```json
{
  "status": "success",
  "message": "SheLLama API is running",
  "timestamp": 1621234567.89
}
```

### Viewing Test Reports

Test reports are generated in the `/app/test-reports` directory, which is mounted as a volume. You can view these reports on your host machine in the `./test-reports` directory.

## Stopping the Environment

```bash
docker-compose -f docker-compose.ansible-test.yml down
```

To remove all containers and volumes:

```bash
docker-compose -f docker-compose.ansible-test.yml down -v
```
