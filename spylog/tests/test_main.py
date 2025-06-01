# tests/test_main.py
"""Testy głównego modułu"""

import unittest
from unittest.mock import patch, MagicMock
from spylog.main import find_python_file_in_args, should_validate


class TestMain(unittest.TestCase):
    """Testy głównego modułu"""

    def test_find_python_file_in_args(self):
        """Test znajdowania pliku Python w argumentach"""
        # Bez pliku Python
        self.assertIsNone(find_python_file_in_args(["-c", 'print("hello")']))

        # Z flagami
        with patch("os.path.isfile", return_value=True):
            result = find_python_file_in_args(["--verbose", "script.py", "--debug"])
            self.assertEqual(result, "script.py")

    def test_should_validate(self):
        """Test decyzji o walidacji"""
        # Puste argumenty
        self.assertFalse(should_validate([]))

        # Flagi które pomijamy
        self.assertFalse(should_validate(["-c", 'print("hello")']))
        self.assertFalse(should_validate(["-m", "module"]))
        self.assertFalse(should_validate(["-h"]))

        # Z plikiem Python
        with patch("spylog.main.find_python_file_in_args", return_value="script.py"):
            self.assertTrue(should_validate(["script.py"]))


if __name__ == "__main__":
    unittest.main()
