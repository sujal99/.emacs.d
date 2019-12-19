;;; init-mu4e.el --- -*- lexical-binding: t -*-
;;
;; Filename: init-mu4e.el
;; Description: Initialize mu4e
;; Author: Mingde (Matthew) Zeng
;; Copyright (C) 2019 Mingde (Matthew) Zeng
;; Created: Mon Dec  2 15:17:14 2019 (-0500)
;; Version: 2.0.0
;; Package-Requires: (mu4e)
;; Last-Updated:
;;           By:
;; URL: https://github.com/MatthewZMD/.emacs.d
;; Keywords: M-EMACS .emacs.d mu mu4e
;; Compatibility: emacs-version >= 26.1
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Commentary:
;;
;; This initializes mu4e for Email clients in Emacs
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or (at
;; your option) any later version.
;;
;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Code:

;; Mu4ePac
(use-package mu4e
  :ensure nil
  :commands (mu4e)
  :init
  (use-package mu4e-alert
    :defer t
    :config
    (when (executable-find "notify-send")
      (mu4e-alert-set-default-style 'libnotify))
    (add-hook 'after-init-hook #'mu4e-alert-enable-notifications)
    (add-hook 'after-init-hook #'mu4e-alert-enable-mode-line-display))
  (use-package mu4e-overview :defer t)
  :bind ("M-z m" . mu4e)
  :custom
  (mu4e-maildir (expand-file-name "~/Maildir"))
  (mu4e-get-mail-command "mbsync -c ~/.emacs.d/mu4e/.mbsyncrc -a")
  (mu4e-view-prefer-html t)
  (mu4e-update-interval 180)
  (mu4e-headers-auto-update t)
  (mu4e-compose-signature-auto-include nil)
  (mu4e-compose-format-flowed t)
  (mu4e-view-show-images t)
  (mu4e-sent-messages-behavior 'delete)
  (mu4e-change-filenames-when-moving t) ; work better for mbsync
  (mu4e-attachment-dir "~/Downloads")
  (message-kill-buffer-on-exit t)
  (mu4e-compose-dont-reply-to-self t)
  (mu4e-view-show-addresses t)
  (mu4e-confirm-quit nil)
  (mu4e-use-fancy-chars t)
  :config
  (run-with-timer 0 60 (lambda () (mu4e-update-mail-and-index t)))
  (add-to-list 'mu4e-view-actions
               '("ViewInBrowser" . mu4e-action-view-in-browser) t)
  (add-hook 'mu4e-view-mode-hook #'visual-line-mode)
  ;; from https://www.reddit.com/r/emacs/comments/bfsck6/mu4e_for_dummies/elgoumx
  (add-hook 'mu4e-headers-mode-hook
            (defun my/mu4e-change-headers ()
	          (interactive)
	          (setq mu4e-headers-fields
	                `((:human-date . 25) ;; alternatively, use :date
		              (:flags . 6)
		              (:from . 22)
		              (:thread-subject . ,(- (window-body-width) 70)) ;; alternatively, use :subject
		              (:size . 7)))))
  ;; spell check
  (add-hook 'mu4e-compose-mode-hook
            (defun my-do-compose-stuff ()
              "My settings for message composition."
              (visual-line-mode)
              (use-hard-newlines -1)
              (flyspell-mode)))
  (add-hook 'mu4e-view-mode-hook
            (lambda() ;; try to emulate some of the eww key-bindings
              (local-set-key (kbd "<tab>") 'shr-next-link)
              (local-set-key (kbd "<backtab>") 'shr-previous-link)))
  (setq mu4e-contexts
        (list
         (make-mu4e-context
          :name "gmail"
          :enter-func (lambda () (mu4e-message "Entering context gmail"))
          :leave-func (lambda () (mu4e-message "Leaving context gmail"))
          :match-func
          (lambda (msg)
		    (when msg
		      (mu4e-message-contact-field-matches
		       msg '(:from :to :cc :bcc) user-mail-address))) ; Set to your email address
          :vars '((mu4e-refile-folder "/gmail/Archive")
	              (mu4e-sent-folder . "/gmail/[email].Sent Mail")
	              (mu4e-drafts-folder . "/gmail/[email].Drafts")
	              (mu4e-trash-folder . "/gmail/[email].Trash")
	              (mu4e-compose-signature . user-full-name)
	              (mu4e-compose-format-flowed . t)
	              (smtpmail-queue-dir . "~/Maildir/gmail/queue/cur")
	              (message-send-mail-function . smtpmail-send-it)
	              (smtpmail-smtp-user . "matthewzmd") ; Set to your username
	              (smtpmail-starttls-credentials . (("smtp.gmail.com" 587 nil nil)))
	              (smtpmail-auth-credentials . (expand-file-name "~/.authinfo.gpg"))
	              (smtpmail-default-smtp-server . "smtp.gmail.com")
	              (smtpmail-smtp-server . "smtp.gmail.com")
	              (smtpmail-smtp-service . 587)
	              (smtpmail-debug-info . t)
	              (smtpmail-debug-verbose . t)
	              (mu4e-maildir-shortcuts . ( ("/gmail/INBOX"            . ?i)
					                          ("/gmail/[email].Sent Mail" . ?s)
					                          ("/gmail/[email].Trash"       . ?t)
					                          ("/gmail/[email].All Mail"  . ?a)
					                          ("/gmail/[email].Starred"   . ?r)
					                          ("/gmail/[email].Drafts"    . ?d))))))))
;; -Mu4ePac

(provide 'init-mu4e)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; init-mu4e.el ends here