;;;; src/target/package.lisp — cl-cc/mir/target feature package
;;;;
;;;; Houses target-desc and predefined target descriptions.
;;;; Pure :cl leaf — no other cl-cc dependencies.

(defpackage :cl-cc/mir/target
  (:use :cl)
  (:export
    #:*AARCH64-TARGET*
    #:*RISCV64-TARGET*
    #:*TARGET-REGISTRY*
    #:*WASM32-TARGET*
    #:*X86-64-TARGET*
    #:FIND-TARGET
    #:MAKE-TARGET-DESC
    #:REGISTER-TARGET
    #:TARGET-64-BIT-P
    #:TARGET-ALLOCATABLE-REGS
    #:TARGET-ARG-REGS
    #:TARGET-CALLEE-SAVED
    #:TARGET-CALLER-SAVED
    #:TARGET-DESC
    #:TARGET-DESC-P
    #:TARGET-ENDIANNESS
    #:TARGET-FEATURES
    #:TARGET-FP-ARG-REGS
    #:TARGET-FP-RET-REG
    #:TARGET-GPR-COUNT
    #:TARGET-GPR-NAMES
    #:TARGET-HAS-FEATURE-P
    #:TARGET-LEGAL-OPS
    #:TARGET-NAME
    #:TARGET-OP-EXPAND
    #:TARGET-OP-LEGAL-P
    #:TARGET-REG-INDEX
    #:TARGET-RET-REG
    #:TARGET-SCRATCH-REGS
    #:TARGET-STACK-ALIGNMENT
    #:TARGET-WORD-SIZE
))
