#!/bin/bash

# Test script for SheLLama shell command execution testing
# This script demonstrates basic shell script functionality

# Define colors for output
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

# Print header
echo -e "${BLUE}===========================================================${NC}"
echo -e "${BLUE}                SheLLama Test Script                    ${NC}"
echo -e "${BLUE}===========================================================${NC}"

# Print script information
echo -e "\n${YELLOW}Script Information:${NC}"
echo -e "Script Name: $(basename "$0")"
echo -e "Working Directory: $(pwd)"
echo -e "User: $(whoami)"
echo -e "Date and Time: $(date)"

# Process arguments
echo -e "\n${YELLOW}Arguments:${NC}"
if [ $# -eq 0 ]; then
    echo -e "${RED}No arguments provided${NC}"
else
    echo -e "Number of arguments: $#"
    for i in "$@"; do
        echo -e "Argument: ${GREEN}$i${NC}"
    done
    
    # Check for specific flags
    if [[ " $* " =~ " --verbose " ]]; then
        echo -e "\n${YELLOW}Verbose mode enabled${NC}"
        VERBOSE=true
    fi
    
    if [[ " $* " =~ " --help " ]]; then
        echo -e "\n${YELLOW}Help:${NC}"
        echo -e "Usage: $0 [options]\n"
        echo -e "Options:"
        echo -e "  --verbose\t\tEnable verbose output"
        echo -e "  --help\t\tShow this help message"
        echo -e "  --file <filename>\tSpecify a file to process"
        exit 0
    fi
    
    # Process file argument
    if [[ " $* " =~ " --file " ]]; then
        FILE_INDEX=$(( $(echo "$*" | grep -o "--file" | wc -l) + 1 ))
        FILE_NAME=$(echo "$*" | awk -v idx="$FILE_INDEX" '{print $idx}')
        if [ -f "$FILE_NAME" ]; then
            echo -e "\n${YELLOW}File Information:${NC}"
            echo -e "File: ${GREEN}$FILE_NAME${NC}"
            echo -e "Size: $(du -h "$FILE_NAME" | cut -f1)"
            echo -e "Lines: $(wc -l < "$FILE_NAME")"
            
            if [ "$VERBOSE" = true ]; then
                echo -e "\n${YELLOW}File Contents:${NC}"
                cat "$FILE_NAME"
            fi
        else
            echo -e "\n${RED}Error: File '$FILE_NAME' not found${NC}"
        fi
    fi
fi

# System information
echo -e "\n${YELLOW}System Information:${NC}"
echo -e "OS: $(uname -s)"
echo -e "Kernel: $(uname -r)"
echo -e "Architecture: $(uname -m)"

# Directory listing
echo -e "\n${YELLOW}Directory Contents:${NC}"
ls -la

# Environment variables
echo -e "\n${YELLOW}Environment Variables:${NC}"
echo -e "PATH: $PATH"
echo -e "HOME: $HOME"
echo -e "USER: $USER"
echo -e "SHELL: $SHELL"

# Create a test file
TEST_FILE="shellama_test_output.txt"
echo -e "\n${YELLOW}Creating Test File:${NC} $TEST_FILE"
echo "This is a test file created by SheLLama test script" > "$TEST_FILE"
echo "Created at: $(date)" >> "$TEST_FILE"
echo "By user: $(whoami)" >> "$TEST_FILE"
echo -e "File created successfully: ${GREEN}$TEST_FILE${NC}"

# Read the test file
echo -e "\n${YELLOW}Test File Contents:${NC}"
cat "$TEST_FILE"

# Clean up
echo -e "\n${YELLOW}Cleaning Up:${NC}"
rm "$TEST_FILE"
echo -e "Removed test file: ${GREEN}$TEST_FILE${NC}"

# Exit with success
echo -e "\n${GREEN}Test script completed successfully${NC}"
exit 0
