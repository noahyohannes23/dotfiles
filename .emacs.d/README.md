# Emacs config (dotfiles)

My Emacs configuration. Tracked files:

- `init.el`   — main config (loaded by Emacs 30+ from `~/.emacs.d/init.el`)
- `custom.el` — machine-generated `custom-set-*` settings (safe-themes, faces)

Everything else in `~/.emacs.d/` (packages, caches, history) is generated and
intentionally **not** tracked — see the bare-repo notes below.

## Fresh-machine bootstrap

Do these in order on a new machine:

1. **Clone the config into place.** This repo is managed as a *bare* repo whose
   work-tree is `$HOME`, so the files live at their real paths. To reproduce it:

   ```bash
   git clone --bare git@github.com:<you>/dotfiles.git "$HOME/.dotfiles"
   alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
   dotfiles config --local status.showUntrackedFiles no
   dotfiles checkout        # writes .emacs.d/init.el, custom.el into place
   ```

   Add the `alias` line to your `~/.bashrc` so it persists.

2. **Install the external toolchain** (not in this repo — see `setup.sh`):
   - Node.js / npm  — required for the Dockerfile language server
   - Run `bash ~/.emacs.d/setup.sh` to install the npm global and print the
     remaining manual steps.

3. **First Emacs launch** installs all packages automatically
   (`use-package-always-ensure`). Then run these once, inside Emacs:

   ```
   M-x neocaml-install-grammars          ;; OCaml tree-sitter grammars
   M-x treesit-install-language RET dockerfile RET
   ```

4. **OCaml editing** additionally needs opam + a devcontainer per project;
   see the comments in `init.el` (the neocaml / eglot / TRAMP block).

## Why a bare repo (not symlinks / Stow)

With essentially one config file, symlink managers are overkill. The bare repo
tracks the real files in place — nothing to symlink, nothing to remember.
Untracked files in `$HOME` are hidden via `status.showUntrackedFiles no`, so
`dotfiles status` only shows what you actually track.
