# SheLLama

SheLLama is a Python package for shell and filesystem operations in the PyLama ecosystem. It provides a unified interface for file management, directory operations, and shell command execution, available both as a Python library and a REST API service.

## Features

- File operations (read, write, list, search)
- Directory management
- Shell command execution
- Git integration for version control
- Secure file handling with proper permissions

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

SheLLama can be run as a standalone REST API service:

```bash
# Start the SheLLama API server
python -m shellama.app --port 8002 --host 127.0.0.1
```

Or using the Makefile:

```bash
make run PORT=8002 HOST=127.0.0.1
```

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

```bash
# Install development dependencies
pip install -e ".[dev]"

# Run tests
python -m pytest

# Format code
black shellama tests

# Lint code
flake8 shellama tests
```

## License

MIT
