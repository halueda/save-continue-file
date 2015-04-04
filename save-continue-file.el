;;;
;;; continue-file
;;;
;;;
;;; save filenames and restore from it.
;;;

(defvar continue-file "~/.continue.el"
  "*filename of continue-file"
  )

(defun old-save-continue-file ()
  (interactive)
  (set-buffer (generate-new-buffer continue-file))
  (insert (format "(mapcar 'find-file '%S)\n" 
		  (nreverse (delq nil (mapcar 'buffer-file-name (buffer-list))))))
  (write-file continue-file)
  (kill-buffer (current-buffer))
  )


(defun old2-save-continue-file ()
  (interactive)
  (save-some-buffers t)
  (let ((l (reverse (buffer-list)))
	(continue-buf (generate-new-buffer continue-file))
	buf
	file)
    (set-buffer continue-buf)
    (while l
      (setq buf (car l)
	    file (buffer-file-name buf))
      (if (continue-file-no-save-p file)
	  (insert (format "(find-file %S)\n (goto-char %d)\n"
			  file
			  (save-excursion
			    (set-buffer buf)
			    (point))))
	)
      (setq l (cdr l))
      )
    (write-file continue-file)
    (kill-buffer continue-buf)
    )
  )

(defun save-continue-file ()
  "backup version not tested"
  (interactive)
  (save-some-buffers t)
  (save-excursion
    (let ((cf-visited (get-file-buffer continue-file))
	  (continue-buf (find-file continue-file))
	  ;; never save continue-file itself because 
	  ;; during loading, (goto-char) changes the (point) and get into the infinite loop
	  (l (reverse (cdr (buffer-list))))
	  buf
	  file
	  history-files
	  (make-backup-files t)
	  (version-control t)
	  (kept-new-versions 10)
	  (delete-old-versions t)
	  )
      (set-buffer continue-buf)
      (erase-buffer)
      (while l
	(setq buf (car l)
	      file (save-continue-buffer-file-name buf))
	(if (and file
		 (not (continue-file-no-save-p file))
		 )
	    (progn
	      (insert (format "(find-file %S)\n (goto-char %d)\n"
			      file
			      (save-excursion
				(set-buffer buf)
				(point))))
	      (setq history-files (cons file history-files))
	      )
	  )
	(setq l (cdr l))
	)
      (insert "(add-hook 'kill-emacs-hook 'save-continue-file)\n")
      ; ここに visit-file の mini-buffer用の file-name-history 向けに、上のfileとして保存したリストを設定する
      (insert (format "(setq file-name-history '%S)\n" history-files))
      ; save-continue-file hook is started only when loaded!
      (save-buffer '(3))
      (if cf-visited
	  (revert-buffer t t)
	(kill-buffer continue-buf)
	)
      )
    )
  )

(defun save-continue-buffer-file-name (buf)
  (or (buffer-file-name buf)
      (save-excursion
	(set-buffer buf)
	(and (boundp 'list-buffers-directory)
			   list-buffers-directory))))


(defun restore-continue-file ()
  (if (file-readable-p continue-file)
      (progn
	(load-file continue-file)
	(add-hook 'kill-emacs-hook
		  'save-continue-file)
	)
    )
)

(defun continue-file-no-save-p (file)
  (cond
   ((null file)
    nil)
   ((string-match continue-file-no-save-regexp file)
    file)
   (t
    nil)))

(defvar continue-file-no-save-regexp "^/[-a-zA-Z0-9_.@]*:")
