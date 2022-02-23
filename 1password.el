;;; 1password.el --- Integrate 1password CLI tools with Emacs -*- coding: utf-8; lexical-binding: t; -*-
;;
;; Filename: 1password.el
;; Description:
;; Author: Renat Galimov
;; Maintainer:
;; Created: Mon Feb 21 12:38:39 2022 (+0300)
;; Version: 0.0.1
;; Package-Requires: ((emacs "24.4") (subr-x))
;; Last-Updated:
;;           By:
;;     Update #: 69
;; URL:
;; Doc URL:
;; Keywords:
;; Compatibility:
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Commentary:
;; Emacs-1password, that allows you to use your 1password password inside the Emacs environment.
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Change Log:
;;
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

(require 'subr-x)

(defgroup op nil
  "Emacs integration with 1password CLI tools."
  :tag "One Password"
  :group 'external)

(defcustom op-default-account "my"
  "The account to sign in by default."
  :group 'op
  :package-version '(op . "0.0.1")
  :type '(string :tag "Account"))

(defcustom op-default-sign-in-address ""
  "The 1password server address."
  :group 'op
  :package-version '(op . "0.0.1")
  :type '(string :tag "Default sign-in address"))

(defcustom op-default-account ""
  "The 1password server address."
  :group 'op
  :package-version '(op . "0.0.1")
  :type '(string :tag "Default account to sign into"))


;;;###autoload
(defun op-signin (&optional account address)
  "Sign in into the 1password ADDRESS with ACCOUNT.

This will set OP_SESSION_* variable in Emacs env."
  (interactive)
  (let ((password (read-passwd "Enter your 1password password: ")))
    (with-temp-buffer
      (insert password)
      (let* ((account (or account op-default-account))
             (address (or address op-default-sign-in-address))
             (arguments (seq-filter (lambda (input) (and (stringp input) (not (string-blank-p input)))) `(,address ,account)))
             (exit-code (apply #'call-process-region (point-min) (point-max) "op" t t nil "signin" arguments)))
        (when (not (= exit-code 0))
          (clone-buffer "*op output*" t)
          (error "Command 'op' exited with non 0 error code"))
        (goto-char (point-min))
        (when (not (re-search-forward "^export \\([A-Za-z0-9_]+\\)=[\"']\\(.*\\)[\"']" nil t))
          (clone-buffer "*op output*" t)
          (error "Cannot find session settings in op output"))
        (setenv (match-string 1) (match-string 2))))))

(provide 'op)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 1password.el ends here
