#!/usr/bin/env python3
"""
Verification script for SheLLama test markdown directory.

This script verifies that all test files are present and accessible.
It checks the structure of the test_markdown directory and ensures
that all required files exist and have the correct permissions.
"""

import os
import sys
import json
from datetime import datetime

# Define colors for output
COLORS = {
    "GREEN": "\033[0;32m",
    "YELLOW": "\033[1;33m",
    "RED": "\033[0;31m",
    "BLUE": "\033[0;34m",
    "NC": "\033[0m"  # No Color
}

# Define expected directory structure
EXPECTED_STRUCTURE = {
    "file_operations": [
        "README.md",
        "simple_text.txt",
        "markdown_example.md",
        "config_example.json",
        "script_example.py",
        "large_file.txt"
    ],
    "git_operations": [
        "README.md",
        "main_file.md",
        "feature_file.md",
        "conflict_file.md",
        "project_code.py",
        "config.json"
    ],
    "shell_commands": [
        "README.md",
        "test_script.sh",
        "data_processing.sh",
        "sample_data.txt",
        "environment_test.sh",
        "error_test.sh"
    ],
    "devops_tools": [
        "README.md",
        "Dockerfile",
        "docker-compose.yml",
        "ansible_playbook.yml",
        "terraform_example.tf",
        "kubernetes_deployment.yml",
        "jenkins_pipeline.groovy",
        "github_workflow.yml"
    ]
}

def print_header(message):
    """Print a formatted header message."""
    print(f"\n{COLORS['BLUE']}{'=' * 60}{COLORS['NC']}")
    print(f"{COLORS['BLUE']} {message} {COLORS['NC']}")
    print(f"{COLORS['BLUE']}{'=' * 60}{COLORS['NC']}\n")

def print_success(message):
    """Print a success message."""
    print(f"{COLORS['GREEN']}✓ {message}{COLORS['NC']}")

def print_warning(message):
    """Print a warning message."""
    print(f"{COLORS['YELLOW']}⚠ {message}{COLORS['NC']}")

def print_error(message):
    """Print an error message."""
    print(f"{COLORS['RED']}✗ {message}{COLORS['NC']}")

def print_info(message):
    """Print an info message."""
    print(f"{COLORS['BLUE']}ℹ {message}{COLORS['NC']}")

def verify_directory_structure(base_dir):
    """Verify that the directory structure matches the expected structure."""
    print_header("Verifying Directory Structure")
    
    # Check if base directory exists
    if not os.path.isdir(base_dir):
        print_error(f"Base directory '{base_dir}' does not exist")
        return False
    
    print_success(f"Base directory '{base_dir}' exists")
    
    # Check if README.md exists in base directory
    if not os.path.isfile(os.path.join(base_dir, "README.md")):
        print_warning(f"README.md not found in base directory '{base_dir}'")
    else:
        print_success(f"README.md found in base directory '{base_dir}'")
    
    # Check subdirectories
    success = True
    for subdir in EXPECTED_STRUCTURE.keys():
        subdir_path = os.path.join(base_dir, subdir)
        if not os.path.isdir(subdir_path):
            print_error(f"Subdirectory '{subdir}' not found")
            success = False
            continue
        
        print_success(f"Subdirectory '{subdir}' exists")
        
        # Check files in subdirectory
        for filename in EXPECTED_STRUCTURE[subdir]:
            file_path = os.path.join(subdir_path, filename)
            if not os.path.isfile(file_path):
                print_error(f"File '{filename}' not found in '{subdir}'")
                success = False
                continue
            
            # Check if file is readable
            if not os.access(file_path, os.R_OK):
                print_warning(f"File '{filename}' in '{subdir}' is not readable")
                continue
            
            # Check if shell scripts are executable
            if filename.endswith(".sh") and not os.access(file_path, os.X_OK):
                print_warning(f"Shell script '{filename}' in '{subdir}' is not executable")
                print_info(f"  Run: chmod +x {file_path}")
            
            print_success(f"File '{filename}' in '{subdir}' is accessible")
    
    return success

