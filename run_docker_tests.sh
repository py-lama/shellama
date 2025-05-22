#!/bin/bash

# Colors for output
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

# Create test-reports directory if it doesn't exist
mkdir -p test-reports

print_header() {
    echo -e "\n${BLUE}===========================================================${NC}"
    echo -e "${BLUE} $1 ${NC}"
    echo -e "${BLUE}===========================================================${NC}\n"
}

show_help() {
    echo -e "${YELLOW}SheLLama Docker Testing Environment${NC}"
    echo -e "\nUsage: $0 [options]\n"
    echo -e "Options:"
    echo -e "  --build\t\tBuild Docker images before starting"
    echo -e "  --run-tests\t\tRun all tests automatically after starting"
    echo -e "  --interactive\t\tStart in interactive mode (don't run tests automatically)"
    echo -e "  --test-git\t\tRun only Git operations tests"
    echo -e "  --test-file\t\tRun only file operations tests"
    echo -e "  --test-dir\t\tRun only directory operations tests"
    echo -e "  --test-shell\t\tRun only shell operations tests"
    echo -e "  --test-error\t\tRun only error handling tests"
    echo -e "  --stop\t\tStop and remove containers"
    echo -e "  --clean\t\tStop containers and remove volumes"
    echo -e "  --help\t\tShow this help message"
    echo -e "\nExamples:\n"
    echo -e "  $0 --build --run-tests\t# Build and run all tests"
    echo -e "  $0 --interactive\t\t# Start in interactive mode"
    echo -e "  $0 --test-git\t\t# Run only Git operations tests"
    echo -e "  $0 --stop\t\t# Stop containers"
}

# Default options
BUILD=false
RUN_TESTS=false
INTERACTIVE=false
TEST_CATEGORY=""
STOP=false
CLEAN=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --build)
            BUILD=true
            shift
            ;;
        --run-tests)
            RUN_TESTS=true
            shift
            ;;
        --interactive)
            INTERACTIVE=true
            shift
            ;;
        --test-git)
            TEST_CATEGORY="git"
            shift
            ;;
        --test-file)
            TEST_CATEGORY="file"
            shift
            ;;
        --test-dir)
            TEST_CATEGORY="dir"
            shift
            ;;
        --test-shell)
            TEST_CATEGORY="shell"
            shift
            ;;
        --test-error)
            TEST_CATEGORY="error"
            shift
            ;;
        --stop)
            STOP=true
            shift
            ;;
        --clean)
            CLEAN=true
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# Stop containers if requested
if [ "$STOP" = true ]; then
    print_header "Stopping Docker containers"
    docker-compose -f docker-compose.ansible-test.yml down
    echo -e "${GREEN}Containers stopped${NC}"
    exit 0
fi

# Clean containers and volumes if requested
if [ "$CLEAN" = true ]; then
    print_header "Cleaning Docker containers and volumes"
    docker-compose -f docker-compose.ansible-test.yml down -v
    echo -e "${GREEN}Containers and volumes removed${NC}"
    exit 0
fi

# Build and start containers
if [ "$BUILD" = true ]; then
    print_header "Building Docker images"
    docker-compose -f docker-compose.ansible-test.yml build
fi

# Start the mock API service
print_header "Starting mock SheLLama API service"
docker-compose -f docker-compose.ansible-test.yml up -d shellama-mock-api

# Wait for the API to be ready
echo -e "${YELLOW}Waiting for mock API to start...${NC}"
sleep 5

# Check if the API is running
API_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5000/api/shellama/health)
if [ "$API_STATUS" = "200" ]; then
    echo -e "${GREEN}Mock SheLLama API is running${NC}"
else
    echo -e "${RED}Failed to start mock SheLLama API (status code: $API_STATUS)${NC}"
    exit 1
fi

# Run tests if requested
if [ "$RUN_TESTS" = true ]; then
    print_header "Running all Ansible tests"
    docker-compose -f docker-compose.ansible-test.yml up shellama-ansible-tests
    exit 0
fi

# Run specific test category if requested
if [ -n "$TEST_CATEGORY" ]; then
    print_header "Running $TEST_CATEGORY operations tests"
    docker exec -it $(docker ps -qf "name=shellama_shellama-mock-api") bash -c "cd /app && make ansible-test-$TEST_CATEGORY"
    exit 0
fi

# Start interactive mode if requested
if [ "$INTERACTIVE" = true ] || [ "$RUN_TESTS" = false -a -z "$TEST_CATEGORY" ]; then
    print_header "Starting interactive mode"
    echo -e "${YELLOW}Available commands:${NC}"
    echo -e "  ${GREEN}make ansible-test${NC} - Run all tests"
    echo -e "  ${GREEN}make ansible-test-git${NC} - Run Git operations tests"
    echo -e "  ${GREEN}make ansible-test-file${NC} - Run file operations tests"
    echo -e "  ${GREEN}make ansible-test-dir${NC} - Run directory operations tests"
    echo -e "  ${GREEN}make ansible-test-shell${NC} - Run shell operations tests"
    echo -e "  ${GREEN}make ansible-test-error${NC} - Run error handling tests"
    echo -e "  ${GREEN}make ansible-test-git-mock${NC} - Run mock Git operations tests"
    echo -e "\n${YELLOW}Type 'exit' to exit the container${NC}\n"
    
    docker exec -it $(docker ps -qf "name=shellama_shellama-mock-api") bash
fi

echo -e "\n${YELLOW}To stop the containers, run:${NC} $0 --stop"
echo -e "${YELLOW}To clean up containers and volumes, run:${NC} $0 --clean"
