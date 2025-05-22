#!/bin/bash

# Script to run Ansible tests for SheLLama

set -e

# Colors for output
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

# Default options
CLEANUP=true
GENERATE_REPORT=true
VERBOSE=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --no-cleanup)
            CLEANUP=false
            shift
            ;;
        --no-report)
            GENERATE_REPORT=false
            shift
            ;;
        -v|--verbose)
            VERBOSE="-v"
            shift
            ;;
        -vv|--very-verbose)
            VERBOSE="-vv"
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  --no-cleanup       Don't clean up test directories after tests"
            echo "  --no-report        Don't generate HTML test report"
            echo "  -v, --verbose      Show verbose output"
            echo "  -vv, --very-verbose Show very verbose output"
            echo "  -h, --help         Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

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

# Create test directory if it doesn't exist
mkdir -p ansible_tests/logs

# Set environment variables for tests
export SHELLAMA_URL="http://localhost:5000/api/shellama"
export CLEANUP_ENABLED=$CLEANUP
export GENERATE_REPORT=$GENERATE_REPORT
export REPORT_FILE="shellama_test_$(date +%Y%m%d_%H%M%S).html"

# Run the Ansible playbook
echo -e "${YELLOW}Running Ansible tests...${NC}"
ansible-playbook $VERBOSE ansible_tests/shellama_test_playbook.yml -e "cleanup_enabled=$CLEANUP generate_report=$GENERATE_REPORT" | tee ansible_tests/logs/shellama_test_$(date +%Y%m%d_%H%M%S).log

# Check if tests passed
RESULT=$?
if [ $RESULT -eq 0 ]; then
    echo -e "${GREEN}All SheLLama Ansible tests passed successfully!${NC}"
    if [ "$GENERATE_REPORT" = "true" ]; then
        REPORT_PATH="ansible_tests/logs/$REPORT_FILE"
        if [ -f "$REPORT_PATH" ]; then
            echo -e "${BLUE}Test report generated: $REPORT_PATH${NC}"
        fi
    fi
    exit 0
else
    echo -e "${RED}Some SheLLama Ansible tests failed. Check the logs for details.${NC}"
    if [ "$GENERATE_REPORT" = "true" ]; then
        REPORT_PATH="ansible_tests/logs/$REPORT_FILE"
        if [ -f "$REPORT_PATH" ]; then
            echo -e "${BLUE}Test report generated: $REPORT_PATH${NC}"
        fi
    fi
    exit 1
fi
