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
