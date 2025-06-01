# tests/test_validator.py
"""Testy modułu walidacji"""

import unittest
import tempfile
import os
from spylog.validator import validate_python_file, is_python_file


class TestValidator(unittest.TestCase):
    """Testy walidatora"""

    def setUp(self):
        """Przygotowanie testów"""
        self.temp_dir = tempfile.mkdtemp()

    def tearDown(self):
        """Czyszczenie po testach"""
        import shutil

        shutil.rmtree(self.temp_dir)

    def create_temp_file(self, content, filename="test.py"):
        """Stwórz tymczasowy plik"""
        filepath = os.path.join(self.temp_dir, filename)
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(content)
        return filepath

    def test_valid_python_file(self):
        """Test poprawnego pliku Python"""
        content = """
def hello():
    print("Hello, World!")

if __name__ == "__main__":
    hello()
"""
        filepath = self.create_temp_file(content)
        result = validate_python_file(filepath)
        self.assertTrue(result.is_valid)

    def test_invalid_syntax(self):
        """Test niepoprawnej składni"""
        content = """
def hello(
    print("Invalid syntax")
"""
        filepath = self.create_temp_file(content)
        result = validate_python_file(filepath)
        self.assertFalse(result.is_valid)
        self.assertIn("Błąd składni", result.message)

    def test_security_warning(self):
        """Test ostrzeżeń bezpieczeństwa"""
        content = """
import os
os.system("ls")
eval("print('dangerous')")
"""
        filepath = self.create_temp_file(content)
        result = validate_python_file(filepath)
        # Plik jest poprawny składniowo, ale ma ostrzeżenia
        self.assertTrue(len(result.warnings) > 0)

    def test_is_python_file(self):
        """Test rozpoznawania plików Python"""
        # Plik .py
        py_file = self.create_temp_file("print('hello')", "test.py")
        self.assertTrue(is_python_file(py_file))

        # Plik z shebang
        shebang_content = "#!/usr/bin/env python3\nprint('hello')"
        shebang_file = self.create_temp_file(shebang_content, "script")
        self.assertTrue(is_python_file(shebang_file))
