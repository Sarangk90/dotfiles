#!/usr/bin/env bash
# mac-bootstrap.sh — Mac dev‑box bootstrap (Bash 3.2‑compatible, idempotent)
set -euo pipefail

# 0. Ensure Homebrew on PATH
eval "$(/opt/homebrew/bin/brew shellenv)"

echo "› Installing/upgrading packages from Brewfile…"
brew bundle --file="$(dirname "$0")/Brewfile"

# 1. Oh‑My‑Zsh + Powerlevel10k
echo "› Setting up Oh-My-Zsh & Powerlevel10k…"
if [[ ! -d ~/.oh-my-zsh ]]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
if [[ ! -d ~/.oh-my-zsh/custom/themes/powerlevel10k ]]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
  sed -i '' 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
fi

# 2. Zsh plugins (autosuggestions, syntax-highlighting, completions)
PLUGIN_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
mkdir -p "$PLUGIN_DIR"

clone_plugin() {
  [[ -d "$PLUGIN_DIR/$2" ]] || git clone --depth=1 "$1" "$PLUGIN_DIR/$2"
}
clone_plugin https://github.com/zsh-users/zsh-autosuggestions zsh-autosuggestions
clone_plugin https://github.com/zsh-users/zsh-syntax-highlighting zsh-syntax-highlighting
clone_plugin https://github.com/zsh-users/zsh-completions zsh-completions

if grep -q "^plugins=" ~/.zshrc; then
  sed -i '' 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)/' ~/.zshrc
else
  echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)' >> ~/.zshrc
fi

# 3. Shell init snippets
append() { grep -qxF "$1" ~/.zshrc || echo "$1" >> ~/.zshrc; }

append 'typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet'
append 'autoload -Uz compinit && compinit'
append 'alias python=python3'
append 'export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"'
append 'export PATH="$HOME/.jenv/bin:$PATH"'
append 'eval "$(jenv init -)"'
append 'eval "$(pyenv init --path)"; eval "$(pyenv init -)"'
append 'export NVM_DIR="$HOME/.nvm"'
append '[ -s "$(brew --prefix nvm)/nvm.sh" ] && . "$(brew --prefix nvm)/nvm.sh"'


# 4. First-time env setup

# install desired Python versions
DESIRED_PYTHONS=(3.10.12 3.12.3)  # add/remove as needed
for v in "${DESIRED_PYTHONS[@]}"; do
  if ! pyenv versions --bare | grep -qx "$v"; then
    echo ">Installing Python $v"
    pyenv install --skip-existing "$v"
  fi
done
pyenv global "${DESIRED_PYTHONS[@]}"

# Ensure pipx is on PATH
append 'pipx ensurepath'

# Helper to idempotently install a tool via pipx
install_pipx() {
  local pkg=$1
  # pipx list prints lines like "  package poetry 2.x.x, installed using Python …"
  if ! pipx list | grep -q "package $pkg "; then
    echo "› Installing $pkg via pipx…"
    pipx install "$pkg"
  fi
}

# Install Poetry + common Python CLIs
for pkg in poetry pre-commit black isort mypy; do
  install_pipx "$pkg"
done

if ! jenv versions | grep -q 17 && command -v jenv &>/dev/null; then
  jenv add /opt/homebrew/opt/openjdk@17
  jenv global 17
fi

# 5. fzf integration
if [[ -d "$(brew --prefix)/opt/fzf" ]]; then
  "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc --no-bash
fi

# 6. Font for p10k
if ! fc-list | grep -q "MesloLGS NF"; then
  brew install --cask font-meslo-lg-nerd-font
fi

# 7. Vim/Neovim mouse support
VIMRC="$HOME/.vimrc"
touch "$VIMRC"
for line in "set mouse=a" "set ttymouse=sgr" "set ttyfast"; do
  grep -qxF "$line" "$VIMRC" || echo "$line" >> "$VIMRC"
done

# Done
echo -e "\n✅ Bootstrap complete! Source ~/.zshrc or open a new terminal."