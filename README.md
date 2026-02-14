# hypr-config - Personal Configuration Files
My personal configuration files for Arch Linux with Hyprland and various applications.

## Overview
This repository contains configuration files for:
- **Hyprland** - Dynamic tiling Wayland compositor
- **Waybar** - Highly customizable status bar
- **Dunst** - Lightweight notification daemon
- **Kitty** - GPU-accelerated terminal emulator
- **LunarVim** - Neovim-based IDE layer
- **FastFetch** - Linux system information tool
- **Zsh** - Shell configuration
- **Scripts** - Custom utility scripts
- **hyde-themes** - HyDE themes for Hyprland with my customizations

## Structure
```
myconf/
├── dunst/          # Notification daemon configuration
├── fastfetch/      # FastFetch configuration for system information
├── hyde-themes/    # HyDE themes for Hyprland
├── hypr/           # Hyprland compositor settings
├── kitty/          # Kitty terminal emulator configuration
├── lvim/           # LunarVim configuration
├── scripts/        # Custom utility scripts
├── waybar/         # Status bar configuration and modules
└── zshrc/          # Zsh shell configuration
```

## Installation

1. Clone this repository:
```bash
git clone https://github.com/masshirodev/hypr-config ~/.config/myconf
```

2. Create symlinks to the expected config locations:
```bash
# Backup existing configs (optional)
mv ~/.config/dunst ~/.config/dunst.bak
mv ~/.config/hypr ~/.config/hypr.bak
mv ~/.config/waybar ~/.config/waybar.bak
mv ~/.config/hyde ~/.config/hyde.bak
mv ~/.config/fastfetch ~/.config/fastfetch.bak
mv ~/.config/kitty ~/.config/kitty.bak
mv ~/.config/lvim ~/.config/lvim.bak
mv ~/.config/noctalia ~/.config/noctalia.bak
mv ~/.config/Kvantum ~/.config/Kvantum.bak
mv ~/.config/vesktop ~/.config/vesktop.bak

# Create symlinks
ln -s ~/.config/myconf/dunst ~/.config/dunst
rm -r ~/.config/hypr && ln -s ~/.config/myconf/hypr ~/.config/hypr
ln -s ~/.config/myconf/waybar ~/.config/waybar
ln -s ~/.config/myconf/zshrc ~/.zshrc
ln -s ~/.config/myconf/hyde-themes ~/.config/hyde
ln -s ~/.config/myconf/fastfetch ~/.config/fastfetch
ln -s ~/.config/myconf/kitty ~/.config/kitty
ln -s ~/.config/myconf/lvim ~/.config/lvim
ln -s ~/.config/myconf/noctalia ~/.config/noctalia
ln -s ~/.config/myconf/kvantum ~/.config/Kvantum
ln -s ~/.config/myconf/kdeglobals ~/.config/kdeglobals
ln -s ~/.config/myconf/vesktop ~/.config/vesktop
```

3. Make scripts executable:
```bash
chmod +x ~/.config/myconf/scripts/*
```

## Components

### Hyprland
- Split configuration across multiple files for better organization
- Custom keybindings and window rules
- Monitor-specific settings
- Animation configurations

### Waybar
- Modular configuration with separate JSON files for each module
- Custom styling with CSS
- Bottom-positioned bar with transparency effects
- Comprehensive system monitoring modules

### Dunst
- Custom notification styling
- Icon support with themed SVG icons
- Volume-specific notification icons
- Forced to primary monitor display

### Kitty
- GPU-accelerated terminal with custom theming
- Font and appearance configurations
- Integration with Hyprland

### LunarVim
- Neovim-based IDE configuration
- Custom plugins and keybindings
- Language server configurations

### FastFetch
- Custom configuration for system information display

### Scripts
- `merge-json.py` - JSON configuration merger
- `restart-wallpaper.sh` - Wallpaper management
- `swap-workspaces.sh` - Workspace utilities

## Requirements
- Arch Linux
- Hyprland
- Waybar
- Dunst
- Kitty
- LunarVim
- Zsh
- Python 3 (for scripts)
- HyDE

## Customization
Most settings can be customized by editing the respective configuration files:
- Hyprland settings: `hypr/`
- Waybar appearance: `waybar/style.css` and `waybar/modules/`
- Notifications: `dunst/dunstrc`
- Terminal: `kitty/kitty.conf`
- Editor: `lvim/config.lua`

## Notes
- Waybar is configured to run on the "bottom" layer to allow notifications to appear above it
- Dunst is configured to display notifications on the primary monitor (DP-2)
- Some paths may need adjustment based on your specific setup

## License
Personal configuration files - feel free to use and modify as needed.
