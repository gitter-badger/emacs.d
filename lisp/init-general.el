(setq echo-keystrokes 0.1
      use-dialog-box nil
      visible-bell t
      shell-command-switch "-ic"
      x-select-enable-clipboard t ; Share clipboard with system.
      x-select-enable-primary t
      ispell-program-name "aspell"
      whitespace-style '(spaces tabs newline space-mark tab-mark newline-mark)
      tramp-default-method "ssh"
      sentence-end-double-space nil
      enable-recursive-minibuffers t
      browse-url-browser-function 'browse-url-generic
      browse-url-generic-program "firefox")

(setq-default indicate-empty-lines t)

(show-paren-mode t)

(defalias 'yes-or-no-p 'y-or-n-p)

;; Set location of custom.el.
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

(global-auto-revert-mode t)

;; Make scripts executable at save.
(add-hook 'after-save-hook
  'executable-make-buffer-file-executable-if-script-p)

(transient-mark-mode -1)

(put 'narrow-to-region 'disabled nil)
(put 'narrow-to-page 'disabled nil)
(put 'set-goal-column 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)

(require-package 'key-chord)
(key-chord-mode 1)

(global-set-key (kbd "C-h :") 'find-function)

;; Disable `suspend-frame' binding.
(global-unset-key (kbd "C-x C-z"))

;; Avoid shift key for `backward-paragraph' and `forward-paragraph'.
(global-unset-key (kbd "M-}"))
(global-set-key (kbd "M-]") 'forward-paragraph)
(global-unset-key (kbd "M-{"))
(global-set-key (kbd "M-[") 'backward-paragraph)

(global-set-key (kbd "C-c j") 'imenu)

;; Taken from
;; http://milkbox.net/note/single-file-master-emacs-configuration/.
(defmacro after (mode &rest body)
  "`eval-after-load' MODE evaluate BODY."
  (declare (indent defun))
  `(eval-after-load ,mode
     '(progn ,@body)))

(provide 'init-general)
