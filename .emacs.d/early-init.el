;;; early-init.el --- pre-frame startup -*- lexical-binding: t -*-

;; This file runs BEFORE the initial GUI frame is created, unlike init.el
;; which runs after. Frame-geometry parameters (fullscreen, undecorated, size)
;; belong here: put them in `default-frame-alist' now and the initial frame is
;; *born* with them. Set them in init.el instead and the frame is created at a
;; default size first, then `frame-notice-user-settings' asks the compositor to
;; change it after the window is already mapped -- which on this PGTK/Wayland
;; (WSLg) build is unreliable for `fullscreen', especially alongside
;; `undecorated'. Hence Emacs starting up not-fullscreen despite init.el.

;; Start fullscreen. `fullboth' = true fullscreen (no title bar, covers the
;; whole output), as opposed to `maximized'.
(add-to-list 'default-frame-alist '(fullscreen . fullboth))

;; No window-manager decorations. Set here (before mapping) rather than in
;; init.el, because toggling a Wayland surface to undecorated after it is
;; already on screen tends to fight the fullscreen request.
(add-to-list 'default-frame-alist '(undecorated . t))

;; Kill the menu bar, tool bar, and scroll bars as *frame parameters* so the
;; initial frame is never drawn with them. init.el also calls the matching
;; `menu-bar-mode' / `tool-bar-mode' / `scroll-bar-mode' minor modes (which is
;; what keeps M-x toggling them working), but those run after the frame exists,
;; so on their own you get a brief flash of chrome at startup before it's
;; removed. Setting the frame params here suppresses that flash. `0' lines for
;; the bars; nil for the scroll bars.
(dolist (param '((menu-bar-lines . 0)
                 (tool-bar-lines . 0)
                 (vertical-scroll-bars . nil)
                 (horizontal-scroll-bars . nil)))
  (add-to-list 'default-frame-alist param))

;;; early-init.el ends here
