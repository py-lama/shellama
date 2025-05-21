#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Test file operations module
"""

import os
import tempfile
import unittest
from pathlib import Path

from shellama import file_ops


class TestFileOps(unittest.TestCase):
    """Test case for file operations"""

    def setUp(self):
        """Set up test environment"""
        # Create a temporary directory for testing
        self.temp_dir = tempfile.TemporaryDirectory()
        self.test_dir = self.temp_dir.name

        # Create some test files
        self.test_files = [
            'test1.md',
            'test2.md',
            'test3.txt'
        ]

        for filename in self.test_files:
            file_path = os.path.join(self.test_dir, filename)
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(f'Content of {filename}')

    def tearDown(self):
        """Clean up test environment"""
        self.temp_dir.cleanup()

    def test_list_files(self):
        """Test listing files"""
        # Test listing all files
        files = file_ops.list_files(self.test_dir, '*.*')
        self.assertEqual(len(files), 3)

        # Test listing only markdown files
        md_files = file_ops.list_files(self.test_dir, '*.md')
        self.assertEqual(len(md_files), 2)

        # Test listing only text files
        txt_files = file_ops.list_files(self.test_dir, '*.txt')
        self.assertEqual(len(txt_files), 1)

    def test_read_file(self):
        """Test reading a file"""
        # Test reading an existing file
        file_path = os.path.join(self.test_dir, 'test1.md')
        content = file_ops.read_file(file_path)
        self.assertEqual(content, 'Content of test1.md')

        # Test reading a non-existent file
        with self.assertRaises(FileNotFoundError):
            file_ops.read_file(os.path.join(self.test_dir, 'nonexistent.md'))

    def test_write_file(self):
        """Test writing to a file"""
        # Test writing to a new file
        file_path = os.path.join(self.test_dir, 'new_file.md')
        content = 'New file content'
        file_ops.write_file(file_path, content)

        # Verify the file was written correctly
        with open(file_path, 'r', encoding='utf-8') as f:
            self.assertEqual(f.read(), content)

        # Test overwriting an existing file
        file_path = os.path.join(self.test_dir, 'test1.md')
        new_content = 'Updated content'
        file_ops.write_file(file_path, new_content)

        # Verify the file was updated correctly
        with open(file_path, 'r', encoding='utf-8') as f:
            self.assertEqual(f.read(), new_content)

    def test_delete_file(self):
        """Test deleting a file"""
        # Test deleting an existing file
        file_path = os.path.join(self.test_dir, 'test1.md')
        file_ops.delete_file(file_path)

        # Verify the file was deleted
        self.assertFalse(os.path.exists(file_path))

        # Test deleting a non-existent file
        with self.assertRaises(FileNotFoundError):
            file_ops.delete_file(os.path.join(self.test_dir, 'nonexistent.md'))

    def test_file_exists(self):
        """Test checking if a file exists"""
        # Test with an existing file
        file_path = os.path.join(self.test_dir, 'test1.md')
        self.assertTrue(file_ops.file_exists(file_path))

        # Test with a non-existent file
        self.assertFalse(file_ops.file_exists(os.path.join(self.test_dir, 'nonexistent.md')))

    def test_get_file_info(self):
        """Test getting file information"""
        # Test with an existing file
        file_path = os.path.join(self.test_dir, 'test1.md')
        info = file_ops.get_file_info(file_path)

        self.assertEqual(info['name'], 'test1.md')
        self.assertEqual(info['path'], file_path)
        self.assertTrue(info['is_file'])
        self.assertFalse(info['is_dir'])
        self.assertEqual(info['extension'], '.md')

        # Test with a non-existent file
        with self.assertRaises(FileNotFoundError):
            file_ops.get_file_info(os.path.join(self.test_dir, 'nonexistent.md'))


if __name__ == '__main__':
    unittest.main()
