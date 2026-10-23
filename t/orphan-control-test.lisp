;;;; t/orphan-control-test.lisp — intentionally unregistered control test
;;;;
;;;; This valid test source is deliberately absent from ASDF component lists.

(in-package :cl-cc-mir/test)

(describe-sequential "cl-cc-mir dependency closure"
  (it "loads without any other cl-cc package present"
    (dolist (name '("CL-CC/VM" "CL-CC/AST" "CL-CC/IR" "CL-CC/COMPILE"
                    "CL-CC/OPTIMIZE" "CL-CC/BOOTSTRAP" "CL-CC/RUNTIME"))
      (expect (find-package name) :to-be nil))))
