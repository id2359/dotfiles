(provide 'myutils)

(defvar search-buffer "**SEARCH**"
  "Buffer to show custom search results in")

(defun my-search (term)
  (interactive "sSearch Term: ")
  (let
      ((buf (get-buffer-create search-buffer)))
    
  (set-buffer buf)
  (erase-buffer)
  (insert (concat "search for " term " will go here"))
  (display-buffer buf)))






  


