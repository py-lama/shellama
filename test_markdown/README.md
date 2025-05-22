# SheLLama Test Markdown Directory

## Overview

This directory contains test files and examples for testing SheLLama functionality. The structure is organized into subdirectories based on the type of operations being tested.

## Directory Structure

```
/test_markdown/
├── file_operations/       # For testing file handling functions
├── git_operations/        # For testing Git functionality
├── shell_commands/        # For testing shell command execution
└── devops_tools/          # For testing DevOps tools integration
```

## Purpose

This test markdown directory serves several purposes:

1. **Testing Environment**: Provides a controlled environment with example files for testing SheLLama API endpoints
2. **Documentation**: Demonstrates the capabilities and expected behavior of SheLLama
3. **Development**: Supports development of new features with realistic test cases
4. **Ansible Tests**: Used by the Ansible test suite to verify SheLLama functionality

## Test Categories

### File Operations

The `file_operations` directory contains files for testing basic file system operations:

- File creation, reading, updating, and deletion
- File renaming and permission changes
- Content searching and manipulation
- Different file types (text, markdown, JSON, Python)
- Performance testing with larger files

### Git Operations

The `git_operations` directory contains files for testing Git-related functionality:

- Repository initialization and status checking
- Adding and committing changes
- Branch creation, checkout, and merging
- Handling merge conflicts
- Viewing commit history

### Shell Commands

The `shell_commands` directory contains scripts for testing shell command execution:

- Basic command execution and output capturing
- Environment variable handling
- Error handling and reporting
- Command chaining and piping
- Process management

### DevOps Tools

The `devops_tools` directory contains configuration files for testing integration with DevOps tools:

- Docker and Docker Compose
- Ansible
- Terraform
- Kubernetes
- CI/CD tools (Jenkins, GitHub Actions)

## Usage

### Manual Testing

You can use these files for manual testing of SheLLama functionality:

```bash
# Example: Test file reading
curl -X POST http://localhost:5000/api/shellama/file/read \
  -H "Content-Type: application/json" \
  -d '{"path": "/path/to/test_markdown/file_operations/simple_text.txt"}'

# Example: Test Git status
curl -X POST http://localhost:5000/api/shellama/git/status \
  -H "Content-Type: application/json" \
  -d '{"directory": "/path/to/test_markdown/git_operations"}'

# Example: Test shell command execution
curl -X POST http://localhost:5000/api/shellama/shell/exec \
  -H "Content-Type: application/json" \
  -d '{"command": "ls -la", "cwd": "/path/to/test_markdown"}'
```

### Automated Testing

These files are used by the Ansible test suite to verify SheLLama functionality:

```bash
# Run all Ansible tests
make ansible-test

# Run specific test categories
make ansible-test-file   # Test file operations
make ansible-test-git    # Test Git operations
make ansible-test-shell  # Test shell operations
```

## Extending the Test Suite

To add new test files:

1. Identify the appropriate category (file, git, shell, devops)
2. Add your test files to the corresponding directory
3. Update the README.md in that directory to document the new test files
4. If necessary, update the Ansible test playbooks to include tests for the new files

## Docker Testing Environment

A Docker testing environment is available for testing SheLLama with these test files. See the `DOCKER_TESTING.md` file for more information.
