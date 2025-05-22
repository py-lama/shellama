#!/usr/bin/env python3

from flask import Flask, jsonify, request
import os
import time
import uuid

app = Flask(__name__)

# Mock data storage
mock_data = {
    "git_repos": {},
    "files": {},
    "directories": {}
}

# Health check endpoint
@app.route('/api/shellama/health', methods=['GET'])
def health_check():
    return jsonify({
        "status": "success",
        "message": "SheLLama API is running",
        "timestamp": time.time()
    })

# Git operations endpoints
@app.route('/api/shellama/git/init', methods=['POST'])
def git_init():
    data = request.json
    directory = data.get('directory', '/tmp/git_repo')
    
    # Create a mock Git repository
    repo_id = str(uuid.uuid4())
    mock_data['git_repos'][repo_id] = {
        "directory": directory,
        "initialized": True,
        "branches": ["main"],
        "current_branch": "main",
        "files": {},
        "commits": [],
        "status": {
            "untracked": [],
            "staged": [],
            "modified": []
        }
    }
    
    return jsonify({
        "status": "success",
        "message": "Git repository initialized successfully",
        "repository_id": repo_id
    })

@app.route('/api/shellama/git/status', methods=['POST'])
def git_status():
    data = request.json
    directory = data.get('directory', '/tmp/git_repo')
    
    # Find the repository by directory
    repo = None
    repo_id = None
    for rid, r in mock_data['git_repos'].items():
        if r['directory'] == directory:
            repo = r
            repo_id = rid
            break
    
    if not repo:
        return jsonify({
            "status": "error",
            "message": "Git repository not found"
        }), 404
    
    return jsonify({
        "status": "success",
        "untracked": repo["status"]["untracked"],
        "staged": repo["status"]["staged"],
        "modified": repo["status"]["modified"]
    })

@app.route('/api/shellama/git/add', methods=['POST'])
def git_add():
    data = request.json
    directory = data.get('directory', '/tmp/git_repo')
    files = data.get('files', [])
    
    # Find the repository by directory
    repo = None
    repo_id = None
    for rid, r in mock_data['git_repos'].items():
        if r['directory'] == directory:
            repo = r
            repo_id = rid
            break
    
    if not repo:
        return jsonify({
            "status": "error",
            "message": "Git repository not found"
        }), 404
    
    # Move files from untracked to staged
    for file in files:
        if file in repo["status"]["untracked"]:
            repo["status"]["untracked"].remove(file)
            repo["status"]["staged"].append(file)
        elif file in repo["status"]["modified"]:
            repo["status"]["modified"].remove(file)
            repo["status"]["staged"].append(file)
    
    return jsonify({
        "status": "success",
        "message": "Files added to staging area"
    })

@app.route('/api/shellama/git/commit', methods=['POST'])
def git_commit():
    data = request.json
    directory = data.get('directory', '/tmp/git_repo')
    message = data.get('message', 'Commit message')
    
    # Find the repository by directory
    repo = None
    repo_id = None
    for rid, r in mock_data['git_repos'].items():
        if r['directory'] == directory:
            repo = r
            repo_id = rid
            break
    
    if not repo:
        return jsonify({
            "status": "error",
            "message": "Git repository not found"
        }), 404
    
    # Create a commit
    commit_hash = str(uuid.uuid4())[:12]  # Simulate a Git hash
    commit = {
        "hash": commit_hash,
        "message": message,
        "author": "Test User <test@example.com>",
        "date": time.strftime("%Y-%m-%dT%H:%M:%S+00:00"),
        "branch": repo["current_branch"],
        "files": repo["status"]["staged"].copy()
    }
    
    repo["commits"].append(commit)
    
    # Update files in the repository
    for file in repo["status"]["staged"]:
        repo["files"][file] = {
            "content": f"Content of {file}",
            "last_commit": commit_hash
        }
    
    # Clear staged files
    repo["status"]["staged"] = []
    
    return jsonify({
        "status": "success",
        "message": "Changes committed successfully",
        "commit_hash": commit_hash
    })

@app.route('/api/shellama/git/branch', methods=['POST'])
def git_branch():
    data = request.json
    directory = data.get('directory', '/tmp/git_repo')
    branch_name = data.get('branch', 'new-branch')
    
    # Find the repository by directory
    repo = None
    repo_id = None
    for rid, r in mock_data['git_repos'].items():
        if r['directory'] == directory:
            repo = r
            repo_id = rid
            break
    
    if not repo:
        return jsonify({
            "status": "error",
            "message": "Git repository not found"
        }), 404
    
    if branch_name in repo["branches"]:
        return jsonify({
            "status": "error",
            "message": f"Branch '{branch_name}' already exists"
        }), 400
    
    # Create a new branch
    repo["branches"].append(branch_name)
    
    return jsonify({
        "status": "success",
        "message": f"Branch '{branch_name}' created successfully"
    })

