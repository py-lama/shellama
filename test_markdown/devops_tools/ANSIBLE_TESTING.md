# Ansible Testing Environment for PyLama Ecosystem

This directory contains Docker configurations and Ansible files for testing the PyLama ecosystem components in an isolated environment. The setup includes a controller container for running Ansible tests and target containers for each service.

## Overview

The testing environment consists of:

1. **Ansible Controller**: Container with Ansible and testing tools installed
2. **Service Targets**: Containers for each PyLama component (SheLLama, APILama, etc.)
3. **Mock Services**: Containers that simulate services for testing integration

## Prerequisites

- Docker and Docker Compose installed
- Git repository cloned
- Basic understanding of Ansible and Docker

## Directory Structure

```
devops_tools/
├── ansible.cfg                   # Ansible configuration
├── ansible_test_dockerfile       # Dockerfile for Ansible controller
├── ansible_test_docker_compose.yml # Docker Compose for testing environment
├── inventory/                    # Ansible inventory
│   └── hosts                     # Host definitions
├── mock_service.py              # Python script for mock services
├── mock_service_dockerfile      # Dockerfile for mock services
└── ANSIBLE_TESTING.md           # This documentation
```

## Setup Instructions

### 1. Build and Start the Testing Environment

```bash
# Navigate to the devops_tools directory
cd /home/tom/github/py-lama/shellama/test_markdown/devops_tools

# Build and start the containers
docker-compose -f ansible_test_docker_compose.yml up -d
```

### 2. Access the Ansible Controller

```bash
# Connect to the Ansible controller container
docker exec -it devlama-ansible-controller bash
```

### 3. Run Ansible Tests

From inside the Ansible controller container:

```bash
# Verify connectivity to all hosts
ansible all -m ping

# Run a specific test playbook
ansible-playbook /app/ansible_tests/shellama_test_playbook.yml
```

## Available Test Playbooks

- `shellama_test_playbook.yml`: Tests SheLLama functionality
- `mock_git_tests.yml`: Tests Git operations with mock responses
- `mock_file_tests.yml`: Tests file operations with mock responses
- `mock_shell_tests.yml`: Tests shell commands with mock responses

## Testing Without Services

You can run tests that don't require the actual services using the mock test playbooks:

```bash
# Run mock Git tests
ansible-playbook /app/ansible_tests/mock_git_tests.yml

# Run mock file operations tests
ansible-playbook /app/ansible_tests/mock_file_tests.yml

# Run mock shell commands tests
ansible-playbook /app/ansible_tests/mock_shell_tests.yml
```

## Integration with CI/CD

This testing environment can be integrated with CI/CD pipelines by:

1. Building the Docker images in the CI environment
2. Running the test containers
3. Executing Ansible tests
4. Generating test reports

Example GitHub Actions workflow:

```yaml
name: Ansible Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  ansible-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Build test environment
        run: |
          cd shellama/test_markdown/devops_tools
          docker-compose -f ansible_test_docker_compose.yml build
          
      - name: Start test environment
        run: |
          cd shellama/test_markdown/devops_tools
          docker-compose -f ansible_test_docker_compose.yml up -d
          
      - name: Run Ansible tests
        run: |
          docker exec devlama-ansible-controller ansible-playbook /app/ansible_tests/shellama_test_playbook.yml
          
      - name: Collect test reports
        run: |
          docker cp devlama-ansible-controller:/app/reports ./reports
          
      - name: Upload test reports
        uses: actions/upload-artifact@v2
        with:
          name: ansible-test-reports
          path: ./reports
```

## Troubleshooting

### Common Issues

1. **Connection Failures**:
   - Ensure all containers are running: `docker-compose -f ansible_test_docker_compose.yml ps`
   - Check network connectivity: `docker network inspect ansible-test-network`

2. **Permission Issues**:
   - Ensure volume mounts have correct permissions
   - Run containers with appropriate user permissions

3. **Service Unavailable**:
   - Check service logs: `docker logs shellama-target`
   - Verify service health: `curl http://localhost:8002/health`

## Extending the Testing Environment

### Adding New Tests

1. Create a new Ansible playbook in the `ansible_tests` directory
2. Define tasks that test specific functionality
3. Use the mock services or actual services as needed
4. Add appropriate assertions to verify results

### Adding New Services

1. Add a new service definition to `ansible_test_docker_compose.yml`
2. Update the Ansible inventory in `inventory/hosts`
3. Create any necessary mock implementations
4. Add tests for the new service

## License

This testing environment is part of the PyLama ecosystem and is licensed under the Apache License 2.0.
