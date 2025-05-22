#!/bin/bash

# Script to run Ansible tests for SheLLama

set -e

# Colors for output
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[0;33m"
NC="\033[0m" # No Color

echo -e "${YELLOW}=== SheLLama Ansible Test Runner ===${NC}"

# Check if APILama gateway is running and SheLLama service is accessible
echo -e "${YELLOW}Checking if APILama gateway is running and SheLLama service is accessible...${NC}"
if ! curl -s http://localhost:5000/api/shellama/health > /dev/null; then
    echo -e "${RED}ERROR: APILama gateway is not running or SheLLama service is not accessible!${NC}"
    echo -e "${YELLOW}Please start the APILama gateway and SheLLama service with:${NC}"
    echo -e "cd .. && make run-apilama
cd .. && make run-shellama\n"
    exit 1
fi

echo -e "${GREEN}SheLLama service is running.${NC}"

# Set environment variables for tests
export SHELLAMA_URL="http://localhost:5000/api/shellama"

# Create test directory if it doesn't exist
mkdir -p ansible_tests/logs

# Run the Ansible playbook
echo -e "${YELLOW}Running Ansible tests...${NC}"
ansible-playbook -v ansible_tests/shellama_test_playbook.yml | tee ansible_tests/logs/shellama_test_$(date +%Y%m%d_%H%M%S).log

# Check if tests passed
if [ $? -eq 0 ]; then
    echo -e "${GREEN}All SheLLama Ansible tests passed successfully!${NC}"
    exit 0
else
    echo -e "${RED}Some SheLLama Ansible tests failed. Check the logs for details.${NC}"
    exit 1
fi
