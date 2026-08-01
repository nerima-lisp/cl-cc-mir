;;;; cl-cc-target.asd -- ASDF entry point for target descriptors.

(asdf:defsystem :cl-cc-target
  :description "Target descriptors (target-desc API; absorbs calling-convention.lisp callers in Phase 3)"
  :author "takeokunn <bararararatty@gmail.com>"
  :maintainer "takeokunn <bararararatty@gmail.com>"
  :license "MIT"
  :homepage "https://github.com/nerima-lisp/cl-cc-mir"
  :bug-tracker "https://github.com/nerima-lisp/cl-cc-mir/issues"
  :source-control (:git "https://github.com/nerima-lisp/cl-cc-mir.git")
  :version "0.1.0"
  :depends-on ()
  :pathname "src"
  :serial t
  :components
  ((:file "target-package")
   (:file "target")))

(asdf:defsystem "cl-cc-target/test"
  :description "Module boundary tests for cl-cc-target"
  :author "takeokunn <bararararatty@gmail.com>"
  :license "MIT"
  :depends-on ("cl-cc-target" "cl-weave")
  :pathname "t"
  :serial t
  :components ((:file "target-package")
               (:file "target-boundary-test"))
  :perform (asdf:test-op (op system)
             (declare (ignore op system))
             (uiop:symbol-call :cl-weave :run-all-tests :pass-with-no-tests nil)))
