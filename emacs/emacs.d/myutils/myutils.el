(provide 'myutils)

(defvar search-buffer "**SEARCH**"
  "Buffer to show custom search results in")

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

	
  





  