@app.route('/api/shellama/git/checkout', methods=['POST'])
def git_checkout():
    data = request.json
    directory = data.get('directory', '/tmp/git_repo')
    branch_name = data.get('branch', 'main')
    
    # Find the repository by directory
    repo = None
    repo_id = None
    for rid, r in mock_data['git_repos'].items():
        if r['directory'] == directory:
            repo = r
            repo_id = rid
            break
    
    if not repo:
        return jsonify({
            "status": "error",
            "message": "Git repository not found"
        }), 404
    
    if branch_name not in repo["branches"]:
        return jsonify({
            "status": "error",
            "message": f"Branch '{branch_name}' does not exist"
        }), 404
    
    # Switch to the branch
    repo["current_branch"] = branch_name
    
    return jsonify({
        "status": "success",
        "message": f"Switched to branch '{branch_name}'"
    })

@app.route('/api/shellama/git/branches', methods=['POST'])
def git_list_branches():
    data = request.json
    directory = data.get('directory', '/tmp/git_repo')
    
    # Find the repository by directory
    repo = None
    repo_id = None
    for rid, r in mock_data['git_repos'].items():
        if r['directory'] == directory:
            repo = r
            repo_id = rid
            break
    
    if not repo:
        return jsonify({
            "status": "error",
            "message": "Git repository not found"
        }), 404
    
    # Format branches list
    branches = []
    for branch in repo["branches"]:
        branches.append({
            "name": branch,
            "current": branch == repo["current_branch"]
        })
    
    return jsonify({
        "status": "success",
        "branches": branches
    })

@app.route('/api/shellama/git/merge', methods=['POST'])
def git_merge():
    data = request.json
    directory = data.get('directory', '/tmp/git_repo')
    branch_name = data.get('branch', 'feature-branch')
    
    # Find the repository by directory
    repo = None
    repo_id = None
    for rid, r in mock_data['git_repos'].items():
        if r['directory'] == directory:
            repo = r
            repo_id = rid
            break
    
    if not repo:
        return jsonify({
            "status": "error",
            "message": "Git repository not found"
        }), 404
    
    if branch_name not in repo["branches"]:
        return jsonify({
            "status": "error",
            "message": f"Branch '{branch_name}' does not exist"
        }), 404
    
    if branch_name == repo["current_branch"]:
        return jsonify({
            "status": "error",
            "message": f"Cannot merge current branch '{branch_name}' into itself"
        }), 400
    
    # Create a merge commit
    commit_hash = str(uuid.uuid4())[:12]  # Simulate a Git hash
    commit = {
        "hash": commit_hash,
        "message": f"Merge branch '{branch_name}' into {repo['current_branch']}",
        "author": "Test User <test@example.com>",
        "date": time.strftime("%Y-%m-%dT%H:%M:%S+00:00"),
        "branch": repo["current_branch"],
        "files": []
    }
    
    repo["commits"].append(commit)
    
    return jsonify({
        "status": "success",
        "message": "Merge successful",
        "commit_hash": commit_hash
    })

@app.route('/api/shellama/git/history', methods=['POST'])
def git_history():
    data = request.json
    directory = data.get('directory', '/tmp/git_repo')
    
    # Find the repository by directory
    repo = None
    repo_id = None
    for rid, r in mock_data['git_repos'].items():
        if r['directory'] == directory:
            repo = r
            repo_id = rid
            break
    
    if not repo:
        return jsonify({
            "status": "error",
            "message": "Git repository not found"
        }), 404
    
    return jsonify({
        "status": "success",
        "history": repo["commits"]
    })

# File operations endpoints
@app.route('/api/shellama/file/create', methods=['POST'])
def file_create():
    data = request.json
    path = data.get('path', '/tmp/test.txt')
    content = data.get('content', '')
    
    # Create a mock file
    file_id = str(uuid.uuid4())
    mock_data['files'][file_id] = {
        "path": path,
        "content": content,
        "created_at": time.time(),
        "updated_at": time.time()
    }
    
    # If this is in a Git repository, update the repository status
    for repo_id, repo in mock_data['git_repos'].items():
        if path.startswith(repo['directory']):
            filename = os.path.basename(path)
            if filename not in repo["status"]["untracked"]:
                repo["status"]["untracked"].append(filename)
    
    return jsonify({
        "status": "success",
        "message": "File created successfully",
        "file_id": file_id
    })

@app.route('/api/shellama/file/read', methods=['POST'])
def file_read():
    data = request.json
    path = data.get('path', '/tmp/test.txt')
    
    # Find the file by path
    file = None
    file_id = None
    for fid, f in mock_data['files'].items():
        if f['path'] == path:
            file = f
            file_id = fid
            break
    
    if not file:
        return jsonify({
            "status": "error",
            "message": "File not found"
        }), 404
    
    return jsonify({
        "status": "success",
        "content": file["content"]
    })

