#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Mock Service for PyLama Ecosystem Testing

This script creates a simple Flask application that simulates
the behavior of PyLama ecosystem services for testing purposes.
"""

import os
import sys
import json
import logging
from datetime import datetime
from flask import Flask, jsonify, request, Response
from flask_cors import CORS

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger('mock-service')

# Get environment variables
SERVICE_NAME = os.environ.get('SERVICE_NAME', 'mock-service')
PORT = int(os.environ.get('PORT', 5000))
HOST = os.environ.get('HOST', '0.0.0.0')

# Create Flask app
app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

# Store mock data
mock_data = {
    'files': [
        {'name': 'test.txt', 'path': '/tmp/test.txt', 'size': 1024, 'type': 'file'},
        {'name': 'example.md', 'path': '/tmp/example.md', 'size': 2048, 'type': 'file'},
        {'name': 'config.json', 'path': '/tmp/config.json', 'size': 512, 'type': 'file'}
    ],
    'directories': [
        {'name': 'docs', 'path': '/tmp/docs', 'items': 5},
        {'name': 'src', 'path': '/tmp/src', 'items': 10},
        {'name': 'tests', 'path': '/tmp/tests', 'items': 8}
    ],
    'git': {
        'branches': ['main', 'develop', 'feature/test'],
        'status': {'clean': True, 'changes': 0},
        'commits': [
            {'hash': 'abc1234', 'author': 'Test User', 'date': '2025-05-20T10:00:00Z', 'message': 'Initial commit'},
            {'hash': 'def5678', 'author': 'Test User', 'date': '2025-05-21T11:30:00Z', 'message': 'Update README'}
        ]
    },
    'llm': {
        'models': ['gpt-3.5-turbo', 'llama-2-7b', 'mistral-7b'],
        'default': 'gpt-3.5-turbo'
    }
}

# Request counter for statistics
request_counter = 0

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    global request_counter
    request_counter += 1
    
    return jsonify({
        'status': 'ok',
        'service': SERVICE_NAME,
        'timestamp': datetime.now().isoformat(),
        'requests_served': request_counter
    })

@app.route('/api/health', methods=['GET'])
def api_health_check():
    """API health check endpoint"""
    return health_check()

@app.route(f'/api/{SERVICE_NAME}/health', methods=['GET'])
def service_health_check():
    """Service-specific health check endpoint"""
    return health_check()

@app.route('/api/files', methods=['GET'])
def list_files():
    """List files endpoint"""
    global request_counter
    request_counter += 1
    
    directory = request.args.get('directory', '/tmp')
    logger.info(f"Listing files in {directory}")
    
    return jsonify({
        'status': 'success',
        'files': mock_data['files'],
        'service': SERVICE_NAME
    })

@app.route('/api/file', methods=['GET'])
def get_file():
    """Get file content endpoint"""
    global request_counter
    request_counter += 1
    
    filename = request.args.get('filename')
    if not filename:
        return jsonify({
            'status': 'error',
            'message': 'Filename parameter is required'
        }), 400
    
    logger.info(f"Getting content for file {filename}")
    
    # Return mock content based on file extension
    if filename.endswith('.txt'):
        content = "This is a sample text file content.\nLine 2\nLine 3"
    elif filename.endswith('.md'):
        content = "# Markdown Example\n\n## Section 1\n\nThis is a sample markdown file."
    elif filename.endswith('.json'):
        content = json.dumps({"key": "value", "nested": {"data": [1, 2, 3]}})
    else:
        content = f"Mock content for {filename}"
    
    return jsonify({
        'status': 'success',
        'filename': filename,
        'content': content,
        'service': SERVICE_NAME
    })

@app.route('/api/file', methods=['POST'])
def create_file():
    """Create or update file endpoint"""
    global request_counter
    request_counter += 1
    
    data = request.json
    if not data or 'filename' not in data or 'content' not in data:
        return jsonify({
            'status': 'error',
            'message': 'Filename and content are required'
        }), 400
    
    filename = data['filename']
    content = data['content']
    
    logger.info(f"Creating/updating file {filename}")
    
    return jsonify({
        'status': 'success',
        'message': f"File {filename} created/updated successfully",
        'service': SERVICE_NAME
    })

@app.route('/api/directories', methods=['GET'])
def list_directories():
    """List directories endpoint"""
    global request_counter
    request_counter += 1
    
    parent = request.args.get('parent', '/tmp')
    logger.info(f"Listing directories in {parent}")
    
    return jsonify({
        'status': 'success',
        'directories': mock_data['directories'],
        'service': SERVICE_NAME
    })

@app.route('/api/git/status', methods=['GET'])
def git_status():
    """Git status endpoint"""
    global request_counter
    request_counter += 1
    
    repo_path = request.args.get('repo', '/tmp/repo')
    logger.info(f"Getting git status for {repo_path}")
    
    return jsonify({
        'status': 'success',
        'git_status': mock_data['git']['status'],
        'service': SERVICE_NAME
    })

@app.route('/api/git/branches', methods=['GET'])
def git_branches():
    """Git branches endpoint"""
    global request_counter
    request_counter += 1
    
    repo_path = request.args.get('repo', '/tmp/repo')
    logger.info(f"Listing git branches for {repo_path}")
    
    return jsonify({
        'status': 'success',
        'branches': mock_data['git']['branches'],
        'service': SERVICE_NAME
    })

@app.route('/api/git/log', methods=['GET'])
def git_log():
    """Git log endpoint"""
    global request_counter
    request_counter += 1
    
    repo_path = request.args.get('repo', '/tmp/repo')
    logger.info(f"Getting git log for {repo_path}")
    
    return jsonify({
        'status': 'success',
        'commits': mock_data['git']['commits'],
        'service': SERVICE_NAME
    })

@app.route('/api/shell/execute', methods=['POST'])
def execute_shell():
    """Execute shell command endpoint"""
    global request_counter
    request_counter += 1
    
    data = request.json
    if not data or 'command' not in data:
        return jsonify({
            'status': 'error',
            'message': 'Command parameter is required'
        }), 400
    
    command = data['command']
    logger.info(f"Executing shell command: {command}")
    
    # Simulate command execution based on the command
    if command.startswith('ls'):
        stdout = "file1.txt\nfile2.txt\ndirectory1/\ndirectory2/"
        stderr = ""
        exit_code = 0
    elif command.startswith('echo'):
        stdout = command.replace('echo', '').strip()
        stderr = ""
        exit_code = 0
    elif command.startswith('cat'):
        stdout = "This is the content of the file.\nMultiple lines.\nEnd of file."
        stderr = ""
        exit_code = 0
    elif 'error' in command or 'fail' in command:
        stdout = ""
        stderr = "Command failed with error code 1"
        exit_code = 1
    else:
        stdout = f"Executed: {command}"
        stderr = ""
        exit_code = 0
    
    return jsonify({
        'status': 'success' if exit_code == 0 else 'error',
        'stdout': stdout,
        'stderr': stderr,
        'exit_code': exit_code,
        'service': SERVICE_NAME
    })

@app.route('/api/llm/models', methods=['GET'])
def list_models():
    """List LLM models endpoint"""
    global request_counter
    request_counter += 1
    
    return jsonify({
        'status': 'success',
        'models': mock_data['llm']['models'],
        'default': mock_data['llm']['default'],
        'service': SERVICE_NAME
    })

@app.route('/api/llm/generate', methods=['POST'])
def generate_text():
    """Generate text with LLM endpoint"""
    global request_counter
    request_counter += 1
    
    data = request.json
    if not data or 'prompt' not in data:
        return jsonify({
            'status': 'error',
            'message': 'Prompt parameter is required'
        }), 400
    
    prompt = data['prompt']
    model = data.get('model', mock_data['llm']['default'])
    
    logger.info(f"Generating text with model {model}")
    
    # Generate mock response based on the prompt
    response = f"This is a mock response from {model} for the prompt: {prompt[:20]}..."
    
    return jsonify({
        'status': 'success',
        'model': model,
        'response': response,
        'service': SERVICE_NAME
    })

@app.route('/', methods=['GET'])
def index():
    """Root endpoint"""
    return jsonify({
        'service': SERVICE_NAME,
        'version': '1.0.0',
        'description': f'Mock {SERVICE_NAME} service for PyLama ecosystem testing',
        'endpoints': [
            '/health',
            '/api/health',
            f'/api/{SERVICE_NAME}/health',
            '/api/files',
            '/api/file',
            '/api/directories',
            '/api/git/status',
            '/api/git/branches',
            '/api/git/log',
            '/api/shell/execute',
            '/api/llm/models',
            '/api/llm/generate'
        ]
    })

if __name__ == '__main__':
    logger.info(f"Starting mock {SERVICE_NAME} service on {HOST}:{PORT}")
    app.run(host=HOST, port=PORT, debug=True)
