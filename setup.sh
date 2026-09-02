#!/bin/bash
set -e

# 1. Update and upgrade system packages
echo "Updating and upgrading packages..."
pkg update -y && pkg upgrade -y

# 2. Install core utilities
echo "Installing Git, ZSH, Curl, Python, and Pip..."
pkg install -y git zsh curl python python-pip

# Try installing legacy Python 2 if available on your repository mirror
echo "Attempting to install legacy Python 2..."
pkg install -y python2 || echo "Python 2 package not available on this mirror. Skipping."

# 3. Clone dotfiles repository
echo "Cloning dotfiles repository..."
DOTFILES="$HOME/dotfiles"

# Go to HOME first to avoid breaking CWD if we're inside DOTFILES
cd "$HOME"

rm -rf "$DOTFILES"
git clone --depth=1 https://github.com/MichaelB11221/dotfiles.git "$DOTFILES"

# 4. Install Oh My Zsh (Silent automated mode)
echo "Installing Oh My Zsh..."
CHSH=no RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 5. Set ZSH Custom path
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
mkdir -p "$ZSH_CUSTOM/themes"
mkdir -p "$ZSH_CUSTOM/plugins"

# 6. Restore Oh My Zsh custom folder from repo (if it exists)
echo "Setting up Oh My Zsh custom files..."
if [ -d "$DOTFILES/oh-my-zsh-custom" ]; then
  cp -r "$DOTFILES/oh-my-zsh-custom/"* "$ZSH_CUSTOM/" 2>/dev/null || true
  echo "Copied oh-my-zsh-custom/ to \$ZSH_CUSTOM."
fi

# 7. Install Powerlevel10k if not present (fallback)
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
  echo "Powerlevel10k not found in repo, cloning..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
else
  echo "Powerlevel10k already present, skipping clone..."
fi

# 8. Install ZSH Plugins if not present (fallback)
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  echo "zsh-syntax-highlighting not found, cloning..."
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
  echo "zsh-syntax-highlighting already present, skipping clone..."
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  echo "zsh-autosuggestions not found, cloning..."
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
  echo "zsh-autosuggestions already present, skipping clone..."
fi

# 9. Apply dotfiles (.bashrc, .zshrc, .p10k.zsh)
echo "Applying dotfiles..."
cp -f "$DOTFILES/.bashrc" "$HOME/.bashrc"
cp -f "$DOTFILES/.zshrc" "$HOME/.zshrc"
cp -f "$DOTFILES/.p10k.zsh" "$HOME/.p10k.zsh"

# 10. Apply Termux configuration
echo "Configuring Termux..."
mkdir -p "$HOME/.termux"

if [ -d "$DOTFILES/termux" ]; then
  cp -rf "$DOTFILES/termux/"* "$HOME/.termux/" 2>/dev/null || true
  echo "Copied termux/ configs to ~/.termux/"
else
  cat << 'EOF' > "$HOME/.termux/termux.properties"
extra-keys = [ \
  ['ESC','/','-','HOME','UP','END','PGUP'], \
  ['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN'] \
]
EOF
  echo "termux/ folder not found, applying default extra-keys..."
fi

termux-reload-settings

# 11. Apply .shizuku if it exists
if [ -d "$DOTFILES/.shizuku" ]; then
  echo "Copying .shizuku configs..."
  cp -rf "$DOTFILES/.shizuku" "$HOME/"
fi

# 12. Link bashrc to bash_profile
echo "Configuring profile..."
echo "source \$HOME/.bashrc" > "$HOME/.bash_profile"

# 13. Clean up cloned dotfiles
echo "Cleaning up..."
rm -rf "$DOTFILES"

# 14. Set ZSH as the default shell
echo "Setting ZSH as default shell..."
chsh -s zsh

echo "------------------------------------------------"
echo "Setup complete! Please restart Termux completely."
echo "------------------------------------------------"