@app.route('/api/shellama/file/update', methods=['POST'])
def file_update():
    data = request.json
    path = data.get('path', '/tmp/test.txt')
    content = data.get('content', '')
    
    # Find the file by path
    file = None
    file_id = None
    for fid, f in mock_data['files'].items():
        if f['path'] == path:
            file = f
            file_id = fid
            break
    
    if not file:
        return jsonify({
            "status": "error",
            "message": "File not found"
        }), 404
    
    # Update the file
    file["content"] = content
    file["updated_at"] = time.time()
    
    # If this is in a Git repository, update the repository status
    for repo_id, repo in mock_data['git_repos'].items():
        if path.startswith(repo['directory']):
            filename = os.path.basename(path)
            if filename not in repo["status"]["modified"] and filename not in repo["status"]["untracked"]:
                repo["status"]["modified"].append(filename)
    
    return jsonify({
        "status": "success",
        "message": "File updated successfully"
    })

@app.route('/api/shellama/file/delete', methods=['POST'])
def file_delete():
    data = request.json
    path = data.get('path', '/tmp/test.txt')
    
    # Find the file by path
    file = None
    file_id = None
    for fid, f in mock_data['files'].items():
        if f['path'] == path:
            file = f
            file_id = fid
            break
    
    if not file:
        return jsonify({
            "status": "error",
            "message": "File not found"
        }), 404
    
    # Delete the file
    del mock_data['files'][file_id]
    
    return jsonify({
        "status": "success",
        "message": "File deleted successfully"
    })

# Directory operations endpoints
@app.route('/api/shellama/dir/create', methods=['POST'])
def dir_create():
    data = request.json
    path = data.get('path', '/tmp/test_dir')
    
    # Create a mock directory
    dir_id = str(uuid.uuid4())
    mock_data['directories'][dir_id] = {
        "path": path,
        "created_at": time.time(),
        "files": []
    }
    
    return jsonify({
        "status": "success",
        "message": "Directory created successfully",
        "directory_id": dir_id
    })

@app.route('/api/shellama/dir/list', methods=['POST'])
def dir_list():
    data = request.json
    path = data.get('path', '/tmp')
    
    # Find the directory by path
    directory = None
    dir_id = None
    for did, d in mock_data['directories'].items():
        if d['path'] == path:
            directory = d
            dir_id = did
            break
    
    if not directory:
        # If the directory doesn't exist in our mock data, create a default response
        return jsonify({
            "status": "success",
            "files": [],
            "directories": []
        })
    
    # Get files in this directory
    files = []
    for fid, file in mock_data['files'].items():
        if os.path.dirname(file['path']) == path:
            files.append(os.path.basename(file['path']))
    
    # Get subdirectories
    directories = []
    for did, dir in mock_data['directories'].items():
        if os.path.dirname(dir['path']) == path:
            directories.append(os.path.basename(dir['path']))
    
    return jsonify({
        "status": "success",
        "files": files,
        "directories": directories
    })

@app.route('/api/shellama/dir/delete', methods=['POST'])
def dir_delete():
    data = request.json
    path = data.get('path', '/tmp/test_dir')
    
    # Find the directory by path
    directory = None
    dir_id = None
    for did, d in mock_data['directories'].items():
        if d['path'] == path:
            directory = d
            dir_id = did
            break
    
    if not directory:
        return jsonify({
            "status": "error",
            "message": "Directory not found"
        }), 404
    
    # Delete the directory
    del mock_data['directories'][dir_id]
    
    # Delete all files in this directory
    for fid, file in list(mock_data['files'].items()):
        if os.path.dirname(file['path']) == path:
            del mock_data['files'][fid]
    
    return jsonify({
        "status": "success",
        "message": "Directory deleted successfully"
    })

# Shell command endpoint
@app.route('/api/shellama/shell/exec', methods=['POST'])
def shell_exec():
    data = request.json
    command = data.get('command', 'echo "Hello World"')
    cwd = data.get('cwd', '/tmp')
    
    # Mock command execution
    if command.startswith('echo'):
        output = command[5:].strip('"\'')
    elif command.startswith('ls'):
        output = "file1.txt\nfile2.txt\ndirectory1/\ndirectory2/"
    elif command.startswith('cat'):
        output = "Content of the file"
    elif command.startswith('grep'):
        output = "Line containing the search term"
    else:
        output = f"Executed command: {command}"
    
    return jsonify({
        "status": "success",
        "output": output,
        "exit_code": 0
    })

# Error handling endpoint for testing
@app.route('/api/shellama/error/test', methods=['POST'])
def error_test():
    data = request.json
    error_type = data.get('type', 'not_found')
    
    if error_type == 'not_found':
        return jsonify({
            "status": "error",
            "message": "Resource not found"
        }), 404
    elif error_type == 'bad_request':
        return jsonify({
            "status": "error",
            "message": "Bad request"
        }), 400
    elif error_type == 'server_error':
        return jsonify({
            "status": "error",
            "message": "Internal server error"
        }), 500
    else:
        return jsonify({
            "status": "error",
            "message": f"Unknown error type: {error_type}"
        }), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
