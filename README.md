# mac-dotfiles

A one-shot bootstrap for macOS developer workstations. Clone the repo and run a single script to install:

- **Xcode Command-Line Tools** (git, compilers)  
- **Homebrew** (auto-installed if missing) & a **Brewfile** manifest of:
  - CLI tools: `git`, `awscli`, `python@3.12`, `node`, `yarn`, `docker` (CLI), `docker-compose`, `colima`, `kubernetes-cli`, `jenv`, `pyenv`, `pyenv-virtualenv`, `pipx`, `tfenv`, `nvm`, `autojump`
  - GUI apps (Casks): iTerm2, Google Chrome, PyCharm Pro, IntelliJ Ultimate, Sublime Text, Microsoft Teams, Zoom, 1Password, Word, Excel, PowerPoint, VS Code, Meslo Nerd Font
- **Oh-My-Zsh** + **Powerlevel10k** theme  
- Zsh plugins: `zsh-autosuggestions`, `zsh-syntax-highlighting`, `zsh-completions`  
- **fzf** fuzzy-finder key-bindings & completions  
- **autojump** directory jumper  
- Shell snippets: jenv, pyenv (+ virtualenv), nvm, compinit, autojump, fzf, Option-arrow word-motions  
- **Python** via `pyenv` (defaults: 3.10.12, 3.12.3)  
- **pipx** global CLIs: `poetry`, `pre-commit`, `black`, `isort`, `mypy`  
- **jenv** registration of OpenJDK 17  
- **Colima** for macOS Docker runtime  
- Vim/Neovim trackpad & mouse support  

Everything is **idempotent** – re-run the script anytime and it will skip what’s already installed.

---

## Prerequisites

- A **fresh macOS** only needs:
  1. **Xcode Command-Line Tools** (the script auto-installs if missing)  
  2. Internet access  
  3. **(Optional)** SSH key in 1Password and 1Password app installed to retrieve it  

---

## Usage

```bash
# Step 1: install Xcode CLI (prompts & waits)
xcode-select --install

# Step2. Clone this repo
git clone https://github.com/Sarangk90/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Step 3. Run the one-shot setup
./mac-bootstrap.sh
```

Once it finishes (grab a coffee ☕), open a new Terminal or run:

```
source ~/.zshrc
```
---

Manual Tweaks

iTerm2
  1.  Advanced → “Scroll wheel sends arrow keys when in alternate screen mode” → Yes
  2.  Keys → Left Option Key → Esc+ (so Option+←/→ sends Meta arrows)

1Password
  • Open 1Password.app, sign in with your account to unlock your SSH keys.


---

Updating & Customizing
  • Add or remove packages in Brewfile.
  • Re-run the script to install new entries:

```
brew bundle --file=Brewfile
./mac-bootstrap.sh
```

---

License

MIT © Sarang Kulkarni