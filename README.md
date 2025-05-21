# SheLLama

SheLLama is a Python package for shell and filesystem operations in the PyLama ecosystem. It provides a unified interface for file management, directory operations, and shell command execution.

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
```

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
