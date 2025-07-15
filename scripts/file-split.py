#!/usr/bin/env python3
import os
import sys
import re
from pathlib import Path

def create_directories(file_path):
    """Create all necessary directories for the given file path."""
    directory = os.path.dirname(file_path)
    if directory:
        os.makedirs(directory, exist_ok=True)

def split_file(input_file, base_path):
    """Split the input file into multiple files based on path comments."""
    try:
        with open(input_file, 'r', encoding='utf-8') as f:
            content = f.read()
    except FileNotFoundError:
        print(f"Error: File '{input_file}' not found.")
        return False
    except Exception as e:
        print(f"Error reading file: {e}")
        return False
    
    # Split content by lines
    lines = content.split('\n')
    
    current_file_path = None
    current_content = []
    files_created = 0
    
    # Pattern to match file path comments (// path/to/file.ext, -- path/to/file.ext, # path/to/file.ext)
    path_pattern = re.compile(r'^(?://|--|#)\s*(.+\..+)$')
    
    for line in lines:
        # Check if this line is a file path comment
        match = path_pattern.match(line.strip())
        
        if match:
            # Save previous file if we have content
            if current_file_path and current_content:
                save_file(current_file_path, current_content, base_path)
                files_created += 1
            
            # Start new file
            current_file_path = match.group(1)
            current_content = []
        else:
            # Add line to current file content (skip empty lines at the beginning)
            if current_content or line.strip():
                current_content.append(line)
    
    # Save the last file
    if current_file_path and current_content:
        save_file(current_file_path, current_content, base_path)
        files_created += 1
    
    print(f"Successfully created {files_created} files.")
    return True

def save_file(file_path, content, base_path):
    """Save content to the specified file path."""
    # Combine base path with file path
    full_path = os.path.join(base_path, file_path)
    
    # Create directories if they don't exist
    create_directories(full_path)
    
    # Remove trailing empty lines
    while content and not content[-1].strip():
        content.pop()
    
    try:
        with open(full_path, 'w', encoding='utf-8') as f:
            f.write('\n'.join(content))
            if content:  # Add final newline if file has content
                f.write('\n')
        print(f"Created: {full_path}")
    except Exception as e:
        print(f"Error writing file {full_path}: {e}")

def main():
    if len(sys.argv) != 3:
        print("Usage: python script.py <base_path> <input_file>")
        print("Example: python script.py . file.txt")
        sys.exit(1)
    
    base_path = sys.argv[1]
    input_file = sys.argv[2]
    
    # Validate base path
    if not os.path.exists(base_path):
        print(f"Error: Base path '{base_path}' does not exist.")
        sys.exit(1)
    
    if not os.path.isdir(base_path):
        print(f"Error: Base path '{base_path}' is not a directory.")
        sys.exit(1)
    
    # Process the file
    success = split_file(input_file, base_path)
    
    if not success:
        sys.exit(1)

if __name__ == "__main__":
    main()
