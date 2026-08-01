;;;; cl-cc-mir.asd — independent ASDF systems for Machine IR + target descriptors
;;;;
;;;; This file defines two independently-versioned system families that
;;;; share this one repository:
;;;;
;;;;   cl-cc-mir        — the :cl-cc/mir package (mir-value, mir-const,
;;;;                       mir-inst, mir-block, mir-function, mir-module, SSA
;;;;                       variable tracking, RPO, dominators, printer).
;;;;   cl-cc-target      — the :cl-cc/target package (target-desc and the
;;;;                       predefined x86-64/aarch64/riscv64/wasm32
;;;;                       descriptors), formerly its own nerima-lisp/cl-cc-target
;;;;                       repo, folded in here because the two systems were
;;;;                       always co-consumed as a pair and combined were
;;;;                       under 1000 loc. System names are unchanged, so
;;;;                       consumer :depends-on clauses are unaffected — only
;;;;                       the Nix source each is built from now points at
;;;;                       this repo.
;;;;
;;;; Both are pure :cl leaf systems, depending on nothing (including each
;;;; other), mirroring cl-cc-ir.

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
