#!/bin/bash
set -e

echo "#> Dotfiles setup — one-time provisioning"
echo "#> Requires: Arch/Manjaro with yay installed"
echo ""

# Verify yay is available
if ! command -v yay &>/dev/null; then
    echo "#> Error: yay is required but not installed"
    echo "#> Install it first: https://github.com/Jguer/yay"
    exit 1
fi

# ──────────────────────────────────────────────
# Core packages (official repos)
# ──────────────────────────────────────────────
echo "#> Installing core packages..."
sudo pacman -S --needed --noconfirm \
    fish \
    alacritty \
    neovim \
    tmux \
    polybar \
    starship \
    openssh \
    git \
    curl \
    ripgrep \
    xclip \
    gcc \
    zstd \
    age \
    spotify-player

# ──────────────────────────────────────────────
# AUR packages
# ──────────────────────────────────────────────
echo "#> Installing AUR packages..."
yay -S --needed --noconfirm \
    eza \
    lazydocker \
    iamb-bin

# ──────────────────────────────────────────────
# Tuwunel binary (pre-built release)
# ──────────────────────────────────────────────
if ! command -v tuwunel &>/dev/null; then
    echo "#> Installing tuwunel from GitHub releases..."
    mkdir -p ~/.local/bin
    tmpfile=$(mktemp)
    gh release download --repo matrix-construct/tuwunel \
        --pattern '*-release-all-x86_64-v1-linux-gnu-tuwunel.zst' \
        --output "$tmpfile"
    zstd -d "$tmpfile" -o ~/.local/bin/tuwunel
    chmod +x ~/.local/bin/tuwunel
    rm -f "$tmpfile"
    echo "#> tuwunel installed to ~/.local/bin/tuwunel"
else
    echo "#> tuwunel already installed"
fi

# ──────────────────────────────────────────────
# Symlink dotfiles
# ──────────────────────────────────────────────
echo "#> Linking dotfiles..."
cd "$(git rev-parse --show-toplevel)" || exit

for d in */ ; do
    local_config=~/.config/${d%/}
    repo_config=$(pwd)/${d%/}
    if [ -L "${local_config}" ]; then
        rm "${local_config}"
    elif [ -e "${local_config}" ]; then
        echo "#> Warning: ${local_config} exists and is not a symlink, skipping"
        continue
    fi
    ln -s "${repo_config}" "${local_config}"
done

if [ -L ~/.config/fish-ai.ini ]; then
    rm ~/.config/fish-ai.ini
elif [ -e ~/.config/fish-ai.ini ]; then
    echo "#> Warning: ~/.config/fish-ai.ini exists and is not a symlink, skipping"
fi
[ ! -e ~/.config/fish-ai.ini ] && ln -s "$(pwd)/fish-ai.ini" ~/.config/fish-ai.ini

if [ -L ~/.claude ]; then
    rm ~/.claude
elif [ -e ~/.claude ]; then
    echo "#> Warning: ~/.claude exists and is not a symlink, skipping"
fi
[ ! -e ~/.claude ] && ln -s "$(pwd)/claude" ~/.claude

echo "#> Dotfiles linked"

# ──────────────────────────────────────────────
# Claude Code CLI
# ──────────────────────────────────────────────
if ! command -v claude &>/dev/null; then
    echo "#> Installing Claude Code CLI..."
    npm install -g @anthropic-ai/claude-code
    echo "#> Claude Code CLI installed"
else
    echo "#> Claude Code CLI already installed"
fi

# ──────────────────────────────────────────────
# Fish shell
# ──────────────────────────────────────────────
echo "#> Setting up fish..."

# Set fish as default shell if it isn't already
if [ "$SHELL" != "$(command -v fish)" ]; then
    chsh -s "$(command -v fish)"
    echo "#> Default shell set to fish"
fi

# Install fisher and plugins
fish -c '
    curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
    fisher update
'
echo "#> Fisher plugins installed"

# ──────────────────────────────────────────────
# Neovim
# ──────────────────────────────────────────────
echo "#> Bootstrapping neovim plugins..."
nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
echo "#> Neovim plugins synced"

# ──────────────────────────────────────────────
# Tuwunel (Matrix server)
# ──────────────────────────────────────────────
echo "#> Setting up tuwunel..."

mkdir -p ~/.local/share/tuwunel
mkdir -p ~/.config/systemd/user
ln -sf ~/.config/tuwunel/tuwunel.service ~/.config/systemd/user/tuwunel.service
systemctl --user daemon-reload
systemctl --user enable tuwunel
systemctl --user start tuwunel

sleep 2
if curl -sf http://localhost:8008/_matrix/client/versions >/dev/null; then
    echo "#> Tuwunel running on http://localhost:8008"
else
    echo "#> Tuwunel may still be starting — check 'tuwunel-status'"
fi

# ──────────────────────────────────────────────
# Done
# ──────────────────────────────────────────────
echo ""
echo "#> Setup complete"
echo ""
echo "#> Next steps:"
echo "#>   1. Log out and back in (or run 'fish') to use the new shell"
echo "#>   2. Register the tuwunel admin user:"
echo "#>      curl -X POST http://localhost:8008/_matrix/client/r0/register \\"
echo "#>        -H 'Content-Type: application/json' \\"
echo "#>        -d '{\"username\": \"operator\", \"password\": \"<password>\", \"auth\": {\"type\": \"m.login.registration_token\", \"token\": \"jack\"}}'"
