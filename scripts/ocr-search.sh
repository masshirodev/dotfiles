#!/bin/bash

# Quick OCR and Search
# Dependencies: grim, slurp, tesseract, wl-clipboard, xdg-utils, jq
# Usage: ocr-search.sh [mode]
#   no parameter = search only OCR text on Google
#   context      = search with window context on Google
#   interactive  = interactive mode with options
#   jisho        = search on jisho.org (Japanese dictionary)

MODE="${1:-basic}"

TEMP_DIR=$(mktemp -d)
SCREENSHOT="$TEMP_DIR/screenshot.png"
trap "rm -rf $TEMP_DIR" EXIT

# Get the active window title (for context mode)
WINDOW_TITLE=$(hyprctl activewindow -j | jq -r '.title')

# Select region and capture
grim -g "$(slurp)" "$SCREENSHOT" 2>/dev/null || exit 1

# Run OCR (use Japanese for jisho mode, English otherwise)
if [ "$MODE" = "jisho" ]; then
    # Preprocess image for better OCR (requires imagemagick)
    convert "$SCREENSHOT" -resize 300% -sharpen 0x1 -contrast -normalize "$SCREENSHOT"
    
    # Use jpn for better kanji recognition, add eng as fallback
    TEXT=$(tesseract "$SCREENSHOT" stdout -l jpn+jpn_vert 2>/dev/null | tr '\n' ' ' | sed 's/  */ /g' | xargs)
else
    TEXT=$(tesseract "$SCREENSHOT" stdout 2>/dev/null | tr '\n' ' ' | sed 's/  */ /g' | xargs)
fi

if [ -z "$TEXT" ]; then
    notify-send "OCR Search" "No text detected" -t 2000
    exit 1
fi

# Copy original text to clipboard
echo "$TEXT" | wl-copy

# Handle different modes
case "$MODE" in
    jisho)
        # Search on Jisho (Japanese dictionary)
        notify-send "OCR Search" "Searching on Jisho: $TEXT" -t 3000
        ENCODED=$(echo "$TEXT" | jq -sRr @uri)
        xdg-open "https://jisho.org/search/$ENCODED"
        ;;
    
    context)
        # Search with window context
        if [ -n "$WINDOW_TITLE" ] && [ "$WINDOW_TITLE" != "null" ]; then
            SEARCH_QUERY="$TEXT $WINDOW_TITLE"
            notify-send "OCR Search" "Searching: $TEXT\nContext: $WINDOW_TITLE" -t 3000
        else
            SEARCH_QUERY="$TEXT"
            notify-send "OCR Search" "Searching: $TEXT" -t 3000
        fi
        ENCODED=$(echo "$SEARCH_QUERY" | jq -sRr @uri)
        xdg-open "https://www.google.com/search?q=$ENCODED"
        ;;
    
    interactive)
        # Interactive mode
        echo "Detected text: $TEXT"
        if [ -n "$WINDOW_TITLE" ] && [ "$WINDOW_TITLE" != "null" ]; then
            echo "Window context: $WINDOW_TITLE"
        fi
        echo "Text copied to clipboard"
        echo ""
        echo "What would you like to do?"
        echo "1) Search on Google"
        echo "2) Search on Google with context"
        echo "3) Search on DuckDuckGo"
        echo "4) Search on DuckDuckGo with context"
        echo "5) Search on Jisho (Japanese)"
        echo "6) Just copy (already done)"
        echo "7) Cancel"
        read -p "Choice [1-7]: " choice
        
        case $choice in
            1)
                ENCODED=$(echo "$TEXT" | jq -sRr @uri)
                xdg-open "https://www.google.com/search?q=$ENCODED"
                ;;
            2)
                if [ -n "$WINDOW_TITLE" ] && [ "$WINDOW_TITLE" != "null" ]; then
                    SEARCH_QUERY="$TEXT $WINDOW_TITLE"
                else
                    SEARCH_QUERY="$TEXT"
                fi
                ENCODED=$(echo "$SEARCH_QUERY" | jq -sRr @uri)
                xdg-open "https://www.google.com/search?q=$ENCODED"
                ;;
            3)
                ENCODED=$(echo "$TEXT" | jq -sRr @uri)
                xdg-open "https://duckduckgo.com/?q=$ENCODED"
                ;;
            4)
                if [ -n "$WINDOW_TITLE" ] && [ "$WINDOW_TITLE" != "null" ]; then
                    SEARCH_QUERY="$TEXT $WINDOW_TITLE"
                else
                    SEARCH_QUERY="$TEXT"
                fi
                ENCODED=$(echo "$SEARCH_QUERY" | jq -sRr @uri)
                xdg-open "https://duckduckgo.com/?q=$ENCODED"
                ;;
            5)
                ENCODED=$(echo "$TEXT" | jq -sRr @uri)
                xdg-open "https://jisho.org/search/$ENCODED"
                ;;
            6)
                echo "Text is in clipboard"
                ;;
            *)
                echo "Cancelled"
                ;;
        esac
        ;;
    
    *)
        # Basic mode - just search the text
        notify-send "OCR Search" "Searching: $TEXT" -t 3000
        ENCODED=$(echo "$TEXT" | jq -sRr @uri)
        xdg-open "https://www.google.com/search?q=$ENCODED"
        ;;
esac
