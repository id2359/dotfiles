;;; peak-mode --- peak mode
;;; Commentary:
;;; Code:
(defun say-hi ()
  "Say hi."
  (message "hi"))

(defun say-bye ()
  "Blah."
  (message "bye"))

(defvar peak-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "\C-c p") 'say-hi)
    (define-key map (kbd "\C-c q") 'say-bye)
    map)
  "Keyboard map.")


(define-minor-mode peak-project-mode
  "Minor mode for the peak project"
  :lighter " peak-mode"
  :keymap peak-mode-map)




(provide 'peak-project-mode)
;;; peak-project-mode ends here
		        
