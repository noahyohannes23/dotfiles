(require 'package)
;; Nice macro for updating lists in place.
(defmacro append-to-list (target suffix)
  "Append SUFFIX to TARGET in place."
  `(setq ,target (append ,target ,suffix)))
;; Set up emacs package archives with 'package
(append-to-list  package-archives
		 '(("melpa" . "http://melpa.org/packages/") ;; Main package archive
		   ("melpa-stable" . "http://stable.melpa.org/packages/") ;; Some packages might only do stable releases?
		   ("org-elpa" . "https://orgmode.org/elpa/"))) ;; Org packages, I don't use org but seems like a harmless default

(package-initialize)

;; Ensure use-package is present. From here on out, all packages are loaded
;; with use-package, a macro for importing and installing packages. Also, refresh the package archive on load so we can pull the latest packages.
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq
 use-package-always-ensure t ;; Makes sure to download packages if they aren't already downloaded
 use-package-verbose t) ;; Package install logging. Packages break, so its nice to know why.

;; Slurp environment variables from the shell.
;; a.k.a the Most Asked Question on r/emacs
(use-package exec-path-from-shell
  :config
  (exec-path-from-shell-initialize))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("0325a6b5eea7e5febae709dab35ec8648908af12cf2d2b569bedc8da0a3a81c1"
     default))
 '(package-selected-packages '(doom-themes exec-path-from-shell)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(use-package doom-themes
  :init
  (load-theme 'doom-one))






;; Any customizable settings should live in custom.el, not here.
(setq custom-file "~/.emacs.d/custom.el") ;; Without this emacs will dump generated custom settings in this file. No bueno.
(load custom-file 'noerror)

;; OS specific config
(defconst *is-a-mac* (eq system-type 'darwin))
(defconst *is-a-linux* (eq system-type 'gnu/linux))
;; Emacs feels like its developed with linux in mind, here are some mac UX improvements
(when *is-a-mac*
  (setq mac-command-modifier 'meta)
  (setq mac-option-modifier 'none)
  (setq default-input-method "MacOSX"))

;; Some linux love too
(when *is-a-linux*
  (setq x-super-keysym 'meta))

;; Fullscreen by default, as early as possible. This tiny window is not enough
(add-to-list 'default-frame-alist '(fullscreen . fullboth))

;; Drop the GTK menu bar and tool bar. On a HiDPI display (WSLg/Wayland at 300%)
;; this chrome is scaled by the compositor and renders enormous; keybindings
;; cover everything it offered anyway. Re-enable with (menu-bar-mode 1) etc.
(menu-bar-mode -1)
(tool-bar-mode -1)

;; remove scroll bar
(scroll-bar-mode -1)

;; use emacs frame instead of gnome frame
(setq use-system-tooltips nil)

;; set tooltips off entirely, use minibuffer for context menus
(tooltip-mode -1)
;; display line numbers by default
(display-line-numbers-mode 1)

(defun my/context-menu-tmm (event)
  "Open the context menu as a text menu Emacs positions itself."
  (interactive "e")
  (tmm-prompt (context-menu-map event)))
(define-key global-map [mouse-3] #'my/context-menu-tmm)

(use-package minions
  :config (minions-mode 1))

;; try to add Jetka to detault fonts
(add-to-list 'default-frame-alist '(font . "Jetka"))
(add-to-list 'default-frame-alist '(undecorated . t))
;; Stop littering directories with backup/autosave files.
;; `make-backup-files' -> the "file~" copies; `auto-save-default' -> the
;; "#file#" crash-recovery files. Turning both off means no stray files next
;; to what you edit (e.g. in project repos). Trade-off: no auto crash recovery
;; -- if you want that without the clutter, redirect them to a temp dir
;; instead (auto-save-file-name-transforms / backup-directory-alist) rather
;; than disabling. We also drop `.#file' lock files for the same reason.
(setq make-backup-files nil
      auto-save-default nil
      create-lockfiles nil)

;; --- Completion stack: Vertico + Orderless + Marginalia + Consult ---
;; This replaces the old ivy/counsel/swiper setup. The big idea is that
;; everything here builds on Emacs' built-in `completing-read', so it
;; enhances *every* minibuffer prompt (including project.el's) automatically,
;; instead of shipping bespoke `counsel-*' commands for each one.

;; Remember minibuffer history so recently/frequently used candidates sort
;; to the top. Built in, but Vertico leans on it heavily.
(use-package savehist
  :ensure nil ;; built in, don't try to install from an archive
  :init
  (savehist-mode 1))

;; Vertico: the vertical completion UI. The ivy-mode replacement.
(use-package vertico
  :init
  (vertico-mode 1)
  (setq vertico-count 15      ;; was ivy-height
	vertico-cycle t))     ;; wrap around at the top/bottom of the list

;; Orderless: space-separated, order-independent fuzzy matching. This is what
;; makes typing "fo ba" match "foo-bar". `basic' is kept as a fallback so
;; things like TAB file completion still behave.
(use-package orderless
  :init
  (setq completion-styles '(orderless basic)
	completion-category-overrides '((file (styles basic partial-completion)))))

;; Marginalia: rich annotations in the minibuffer (docstrings, file sizes,
;; key bindings next to commands, etc). No ivy equivalent -- pure upgrade.
(use-package marginalia
  :init
  (marginalia-mode 1))

;; Consult: the practical commands. consult-line replaces swiper,
;; consult-buffer replaces ivy-switch-buffer / virtual buffers, and
;; consult-ripgrep is the project-wide search workhorse.
(use-package consult
  :bind (("C-s"   . consult-line)          ;; swiper replacement
	 ("C-x b" . consult-buffer)        ;; richer buffer switcher
	 ("M-y"   . consult-yank-pop)      ;; browsable kill-ring
	 ("M-g g" . consult-goto-line)
	 ("M-g i" . consult-imenu)))

;; --- Project management: built-in project.el ---
;; No package to install -- project.el ships with Emacs 30. It auto-detects
;; projects from your VCS root (git, etc.). The default prefix is `C-x p':
;;   C-x p f  find file in project   (was projectile-find-file)
;;   C-x p g  grep in project
;;   C-x p b  switch buffer in project
;;   C-x p p  switch project         (was projectile-switch-project)
;;   C-x p d  dired at project root
;; Route project search through consult-ripgrep for a nicer, live UI.
(use-package project
  :ensure nil ;; built in
  :config
  (with-eval-after-load 'consult
    (setq consult-project-function (lambda (_) (project-root (project-current))))))

;;  Host side config/markup file types via eglot
;; One time binary install: npm install -g docker-language-server-nodejs

;; Tell emacs to fetch the tree-sitter grammar, then M-x treesit-install-language RET <lang> for each one
(add-to-list 'exec-path (expand-file-name "~/.npm-global/bin"))

;; route dockerfiles to treesitter mode
(add-to-list 'auto-mode-alist '("/Dockerfile\\'" . dockerfile-ts-mode))
(add-to-list 'auto-mode-alist '("\\.dockerfile\\'" . dockerfile-ts-mode))

(add-hook 'dockerfile-ts-mode-hook #'eglot-ensure)

(use-package devcontainer
  :config
  (devcontainer-mode 1))

;; --- OCaml: edit on the host, run the LSP inside the devcontainer ---
;; neocaml (bbatsov) is a tree-sitter-powered OCaml major mode. Tree-sitter
;; parsing runs *inside host Emacs* (it parses buffer text TRAMP fetched), so
;; the grammars must be installed on the host -- one time, run:
;;   M-x neocaml-install-grammars     ;; installs the `ocaml' + `ocaml-interface' grammars
;; neocaml auto-wires .ml -> neocaml-mode and .mli -> neocaml-interface-mode,
;; and auto-registers both with eglot, so there's no :mode/auto-mode-alist to set.
;;
;; eglot (the LSP client, built into Emacs 29+) is what makes the container
;; part work: open a project file over TRAMP -- e.g. via
;; `M-x devcontainer-tramp-dired', which lands you on a
;; /docker:opam@<container>:... path -- and eglot launches the language server
;; *on the remote*, so ocamllsp runs inside the devcontainer with its libraries
;; and opam switch. Open a file with a local path instead and eglot would try
;; ocamllsp on the host, which doesn't have it -- so always reach files via TRAMP.
(use-package neocaml
  :hook ((neocaml-mode           . eglot-ensure)
	 (neocaml-interface-mode . eglot-ensure))
  :config
  ;; neocaml registers its modes with eglot using the bare command "ocamllsp".
  ;; Over TRAMP that won't pick up the container's opam switch, because eglot
  ;; starts the server with a non-interactive, non-login shell that never
  ;; sources the Dockerfile's `eval $(opam env)' in ~/.bashrc -- so PATH,
  ;; CAML_LD_LIBRARY_PATH, etc. would be unset and ocamllsp wouldn't be found
  ;; (or would use the wrong switch). neocaml re-runs its registration in every
  ;; OCaml buffer, so a plain add-to-list would lose the race; instead we
  ;; :override neocaml's own registration so OUR entry is the only one ever
  ;; added. We launch ocamllsp through `opam exec --', which sets up the switch
  ;; environment itself before exec'ing the server and is robust to the switch
  ;; name changing. The grouped key + :language-id values ("ocaml" /
  ;; "ocaml.interface") are copied exactly from neocaml: ocamllsp needs them to
  ;; tell .ml from .mli, and grouping both modes under one key makes eglot run a
  ;; single shared server per project. `opam' lives at /usr/bin/opam, on TRAMP's
  ;; default remote PATH, so it's found without any tramp-remote-path tweaking.
  (advice-add 'neocaml--register-with-eglot :override
	      (lambda ()
		(when (boundp 'eglot-server-programs)
		  (add-to-list 'eglot-server-programs
			       '(((neocaml-mode :language-id "ocaml")
				  (neocaml-interface-mode
				   :language-id "ocaml.interface"))
				 "opam" "exec" "--" "ocamllsp")))))

  ;; Format with ocamlformat on every save. ocamllsp performs the formatting
  ;; itself, so -- like the LSP -- this runs inside the container over TRAMP,
  ;; using the container's ocamlformat and the project's .ocamlformat file (add
  ;; one to the repo root, even just a `version = ...' line, or ocamlformat
  ;; refuses to run). Scoped to neocaml buffers (both modes derive from
  ;; neocaml-base-mode) and only while eglot is live, since eglot-format-buffer
  ;; errors with no server. The `nil t' makes the before-save-hook buffer-local.
  (add-hook 'eglot-managed-mode-hook
	    (lambda ()
	      (when (derived-mode-p 'neocaml-base-mode)
		(add-hook 'before-save-hook #'eglot-format-buffer nil t)))))
