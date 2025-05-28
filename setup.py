#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from setuptools import setup, find_packages

with open("README.md", "r") as fh:
    long_description = fh.read()

setup(
    name="shellama",
    version="0.1.9",
    author="Tom Sapletta",
    author_email="info@devlama.dev",
    description="Shell and filesystem operations for the PyLama ecosystem",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/py-lama/shellama",
    packages=find_packages(),
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    python_requires=">=3.8",
    install_requires=[
        "pathlib>=1.0.1",
        "gitpython>=3.1.0",
    ],
    entry_points={
        "console_scripts": [
            "shellama=shellama.cli:main",
        ],
    },
)
