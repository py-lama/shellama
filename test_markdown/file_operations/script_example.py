#!/usr/bin/env python3
"""
Example Python script for testing SheLLama file operations.

This script demonstrates various Python features and can be used
to test file reading, editing, and execution operations.
"""

import os
import sys
import json
import argparse
from datetime import datetime


class FileProcessor:
    """A class to process files and demonstrate Python features."""

    def __init__(self, directory="."):
        """Initialize the FileProcessor with a directory."""
        self.directory = directory
        self.files = []
        self.stats = {
            "total_files": 0,
            "total_size": 0,
            "file_types": {}
        }

    def scan_directory(self):
        """Scan the directory for files and collect statistics."""
        if not os.path.exists(self.directory):
            print(f"Error: Directory '{self.directory}' does not exist.")
            return False

        print(f"Scanning directory: {self.directory}")
        self.files = []
        self.stats = {
            "total_files": 0,
            "total_size": 0,
            "file_types": {}
        }

        for root, _, files in os.walk(self.directory):
            for file in files:
                file_path = os.path.join(root, file)
                file_size = os.path.getsize(file_path)
                file_ext = os.path.splitext(file)[1].lower()

                self.files.append({
                    "path": file_path,
                    "name": file,
                    "size": file_size,
                    "extension": file_ext,
                    "modified": datetime.fromtimestamp(
                        os.path.getmtime(file_path)
                    ).strftime("%Y-%m-%d %H:%M:%S")
                })

                self.stats["total_files"] += 1
                self.stats["total_size"] += file_size

                if file_ext not in self.stats["file_types"]:
                    self.stats["file_types"][file_ext] = {
                        "count": 0,
                        "total_size": 0
                    }

                self.stats["file_types"][file_ext]["count"] += 1
                self.stats["file_types"][file_ext]["total_size"] += file_size

        return True

    def get_summary(self):
        """Get a summary of the directory scan."""
        return {
            "directory": self.directory,
            "scan_time": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "stats": self.stats
        }

    def save_report(self, output_file="report.json"):
        """Save the scan report to a JSON file."""
        summary = self.get_summary()
        with open(output_file, "w") as f:
            json.dump(summary, f, indent=2)
        print(f"Report saved to {output_file}")
        return output_file

    def print_report(self):
        """Print the scan report to the console."""
        summary = self.get_summary()
        print("\nDirectory Scan Report")
        print("=" * 50)
        print(f"Directory: {summary['directory']}")
        print(f"Scan Time: {summary['scan_time']}")
        print(f"Total Files: {summary['stats']['total_files']}")
        print(f"Total Size: {self._format_size(summary['stats']['total_size'])}")
        
        print("\nFile Types:")
        for ext, data in summary['stats']['file_types'].items():
            ext_name = ext if ext else "(no extension)"
            print(f"  {ext_name}: {data['count']} files, "
                  f"{self._format_size(data['total_size'])}")

    @staticmethod
    def _format_size(size_bytes):
        """Format file size in a human-readable format."""
        if size_bytes < 1024:
            return f"{size_bytes} bytes"
        elif size_bytes < 1024 * 1024:
            return f"{size_bytes / 1024:.2f} KB"
        elif size_bytes < 1024 * 1024 * 1024:
            return f"{size_bytes / (1024 * 1024):.2f} MB"
        else:
            return f"{size_bytes / (1024 * 1024 * 1024):.2f} GB"


def main():
    """Main function to process command line arguments and run the script."""
    parser = argparse.ArgumentParser(
        description="Process files in a directory and generate statistics."
    )
    parser.add_argument(
        "-d", "--directory",
        default=".",
        help="Directory to scan (default: current directory)"
    )
    parser.add_argument(
        "-o", "--output",
        help="Output file for the JSON report"
    )
    parser.add_argument(
        "--no-print",
        action="store_true",
        help="Don't print the report to the console"
    )

    args = parser.parse_args()

    processor = FileProcessor(args.directory)
    if not processor.scan_directory():
        return 1

    if not args.no_print:
        processor.print_report()

    if args.output:
        processor.save_report(args.output)

    return 0


if __name__ == "__main__":
    sys.exit(main())
