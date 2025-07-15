#!/bin/bash

# Check if origin URL is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <origin_url>"
    echo "Example: $0 https://github.com/username/repo.git"
    exit 1
fi

# Initialize git repository and push to origin
echo "Initializing git repository..."
git init

echo "Adding all files..."
git add *

echo "Creating first commit..."
git commit -m "first commit"

echo "Setting main branch..."
git branch -M main

echo "Adding remote origin: $1"
git remote add origin "$1"

echo "Pushing to origin..."
git push -u origin main

echo "Repository initialized and pushed successfully!"
