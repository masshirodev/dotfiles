#!/usr/bin/env python3
import argparse
import glob
import json
import os
import shutil
import sys
from pathlib import Path
from typing import Dict, List, Optional

# Default config filename to look for in project folders
CONFIG_FILENAME = "to_claude.json"


class ProjectConfig:
    def __init__(self, config_path: Optional[str] = None):
        self.config_path = config_path
        self.config: Dict = self._load_config()

    def _load_config(self) -> Dict:
        """Load configuration from file or create default if not exists"""
        if self.config_path and os.path.exists(self.config_path):
            try:
                with open(self.config_path, "r") as f:
                    return json.load(f)
            except json.JSONDecodeError:
                print(f"Error: Invalid config file format in {self.config_path}")
                return self._create_default_config()
        elif self.config_path:
            print(f"Config file not found: {self.config_path}")
            return self._create_default_config()
        return self._create_default_config()

    def _create_default_config(self) -> Dict:
        """Create default configuration"""
        default_config = {
            "data": {
                "default_excludes": [
                    ".git",
                    ".idea",
                    "node_modules",
                    "__pycache__",
                    ".env",
                    "*.pyc",
                    "*.pyo",
                    "*.pyd",
                    ".DS_Store",
                    "Thumbs.db",
                ],
                "profiles": [
                    {
                        "name": "api",
                        "folders": [
                            "src/main/**",
                            "src/test/**",
                            "pom.xml",
                            "build.gradle",
                        ],
                        "excludes": [],
                    },
                    {
                        "name": "frontend",
                        "folders": [
                            "src/**",
                            "public/**",
                            "package.json",
                            "package-lock.json",
                            "yarn.lock",
                            ".eslintrc.*",
                            ".prettierrc.*",
                            "tsconfig.json",
                        ],
                        "excludes": [
                            "*.test.js",
                            "*.test.ts",
                            "*.spec.js",
                            "*.spec.ts",
                        ],
                    },
                    {"name": "full", "folders": ["**"], "excludes": []},
                ],
            }
        }

        if self.config_path:
            # Create config file in the specified location
            os.makedirs(os.path.dirname(self.config_path), exist_ok=True)
            with open(self.config_path, "w") as f:
                json.dump(default_config, f, indent=2)
            print(f"Created default config file: {self.config_path}")

        return default_config

    def get_profile(self, profile_name: str) -> Dict:
        """Get a specific profile by name"""
        profiles = self.config.get("data", {}).get("profiles", [])
        for profile in profiles:
            if profile.get("name") == profile_name:
                return profile
        raise ValueError(f"Profile '{profile_name}' not found in configuration")

    def get_profile_paths(self, profile_name: str) -> List[str]:
        """Get paths for a specific profile"""
        profile = self.get_profile(profile_name)
        return profile.get("folders", [])

    def get_profile_excludes(self, profile_name: str) -> List[str]:
        """Get profile-specific excludes"""
        profile = self.get_profile(profile_name)
        return profile.get("excludes", [])

    def get_default_excludes(self) -> List[str]:
        """Get default exclusion patterns"""
        return self.config.get("data", {}).get("default_excludes", [])

    def list_profiles(self) -> List[str]:
        """List all available profile names"""
        profiles = self.config.get("data", {}).get("profiles", [])
        return [profile.get("name") for profile in profiles if profile.get("name")]


def should_exclude(path: str, exclude_patterns: List[str]) -> bool:
    """Check if path should be excluded based on patterns"""
    return any(pattern in path for pattern in exclude_patterns)


def copy_files_recursive(
    src_path: str,
    destination_folder: str,
    folder_prefix: str,
    exclude_patterns: List[str],
    source_folder: str,
) -> None:
    """Recursively copy files from source path to destination with prefix"""
    try:
        if not os.path.exists(src_path):
            print(f"Warning: {src_path} does not exist")
            return

        if should_exclude(src_path, exclude_patterns):
            print(f"Excluded: {src_path}")
            return

        if os.path.isfile(src_path):
            filename = os.path.basename(src_path)
            dst_path = os.path.join(destination_folder, f"{folder_prefix}_{filename}")
            shutil.copy2(src_path, dst_path)
            print(f"Copied: {src_path} -> {dst_path}")
            return

        for item in os.listdir(src_path):
            item_path = os.path.join(src_path, item)
            if should_exclude(item_path, exclude_patterns):
                print(f"Excluded: {item_path}")
                continue

            rel_path = os.path.relpath(item_path, source_folder)
            new_prefix = rel_path.replace(os.sep, "_")

            if os.path.isfile(item_path):
                dst_path = os.path.join(destination_folder, f"{new_prefix}")
                shutil.copy2(item_path, dst_path)
                print(f"Copied: {item_path} -> {dst_path}")
            else:
                copy_files_recursive(
                    item_path,
                    destination_folder,
                    new_prefix,
                    exclude_patterns,
                    source_folder,
                )

    except PermissionError:
        print(f"Permission denied: {src_path}")
    except Exception as e:
        print(f"Error processing {src_path}: {str(e)}")


