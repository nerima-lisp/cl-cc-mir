;;;; t/target-package.lisp — test package for cl-cc-target

(defpackage :cl-cc-target/test
  (:use :cl)
  (:import-from :cl-weave
                :describe-sequential
                :it
                :expect))
