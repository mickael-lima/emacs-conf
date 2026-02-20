(setq custom-file (locate-user-emacs-file "custom.el"))
(load custom-file :no-error-if-file-is-missing)

;; Loading use-package
(require 'package)
(add-to-list 'package-archives '("gnu"   . "https://elpa.gnu.org/packages/"))

(package-initialize)

;; Configuring use-package for emacs < 29
(when (< emacs-major-version 29)
  (unless (package-installed-p 'use-package)
    (unless package-archives-contents
      (package-refresh-contents))
    (package-install 'use-package)))

;; Hide dev warnings when installing a new package
(add-to-list 'display-buffer-alist
             '("\\`\\*\\(Warnings\\|Compile-Log\\)\\*\\'"
               (display-buffer-no-window)
               (allow-no-window . t)))

;; Font
(set-face-attribute 'default nil :font "Aporetic Sans Mono-12")

(use-package ef-themes
  :ensure t
  :config
  (load-theme 'ef-orange :no-confirm-loading))
