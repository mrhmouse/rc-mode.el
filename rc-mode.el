;; rc-mode, a major mode for the Plan 9 shell

(defun rc-intersperse (items sep)
  (if (null (cdr items))
      items
    (cons (car items)
          (cons sep (rc-intersperse (cdr items) sep)))))

(defun rc-join-string (strings sep)
  (apply #'concat (rc-intersperse strings sep)))

(setq rc-highlights
      `(("'[^']*'"
         . font-lock-string-face)
        
        ("#.*$"
         . font-lock-comment-face)
        
        (,(rc-join-string '("fn" "break"
                            "builtin" "cd"
                            "echo" "eval"
                            "exec" "exit"
                            "limit" "newpgrp"
                            "return" "shift"
                            "umask" "wait"
                            "whatis" "\\$#?\\*"
                            "\\$0" "\\$apids?"
                            "\\$bqstatus" "\\$cdpath"
                            "\\$history" "\\$home"
                            "\\$ifs" "\\$path" "\\$pid"
                            "\\$prompt" "\\$status"
                            "\\$version")
                          "\\|")
         . font-lock-builtin-face)
        
        (,(rc-join-string '("if" "while" "for" "else" "if not"
                            "switch"
                            "@" "=" "&" "&&" "\\^"
                            "|" ";"
                            "<<?" ">>?"
                            "\\(>>?\\|<<?\\||\\)\\[\\d+\\(=\\d+\\)\\]"
                            "||" "~")
                          "\\|")
         . font-lock-keyword-face)
        
        ("\\(?1:\\$#?\\$*\\w+\\)\\|\\(?1:\\w+\\)[[:space:]]*="
         1 font-lock-variable-name-face)

        ("!"
         . font-lock-negation-char-face)))

(defun rc-indent-line ()
  "Indent current line as Plan9 RC shell script"
  (interactive)
  (indent-line-to 
   (save-excursion
     (beginning-of-line)
     (cond
      ((bobp) 0)
      ((or (rc-looking-at-continuation)
           (rc-under-block-header))
       (+ (rc-previous-line-indentation) 2))
      ((rc-looking-at-block-end)
       (- (rc-previous-line-indentation) 2))
      (t (rc-previous-line-indentation))))))

(defun rc-looking-at-block-end ()
  (save-excursion
    (beginning-of-line)
    (looking-at "^[ \t]*}")))

(defun rc-looking-at-continuation ()
  (save-excursion
    (rc-previous-line)
    (looking-at ".*\\\\$")))

(defun rc-previous-line ()
  (forward-line -1)
  (beginning-of-line)
  (while (and (looking-at "^[ \t]*$")
              (not (bobp)))
    (forward-line -1)
    (beginning-of-line)))

(defun rc-under-block-header ()
  (save-excursion
    (rc-previous-line)
    (looking-at ".*{[ \t]*\\(#[^']*\\)?$")))

(defun rc-previous-line-indentation ()
  (save-excursion
    (rc-previous-line)
    (while (rc-looking-at-continuation)
      (previous-line))
    (current-indentation)))

(define-derived-mode rc-mode fundamental-mode
  (setq mode-name "plan9-rc")
  (setq font-lock-defaults '(rc-highlights))
  (setq indent-line-function 'rc-indent-line))

(add-to-list 'auto-mode-alist
             '("\\.rc\\'" . rc-mode))
