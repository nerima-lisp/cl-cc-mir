;;;; cl-cc-mir.asd — independent ASDF system for Machine IR + target descriptors
;;;;
;;;; Phase 2 leaf extraction. Files live in the :cl-cc/mir package
;;;; (mir-value, mir-const, mir-inst, mir-block, mir-function, mir-module,
;;;; SSA variable tracking, RPO, dominators, printer, target-desc, and
;;;; predefined x86-64/aarch64/riscv64/wasm32 descriptors). Depends on
;;;; nothing — pure :cl leaf system, mirroring cl-cc-ir.

(asdf:defsystem :cl-cc-mir
  :description "Machine IR: SSA CFG, dominators, phi nodes, target descriptors"
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
  ((:file "package")
   (:file "mir")
   (:file "mir-builder")
   (:file "mir-analysis")))

(asdf:defsystem "cl-cc-mir/test"
  :description "Module boundary tests for cl-cc-mir"
  :author "takeokunn <bararararatty@gmail.com>"
  :license "MIT"
  :depends-on ("cl-cc-mir" "cl-weave")
  :pathname "t"
  :serial t
  :components ((:file "package")
               (:file "mir-boundary-test"))
  :perform (asdf:test-op (op system)
             (declare (ignore op system))
             (uiop:symbol-call :cl-weave :run-all-tests :pass-with-no-tests nil)))
