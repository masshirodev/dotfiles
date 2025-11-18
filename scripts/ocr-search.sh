#!/bin/bash

# Quick OCR and Search (auto-search version)
# Dependencies: grim, slurp, tesseract, wl-clipboard, xdg-utils, jq

TEMP_DIR=$(mktemp -d)
SCREENSHOT="$TEMP_DIR/screenshot.png"
trap "rm -rf $TEMP_DIR" EXIT

# Get the active window title
WINDOW_TITLE=$(hyprctl activewindow -j | jq -r '.title')

# Select region and capture
grim -g "$(slurp)" "$SCREENSHOT" 2>/dev/null || exit 1

# Run OCR
TEXT=$(tesseract "$SCREENSHOT" stdout 2>/dev/null | tr '\n' ' ' | sed 's/  */ /g' | xargs)

if [ -z "$TEXT" ]; then
    notify-send "OCR Search" "No text detected" -u critical
    exit 1
fi

# Copy original text to clipboard
echo "$TEXT" | wl-copy

# Combine window title with OCR text for search
if [ -n "$WINDOW_TITLE" ] && [ "$WINDOW_TITLE" != "null" ]; then
    SEARCH_QUERY="$TEXT $WINDOW_TITLE"
    notify-send "OCR Search" "Searching: $TEXT\nContext: $WINDOW_TITLE" -t 3000
else
    SEARCH_QUERY="$TEXT"
    notify-send "OCR Search" "Searching: $TEXT" -t 3000
fi

# Open in browser (choose your preferred search engine)
ENCODED=$(echo "$SEARCH_QUERY" | jq -sRr @uri)
xdg-open "https://www.google.com/search?q=$ENCODED"