def verify_file_contents(base_dir):
    """Verify that file contents are valid and properly formatted."""
    print_header("Verifying File Contents")
    
    success = True
    
    # Check JSON files
    for subdir in EXPECTED_STRUCTURE.keys():
        for filename in EXPECTED_STRUCTURE[subdir]:
            if filename.endswith(".json"):
                file_path = os.path.join(base_dir, subdir, filename)
                try:
                    with open(file_path, 'r') as f:
                        json.load(f)
                    print_success(f"JSON file '{filename}' in '{subdir}' is valid")
                except json.JSONDecodeError as e:
                    print_error(f"JSON file '{filename}' in '{subdir}' is invalid: {str(e)}")
                    success = False
                except Exception as e:
                    print_error(f"Error reading file '{filename}' in '{subdir}': {str(e)}")
                    success = False
    
    # Check shell scripts
    for filename in EXPECTED_STRUCTURE["shell_commands"]:
        if filename.endswith(".sh"):
            file_path = os.path.join(base_dir, "shell_commands", filename)
            try:
                with open(file_path, 'r') as f:
                    first_line = f.readline().strip()
                if not first_line.startswith("#!/"):
                    print_warning(f"Shell script '{filename}' does not start with shebang line")
                else:
                    print_success(f"Shell script '{filename}' has proper shebang line")
            except Exception as e:
                print_error(f"Error reading file '{filename}' in 'shell_commands': {str(e)}")
                success = False
    
    return success

def generate_report(base_dir):
    """Generate a report of the test markdown directory."""
    print_header("Generating Report")
    
    report = {
        "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "base_directory": base_dir,
        "subdirectories": {}
    }
    
    # Collect information about subdirectories
    for subdir in EXPECTED_STRUCTURE.keys():
        subdir_path = os.path.join(base_dir, subdir)
        if not os.path.isdir(subdir_path):
            continue
        
        files = []
        for filename in os.listdir(subdir_path):
            file_path = os.path.join(subdir_path, filename)
            if os.path.isfile(file_path):
                file_info = {
                    "name": filename,
                    "size": os.path.getsize(file_path),
                    "last_modified": datetime.fromtimestamp(os.path.getmtime(file_path)).strftime("%Y-%m-%d %H:%M:%S"),
                    "readable": os.access(file_path, os.R_OK),
                    "writable": os.access(file_path, os.W_OK),
                    "executable": os.access(file_path, os.X_OK)
                }
                files.append(file_info)
        
        report["subdirectories"][subdir] = {
            "path": subdir_path,
            "files": files,
            "file_count": len(files)
        }
    
    # Write report to file
    report_file = os.path.join(base_dir, "test_files_report.json")
    try:
        with open(report_file, 'w') as f:
            json.dump(report, f, indent=2)
        print_success(f"Report generated: {report_file}")
    except Exception as e:
        print_error(f"Error generating report: {str(e)}")
    
    return report

def main():
    """Main function."""
    # Determine base directory
    if len(sys.argv) > 1:
        base_dir = sys.argv[1]
    else:
        # Default to the directory where the script is located
        base_dir = os.path.dirname(os.path.abspath(__file__))
    
    print_header("SheLLama Test Markdown Directory Verification")
    print_info(f"Base directory: {base_dir}")
    print_info(f"Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    # Verify directory structure
    structure_ok = verify_directory_structure(base_dir)
    
    # Verify file contents
    contents_ok = verify_file_contents(base_dir)
    
    # Generate report
    report = generate_report(base_dir)
    
    # Print summary
    print_header("Verification Summary")
    if structure_ok and contents_ok:
        print_success("All tests passed!")
    elif structure_ok:
        print_warning("Directory structure is correct, but some file contents have issues")
    elif contents_ok:
        print_warning("File contents are valid, but directory structure has issues")
    else:
        print_error("Both directory structure and file contents have issues")
    
    # Print file counts
    print("\nFile counts by directory:")
    for subdir, info in report["subdirectories"].items():
        print(f"{COLORS['BLUE']}{subdir}{COLORS['NC']}: {info['file_count']} files")
    
    total_files = sum(info['file_count'] for info in report["subdirectories"].values())
    print(f"\n{COLORS['GREEN']}Total files: {total_files}{COLORS['NC']}")
    
    return 0 if structure_ok and contents_ok else 1

if __name__ == "__main__":
    sys.exit(main())
