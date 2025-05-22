#!/bin/bash

# Environment variable test script for SheLLama shell command testing
# This script demonstrates environment variable handling in shell commands

# Print header
echo "===================================================="
echo "         Environment Variable Test Script          "
echo "===================================================="

# Display current environment variables
echo "\nCurrent Environment Variables:\n"
echo "USER: $USER"
echo "HOME: $HOME"
echo "PATH: $PATH"
echo "SHELL: $SHELL"
echo "PWD: $PWD"

# Set custom environment variables
echo "\nSetting custom environment variables..."
SHELLAMA_TEST_VAR="Hello from SheLLama!"
SHELLAMA_API_URL="http://localhost:5000"
SHELLAMA_DEBUG="true"
SHELLAMA_VERSION="1.0.0"

export SHELLAMA_TEST_VAR SHELLAMA_API_URL SHELLAMA_DEBUG SHELLAMA_VERSION

# Display custom environment variables
echo "\nCustom Environment Variables:\n"
echo "SHELLAMA_TEST_VAR: $SHELLAMA_TEST_VAR"
echo "SHELLAMA_API_URL: $SHELLAMA_API_URL"
echo "SHELLAMA_DEBUG: $SHELLAMA_DEBUG"
echo "SHELLAMA_VERSION: $SHELLAMA_VERSION"

# Use environment variables in commands
echo "\nUsing environment variables in commands:\n"
echo "Current user's home directory: $HOME"
ls -la "$HOME" | head -n 5

# Create a file using environment variables for the name
TEST_FILE="${SHELLAMA_TEST_VAR// /_}.txt"
echo "\nCreating test file: $TEST_FILE"
echo "This file was created by the environment test script." > "$TEST_FILE"
echo "Created at: $(date)" >> "$TEST_FILE"
echo "Using SHELLAMA_VERSION: $SHELLAMA_VERSION" >> "$TEST_FILE"

# Show file contents
echo "\nFile contents:\n"
cat "$TEST_FILE"

# Test conditional based on environment variable
echo "\nTesting conditional based on environment variable:\n"
if [ "$SHELLAMA_DEBUG" = "true" ]; then
    echo "Debug mode is enabled"
    echo "Additional debug information:"
    echo "- Script: $(basename "$0")"
    echo "- PID: $$"
    echo "- Parent PID: $PPID"
    echo "- Date: $(date)"
    echo "- Uptime: $(uptime)"
else
    echo "Debug mode is disabled"
fi

# Test environment variable with default value
echo "\nTesting environment variable with default value:\n"
SHELLAMA_CONFIG=${SHELLAMA_CONFIG:-"default_config.json"}
echo "SHELLAMA_CONFIG: $SHELLAMA_CONFIG"

# Clean up
echo "\nCleaning up..."
rm "$TEST_FILE"
echo "Removed test file: $TEST_FILE"

# Unset custom environment variables
echo "\nUnsetting custom environment variables..."
unset SHELLAMA_TEST_VAR SHELLAMA_API_URL SHELLAMA_DEBUG SHELLAMA_VERSION

# Verify variables are unset
echo "\nVerifying variables are unset:\n"
echo "SHELLAMA_TEST_VAR: ${SHELLAMA_TEST_VAR:-<unset>}"
echo "SHELLAMA_API_URL: ${SHELLAMA_API_URL:-<unset>}"
echo "SHELLAMA_DEBUG: ${SHELLAMA_DEBUG:-<unset>}"
echo "SHELLAMA_VERSION: ${SHELLAMA_VERSION:-<unset>}"

echo "\nEnvironment test script completed successfully"
exit 0
