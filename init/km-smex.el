;; http://www.juanrubio.me/2011/11/emacs-smex-m-x-do-not-like-typing/
(require 'smex)
(smex-initialize)
;; smex bound in km-evil.ex (,x)
(global-set-key (kbd "M-x") 'smex-major-mode-commands)
;; old M-x
(global-set-key (kbd "M-X") 'execute-extended-command)