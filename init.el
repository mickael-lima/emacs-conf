(setq custom-file (locate-user-emacs-file "custom.el"))
(load custom-file :no-error-if-file-is-missing)

;; Loading use-package
(require 'package)
(add-to-list 'package-archives '("gnu"   . "https://elpa.gnu.org/packages/"))
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

(eval-when-compile
  (require 'use-package))

(setq use-package-always-ensure t)

;; Hide dev warnings when installing a new package
(add-to-list 'display-buffer-alist
             '("\\`\\*\\(Warnings\\|Compile-Log\\)\\*\\'"
               (display-buffer-no-window)
               (allow-no-window . t)))

;; Font
(set-face-attribute 'default nil :font "Aporetic Sans Mono-12")

;; Number line mode
(add-hook 'prog-mode-hook 'display-line-numbers-mode)
(add-hook 'text-mode-hook 'display-line-numbers-mode)
(add-hook 'conf-mode-hook 'display-line-numbers-mode)
(setq display-line-numbers-type 'relative)

;; whick-key is now embeded in emacs
(which-key-mode 1)

;; Remember and restore the last cursor location of opened files
(save-place-mode 1)

;; Revert buffers when the underlying file has changed
(global-auto-revert-mode 1)

;; Why this is not the default?
(setq delete-selection-mode t)

;; Ctrl + Backspace does not mess with my clipboard
(global-set-key (kbd "<C-backspace>") (lambda () 
					(interactive) 
					(delete-region (point) 
						       (progn (forward-word -1) (point)))))

;; Ask who is the master file in LaTeX-mode
(setq-default TeX-master nil)

;; Transparency bg, cool looking
(set-frame-parameter nil 'alpha-background 90)
(add-to-list 'default-frame-alist '(alpha-background . 90))

;; --- Packages ---
(use-package evil
  :ensure t
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  (evil-mode 1)
  
  :hook
  (conf-mode . turn-on-evil-mode)
  (prog-mode . turn-on-evil-mode)
  (text-mode . turn-on-evil-mode)

  :config
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)
  (evil-set-undo-system 'undo-redo)

  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :init
  (evil-collection-init))


;; AucTeX settings - from https://fmneto.com/2026/04/17/ensinando-latex-para-o-emacs/
(use-package tex
  :ensure auctex
  :defer t
  :hook ((LaTeX-mode . LaTeX-math-mode)
	 (LaTeX-mode . turn-on-reftex)
	 (LaTeX-mode . visual-line-mode)
	 (LaTeX-mode . outline-minor-mode)
	 (LaTeX-mode . TeX-source-correlate-mode)
	 (LaTeX-mode . (lambda ()
			 (setq-local TeX-command-default "LatexMk"))))
  :config
  (setq TeX-auto-save t
      TeX-parse-self t
      TeX-save-query nil
      TeX-PDF-mode t
      TeX-source-correlate-mode t
      TeX-source-correlate-method 'synctex
      TeX-source-correlate-start-server t))

(use-package company-auctex
  :after (company tex)
  :config
  (company-auctex-init))

(use-package pdf-tools
  :defer t
  :magic ("%PDF" . pdf-view-mode) ;; ensure DocView is not used
  :config
  (pdf-tools-install :no-query)
  (setq-default pdf-view-display-size 'fit-width)
  (define-key pdf-view-mode-map (kbd "C-s") 'isearch-forward))

(setq TeX-view-program-selection '((output-pdf "PDF Tools"))
      TeX-view-program-list '(("PDF Tools" TeX-pdf-tools-sync-view))
      TeX-source-correlate-start-server t)

(add-hook 'TeX-after-compilation-finished-functions
  #'TeX-revert-document-buffer)

(use-package reftex
  :defer t
  :hook (LaTeX-mode . turn-on-reftex)
  :config
  (setq reftex-plug-into-AUCTeX t
        reftex-save-parse-info t
        reftex-cite-prompt-optional-args t)

  (setq reftex-cite-format
        '((?c . "\\cite{%l}")
          (?p . "\\parencite{%l}")
          (?t . "\\textcite{%l}")
          (?f . "\\footcite{%l}")
          (?s . "\\supercite{%l}")
          (?a . "\\autocite{%l}"))))

;; syntax checker
(use-package flycheck
  :ensure t
  :init (global-flycheck-mode))

;; Enable Vertico.
(use-package vertico
  :ensure t
  :custom
  (vertico-scroll-margin 0) ;; Different scroll margin
  (vertico-resize nil) ;; Grow and shrink the Vertico minibuffer

  :init
  (vertico-mode))

(use-package corfu
  :ensure t
  
  :custom
  (corfu-cycle t)
  (corfu-preselect 'prompt)

  (corfu-auto t)
  (corfu-auto-delay 0.2)
  (corfu-auto-trigger ".") ;; Custom trigger characters
  (corfu-quit-no-match 'separator) ;; or t
  
  :init
  (global-corfu-mode))

;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :ensure t
  :init
  (savehist-mode))

;; Emacs minibuffer configurations.
(use-package emacs
  :custom
  (context-menu-mode t)
  (enable-recursive-minibuffers t)
  (read-extended-command-predicate #'command-completion-default-include-p)
  (tab-always-indent 'complete)
  (text-mode-ispell-word-completion nil)
  (read-extended-command-predicate #'command-completion-default-include-p)

  ;; Do not allow the cursor in the minibuffer prompt
  (minibuffer-prompt-properties
   '(read-only t cursor-intangible t face minibuffer-prompt)))
  
;; orderless completion style for corfu
(use-package orderless
  :ensure t
  :custom
  ;; (orderless-style-dispatchers '(orderless-affix-dispatch))
  ;; (orderless-component-separator #'orderless-escapable-split-on-space)
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion))))
  (completion-category-defaults nil)) ;; Disable defaults, use our settings)

(use-package magit
  :ensure t)

(use-package diff-hl
  :ensure t
  :hook (dired-mode . diff-hl-dired-mode)
  :init
  (global-diff-hl-mode 1)
  (diff-hl-flydiff-mode 1)
  (unless (display-graphic-p)
    (diff-hl-margin-mode 1)))

(use-package elcord
  :ensure t)

(use-package ef-themes
  :ensure t
  :init
  (load-theme 'ef-winter :noconfirm))

;; Dired custom config - https://github.com/daviwil/emacs-from-scratch/blob/8c302a79bf5700f6ef0279a3daeeb4123ae8bd59/Emacs.org#dired
(use-package dired
  :ensure nil
  :commands (dired dired-jump)
  :bind (("C-x C-j" . dired-jump))
  :custom ((dired-listing-switches "-agho --group-directories-first"))
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "h" 'dired-single-up-directory
    "l" 'dired-single-buffer))

(use-package dired-single)

(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode))
