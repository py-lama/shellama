#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
SheLLama Logger

This module provides logging functionality for the SheLLama service.
"""

import os
import logging
from logging.handlers import RotatingFileHandler

# Create a logger
logger = logging.getLogger('shellama')
logger.setLevel(logging.INFO)

# Create a formatter
formatter = logging.Formatter(
    '[%(asctime)s] [%(levelname)s] [%(name)s] - %(message)s'
)

# Create a console handler
console_handler = logging.StreamHandler()
console_handler.setFormatter(formatter)
logger.addHandler(console_handler)

# Create a file handler
log_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'logs')
os.makedirs(log_dir, exist_ok=True)
file_handler = RotatingFileHandler(
    os.path.join(log_dir, 'shellama.log'),
    maxBytes=10485760,  # 10 MB
    backupCount=10
)
file_handler.setFormatter(formatter)
logger.addHandler(file_handler)


def log_file_operation(operation: str, filename: str = 'all_files', success: bool = True, error: str = None):
    """
    Log a file operation.
    
    Args:
        operation (str): The file operation that was performed (e.g., 'read', 'write', 'list').
        filename (str, optional): The name of the file that was operated on. Defaults to 'all_files'.
        success (bool, optional): Whether the file operation was successful. Defaults to True.
        error (str, optional): The error message if the file operation failed. Defaults to None.
    """
    if success:
        logger.info(f"File operation: {operation} on {filename} - Success")
    else:
        logger.error(f"File operation: {operation} on {filename} - Failed: {error}")


def log_dir_operation(operation: str, directory: str = '.', success: bool = True, error: str = None):
    """
    Log a directory operation.
    
    Args:
        operation (str): The directory operation that was performed (e.g., 'create', 'delete', 'list').
        directory (str, optional): The directory that was operated on. Defaults to '.'.
        success (bool, optional): Whether the directory operation was successful. Defaults to True.
        error (str, optional): The error message if the directory operation failed. Defaults to None.
    """
    if success:
        logger.info(f"Directory operation: {operation} on {directory} - Success")
    else:
        logger.error(f"Directory operation: {operation} on {directory} - Failed: {error}")


def init_app(app):
    """
    Initialize the logger for the Flask application.
    
    Args:
        app (Flask): The Flask application to initialize the logger for.
    """
    if not app.debug:
        app.logger.setLevel(logging.INFO)
        app.logger.addHandler(console_handler)
        app.logger.addHandler(file_handler)
    
    # Log when the app starts
    logger.info(f"SheLLama API started on {app.config.get('HOST', '127.0.0.1')}:{app.config.get('PORT', 8082)}")



def log_shell_command(command: str, success: bool = True, exit_code: int = 0, error: str = None):
    """
    Log a shell command execution.
    
    Args:
        command (str): The shell command that was executed.
        success (bool, optional): Whether the command execution was successful. Defaults to True.
        exit_code (int, optional): The exit code of the command. Defaults to 0.
        error (str, optional): The error message if the command execution failed. Defaults to None.
    """
    if success:
        logger.info(f"Shell command: {command} - Success (exit code: {exit_code})")
    else:
        logger.error(f"Shell command: {command} - Failed (exit code: {exit_code}): {error}")
