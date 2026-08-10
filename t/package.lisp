;;;; t/package.lisp — test package for cl-cc-mir

(defpackage :cl-cc-mir/test
  (:use :cl)
  (:import-from :cl-weave
                :describe-sequential
                :it
                :expect))
