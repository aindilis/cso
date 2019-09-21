;;; cso.el --- CSO access functions

;; Copyright (C) 2006  Free Software Foundation, Inc.

;; Author: Jason Sayne <jasayne@frdcsa>
;; Keywords: 

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;;

(global-set-key "\C-crc" 'cso-lookup-a)
(global-set-key "\C-crC" 'cso-lookup-n)
(global-set-key "\C-crero" 'cso-open-cso-program-file)

;; Have a way to figure out which functions have been defined by the
;; frdcsa, such as emacs lisp, perl and prolog ones.

;;;;;;;;;;;;;;;;;;

(defun cso-function (&optional function-name)
 ""
 (interactive)
 (kmax-not-yet-implemented))

(define-derived-mode cso-function-mode
 emacs-lisp-mode "CSO-Function"
 "Major mode for viewing function KB in CSO.
\\{emacs-lisp-mode-map}"
 (setq case-fold-search nil)

 (define-key cso-function-mode-map "\C-csos" 'cso-function-search)
 (define-key cso-function-mode-map "\C-csor" 'cso-function-render-page)

 ;; (setq font-lock-defaults
 ;;  '(formalog-prolog-font-lock-keywords nil nil ((?_ . "w"))))

 ;; (re-font-lock)
 )

(defun cso-function-render-page ()
 ""
 (interactive)

 ;; buffer-local function-kb
 ;; query the function-kb for it's name etc

 ;; (clear the page)

 ;; (formalog-query ())

 ;; what kind of function it is

 ;; in what context is it found: i.e. an emacs function?  a shell command, etc.

 ;; (have the planning ontology, operational/denotational/axiomatic etc semantics for it)

 ;; have concomitant grammars related to it

 ;; have observations about the preconditions and effects of running the function

 ;; other IAEC/Cyc/FLP/LogicMoo/Perform info about it

 )

;;;;;;;;;;;;;;;;;;

(defun cso-function-search ()
 ""
 (interactive)
 (kmax-not-yet-implemented))

(define-derived-mode cso-function-search-mode
 emacs-lisp-mode "CSO-Function-Search"
 "Major mode for viewing function KB in CSO.
\\{emacs-lisp-mode-map}"
 (setq case-fold-search nil)

 (define-key cso-function-mode-map (kbd "TAB") 'formalog-complete-or-tab)
 (define-key cso-function-mode-map [C-tab] 'flp-complete-or-tab)

 ;; (setq font-lock-defaults
 ;;  '(formalog-prolog-font-lock-keywords nil nil ((?_ . "w"))))

 ;; (re-font-lock)
 )

(defun cso-lookup-a ()
 "Lookup file underpoint as part of either current package or all packages."
 (interactive)
 (let* ((system
	 (thing-at-point 'symbol))
	(command
	 (concat
	  "rxvt -geometry 179x66+0+34 -e /var/lib/myfrdcsa/codebases/internal/cso/cso.sh --mysql -a " system " &")))
  (if system
   (progn
    (message command)
    (shell-command command))
   (message "No system at point"))))

(defun cso-lookup-n ()
 "Lookup file underpoint as part of either current package or all packages."
 (interactive)
 (let* ((system
	 (thing-at-point 'symbol))
	(command
	 (concat
	  "rxvt -geometry 179x66+0+34 -e /var/lib/myfrdcsa/codebases/internal/cso/cso.sh --mysql -n " system " &")))
  (if system
   (progn
    (message command)
    (shell-command command))
   (message "No system at point"))))

(defun cso-open-cso-program-file ()
 ""
 (interactive)
 (ffap "/var/lib/myfrdcsa/codebases/internal/cso/comprehensive-software-ontology/cso.pl"))

;;; Code:

;; (defun cso-edit-ontology ()
;;  ""
;;  (interactive)
;;  (ffap ""))

(provide 'cso)
;;; cso.el ends here
