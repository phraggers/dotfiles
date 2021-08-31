;;=========================
;; Phraggers Emacs Init
;;=========================

;=-=-=-=-=-=-=-=-=
;;;;; SYSTEM ;;;;;
;=-=-=-=-=-=-=-=-=

;; Determine OS
(setq phr-macos (eq system-type 'darwin))
(setq phr-linux (eq system-type 'gnu/linux))
(setq phr-win32 (eq system-type 'windows-nt))

;; Startup
(setq default-directory "w:")
(setq inhibit-startup-message t) ;disable welcome screen
(display-time) ;show clock in lower right
(scroll-bar-mode -1) ;disable scroll bar
(tool-bar-mode -1) ;disable toolbar
(menu-bar-mode -1) ;disable menubar
(set-fringe-mode 5) ;add edge margin
(setq-default word-wrap t) ;enable word-wrap
(global-auto-revert-mode) ;if editing externally, emacs will update buffers
(add-hook 'emacs-startup-hook 'toggle-frame-fullscreen) ;start fullscreen
(global-unset-key (kbd "C-z")) ;disable ctrl+z minimizing emacs
(setq make-backup-files nil) ;disable spamming ~files everywhere
(setq auto-save-default nil) ;turn off autosave
(setq auto-save-interval 0) ;turn off autosave timer

;; UTF-8
(setq-default buffer-file-coding-system 'utf-8-unix)
(set-terminal-coding-system 'utf-8)
(set-language-environment 'utf-8)
(set-keyboard-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
(setq locale-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)

;; MacOS specifics
(when phr-macos
  (cua-mode 0) ;stop keybinds like C-x C-z etc
  (osx-key-mode 0) ;disable mac keybinds
  (setq mac-command-modifier 'meta) ;enable command to be mod
  (setq mac-command-key-is-meta t) ;set Cmd to meta mod
  (setq mac-pass-command-to-system nil) ;intercept cmd key
  (setq x-select-enable-clipboard t) ;t = primary sel, nil = clipboard sel
  (setq special-display-regexps nil) ;disable weird mac display stuff
  (setq special-display-buffer-names nil) ;disable weird mac buffer stuff
  (define-key function-key-map [return] [13]) ;mac return keycode can be weird
  )

;; Set Display
(split-window-horizontally) ;horizontal split
(global-linum-mode t) ;enable line numbers
(setq linum-format "%3d\u007C") ;line number format

;; Disable Bell
(defun nil-bell ())
(setq ring-bell-function 'nil-bell)

; Set high undo buffers
(setq undo-limit 10000000)
(setq undo-strong-limit 10000000)

; Base theme
(load-theme 'deeper-blue)

;; Fonts
(set-face-attribute 'default nil :font "Liberation Mono" :height 110 :weight 'semibold :background "#000000") ;Default font
(set-face-background 'linum "#000000") ;Line Number background
(set-face-foreground 'highlight nil) ;Disable highlight override fg color

;; Line Highlight
(require 'hl-line) ;disable inheriting from highlight, to preserve fg color
(set-face-attribute 'hl-line nil :inherit nil :background "#0c0e30")
(global-hl-line-mode 1)

;; Highlight TODO, NOTE, TEST
(setq fixme-modes '(c++-mode c-mode emacs-lisp-mode))
(make-face 'font-lock-fixme-face)
(make-face 'font-lock-note-face)
(make-face 'font-lock-test-face)
(mapc (lambda (mode)
        (font-lock-add-keywords
         mode
         '(("\\<\\(TODO\\)" 1 'font-lock-fixme-face t)
		   ("\\<\\(TEST\\)" 1 'font-lock-test-face t)
           ("\\<\\(NOTE\\)" 1 'font-lock-note-face t))))
      fixme-modes)
(modify-face 'font-lock-fixme-face "Red" nil nil t nil t nil nil)
(modify-face 'font-lock-test-face "Yellow" nil nil t nil t nil nil)
(modify-face 'font-lock-note-face "Dark Green" nil nil t nil t nil nil)

;=-=-=-=-=-=-=-=-=-=
;;;;; PACKAGES ;;;;;
;=-=-=-=-=-=-=-=-=-=

;; Packages Init
(setq package-archives '(("melpa" . "http://melpa.org/packages/")
			 ("org" . "https://orgmode.org/elpa/")
			 ("elpa" . "https://elpa.gnu.org/packages/")))
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

;; Counsel
(use-package counsel)

;; Rainbow Delimiters
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; Which Key
(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.3))

;; Helpful
(use-package helpful
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

;; Nyan Mode
(use-package nyan-mode)
(nyan-mode) ;nyanyanyanyanyan
(nyan-start-animation)

;; Ivy
(use-package ivy
  :diminish
  :bind (
	 :map ivy-minibuffer-map
	 ("TAB" . ivt-alt-done)
	 ("C-l" . ivy-alt-done)
	 :map ivy-switch-buffer-map
	 ("C-l" . ivy-done)
	 ("C-d" . ivy-switch-buffer-kill)
	 :map ivy-reverse-i-search-map
	 ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))

(use-package ivy-rich
  :init
  (ivy-rich-mode 1))

;; Doom Modeline (and icons)
; NOTE: when first run: M-x all-the-icons-install-fonts 
; On windows right click each downloaded font > install
; also get https://dn-works.com/wp-content/uploads/2020/UFAS-Fonts/Symbola.zip
(use-package all-the-icons)
(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 10)))

;; C-Mode
(require 'cc-mode) ;ensure c/++ major modes
(require 'compile) ;ensure compile funcs

;; Compile
(when phr-win32
  (setq compile-command "w:/build.bat"))

;; Auto Complete
(use-package auto-complete)
(require 'auto-complete)
(require 'auto-complete-config)
(ac-config-default)

;(use-package auto-complete-c-headers)

;;TODO complete include paths
;(when phr-macos
;  (defun my:ac-c-header-init ()
;    (require 'auto-complete-c-headers)
;    (add-to-list 'ac-sources 'ac-source-c-headers)
;    (add-to-list 'achead:include-directories
;		 '"$path"))
;  )

;(when phr-linux
;  (defun my:ac-c-header-init ()
;    (require 'auto-complete-c-headers)
;    (add-to-list 'ac-sources 'ac-source-c-headers)
;    (add-to-list 'achead:include-directories
;		 '"$path"))
;  )

; in vcvarsall %include% has include paths
; in eshell use:
; for m in {split-string $include ";"} {echo $m}
;(when phr-win32
;  (defun my:ac-c-header-init ()
;    (require 'auto-complete-c-headers)
;    (add-to-list 'ac-sources 'ac-source-c-headers)
;    (add-to-list 'achead:include-directories
;		 '"$path"))
;  )

;(add-hook 'c++-mode-hook 'my:ac-c-header-init)
;(add-hook 'c-mode-hook 'my:ac-c-header-init)

;;YASnippet
(use-package yasnippet)
(use-package yasnippet-snippets)
(require 'yasnippet)
(require 'yasnippet-snippets)
(yas-global-mode 1)

;; Smart Parens
(use-package smartparens)
(require 'smartparens)
(require 'smartparens-config)
(smartparens-global-mode)

;; Corfu
(use-package corfu
  :init
  (corfu-global-mode))

;; General Key Bindings
(use-package general)

;=-=-=-=-=-=-=-=-=-=-=-=
;;;;; KEYBINDINGS ;;;;;;
;=-=-=-=-=-=-=-=-=-=-=-=

;; GENERAL
(require 'general)
; ==== Global ====
; `general-define-key' acts like `global-set-key' when :keymaps is not
; specified (because ":keymaps 'global" is the default)
; kbd is not necessary and arbitrary amount of key def pairs are allowed
; ==== Mode ====
; `general-define-key' is comparable to `define-key' when :keymaps is specified
; NOTE: keymaps specified with :keymaps must be quoted
; ==== Prefix ===
; example:
;(general-define-key
; :prefix "C-c"
; "a" 'org-agenda)

;; General: Global
(general-define-key
 "M-x" 'counsel-M-x
 "C-s" 'counsel-grep-or-swiper
 "M-<left>" 'previous-buffer
 "M-<right>" 'next-buffer
 "M-<up>" 'counsel-switch-buffer
 "M-<down>" 'counsel-switch-buffer-other-window
 "C-d" 'kill-line
 "C-q" 'kill-ring-save
 "C-f" 'yank
 "M-w" 'other-window
 "M-k" 'kill-this-buffer
 "C-<f5>" 'compile
 "<f5>" 'recompile
 "M-," 'previous-error
 "M-." 'next-error
 "M-q" 'fill-paragraph
 )

;; General: Mode
; org-mode
(general-def org-mode-map
 "C-c C-q" 'counsel-org-tag
 )

; c mode
(general-def c-mode-base-map
  "C-d" 'kill-line
  )

;; Find and Replace
(defun phr-replace-string (FromString ToString)
  "Replace a string without moving point."
  (interactive "sReplace: \nsReplace: %s With: ")
  (save-excursion
    (replace-string FromString ToString)
    ))
(define-key global-map [f8] 'phr-replace-string)
