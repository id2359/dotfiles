(setq data '((fred 23)
	     (harry 100)))


(assoc 'fred data)


(defmacro getkey (key data)
  `(assoc (quote ,key) ,data))


(getkey fred data)


(getkey harry data)
