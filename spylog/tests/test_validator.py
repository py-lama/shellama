# tests/__init__.py
"""Testy dla Spyq"""

# tests/test_validator.py
"""Testy modułu walidacji"""

import unittest
import tempfile
import os
from spyq.validator import validate_python_file, is_python_file

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
        with open(filepath, 'w', encoding='utf-8') as f:
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


# tests/test_main.py
"""Testy głównego modułu"""

import unittest
from unittest.mock import patch, MagicMock
from spyq.main import find_python_file_in_args, should_validate

class TestMain(unittest.TestCase):
    """Testy głównego modułu"""
    
    def test_find_python_file_in_args(self):
        """Test znajdowania pliku Python w argumentach"""
        # Bez pliku Python
        self.assertIsNone(find_python_file_in_args(['-c', 'print("hello")']))
        
        # Z flagami
        with patch('os.path.isfile', return_value=True):
            result = find_python_file_in_args(['--verbose', 'script.py', '--debug'])
            self.assertEqual(result, 'script.py')
    
    def test_should_validate(self):
        """Test decyzji o walidacji"""
        # Puste argumenty
        self.assertFalse(should_validate([]))
        
        # Flagi które pomijamy
        self.assertFalse(should_validate(['-c', 'print("hello")']))
        self.assertFalse(should_validate(['-m', 'module']))
        self.assertFalse(should_validate(['-h']))
        
        # Z plikiem Python
        with patch('spyq.main.find_python_file_in_args', return_value='script.py'):
            self.assertTrue(should_validate(['script.py']))


if __name__ == '__main__':
    unittest.main()


# tests/fixtures/valid_script.py
"""Poprawny skrypt testowy"""

def main():
    """Główna funkcja"""
    print("Hello from valid script!")
    return 0

if __name__ == "__main__":
    exit(main())


# tests/fixtures/invalid_syntax.py
"""Niepoprawny skrypt testowy"""

def main(
    print("Missing closing parenthesis")
    return 0


# tests/fixtures/security_warning.py
"""Skrypt z ostrzeżeniami bezpieczeństwa"""

import os
import subprocess

def dangerous_function():
    """Funkcja z niebezpiecznymi wywołaniami"""
    os.system("rm -rf /")  # Niebezpieczne!
    eval("print('eval is dangerous')")  # Niebezpieczne!
    exec("print('exec is dangerous')")  # Niebezpieczne!
    subprocess.call(["ls", "-la"])  # Potencjalnie niebezpieczne

if __name__ == "__main__":
    dangerous_function()