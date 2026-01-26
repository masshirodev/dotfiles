#!/bin/bash

# check_install.sh - Check which package manager installed a package
# Usage: check_install.sh <package_name>
# 
# Checks: pacman, yay (AUR), flatpak, snap, pip

if [ -z "$1" ]; then
    echo "Usage: $0 <package_name>"
    exit 1
fi

PACKAGE="$1"
FOUND=0

echo "Checking for package: $PACKAGE"
echo "================================"
echo ""

# Check pacman
if command -v pacman &> /dev/null; then
    if pacman -Qi "$PACKAGE" &> /dev/null; then
        echo "✓ Found in: pacman (official repos)"
        FOUND=1
    fi
fi

# Check yay/AUR
if command -v yay &> /dev/null; then
    # Check if it's from AUR specifically
    if yay -Qi "$PACKAGE" &> /dev/null; then
        # Get the repository info
        REPO=$(yay -Qi "$PACKAGE" | grep "Repository" | awk '{print $3}')
        if [ "$REPO" = "aur" ]; then
            echo "✓ Found in: yay (AUR)"
            FOUND=1
        fi
    fi
fi

# Check flatpak
if command -v flatpak &> /dev/null; then
    if flatpak list --app | grep -qi "$PACKAGE"; then
        echo "✓ Found in: flatpak"
        # Show the full flatpak name
        flatpak list --app | grep -i "$PACKAGE" | awk '{print "  Full name: " $2}'
        FOUND=1
    fi
fi

# Check snap
if command -v snap &> /dev/null; then
    if snap list 2>/dev/null | grep -q "^$PACKAGE "; then
        echo "✓ Found in: snap"
        FOUND=1
    fi
fi

# Check pip (system-wide)
if command -v pip &> /dev/null; then
    if pip list 2>/dev/null | grep -qi "^$PACKAGE "; then
        echo "✓ Found in: pip (system-wide)"
        FOUND=1
    fi
fi

# Check if it's just a binary in PATH
if [ $FOUND -eq 0 ]; then
    if command -v "$PACKAGE" &> /dev/null; then
        BINARY_PATH=$(which "$PACKAGE")
        echo "✓ Binary found at: $BINARY_PATH"
        echo "  (Unable to determine package manager)"
        
        # Try to give hints based on path
        case "$BINARY_PATH" in
            /usr/bin/*|/usr/local/bin/*)
                echo "  Hint: Likely installed via pacman or compiled manually"
                ;;
            ~/.local/bin/*|$HOME/.local/bin/*)
                echo "  Hint: Likely user-installed (pip --user, cargo, etc.)"
                ;;
            /snap/*)
                echo "  Hint: Likely a snap package"
                ;;
        esac
        FOUND=1
    fi
fi

if [ $FOUND -eq 0 ]; then
    echo "✗ Package not found in any package manager"
    exit 1
fi
