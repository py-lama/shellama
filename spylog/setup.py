"""
Setup script dla Spyq
"""

from setuptools import setup, find_packages
import os


# Odczytaj README
def read_readme():
    readme_path = os.path.join(os.path.dirname(__file__), "README.md")
    if os.path.exists(readme_path):
        with open(readme_path, "r", encoding="utf-8") as f:
            return f.read()
    return ""


# Odczytaj requirements
def read_requirements(filename):
    req_path = os.path.join(os.path.dirname(__file__), filename)
    if os.path.exists(req_path):
        with open(req_path, "r", encoding="utf-8") as f:
            return [line.strip() for line in f if line.strip() and not line.startswith("#")]
    return []


setup(
    name="spyq",
    version="0.1.0",
    description="Python Validator Proxy - waliduje pliki Python przed uruchomieniem",
    long_description=read_readme(),
    long_description_content_type="text/markdown",
    author="Spyq Team",
    author_email="spyq@example.com",
    url="https://github.com/your-username/spyq",
    packages=find_packages(),
    # Entry points - komendy dostępne po instalacji
    entry_points={
        "console_scripts": [
            "spyq=spyq.main:cli",
        ],
    },
    # Wymagania
    install_requires=read_requirements("requirements.txt"),
    extras_require={
        "dev": read_requirements("requirements-dev.txt"),
    },
    # Kompatybilność
    python_requires=">=3.6",
    # Klasyfikatory PyPI
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: Developers",
        "Topic :: Software Development :: Quality Assurance",
        "Topic :: Software Development :: Testing",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.6",
        "Programming Language :: Python :: 3.7",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Programming Language :: Python :: 3.12",
        "Operating System :: OS Independent",
        "Environment :: Console",
    ],
    # Słowa kluczowe
    keywords="python validator security syntax checker proxy",
    # Linki projektu
    project_urls={
        "Bug Reports": "https://github.com/your-username/spyq/issues",
        "Source": "https://github.com/your-username/spyq",
        "Documentation": "https://github.com/your-username/spyq#readme",
    },
    # Dołącz pliki dodatkowe
    include_package_data=True,
    zip_safe=False,
)
