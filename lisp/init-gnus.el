(require 'gnus)

(setq gnus-directory "~/.gnus.d"
      gnus-home-directory "~/.gnus.d"
      message-directory "~/.gnus.d/mail"
      message-auto-save-directory "~/.gnus.d/drafts"
      nnml-directory "~/.gnus.d/nnml-mail"
      nnfolder-directory "~/.gnus.d/mail/archive"
      nnfolder-active-file "~/.gnus.d/mail/archive/active"
      gnus-article-save-directory "~/.gnus.d/saved"
      gnus-kill-files-directory "~/.gnus.d/scores"
      gnus-cache-directory "~/.gnus.d/cache"
      gnus-startup-file (nnheader-concat gnus-home-directory "newsrc")
      gnus-init-file (nnheader-concat gnus-home-directory "gnus")
      gnus-save-newsrc-file nil
      gnus-read-newsrc-file nil)

(defun km/sync-mail ()
  (interactive)
  (let ((bufname (get-buffer-create "*Mail sync*"))
        (default-directory "~"))
    (with-current-buffer bufname
      (view-mode 1)
      (goto-char (point-max)))
    (display-buffer bufname)
    (start-process "mail sync" bufname km/sync-mail-cmd)))

(defvar km/sync-mail-cmd "~/bin/sync-mail.sh"
  "Run sync mail script.")

;; http://www.emacswiki.org/emacs/GnusSync
(defun gnus-grace-exit-before-kill-emacs ()
  (if (and (fboundp 'gnus-alive-p)
           (gnus-alive-p))
      (let ((noninteractive t))
        (gnus-group-exit))))
(add-hook 'kill-emacs-hook 'gnus-grace-exit-before-kill-emacs)

(setq imap-shell-program "/usr/lib/dovecot/imap -c ~/.dovecotrc"
      gnus-select-method '(nnimap "dov" (nnimap-stream shell))
      gnus-secondary-select-methods '((nntp "news.gmane.org"))
      message-send-mail-function 'message-send-mail-with-sendmail
      sendmail-program "/usr/bin/msmtp"
      message-sendmail-envelope-from 'header
      gnus-gcc-mark-as-read t
      message-citation-line-function 'message-insert-formatted-citation-line
      message-citation-line-format "On %D %R, %N wrote:"
      message-kill-buffer-on-exit t
      gnus-group-list-inactive-groups nil
      gnus-topic-display-empty-topics nil
      gnus-visible-headers '("^From" "^Subject" "^Date" "^To" "^Cc" "^User-Agent")
      gnus-confirm-mail-reply-to-news t
      mm-discouraged-alternatives '("text/html" "text/richtext")
      footnote-section-tag "")

;; Use for rss too specific to add to gwene.
(require 'nnrss)

;; Start in topic mode.
(add-hook 'gnus-group-mode-hook 'gnus-topic-mode)

(add-hook 'message-mode-hook
          '(lambda ()
             (flyspell-mode 1)))

(setq gnus-summary-line-format "%U%R %&user-date;%-20= %-15,15f  %B %S \n"
      gnus-sum-thread-tree-indent "  "
      gnus-sum-thread-tree-root "."
      gnus-sum-thread-tree-false-root "o "
      gnus-sum-thread-tree-single-indent ""
      gnus-sum-thread-tree-leaf-with-other "+-> "
      gnus-sum-thread-tree-vertical "| "
      gnus-sum-thread-tree-single-leaf "`-> ")

(setq gnus-thread-sort-functions
      '(gnus-thread-sort-by-number gnus-thread-sort-by-most-recent-date))

(defun km/follow-gwene-link ()
  "Follow link at bottom of gwene message"
  (interactive)
  (km/gnus-end-of-article-buffer)
  (search-backward "Link")
  (widget-button-press (point)))

(define-key gnus-summary-mode-map
  (kbd "C-c j") 'km/follow-gwene-link)
(define-key gnus-article-mode-map
  (kbd "C-c j") 'km/follow-gwene-link)

(defun km/gnus-open-github-patch ()
  "Open patch from github email.
A new buffer with the patch contents is opened in another window."
  (interactive)
  (km/gnus-end-of-article-buffer)
  (search-backward "patch")
  (let ((url (thing-at-point 'url))
        (patch-buffer (generate-new-buffer "*gnus-github-patch*")))
    (switch-to-buffer-other-window patch-buffer)
    (url-insert-file-contents url)
    (diff-mode)
    (view-mode 1)))

(defun km/gnus-end-of-article-buffer ()
  "Move point to the end of the article buffer."
  ;; The next 3 lines are from `gnus-summary-widget-forward'.
  (gnus-summary-select-article)
  (gnus-configure-windows 'article)
  (select-window (gnus-get-buffer-window gnus-article-buffer))
  (goto-char (point-max)))

(require 'notmuch)
(require 'org-gnus)

(define-key gnus-group-mode-map "GG" 'notmuch-search)
;; http://roland.entierement.nu/blog/2010/09/08/gnus-dovecot-offlineimap-search-a-howto.html
(defun km/notmuch-shortcut ()
  (define-key gnus-group-mode-map "GG" 'notmuch-search))

(defun km/notmuch-file-to-group (file)
  "Calculate the Gnus group name from the given file name."
  (let ((group (file-name-directory (directory-file-name (file-name-directory file)))))
    (setq group (replace-regexp-in-string ".*/mail/" "nnimap+dov:" group))
    (setq group (replace-regexp-in-string "/$" "" group))
    (if (string-match ":$" group)
        (concat group "INBOX")
      (replace-regexp-in-string ":\\." ":" group))))

(defun km/notmuch-goto-message-in-gnus ()
  "Open a summary buffer containing the current notmuch article."
  (interactive)
  (let ((group (km/notmuch-file-to-group (notmuch-show-get-filename)))
        (message-id (replace-regexp-in-string
                     "^id:" "" (notmuch-show-get-message-id))))
    (setq message-id (replace-regexp-in-string "\"" "" message-id))
    (if (and group message-id)
        (progn
    (switch-to-buffer "*Group*")
    (org-gnus-follow-link group message-id))
      (message "Couldn't get relevant infos for switching to Gnus."))))

(define-key notmuch-show-mode-map (kbd "C-c C-c") 'km/notmuch-goto-message-in-gnus)
(add-hook 'gnus-group-mode-hook 'km/notmuch-shortcut)

(setq notmuch-fcc-dirs nil)

;; Modified from
;; http://emacs-fu.blogspot.com/2008/12/some-simple-tricks-boxquote-footnote.html.
(defun km/snip-mail-quote (beg end &optional quote-char no-number)
  "Replace region lines with \"[n lines ...]\".

The default QUOTE-CHAR is \">\". Text following the snipped lines
is placed on a new line and the resulting paragraph is filled. If
NO-NUMBER is non-nil, the number of lines is not added."
  (interactive "r")
  (let ((nlines (count-lines beg end))
        (quote-char (or quote-char ">")))
    (delete-region beg end)
    (if no-number
        (insert (format "[...]"))
      (insert (format "[%d line%s ...]" nlines (if (= 1 nlines) "" "s"))))
    (search-backward "[")
    (unless (bolp)
      (newline))
    (search-forward "]")
    (unless (eolp)
      (newline)
      (insert quote-char)
      (just-one-space)
      (fill-paragraph))))

(define-key message-mode-map
  (kbd "C-c m s") 'km/snip-mail-quote)

;; Without reporting the number of lines
(define-key message-mode-map
  (kbd "C-c m S") '(lambda (beg end)
                     (interactive "r")
                     (km/snip-mail-quote beg end nil t)))

(add-hook 'gnus-summary-mode-hook
          (lambda ()
            (gnus-define-keys gnus-summary-mode-map
              "j" gnus-summary-next-unread-article
              ";" gnus-summary-universal-argument  ;; mutt's tag
              "e" gnus-summary-scroll-up)))

(add-hook 'gnus-group-mode-hook
          (lambda ()
            (gnus-define-keys gnus-group-mode-map
              "e" gnus-topic-select-group)))

(add-hook 'gnus-article-mode-hook
          (lambda ()
            (gnus-define-keys gnus-article-mode-map
              "e" shr-browse-url)))

(defadvice gnus (around gnus-fullscreen activate)
  (window-configuration-to-register :gnus-fullscreen)
  ad-do-it
  (delete-other-windows))
(defadvice gnus-group-exit (around gnus-restore-screen activate)
  ad-do-it
  (jump-to-register :gnus-fullscreen))

(provide 'init-gnus)