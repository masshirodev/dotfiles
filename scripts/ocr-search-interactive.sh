#!/bin/bash

# OCR and Search Script for Wayland
# Dependencies: grim, slurp, tesseract, wl-clipboard, xdg-utils, jq

# Create temp directory
TEMP_DIR=$(mktemp -d)
SCREENSHOT="$TEMP_DIR/screenshot.png"

# Cleanup on exit
trap "rm -rf $TEMP_DIR" EXIT

# Get the active window title
WINDOW_TITLE=$(hyprctl activewindow -j | jq -r '.title')

# Select region and capture
echo "Select a region..."
grim -g "$(slurp)" "$SCREENSHOT"

if [ ! -f "$SCREENSHOT" ]; then
    echo "Screenshot cancelled or failed"
    exit 1
fi

# Run OCR
echo "Running OCR..."
TEXT=$(tesseract "$SCREENSHOT" stdout 2>/dev/null)

if [ -z "$TEXT" ]; then
    echo "No text detected"
    exit 1
fi

# Clean up the text (remove extra whitespace)
TEXT=$(echo "$TEXT" | tr '\n' ' ' | sed 's/  */ /g' | xargs)

echo "Detected text: $TEXT"
if [ -n "$WINDOW_TITLE" ] && [ "$WINDOW_TITLE" != "null" ]; then
    echo "Window context: $WINDOW_TITLE"
fi

# Copy to clipboard
echo "$TEXT" | wl-copy
echo "Text copied to clipboard"

# Prepare search query
if [ -n "$WINDOW_TITLE" ] && [ "$WINDOW_TITLE" != "null" ]; then
    SEARCH_QUERY="$TEXT $WINDOW_TITLE"
else
    SEARCH_QUERY="$TEXT"
fi

# Ask what to do
echo ""
echo "What would you like to do?"
echo "1) Search on Google (with context)"
echo "2) Search on DuckDuckGo (with context)"
echo "3) Search without window context"
echo "4) Just copy (already done)"
echo "5) Cancel"
read -p "Choice [1-5]: " choice

case $choice in
    1)
        # URL encode the text
        ENCODED=$(echo "$SEARCH_QUERY" | jq -sRr @uri)
        xdg-open "https://www.google.com/search?q=$ENCODED"
        ;;
    2)
        ENCODED=$(echo "$SEARCH_QUERY" | jq -sRr @uri)
        xdg-open "https://duckduckgo.com/?q=$ENCODED"
        ;;
    3)
        ENCODED=$(echo "$TEXT" | jq -sRr @uri)
        echo "Searching without context..."
        xdg-open "https://www.google.com/search?q=$ENCODED"
        ;;
    4)
        echo "Text is in clipboard"
        ;;
    *)
        echo "Cancelled"
        ;;
esac