def expand_glob_patterns(patterns: List[str], source_folder: str) -> List[str]:
    """Expand glob patterns to actual file paths"""
    expanded_paths = []
    for pattern in patterns:
        # Handle the /** pattern specially
        if pattern.endswith("/**"):
            base_path = os.path.join(source_folder, pattern[:-3])
            if os.path.exists(base_path):
                # Add the base directory
                expanded_paths.append(base_path)
                # Add all subdirectories and files
                for root, dirs, files in os.walk(base_path):
                    expanded_paths.extend([os.path.join(root, d) for d in dirs])
                    expanded_paths.extend([os.path.join(root, f) for f in files])
        else:
            # Handle regular paths and other glob patterns
            full_pattern = os.path.join(source_folder, pattern)
            matches = glob.glob(full_pattern, recursive=True)
            if matches:
                expanded_paths.extend(matches)
            else:
                # If no matches, add the original path (might be a direct path)
                potential_path = os.path.join(source_folder, pattern)
                if os.path.exists(potential_path):
                    expanded_paths.append(potential_path)

    return expanded_paths


def find_config_file(source_folder: str) -> Optional[str]:
    """Find config file in the source folder"""
    config_path = os.path.join(source_folder, CONFIG_FILENAME)
    if os.path.exists(config_path):
        return config_path
    return None


def main():
    parser = argparse.ArgumentParser(
        description="Copy project files to Claude directory"
    )
    parser.add_argument("source_folder", help="Source folder to copy from")
    parser.add_argument(
        "paths", nargs="*", help="Specific paths to copy (relative to source folder)"
    )
    parser.add_argument("-p", "--profile", help="Profile name from configuration")
    parser.add_argument(
        "-x", "--exclude", help="Additional patterns to exclude (comma-separated)"
    )
    parser.add_argument(
        "-d",
        "--destination",
        help="Destination folder",
        default="./claude_files",
    )
    parser.add_argument(
        "--list-profiles", action="store_true", help="List all available profiles"
    )
    parser.add_argument(
        "--init-config",
        action="store_true",
        help="Create a default config file in the source folder",
    )

    args = parser.parse_args()

    try:
        # Resolve source folder path
        source_folder = os.path.abspath(args.source_folder)

        if not os.path.exists(source_folder):
            print(f"Error: Source folder '{source_folder}' does not exist")
            sys.exit(1)

        # Find or create config file
        config_path = find_config_file(source_folder)

        if args.init_config:
            config_path = os.path.join(source_folder, CONFIG_FILENAME)
            project_config = ProjectConfig(config_path)
            print(f"Initialized config file at: {config_path}")
            sys.exit(0)

        if not config_path:
            print(f"No config file found in '{source_folder}'")
            print(f"Run with --init-config to create a default {CONFIG_FILENAME}")
            # Create a minimal config for this run
            project_config = ProjectConfig()
        else:
            project_config = ProjectConfig(config_path)
            print(f"Using config file: {config_path}")

        # List profiles if requested
        if args.list_profiles:
            profiles = project_config.list_profiles()
            if profiles:
                print("Available profiles:")
                for profile in profiles:
                    print(f"  - {profile}")
            else:
                print("No profiles found in configuration")
            sys.exit(0)

        # Build exclude patterns
        exclude_patterns = project_config.get_default_excludes()

        if args.exclude:
            exclude_patterns.extend([p.strip() for p in args.exclude.split(",")])

        # Determine what to copy
        if args.profile:
            folders_to_copy = project_config.get_profile_paths(args.profile)
            # Add profile-specific excludes
            profile_excludes = project_config.get_profile_excludes(args.profile)
            exclude_patterns.extend(profile_excludes)
        elif args.paths:
            folders_to_copy = args.paths
        else:
            print("Error: Must specify either --profile or provide paths to copy")
            parser.print_help()
            sys.exit(1)

        # Expand all glob patterns
        expanded_paths = expand_glob_patterns(folders_to_copy, source_folder)

        if not expanded_paths:
            print("No matching files found")
            sys.exit(1)

        # Create destination folder
        destination = os.path.abspath(args.destination)
        os.makedirs(destination, exist_ok=True)
        print(f"Copying to: {destination}")

        # Copy files
        for path in expanded_paths:
            if should_exclude(path, exclude_patterns):
                print(f"Excluded: {path}")
                continue

            rel_path = os.path.relpath(path, source_folder)
            folder_prefix = rel_path.replace(os.sep, "_")

            if os.path.isfile(path):
                dst_path = os.path.join(destination, folder_prefix)
                shutil.copy2(path, dst_path)
                print(f"Copied: {path} -> {dst_path}")
            else:
                copy_files_recursive(
                    path, destination, folder_prefix, exclude_patterns, source_folder
                )

        print(f"\nCopy completed! Files copied to: {destination}")

    except Exception as e:
        print(f"Error: {str(e)}")
        sys.exit(1)


if __name__ == "__main__":
    main()
