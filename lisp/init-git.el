(add-to-list 'load-path "~/src/emacs/git-modes")
(add-to-list 'load-path "~/src/emacs/magit")
(require 'magit)

(autoload 'magit-blame-mode "magit-blame" nil t)

(require-package 'git-annex)
(require 'git-annex)

(setq git-annex-commit nil)

(add-hook 'magit-mode-hook 'turn-on-magit-annex)

(key-chord-define-global ",g" 'magit-status)

(define-key magit-popup-mode-map (kbd "SPC <t>") 'magit-invoke-popup-switch)
(define-key magit-popup-mode-map (kbd "SPC SPC <t>") 'magit-invoke-popup-option)

(defun km/magit-auto-commit ()
  "Commit all changes with \"auto\" commit message.
Useful for non-source code repos (e.g., Org mode note files)."
  (interactive)
  (magit-run-git "commit" "--all" "--message=auto"))

(defun km/magit-push-all ()
  "Push all branches."
  (interactive)
  (let ((remote (magit-read-remote "Remote")))
    (magit-run-git-async "push" "-v" remote "--all")))

(defun km/magit-log-all-branches (range &optional args)
  (interactive (magit-log-read-args t nil))
  (add-to-list 'args "--all")
  (magit-log-dwim range args))

(defun km/magit-checkout-local-tracking (remote-branch)
  "Create and checkout a local tracking branch for REMOTE-BRANCH.
\(git checkout -t REMOTE-BRANCH\)"
  (interactive
   (list (magit-completing-read "Remote branch"
                                (magit-list-remote-branch-names))))
  (magit-run-git "checkout" "-t" remote-branch))

(magit-define-popup-action 'magit-commit-popup
  ?u "Auto commit" 'km/magit-auto-commit)
(magit-define-popup-action 'magit-push-popup
  ?a "Push all" 'km/magit-push-all)
(magit-define-popup-action 'magit-log-popup
  ?a "All branches" 'km/magit-log-all-branches)
(magit-define-popup-action 'magit-branch-popup
  ?t "Local tracking" 'km/magit-checkout-local-tracking)

;; http://whattheemacsd.com/setup-magit.el-01.html
(defadvice magit-status (around magit-fullscreen activate)
  ad-do-it
  (delete-other-windows))

(setq magit-restore-window-configuration t
      magit-completing-read-function 'magit-ido-completing-read
      magit-popup-show-help-echo nil
      magit-popup-show-help-section nil
      magit-log-show-margin nil)

(setq vc-follow-symlinks t)

(provide 'init-git)
