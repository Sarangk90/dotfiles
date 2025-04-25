#!/usr/bin/env bash
# mac-bootstrap.sh — Mac dev-box bootstrap (Bash 3.2-compatible, idempotent)
set -euo pipefail

###############################################################################
# 0. Homebrew on PATH and up to date
###############################################################################
eval "$(/opt/homebrew/bin/brew shellenv)"
echo "› Updating Homebrew …"
brew update

echo "› Installing / upgrading packages from Brewfile …"
brew bundle --file="$(dirname "$0")/Brewfile"

###############################################################################
# 1. Oh-My-Zsh + Powerlevel10k
###############################################################################
echo "› Setting up Oh-My-Zsh & Powerlevel10k …"

if [[ ! -d ~/.oh-my-zsh ]]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

THEME_DIR=~/.oh-my-zsh/custom/themes/powerlevel10k
if [[ ! -d $THEME_DIR ]]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$THEME_DIR"
  sed -i '' 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\\/powerlevel10k"/' ~/.zshrc
fi

###############################################################################
# 2. Zsh plugins
###############################################################################
PLUGIN_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
mkdir -p "$PLUGIN_DIR"

clone_plugin() {
  [[ -d "$PLUGIN_DIR/$2" ]] || git clone --depth=1 "$1" "$PLUGIN_DIR/$2"
}
clone_plugin https://github.com/zsh-users/zsh-autosuggestions     zsh-autosuggestions
clone_plugin https://github.com/zsh-users/zsh-syntax-highlighting zsh-syntax-highlighting
clone_plugin https://github.com/zsh-users/zsh-completions         zsh-completions

if grep -q "^plugins=" ~/.zshrc; then
  sed -i '' 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)/' ~/.zshrc
else
  echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)' >> ~/.zshrc
fi

###############################################################################
# 3. zshrc helper snippets
###############################################################################
append() { grep -qxF "$1" ~/.zshrc || echo "$1" >> ~/.zshrc; }

append 'typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet'
append 'autoload -Uz compinit && compinit'
append 'export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"'
append 'export PATH="$HOME/.jenv/bin:$PATH"'
append 'eval "$(jenv init -)"'
append 'eval "$(pyenv init --path)"; eval "$(pyenv init -)"'
append 'eval "$(pyenv virtualenv-init -)"'
append 'export NVM_DIR="$HOME/.nvm"'
append '[ -s "$(brew --prefix nvm)/nvm.sh" ] && . "$(brew --prefix nvm)/nvm.sh"'

###############################################################################
# 4. Python runtimes via pyenv
###############################################################################
DESIRED_PYTHONS=(3.10.12 3.12.3)
for v in "${DESIRED_PYTHONS[@]}"; do
  echo "› Ensuring Python $v via pyenv …"
  pyenv install --skip-existing "$v"
done
pyenv global "${DESIRED_PYTHONS[@]}"

###############################################################################
# 5. pipx global CLIs
###############################################################################
echo "› Configuring pipx path …"
pipx ensurepath --force

install_pipx_pkg() {
  local pkg=$1
  if ! pipx list | grep -q "package $pkg "; then
    echo "› Installing $pkg via pipx …"
    pipx install "$pkg"
  fi
}

for pkg in poetry pre-commit black isort mypy; do
  install_pipx_pkg "$pkg"
done

###############################################################################
# 6. jenv — register JDK 17 once
###############################################################################
if command -v jenv &>/dev/null && ! jenv versions | grep -q 17; then
  echo "› Registering OpenJDK 17 with jenv …"
  jenv add /opt/homebrew/opt/openjdk@17
  jenv global 17
fi

###############################################################################
# 7. fzf key-bindings & completions
###############################################################################
if [[ -d "$(brew --prefix)/opt/fzf" ]]; then
  "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc --no-bash
fi

###############################################################################
# 8. Meslo Nerd Font for Powerlevel10k
###############################################################################
if ! fc-list | grep -q "MesloLGS NF"; then
  brew install --cask font-meslo-lg-nerd-font
fi

###############################################################################
# 9. Vim/Neovim mouse support
###############################################################################
VIMRC="$HOME/.vimrc"
touch "$VIMRC"
for line in "set mouse=a" "set ttymouse=sgr" "set ttyfast"; do
  grep -qxF "$line" "$VIMRC" || echo "$line" >> "$VIMRC"
done

###############################################################################
# 10. Colima 
###############################################################################
if command -v colima &>/dev/null; then
  if ! colima status &>/dev/null; then
    echo "› Starting Colima (Docker runtime) …"
    colima start
  else
    echo "↪ Colima already running, skipping"
  fi
fi
###############################################################################
# Done
###############################################################################
echo -e "\\n✅  Bootstrap complete!  Open a new terminal or run:  source ~/.zshrc"