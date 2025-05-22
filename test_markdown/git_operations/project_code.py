#!/usr/bin/env python3
"""
Example Python code file for testing Git operations.

This file simulates a simple Python project that will be modified
across different branches to test Git operations.
"""

import json
import os
from datetime import datetime


class GitProject:
    """A simple class representing a project under Git version control."""

    def __init__(self, name, version="1.0.0"):
        """Initialize the project with a name and version."""
        self.name = name
        self.version = version
        self.created_at = datetime.now()
        self.features = []
        self.contributors = []

    def add_feature(self, feature_name, description):
        """Add a new feature to the project."""
        feature = {
            "name": feature_name,
            "description": description,
            "added_at": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        }
        self.features.append(feature)
        return feature

    def add_contributor(self, name, role):
        """Add a new contributor to the project."""
        contributor = {
            "name": name,
            "role": role,
            "joined_at": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        }
        self.contributors.append(contributor)
        return contributor

    def update_version(self, new_version):
        """Update the project version."""
        old_version = self.version
        self.version = new_version
        return {
            "old_version": old_version,
            "new_version": new_version,
            "updated_at": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        }

    def get_info(self):
        """Get project information as a dictionary."""
        return {
            "name": self.name,
            "version": self.version,
            "created_at": self.created_at.strftime("%Y-%m-%d %H:%M:%S"),
            "features": self.features,
            "contributors": self.contributors
        }

    def save_to_file(self, filename="project_info.json"):
        """Save project information to a JSON file."""
        with open(filename, "w") as f:
            json.dump(self.get_info(), f, indent=2)
        return filename


# Main function to demonstrate the class
def main():
    """Create a sample project and demonstrate its functionality."""
    project = GitProject("Sample Git Project")
    
    # Add features
    project.add_feature("User Authentication", "Basic login and registration")
    project.add_feature("Data Export", "Export data to CSV and JSON formats")
    
    # Add contributors
    project.add_contributor("Alice", "Project Manager")
    project.add_contributor("Bob", "Developer")
    
    # Print project info
    print("Project Information:")
    print(f"Name: {project.name}")
    print(f"Version: {project.version}")
    print(f"Created: {project.created_at.strftime('%Y-%m-%d %H:%M:%S')}")
    
    print("\nFeatures:")
    for feature in project.features:
        print(f"- {feature['name']}: {feature['description']}")
    
    print("\nContributors:")
    for contributor in project.contributors:
        print(f"- {contributor['name']} ({contributor['role']})")
    
    # Save to file
    filename = project.save_to_file()
    print(f"\nProject information saved to {filename}")


if __name__ == "__main__":
    main()
