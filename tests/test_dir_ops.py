#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Test directory operations module
"""

import os
import tempfile
import unittest
from pathlib import Path

from shellama import dir_ops


class TestDirOps(unittest.TestCase):
    """Test case for directory operations"""

    def setUp(self):
        """Set up test environment"""
        # Create a temporary directory for testing
        self.temp_dir = tempfile.TemporaryDirectory()
        self.test_dir = self.temp_dir.name

        # Create some test subdirectories
        self.test_subdirs = [
            'subdir1',
            'subdir2',
            'subdir3'
        ]

        for dirname in self.test_subdirs:
            dir_path = os.path.join(self.test_dir, dirname)
            os.makedirs(dir_path)

            # Create a test file in each subdirectory
            with open(os.path.join(dir_path, 'test.txt'), 'w', encoding='utf-8') as f:
                f.write(f'Content of {dirname}/test.txt')

    def tearDown(self):
        """Clean up test environment"""
        self.temp_dir.cleanup()

    def test_create_directory(self):
        """Test creating a directory"""
        # Test creating a new directory
        new_dir = os.path.join(self.test_dir, 'new_dir')
        dir_ops.create_directory(new_dir)

        # Verify the directory was created
        self.assertTrue(os.path.isdir(new_dir))

        # Test creating a directory that already exists
        dir_ops.create_directory(new_dir)  # Should not raise an exception

        # Test creating a nested directory
        nested_dir = os.path.join(self.test_dir, 'nested', 'dir')
        dir_ops.create_directory(nested_dir)

        # Verify the nested directory was created
        self.assertTrue(os.path.isdir(nested_dir))

    def test_delete_directory(self):
        """Test deleting a directory"""
        # Test deleting an empty directory
        empty_dir = os.path.join(self.test_dir, 'empty_dir')
        os.makedirs(empty_dir)
        dir_ops.delete_directory(empty_dir)

        # Verify the directory was deleted
        self.assertFalse(os.path.exists(empty_dir))

        # Test deleting a non-empty directory without recursive flag
        non_empty_dir = os.path.join(self.test_dir, 'non_empty_dir')
        os.makedirs(non_empty_dir)
        with open(os.path.join(non_empty_dir, 'test.txt'), 'w', encoding='utf-8') as f:
            f.write('Test content')

        with self.assertRaises(OSError):
            dir_ops.delete_directory(non_empty_dir, recursive=False)

        # Test deleting a non-empty directory with recursive flag
        dir_ops.delete_directory(non_empty_dir, recursive=True)

        # Verify the directory was deleted
        self.assertFalse(os.path.exists(non_empty_dir))

        # Test deleting a non-existent directory
        with self.assertRaises(FileNotFoundError):
            dir_ops.delete_directory(os.path.join(self.test_dir, 'nonexistent'))

    def test_list_directories(self):
        """Test listing directories"""
        # Test listing directories
        directories = dir_ops.list_directories(self.test_dir)

        # Verify the correct number of directories was returned
        self.assertEqual(len(directories), 3)

        # Verify the directory names are correct
        dir_names = [d['name'] for d in directories]
        for subdir in self.test_subdirs:
            self.assertIn(subdir, dir_names)

        # Test listing directories in a non-existent directory
        with self.assertRaises(FileNotFoundError):
            dir_ops.list_directories(os.path.join(self.test_dir, 'nonexistent'))

    def test_directory_exists(self):
        """Test checking if a directory exists"""
        # Test with an existing directory
        dir_path = os.path.join(self.test_dir, 'subdir1')
        self.assertTrue(dir_ops.directory_exists(dir_path))

        # Test with a non-existent directory
        self.assertFalse(dir_ops.directory_exists(os.path.join(self.test_dir, 'nonexistent')))

    def test_get_directory_size(self):
        """Test getting directory size"""
        # Test with an existing directory
        dir_path = os.path.join(self.test_dir, 'subdir1')
        size = dir_ops.get_directory_size(dir_path)

        # Verify the size is greater than 0
        self.assertGreater(size, 0)

        # Test with a non-existent directory
        with self.assertRaises(FileNotFoundError):
            dir_ops.get_directory_size(os.path.join(self.test_dir, 'nonexistent'))

    def test_copy_directory(self):
        """Test copying a directory"""
        # Test copying a directory
        source_dir = os.path.join(self.test_dir, 'subdir1')
        dest_dir = os.path.join(self.test_dir, 'copy_of_subdir1')
        dir_ops.copy_directory(source_dir, dest_dir)

        # Verify the directory was copied
        self.assertTrue(os.path.isdir(dest_dir))
        self.assertTrue(os.path.isfile(os.path.join(dest_dir, 'test.txt')))

        # Verify the content of the copied file
        with open(os.path.join(dest_dir, 'test.txt'), 'r', encoding='utf-8') as f:
            self.assertEqual(f.read(), 'Content of subdir1/test.txt')

        # Test copying a non-existent directory
        with self.assertRaises(FileNotFoundError):
            dir_ops.copy_directory(os.path.join(self.test_dir, 'nonexistent'), dest_dir)


if __name__ == '__main__':
    unittest.main()
