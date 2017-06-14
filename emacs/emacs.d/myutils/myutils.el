;;; package --- Misc functions I need
;;; Commentary:
;;; Code:
(defvar search-buffer "**SEARCH**"
  "Buffer to show custom search results in.")

(defun my-search (term)
  (interactive "sSearch Term: ")
  (let
      ((buf (get-buffer-create search-buffer))
       (pyfiles "*.py")
       (project-root "/home/lee/src/rdrf"))
    
  (set-buffer buf)
  (erase-buffer)
  (insert (concat "search for " term " will go here"))

  (rgrep term pyfiles project-root)
  (display-buffer buf)))


(defun kill-buffers ()
  (interactive)
  (mapcar 'kill-buffer (buffer-list)))


(defun kill-other-buffers ()
  (interactive)
  (mapcar 'kill-buffer (delq  (current-buffer) (buffer-list))))


(defun rdrf-search (s)
  (interactive "sSearch term: ")
  (let ((pattern (concat ".*" s ".*")))
    (progn 
     (grep-compute-defaults)
     (rgrep  pattern "*.py" "~/src/rdrf"))))


(defun wrap-region-with-trans (start end)
  (interactive "r")
  (let* ((text (buffer-substring-no-properties start end))
        (translated (concat "{% trans  \"" text "\" %}")))
  (save-excursion
      (delete-region start end)
      (goto-char start)
      (insert translated))))

(defun wrap-region-with-gettext (start end)
  (interactive "r")
  (let* ((text (buffer-substring-no-properties start end))
        (translated (concat "gettext(" text  ")")))
  (save-excursion
      (delete-region start end)
      (goto-char start)
      (insert translated))))


(provide 'myutils)
;;; myutils.el ends here

