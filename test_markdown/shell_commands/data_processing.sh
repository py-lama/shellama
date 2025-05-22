#!/bin/bash

# Data processing script for SheLLama shell command testing
# This script demonstrates data processing operations using shell commands

# Default values
INPUT_FILE="sample_data.txt"
OUTPUT_FILE="processed_data.txt"
OPERATION="count"

# Function to display usage information
show_usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -i, --input FILE    Input file (default: sample_data.txt)"
    echo "  -o, --output FILE   Output file (default: processed_data.txt)"
    echo "  -p, --operation OP  Operation to perform (count, sort, filter, transform)"
    echo "  -h, --help          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --input data.txt --operation sort"
    echo "  $0 --operation filter --output filtered.txt"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--input)
            INPUT_FILE="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -p|--operation)
            OPERATION="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            echo "Error: Unknown option $1"
            show_usage
            exit 1
            ;;
    esac
done

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' not found"
    exit 1
fi

# Perform the requested operation
case $OPERATION in
    count)
        echo "Counting data in $INPUT_FILE..."
        echo "Total lines: $(wc -l < "$INPUT_FILE")" > "$OUTPUT_FILE"
        echo "Total words: $(wc -w < "$INPUT_FILE")" >> "$OUTPUT_FILE"
        echo "Total characters: $(wc -c < "$INPUT_FILE")" >> "$OUTPUT_FILE"
        
        # Count occurrences of each word
        echo "\nWord frequency:" >> "$OUTPUT_FILE"
        cat "$INPUT_FILE" | tr -s '[:space:]' '\n' | sort | uniq -c | sort -nr >> "$OUTPUT_FILE"
        ;;
    
    sort)
        echo "Sorting data in $INPUT_FILE..."
        sort "$INPUT_FILE" > "$OUTPUT_FILE"
        ;;
    
    filter)
        echo "Filtering data in $INPUT_FILE..."
        # Filter out empty lines and comments
        grep -v "^\s*$" "$INPUT_FILE" | grep -v "^\s*#" > "$OUTPUT_FILE"
        ;;
    
    transform)
        echo "Transforming data in $INPUT_FILE..."
        # Convert to uppercase, replace spaces with commas
        tr '[:lower:]' '[:upper:]' < "$INPUT_FILE" | tr ' ' ',' > "$OUTPUT_FILE"
        ;;
    
    *)
        echo "Error: Unknown operation '$OPERATION'"
        echo "Valid operations: count, sort, filter, transform"
        exit 1
        ;;
esac

echo "Operation '$OPERATION' completed successfully"
echo "Results saved to $OUTPUT_FILE"

# Display a preview of the output
echo "\nOutput preview:"
head -n 5 "$OUTPUT_FILE"

exit 0
