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
(when phr-win32
  (setq default-directory "w:"))
(setq inhibit-startup-message t) ;disable welcome screen
(display-time) ;show clock in lower right
(if (display-graphic-p) ;when emacs window mode
    (progn
      (scroll-bar-mode -1) ;disable scroll bar
      (tool-bar-mode -1) ;disable toolbar
      (set-fringe-mode 5) ;add edge margin
      ))
(menu-bar-mode -1) ;disable menubar

;; Editing
(set-default 'truncate-lines t) ;line wrap (nil=wrap, t=dont)
(setq-default word-wrap t) ;if using line wrap then whole words are wrapped
(global-auto-revert-mode) ;if editing externally, emacs will update buffers
(global-unset-key (kbd "C-z")) ;disable ctrl+z minimizing emacs
(setq make-backup-files nil) ;disable spamming ~files everywhere
(setq auto-save-default nil) ;turn off autosave
(setq auto-save-interval 0) ;turn off autosave timer
(delete-selection-mode 1) ;typed text overwrites highlighted text
(add-hook 'write-file-hooks 'delete-trailing-whitespace) ;delete trailing whitespace on save

;; UTF-8
(setq-default buffer-file-coding-system 'utf-8-unix)
(set-terminal-coding-system 'utf-8)
(set-language-environment 'utf-8)
(set-keyboard-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
(setq locale-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)

;; MacOS specifics
(when phr-macos
  (cua-mode 0) ;stop keybinds like C-x C-z etc
  ;(osx-key-mode 0) ;disable mac keybinds
  (setq mac-command-modifier 'meta) ;enable command to be mod
  (setq mac-command-key-is-meta t) ;set Cmd to meta mod
  (setq mac-pass-command-to-system nil) ;intercept cmd key
  (setq x-select-enable-clipboard t) ;t = primary sel, nil = clipboard sel
  (setq special-display-regexps nil) ;disable weird mac display stuff
  (setq special-display-buffer-names nil) ;disable weird mac buffer stuff
  (define-key function-key-map [return] [13]) ;mac return keycode can be weird
  )

;; Set Display
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
(require 'compile)
(set-face-attribute 'compilation-info nil :weight 'bold :foreground "green")
(set-face-attribute 'compilation-error nil :weight 'bold :foreground "red")

;; Line Highlight
(require 'hl-line) ;disable inheriting from highlight, to preserve fg color
(set-face-attribute 'hl-line nil :inherit nil :background "#0c0e30")
(global-hl-line-mode 1)

;;=-=-=-=-=-=-=;;
;; Compilation ;;
;;=-=-=-=-=-=-=;;

(defun phr-create-win32-build-script ()
    "Create build.bat if it doesn't exist"
    (if (file-exists-p "w:/build.bat")
	(message "build.bat exists")
      (find-file-other-window "w:/build.bat")
      (insert "@echo off\n\n")
      (insert "set ProjectName=PROJECT\n\n")
      (insert "if not exist w:\\build mkdir w:\\build\n")
      (insert "if exist w:\\build\\%ProjectName%.exe del w:\\build\\%ProjectName%.exe\n\n")
      (insert "set InternalDefines=\n")
      (insert "set CompilerSwitches=-nologo\n")
      (insert "set CompilerInput=w:\\src\\%ProjectName%.cpp\n")
      (insert "set LinkerOptions=\n")
      (insert "set LinkerLibs=\n")
      (insert "echo.\n")
      (insert "pushd w:\\build\n")
      (insert "cl %InternalDefines% %CompilerSwitches% %CompilerInput% /link %LinkerOptions% %LinkerLibs%\n")
      (insert "popd\n\n")
      (insert "if not exist w:\\build\\%ProjectName%.exe exit /b 1\n")
      (insert "exit /b 0")
      (save-buffer)
      (kill-buffer)
      (other-window)
      ))

(require 'dired)
(when phr-win32
  (if (not (file-directory-p "w:/build"))
      (dired-create-directory "w:/build"))
  (if (not (file-directory-p "w:/data"))
      (dired-create-directory "w:/data"))
  (if (not (file-directory-p "w:/src"))
      (dired-create-directory "w:/src"))
  (phr-create-win32-build-script))

; TODO: other platform build scripts
(require 'cc-mode)
(when phr-win32
  (setq compile-command "w:/build.bat"))

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;;; C-STYLE AND FUNCTIONS ;;;;
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

;; Set Major Modes
(setq auto-mode-alist
      (append
       '(
	 ("\\.cpp$" . c++-mode)
	 ("\\.c$" . c++-mode)
	 ("\\.h$" . c++-mode)
	 ("\\.txt$" . indented-text-mode)
	 ("\\.el$" . emacs-lisp-mode)
	 ("\\.emacs$" . emacs-lisp-mode)
	 ) auto-mode-alist))

;; C++ Style
(defconst phr-c-style
  '(
    (c-electric-pound-behavior . nil)
    (c-tab-always-indent . t)
    (c-comment-only-line-offset . 0)

    (c-hanging-braces-alist . (
			       (class-open)
                               (class-close)
                               (defun-open)
                               (defun-close)
                               (inline-open)
                               (inline-close)
                               (brace-list-open)
                               (brace-list-close)
                               (brace-list-intro)
                               (brace-list-entry)
                               (block-open)
                               (block-close)
                               (substatement-open)
                               (statement-case-open)
                               (class-open)
			       ))

    (c-hanging-colons-alist . (
			       (inher-intro)
                               (case-label)
                               (label)
                               (access-label)
                               (access-key)
                               (member-init-intro)
			       ))

    (c-cleanup-list . (
		       scope-operator
                       list-close-comma
                       defun-close-semi
		       ))

    (c-offsets-alist . (
			(arglist-close . c-lineup-arglist)
                        (label                 . -2)
                        (access-label          . -2)
                        (substatement-open     .  0)
                        (statement-case-intro  .  2)
                        (statement-block-intro .  c-lineup-for)
                        (case-label            .  2)
                        (block-open            .  0)
                        (inline-open           .  0)
                        (topmost-intro-cont    .  0)
                        (knr-argdecl-intro     . -2)
                        (brace-list-open       .  0)
                        (brace-list-intro      .  2)
			))

    (c-echo-syntactic-information-p . t)
    )

  "phr-c-style")

(defun phr-c-hook ()
  (c-add-style "phr-style" phr-c-style t)

  (setq tab-width 2
	indent-tabs-mode nil)

  (c-set-offset 'member-init-intro '++)
  (c-toggle-auto-hungry-state -1)

  (setq dabbrev-case-replace t)
  (setq dabbrev-case-fold-search t)
  (setq dabbrev-upcase-means-case-search t)
  (abbrev-mode 1)

  (defun phr-header-format ()
    "Format header file."
    (interactive)
    (setq BaseFileName (file-name-sans-extension (file-name-nondirectory buffer-file-name)))
    (insert "#ifndef ")
    (push-mark)
    (insert BaseFileName)
    (upcase-region (mark) (point))
    (pop-mark)
    (insert "_H\n")
    (insert "/* ========================================================================\n")
    (insert "   $File:    ")
    (insert BaseFileName)
    (insert ".h")
    (insert " $\n")
    (insert "   $Project:  $\n")
    (insert "   $Date:    ")
    (insert (format-time-string "%d-%m-%Y" (current-time)))
    (insert " $\n")
    (insert "   $Author:  Phil Bagshaw $\n")
    (insert "   $Notice:  (c)Phragware ")
    (insert (format-time-string "%Y" (current-time)))
    (insert " $\n")
    (insert "   ======================================================================== */\n")
    (insert "\n\n\n")
    (insert "#define ")
    (push-mark)
    (insert BaseFileName)
    (upcase-region (mark) (point))
    (pop-mark)
    (insert "_H\n")
    (insert "#endif")
    )

  (defun phr-source-format ()
    "Format source file."
    (interactive)
    (setq BaseFileName (file-name-sans-extension (file-name-nondirectory buffer-file-name)))
    (insert "/* ========================================================================\n")
    (insert "   $File:    ")
    (insert BaseFileName)
    (insert ".c(pp)")
    (insert " $\n")
    (insert "   $Project:  $\n")
    (insert "   $Date:    ")
    (insert (format-time-string "%d-%m-%Y" (current-time)))
    (insert " $\n")
    (insert "   $Author:  Phil Bagshaw $\n")
    (insert "   $Notice:  (c)Phragware ")
    (insert (format-time-string "%Y" (current-time)))
    (insert " $\n")
    (insert "   ======================================================================== */\n")
    )

  (cond ((file-exists-p buffer-file-name) t)
        ((string-match "[.]cpp" buffer-file-name) (phr-source-format))
        ((string-match "[.]c" buffer-file-name) (phr-source-format))
        ((string-match "[.]h" buffer-file-name) (phr-header-format)))

  (defun phr-find-corresponding-file ()
    "Find this file's corresponding src/header file"
    (interactive)
    (setq CorrespondingFileName nil)
    (setq BaseFileName (file-name-sans-extension buffer-file-name))
    (if (string-match "\\.c" buffer-file-name)
	(setq CorrespondingFileName (concat BaseFileName ".h")))
    (if (string-match "\\.h" buffer-file-name)
	(if (file-exists-p (concat BaseFileName ".c"))
	    (setq CorrespondingFileName (concat BaseFileName ".c"))
	  (setq CorrespondingFileName (concat BaseFileName ".cpp"))))
    (if (string-match "\\.cpp" buffer-file-name)
	(setq CorrespondingFileName (concat BaseFileName ".h")))
    (if CorrespondingFileName (find-file CorrespondingFileName)
      (error "Unable to find a corresponding file")))

  (defun phr-find-corresponding-file-other-window ()
    "Find this file's corresponding src/header file (other window)"
    (interactive)
    (find-file-other-window buffer-file-name)
    (phr-find-corresponding-file)
    (other-window -1))
  )

(add-hook 'c-mode-common-hook 'phr-c-hook)

;; Highlight TODO, NOTE, TEST, IMPORTANT
(setq fixme-modes '(c++-mode c-mode emacs-lisp-mode))
(make-face 'font-lock-fixme-face)
(make-face 'font-lock-note-face)
(make-face 'font-lock-test-face)
(make-face 'font-lock-important-face)
(mapc (lambda (mode)
        (font-lock-add-keywords
         mode
         '(
	   ("\\<\\(TODO\\)" 1 'font-lock-fixme-face t)
	   ("\\<\\(NOTE\\)" 1 'font-lock-note-face t)
	   ("\\<\\(TEST\\)" 1 'font-lock-test-face t)
	   ("\\<\\(IMPORTANT\\)" 1 'font-lock-important-face t)
           )))
      fixme-modes)
(modify-face 'font-lock-fixme-face "Red" nil nil t nil t nil nil)
(modify-face 'font-lock-test-face "Cyan" nil nil t nil t nil nil)
(modify-face 'font-lock-important-face "Yellow" nil nil t nil t nil nil)
(modify-face 'font-lock-note-face "Dark Green" nil nil t nil t nil nil)

;; Find and Replace
(defun phr-replace-string (FromString ToString)
  "Replace a string without moving point."
  (interactive "sReplace: \nsReplace: %s With: ")
  (save-excursion
    (replace-string FromString ToString)
    ))

;; Windmove left/right
; if already left, delete other windows
; if already right, split-horizontally
(defun phr-windmove-left()
  (interactive)
  (condition-case nil (windmove-left)
    (error (delete-other-windows))))

(defun phr-windmove-right()
  (interactive)
  (condition-case nil (windmove-right)
    (error (split-window-horizontally))))

;; open loaded config file
(defun phr-open-loaded-config()
  (interactive)
  (find-file (nth 2 command-line-args)))

;=-=-=-=-=-=-=-=-=-=
;;;;; PACKAGES ;;;;;
;=-=-=-=-=-=-=-=-=-=

;; Packages Init
(setq package-archives '(("melpa" . "http://melpa.org/packages/")
			 ("org" . "https://orgmode.org/elpa/")
			 ("elpa" . "https://elpa.gnu.org/packages/")))
(package-initialize)
(when (not package-archive-contents)
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

;; Ivy
(use-package ivy
  :diminish
  :bind (
	 :map ivy-minibuffer-map
	      ("TAB" . ivy-alt-done)
	      ("ENTER" . ivy-immediate-done)
	      :map ivy-switch-buffer-map
	      ("TAB" . ivy-done)
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
  :custom ((doom-modeline-height 8)))

;; Auto Complete
(use-package auto-complete)
(require 'auto-complete)
(require 'auto-complete-config)
(ac-config-default)

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

;; Magit (C-x g)
(defadvice server-ensure-safe-dir (around
                                   my-around-server-ensure-safe-dir
                                   activate)
  "Ignores any errors raised from (setq )erver-ensure-safe-dir"
  (ignore-errors ad-do-it))

(use-package magit
  :ensure t)

;; General Key Bindings
(use-package general)

;=-=-=-=-=-=-=-=-=-=-=-=
;;;;; KEYBINDINGS ;;;;;;
;=-=-=-=-=-=-=-=-=-=-=-=

;; GENERAL
(require 'general)

;; General: Global
(general-define-key
 "M-x" 'counsel-M-x
 "C-s" 'counsel-grep-or-swiper
 "M-<up>" 'previous-buffer
 "M-<down>" 'next-buffer
 "M-<left>" 'phr-windmove-left
 "M-<right>" 'phr-windmove-right
 "C-d" 'kill-line
 "C-q" 'kill-ring-save
 "C-f" 'yank
 "M-w" 'switch-to-buffer
 "M-k" 'kill-this-buffer
 "C-<f5>" 'compile
 "<f5>" 'recompile
 "M-," 'previous-error
 "M-." 'next-error
 "M-q" 'quoted-insert
 "M-[" 'backward-sexp
 "M-]" 'forward-sexp
 "M-j" 'imenu
 "M-g" 'goto-line
 "C-x <f12>" 'phr-open-loaded-config
 )

;; General: Mode
; org-mode
(general-def org-mode-map
 "C-c C-q" 'counsel-org-tag
 )

; c mode
(general-def c-mode-base-map
  "C-d" 'kill-line
  "M-q" 'quoted-insert
  )

; custom c-style functions
(define-key global-map [f8] 'phr-replace-string)
(define-key c++-mode-map [f12] 'phr-find-corresponding-file)
(define-key c++-mode-map [M-f12] 'phr-find-corresponding-file-other-window)

; Tab
(define-key c++-mode-map [S-tab] 'indent-for-tab-command)
(define-key c++-mode-map [C-tab] 'indent-region)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(general magit corfu smartparens yasnippet-snippets yasnippet auto-complete doom-modeline all-the-icons ivy-rich helpful which-key rainbow-delimiters counsel use-package)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
