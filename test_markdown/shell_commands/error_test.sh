#!/bin/bash

# Error handling test script for SheLLama shell command testing
# This script demonstrates error handling in shell commands

# Define colors for output
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
NC="\033[0m" # No Color

# Print header
echo -e "${YELLOW}====================================================${NC}"
echo -e "${YELLOW}          Error Handling Test Script               ${NC}"
echo -e "${YELLOW}====================================================${NC}"

# Function to handle errors
handle_error() {
    local exit_code=$1
    local error_message=$2
    local command=$3
    
    echo -e "\n${RED}ERROR: $error_message${NC}"
    echo -e "Command: $command"
    echo -e "Exit code: $exit_code"
    echo -e "Line number: ${BASH_LINENO[0]}"
    
    # Log error to file
    echo "[$(date)] ERROR: $error_message | Command: $command | Exit code: $exit_code | Line: ${BASH_LINENO[0]}" >> error_log.txt
}

# Enable error tracing
set -e

# Test 1: Command not found
echo -e "\n${YELLOW}Test 1: Command not found${NC}"
echo "Attempting to run a non-existent command..."

# Save current options
old_options=$(set +o)

# Temporarily disable exit on error
set +e

# Run non-existent command
nonexistentcommand
handle_error $? "Command not found" "nonexistentcommand"

# Test 2: File not found
echo -e "\n${YELLOW}Test 2: File not found${NC}"
echo "Attempting to read a non-existent file..."

cat nonexistentfile.txt
handle_error $? "File not found" "cat nonexistentfile.txt"

# Test 3: Permission denied
echo -e "\n${YELLOW}Test 3: Permission denied${NC}"
echo "Creating a file with no read permissions..."

touch nopermission.txt
chmod 000 nopermission.txt

cat nopermission.txt
handle_error $? "Permission denied" "cat nopermission.txt"

# Clean up
chmod 644 nopermission.txt
rm nopermission.txt

# Test 4: Invalid argument
echo -e "\n${YELLOW}Test 4: Invalid argument${NC}"
echo "Using invalid arguments with a command..."

ls --invalidarg
handle_error $? "Invalid argument" "ls --invalidarg"

# Test 5: Pipeline error
echo -e "\n${YELLOW}Test 5: Pipeline error${NC}"
echo "Creating a pipeline with an error..."

cat nonexistentfile.txt | grep "test"
handle_error $? "Pipeline error" "cat nonexistentfile.txt | grep \"test\""

# Test 6: Arithmetic error
echo -e "\n${YELLOW}Test 6: Arithmetic error${NC}"
echo "Attempting division by zero..."

# This will cause an error in bash
echo $((5 / 0))
handle_error $? "Arithmetic error" "echo \$((5 / 0))"

# Test 7: Command substitution error
echo -e "\n${YELLOW}Test 7: Command substitution error${NC}"
echo "Using command substitution with an error..."

result=$(nonexistentcommand)
handle_error $? "Command substitution error" "result=\$(nonexistentcommand)"

# Test 8: Exit code handling
echo -e "\n${YELLOW}Test 8: Exit code handling${NC}"
echo "Testing exit code handling..."

false
if [ $? -ne 0 ]; then
    echo -e "${GREEN}Successfully detected non-zero exit code${NC}"
else
    echo -e "${RED}Failed to detect non-zero exit code${NC}"
fi

# Restore previous options
eval "$old_options"

# Test 9: Trap for signals
echo -e "\n${YELLOW}Test 9: Trap for signals${NC}"
echo "Setting up trap for SIGINT..."

trap 'echo -e "\n${YELLOW}Caught SIGINT signal${NC}"; exit 1' INT
echo "Trap set. In a real scenario, pressing Ctrl+C would trigger this trap."

# Remove the trap
trap - INT

# Test 10: Conditional error handling
echo -e "\n${YELLOW}Test 10: Conditional error handling${NC}"
echo "Testing conditional error handling..."

command_output=$(ls nonexistentdirectory 2>&1)
if [ $? -ne 0 ]; then
    echo -e "${GREEN}Error detected and handled gracefully${NC}"
    echo -e "Error message: ${RED}$command_output${NC}"
else
    echo -e "${GREEN}Command executed successfully${NC}"
    echo "Output: $command_output"
fi

# Display error log
echo -e "\n${YELLOW}Error Log:${NC}"
if [ -f error_log.txt ]; then
    cat error_log.txt
else
    echo "No error log file found"
fi

echo -e "\n${GREEN}Error handling test script completed${NC}"
exit 0
