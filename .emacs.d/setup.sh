#!/usr/bin/env bash
# setup.sh — doctor / bootstrapper for this Emacs config.
#
# This does NOT try to install Node.js itself (too OS-specific to do safely).
# It installs only what's safe and idempotent, and reports what's missing.
# Re-running it is always safe.
set -euo pipefail

echo "== Emacs config setup =="

# --- Dockerfile language server (needs npm) ---
if command -v npm >/dev/null 2>&1; then
  echo "-> npm found; installing docker-language-server-nodejs (global)..."
  npm install -g docker-language-server-nodejs
else
  echo "!! npm not found. Install Node.js first (apt/brew/nvm), then re-run."
fi

# --- Manual, in-Emacs steps we can't reliably script ---
cat <<'EOF'

== Remaining manual steps ==
First launch of Emacs installs all packages automatically. Then, inside Emacs:

  M-x neocaml-install-grammars              # OCaml tree-sitter grammars
  M-x treesit-install-language RET dockerfile RET

For OCaml editing you also need opam + a per-project devcontainer; see the
neocaml/eglot/TRAMP comment block in init.el.

Done.
EOF
