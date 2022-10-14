;;; package-config.el --- Setup my packages

;;; Commentary:
;; 

(require 'use-package)

;;; Code:

(setq context "work")

(if (string-equal context "work")
    (setup-work-packages)
  (setup-home-packages))


(defun setup-work-packages ()
  "Set up stuff I use at work."
  (use-package evil
    :ensure t
    )

  
  
  )

(defun setup-home-packages ()
  "Set up stuff I use at home."
  (use-package evil
    :ensure t
    )
  )



  

(provide 'package-config)

;;; package-config.el ends here
