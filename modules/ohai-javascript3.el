;;; -*- lexical-binding: t -*-
;;; ohai-javascript.el --- Everybody's favourite personal hell.

;; Copyright (C) 2015 Bodil Stokke

;; Author: Bodil Stokke <bodil@bodil.org>

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Code:

(require 'ohai-package)
(require 'ohai-lib)

;; If npm is installed, add its local prefix to the executable
;; search path, which helps Emacs find linters etc.
;; This isn't Windows compatible, but then neither is npm, really.
(-when-let (npm-prefix (ohai/exec-if-exec "npm" "config get prefix"))
  (setenv "PATH" (concat npm-prefix "/bin:" (getenv "PATH"))))

;; Install js3-mode, which improves on Emacs's default JS mode
;; tremendously.
(package-require 'js3-mode)
(add-to-list 'auto-mode-alist '("\\.js$" . js3-mode))
(add-to-list 'auto-mode-alist '("\\.es6\\'" . js3-mode))
(add-to-list 'auto-mode-alist '("\\.ejs\\'" . js3-mode))

;; But for JSON files, it's better to stick with plain old js-mode.
; I'll try living dangerously...
(add-to-list 'auto-mode-alist '("\\.json$" . js3-mode))

;; Configure js2-mode good.
(setq-default
 js3-mode-indent-ignore-first-tab t
 js3-strict-inconsistent-return-warning nil
 js3-global-externs
 '("module" "require" "__dirname" "process" "console" "JSON" "$" "_"))
 ;; js2-show-parse-errors nil
 ;; js2-strict-var-hides-function-arg-warning nil
 ;; js2-strict-missing-semi-warning nil
 ;; js2-strict-trailing-comma-warning nil
 ;; js2-strict-cond-assign-warning nil
 ;; js2-strict-var-redeclaration-warning nil

;; Use Tern for smarter JS.
(package-require 'tern)
(add-hook 'js3-mode-hook (lambda () (tern-mode t)))

;; Locate the Tern binary by querying the system search path, which
;; should now include the local npm prefix.
(setq tern-command (list (or (ohai/resolve-exec "tern") "tern")))

;; Setup Tern as an autocomplete source.
(with-eval-after-load "company"
  (package-require 'company-tern)
  (require 'company-tern)
  (add-to-list 'company-backends 'company-tern))

;; Leverage js3-mode to get some refactoring support through js3-refactor.
;(package-require 'js3-refactor)
(add-hook 'js3-mode-hook
          (lambda ()
            (js3r-add-keybindings-with-prefix "C-c C-m")))



(provide 'ohai-javascript3)
