# SheLLama

SheLLama is a dedicated REST API service for shell and filesystem operations in the PyLama ecosystem. It provides a unified interface for file management, directory operations, shell command execution, and Git integration, available both as a Python library and a standalone REST API service that communicates with the APILama gateway.

## Features

- **RESTful API**: Complete REST API for all shell and filesystem operations
- **File Operations**: Read, write, list, and search files with proper error handling
- **Directory Management**: Create, delete, and list directories with detailed information
- **Shell Command Execution**: Execute shell commands with output capture and error handling
- **Git Integration**: Initialize repositories, commit changes, view status and logs
- **Secure File Handling**: Proper permissions and security checks for all operations
- **Cross-Origin Support**: CORS headers for integration with web applications
- **Detailed Logging**: Comprehensive logging of all operations for debugging and auditing

## Installation

```bash
# Create a virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install the package
pip install -e .
```

## Usage

### As a Python Library

```python
# File operations
from shellama import file_ops

# List files in a directory
files = file_ops.list_files('/path/to/directory')

# Read a file
content = file_ops.read_file('/path/to/file.md')

# Write to a file
file_ops.write_file('/path/to/file.md', 'New content')

# Directory operations
from shellama import dir_ops

# Create a directory
dir_ops.create_directory('/path/to/new/directory')

# Shell commands
from shellama import shell

# Execute a shell command
result = shell.execute_command('ls -la')

# Git operations
from shellama import git_ops

# Get git status
status = git_ops.get_status('/path/to/repo')
```

### As a REST API Service

SheLLama is designed to run as a standalone REST API service that communicates with the APILama gateway:

```bash
# Start the SheLLama API server
python -m shellama.app --port 8002 --host 127.0.0.1
```

Using environment variables:

```bash
export PORT=8002
export HOST=127.0.0.1
export DEBUG=False
python -m shellama.app
```

Or using the Makefile:

```bash
make run PORT=8002 HOST=127.0.0.1
```

### Environment Variables

SheLLama uses the following environment variables for configuration:

- `PORT`: The port to run the server on (default: 8002)
- `HOST`: The host to bind to (default: 127.0.0.1)
- `DEBUG`: Enable debug mode (default: False)
- `LOG_LEVEL`: Logging level (default: INFO)
- `LOG_FILE`: Log file path (default: shellama.log)
- `SECRET_KEY`: Secret key for secure operations

You can set these variables in a `.env` file or pass them directly when starting the server.

#### API Endpoints

**File Operations:**
- `GET /files?directory=/path/to/dir` - List files in a directory
- `GET /file?filename=/path/to/file.md` - Get file content
- `POST /file` - Save file content (JSON body: `{"filename": "path", "content": "data"}`)
- `DELETE /file?filename=/path/to/file.md` - Delete a file

**Directory Operations:**
- `GET /directory?path=/path/to/dir` - Get directory information
- `POST /directory` - Create a directory (JSON body: `{"path": "/path/to/dir"}`)
- `DELETE /directory?path=/path/to/dir` - Delete a directory

**Shell Operations:**
- `POST /shell` - Execute a shell command (JSON body: `{"command": "ls -la", "cwd": "/path/to/dir"}`)

**Git Operations:**
- `GET /git/status?path=/path/to/repo` - Get git repository status
- `POST /git/init` - Initialize a git repository (JSON body: `{"path": "/path/to/dir"}`)
- `POST /git/commit` - Commit changes (JSON body: `{"path": "/path/to/repo", "message": "commit message"}`)
- `GET /git/log?path=/path/to/repo` - Get git commit history

## Development

### Setting Up the Development Environment

```bash
# Create a virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install development dependencies
pip install -e ".[dev]"
```

### Running Tests

```bash
# Run all tests
python -m pytest

# Run specific test file
python -m pytest tests/test_file_ops.py

# Run with coverage report
python -m pytest --cov=shellama tests/
```

### Ansible Integration Tests

SheLLama includes a comprehensive suite of Ansible tests that verify the functionality of all API endpoints. These tests ensure that the service works correctly and can be integrated with other systems.

```bash
# Run all Ansible tests
make ansible-test

# Or run the test script directly with options
./run_ansible_tests.sh

# Run with verbose output
./run_ansible_tests.sh --verbose

# Run without cleaning up test directories
./run_ansible_tests.sh --no-cleanup

# Run without generating HTML report
./run_ansible_tests.sh --no-report

# Show help
./run_ansible_tests.sh --help
```

#### Test Reports

The Ansible tests generate a comprehensive HTML report that provides detailed information about the test results. The report includes:

- Test summary with overall status
- Detailed results for each test category (file operations, directory operations, shell operations, git operations)
- Assertions verification
- Timestamps and environment information

Test reports are saved in the `ansible_tests/logs/` directory with a timestamp in the filename.

The Ansible tests cover:
- File operations (create, read, update, delete)
- Directory operations (create, list, delete)
- Shell command execution
- Git operations (comprehensive):
  - Repository initialization
  - Status checking
  - Adding and committing files
  - Branch creation and checkout
  - Merging branches
  - Viewing commit history
- Error handling (edge cases):
  - Non-existent directories and files
  - Invalid Git repositories and branches
  - Invalid shell commands
  - Proper error response validation
- Health check endpoints

#### Testing through APILama Gateway

The Ansible tests are designed to test SheLLama through the APILama gateway, which is the recommended way to access SheLLama in production. The APILama gateway adds the `/api/shellama` prefix to all SheLLama endpoints.

To run the tests, both the APILama gateway and SheLLama service must be running:

```bash
# In one terminal, start the APILama gateway
cd ../apilama
make run

# In another terminal, start the SheLLama service
cd ../shellama
make run

# Then run the tests
make ansible-test
```

Test results are logged to `ansible_tests/logs/` for debugging and auditing purposes.

### Code Quality

```bash
# Format code with Black
black shellama tests

# Lint code with Flake8
flake8 shellama tests

# Type checking with MyPy
mypy shellama
```

### Docker Development

```bash
# Build the Docker image
docker build -t shellama .

# Run the container
docker run -p 8002:8002 shellama
```

## License

MIT
