# OCR Search Script

A versatile OCR tool for Wayland/Hyprland that captures screen regions, extracts text, and searches it online with contextual awareness.

## Features

- 📸 Screen region selection and OCR
- 🌐 Multiple search engines (Google, DuckDuckGo, Jisho)
- 🪟 Context-aware search using window titles
- 🇯🇵 Japanese text recognition for language learning
- 📋 Automatic clipboard copy
- 🔔 Desktop notifications
- ⌨️ Multiple modes for different workflows

## Installation

### 1. Install Dependencies

```bash
# Core tools
sudo pacman -S grim slurp tesseract wl-clipboard xdg-utils jq libnotify

# Language data for OCR
sudo pacman -S tesseract-data-eng tesseract-data-jpn tesseract-data-jpn_vert

# Image preprocessing (improves Japanese OCR accuracy, especially for kanji)
sudo pacman -S imagemagick

# Notification daemon (if not already installed)
# Choose one:
sudo pacman -S mako        # lightweight
sudo pacman -S dunst       # more features
```

#### Optional: Better Japanese OCR Models

For improved kanji recognition, download the best trained Japanese model:

```bash
cd /usr/share/tessdata/
sudo wget https://github.com/tesseract-ocr/tessdata_best/raw/main/jpn.traineddata
sudo chmod 644 jpn.traineddata
```

### 2. Download the Script

```bash
# Download to your home directory
cd ~
# Copy the script content or download it
chmod +x ocr-search.sh
```

### 3. Configure Hyprland Keybinds

Add these to your `~/.config/hypr/hyprland.conf`:

```
# Basic search (English OCR + Google)
bind = SUPER SHIFT, S, exec, ~/ocr-search.sh

# Context-aware search (includes window title)
bind = SUPER SHIFT, C, exec, ~/ocr-search.sh context

# Japanese dictionary search (Jisho)
bind = SUPER SHIFT, J, exec, ~/ocr-search.sh jisho

# Interactive mode (choose search engine)
bind = SUPER SHIFT, O, exec, ~/ocr-search.sh interactive
```

Then reload Hyprland config:
```bash
hyprctl reload
```

## Usage Modes

### Basic Mode (default)
```bash
./ocr-search.sh
```
- Uses English OCR
- Searches on Google
- Copies text to clipboard

### Context Mode
```bash
./ocr-search.sh context
```
- Uses English OCR
- Adds window title to search query
- Example: "strange mood" from Dwarf Fortress → searches "strange mood Dwarf Fortress"

### Jisho Mode
```bash
./ocr-search.sh jisho
```
- Uses Japanese OCR
- Searches on jisho.org
- Perfect for manga/visual novels

### Interactive Mode
```bash
./ocr-search.sh interactive
```
- Prompts you to choose:
  1. Google search
  2. Google with context
  3. DuckDuckGo search
  4. DuckDuckGo with context
  5. Jisho (Japanese)
  6. Just copy to clipboard
  7. Cancel

## Workflow

1. Press your configured hotkey
2. Click and drag to select a screen region
3. Script performs OCR on the selected area
4. Text is copied to clipboard
5. Browser opens with search results (depending on mode)
6. Notification shows what was detected

## Troubleshooting

### "No text detected" notification won't disappear
```bash
# Kill and restart your notification daemon
killall mako && mako &
# or
killall dunst && dunst &
```

### Japanese text not recognized
Make sure you installed the Japanese language data:
```bash
pacman -Qs tesseract-data-jpn
```

If kanji specifically doesn't work:
1. Install vertical text support: `sudo pacman -S tesseract-data-jpn_vert`
2. Download better models (see installation section above)
3. The script has image preprocessing commented out - edit the script and uncomment the `convert` line for better results

### Script doesn't run
Check if it's executable:
```bash
chmod +x ~/ocr-search.sh
```

### Keybinds don't work
Make sure Hyprland config is loaded:
```bash
hyprctl reload
```

## Customization

### Change Default Search Engine

Edit the script and change this line in the "basic" mode:
```bash
xdg-open "https://www.google.com/search?q=$ENCODED"
```

To use DuckDuckGo instead:
```bash
xdg-open "https://duckduckgo.com/?q=$ENCODED"
```

### Add More Languages

Install additional tesseract language packs:
```bash
# List available languages
pacman -Ss tesseract-data

# Install a language (example: Spanish)
sudo pacman -S tesseract-data-spa
```

Then modify the script to use it:
```bash
tesseract "$SCREENSHOT" stdout -l spa
```

### Use Multiple Languages at Once

For mixed Japanese/English text:
```bash
tesseract "$SCREENSHOT" stdout -l jpn+eng
```

## Dependencies Explained

- **grim**: Screenshot tool for Wayland
- **slurp**: Region selector for Wayland
- **tesseract**: OCR engine
- **tesseract-data-***: Language data for OCR
- **tesseract-data-jpn_vert**: Vertical Japanese text recognition (improves kanji detection)
- **imagemagick**: Image preprocessing for better OCR accuracy
- **wl-clipboard**: Clipboard utilities for Wayland
- **xdg-utils**: Opens URLs in default browser
- **jq**: JSON processor (for URL encoding and hyprctl output)
- **libnotify**: Desktop notifications
- **mako/dunst**: Notification daemon

## Tips

- For better Japanese OCR accuracy, use clear fonts and avoid handwritten text
- If kanji recognition is poor, uncomment the imagemagick preprocessing line in the script
- Vertical Japanese text (common in manga) benefits from the jpn_vert language pack
- Context mode works best with games and applications with descriptive window titles
- The interactive mode is great when you're not sure which search engine to use
- OCR'd text is always copied to clipboard, even if the search fails

## License

Free to use and modify.
