;;; nano-splash.el --- N Λ N O Splash -*- lexical-binding: t -*-
;; ---------------------------------------------------------------------
;; GNU Emacs / N Λ N O Splash
;; Copyright (C) 2020-2021 - N Λ N O developers 
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;; ---------------------------------------------------------------------
;; 
;; This file defines a splash screen
;;  - No logo, no modeline, no scrollbars
;;  - Any key / mouse click kills the splash screen
;;  - With emacs-mac (Mituharu), splash screen is faded out after .5 seconds
;;
;; Note: The screen is not shown if there are opened file buffers. For
;;       example, if you start emacs with a filename on the command
;;       line, the splash screen is not shown.

(require 'subr-x)
(require 'cl-lib)


(defgroup nano nil
  "N Λ N O")

(defgroup nano-splash nil
  "Splash screen" :group 'nano)

(defcustom nano-splash-title "GNU Emacs / N Λ N O"
  "Splash screen title"
  :type 'string :group 'nano-splash)

(defcustom nano-splash-subtitle "Emacs made simple"
  "Splash screen subtitle"
  :type 'string :group 'nano-splash)

(defcustom nano-splash-duration 1.5
  "Splash screen duration (in seconds)"
  :type 'float :group 'nano-splash)

(defun nano-splash-resize-h ()
  (let (window-configuration-change-hook)
    (with-current-buffer (get-buffer-create "*splash*")
      (with-silent-modifications
        (erase-buffer)
        (setq fill-column (round (window-body-width nil)))
        ;; Vertical padding to center
        (insert-char ?\n (+ (/ (round (- (window-body-height nil) 1))
                               2)
                            1))
        (insert (propertize nano-splash-title 'face 'nano-strong))
        (center-line)
        (insert "\n")
        (insert (propertize nano-splash-subtitle 'face 'nano-faded))
        (center-line)
        (goto-char 0)))))

(defun nano-splash ()
  "Nano Emacs splash screen"
  (let ((splash-buffer (get-buffer-create "*splash*")))
    (with-current-buffer splash-buffer
      ;; Hide modeline before window-body-height is computed
      (setq header-line-format nil)
      (setq mode-line-format nil)
      (setq cursor-type nil)
      (setq line-spacing 0)
      (nano-splash-resize-h)
      (read-only-mode t)
      (display-buffer-same-window splash-buffer nil)
      (run-with-idle-timer nano-splash-duration nil 'nano-splash-fade-out))))

(defun nano-splash-init-h ()
  (unless noninteractive
    (add-hook 'window-configuration-change-hook #'nano-splash-resize-h)
    (nano-splash)))

(defun nano-splash-fade-out ()
  "Fade out current frame for duration and goes to command-or-bufffer"
  (when (get-buffer "*splash*")
    (if (fboundp 'mac-start-animation)
        (mac-start-animation nil :type 'fade-out :duration 2))
    (kill-buffer "*splash*")))

(provide 'nano-splash)


