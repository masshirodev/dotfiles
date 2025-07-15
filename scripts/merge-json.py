#!/usr/bin/env python3

import json
import sys
from pathlib import Path
from typing import List, Union, Dict

def read_json_file(file_path: Path) -> Union[Dict, List]:
    """
    Read and parse a JSON file.
    
    Args:
        file_path: Path to the JSON file
        
    Returns:
        Parsed JSON content as either a dict or list
    """
    try:
        with open(file_path, 'r') as f:
            return json.load(f)
    except json.JSONDecodeError as e:
        print(f"Error parsing {file_path}: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
        sys.exit(1)

def merge_json_files(file_paths: List[Path]) -> List:
    """
    Merge multiple JSON files into a single list.
    
    Args:
        file_paths: List of paths to JSON files
        
    Returns:
        List containing all objects from input files
    """
    merged_data = []
    
    for file_path in file_paths:
        data = read_json_file(file_path)
        
        # If the data is a dict, convert it to a single-item list
        if isinstance(data, dict):
            merged_data.append(data)
        # If it's a list, extend our result with its contents
        elif isinstance(data, list):
            merged_data.extend(data)
        else:
            print(f"Warning: Unexpected data type in {file_path}")
            continue
            
    return merged_data

def main():
    if len(sys.argv) < 3:
        print("Usage: ./merge_json.py output.json input1.json input2.json [input3.json ...]")
        sys.exit(1)
    
    output_file = Path(sys.argv[1])
    input_files = [Path(f) for f in sys.argv[2:]]
    
    # Verify all input files exist
    for file_path in input_files:
        if not file_path.exists():
            print(f"Error: File {file_path} does not exist")
            sys.exit(1)
    
    # Merge the files
    merged_data = merge_json_files(input_files)
    
    # Write the merged data to the output file
    try:
        with open(output_file, 'w') as f:
            json.dump(merged_data, f, indent=2)
        print(f"Successfully merged {len(input_files)} files into {output_file}")
    except Exception as e:
        print(f"Error writing to {output_file}: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
