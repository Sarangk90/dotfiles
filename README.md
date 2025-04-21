# mac‑dotfiles

This repo bootstraps a macOS development environment with:
- Homebrew & Brewfile for package management
- Oh‑My‑Zsh, Powerlevel10k, and essential Zsh plugins
- Env managers: jenv, pyenv, tfenv, nvm
- Editor support: Vim trackpad & mouse settings
- GitHub Actions to keep Brewfile up to date

## Usage
1. Clone:

```bash
git clone <repo-url> ~/.dotfiles
cd ~/.dotfiles
```

2. Bootstrap:
```
chmod +x mac-bootstrap.sh
./mac-bootstrap.sh
```

3. Manual tweak: iTerm2 → Preferences → Advanced → enable **Scroll wheel sends arrow keys...** for Vim scroll support.

## Updating Packages
- Edit `Brewfile`, then:
```bash
brew bundle --file=Brewfile
git add Brewfile
git commit -m "feat: ..."
git push
```

GitHub Actions auto-PRs on schedule.

```
License

MIT © Sarang Kulkarni