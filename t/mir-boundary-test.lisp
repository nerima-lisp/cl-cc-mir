;;;; t/mir-boundary-test.lisp — module boundary tests for cl-cc-mir
;;;;
;;;; cl-cc's own suite covers MIR behaviour against this system. What is pinned
;;;; here is the property the extraction rests on -- a pure :cl leaf -- and the
;;;; builder surface a consumer constructs machine-level IR through.

(in-package :cl-cc-mir/test)

(describe-sequential "cl-cc-mir dependency closure"
  (it "loads without any other cl-cc package present"
    (dolist (name '("CL-CC/VM" "CL-CC/AST" "CL-CC/IR" "CL-CC/COMPILE"
                    "CL-CC/OPTIMIZE" "CL-CC/BOOTSTRAP" "CL-CC/RUNTIME"))
      (expect (find-package name) :to-be nil))))

(describe-sequential "cl-cc-mir public surface"
  (it "exports the builders a consumer constructs MIR with"
    (dolist (name '("MIR-MAKE-FUNCTION" "MIR-NEW-BLOCK" "MIR-NEW-VALUE" "MIR-EMIT"))
      (expect (nth-value 1 (find-symbol name :cl-cc/mir)) :to-be :external)))

  (it "exports the analyses and the printer"
    (dolist (name '("MIR-RPO" "MIR-DOMINATORS" "MIR-PRINT-FUNCTION"))
      (expect (nth-value 1 (find-symbol name :cl-cc/mir)) :to-be :external))))

(describe-sequential "mir construction"
  (it "gives a fresh function an entry block"
    (let ((fn (cl-cc/mir:mir-make-function 'f)))
      (expect (cl-cc/mir:mirf-entry fn) :to-be-truthy)))

  (it "allocates distinct block ids"
    (let* ((fn (cl-cc/mir:mir-make-function 'f))
           (a (cl-cc/mir:mir-new-block fn))
           (b (cl-cc/mir:mir-new-block fn)))
      (expect (eql (cl-cc/mir:mirb-id a) (cl-cc/mir:mirb-id b)) :to-be nil)))

  (it "gives a non-terminator a destination without being asked"
    ;; MIR-EMIT allocates the dst itself for value-producing ops, which is what
    ;; lets a builder chain instructions without tracking value numbers.
    (let* ((fn (cl-cc/mir:mir-make-function 'f))
           (entry (cl-cc/mir:mirf-entry fn))
           (inst (cl-cc/mir:mir-emit entry :add)))
      (expect (cl-cc/mir:miri-dst inst) :to-be-truthy)))

  (it "gives a terminator none"
    ;; :RET is in the no-dst set: a terminator producing a value would put a
    ;; definition after the block's exit.
    (let* ((fn (cl-cc/mir:mir-make-function 'f))
           (entry (cl-cc/mir:mirf-entry fn))
           (inst (cl-cc/mir:mir-emit entry :ret)))
      (expect (cl-cc/mir:miri-dst inst) :to-be nil))))
