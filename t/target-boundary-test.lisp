;;;; t/target-boundary-test.lisp — module boundary tests for cl-cc-target

(in-package :cl-cc-target/test)

(describe-sequential "cl-cc-target dependency closure"
  (it "loads without any other cl-cc package present"
    (dolist (name '("CL-CC/VM" "CL-CC/MIR" "CL-CC/IR" "CL-CC/CODEGEN"
                    "CL-CC/BOOTSTRAP" "CL-CC/RUNTIME"))
      (expect (find-package name) :to-be nil))))

(describe-sequential "target registry"
  (it "registers every predefined target at load time"
    ;; The four are registered by top-level forms in target.lisp, so a consumer
    ;; can look one up without knowing they exist as variables.
    (dolist (name '(:x86-64 :aarch64 :riscv64 :wasm32))
      (expect (cl-cc/target:find-target name) :to-be-truthy)))

  (it "returns nil for a target nobody registered"
    (expect (cl-cc/target:find-target :no-such-target) :to-be nil))

  (it "names each descriptor after the key it is registered under"
    (dolist (name '(:x86-64 :aarch64 :riscv64 :wasm32))
      (expect (cl-cc/target:target-name (cl-cc/target:find-target name))
              :to-be name))))

(describe-sequential "target descriptions"
  (it "gives wasm32 structured control flow and the others none"
    ;; The Stackifier runs only for a target that cannot express arbitrary
    ;; branches, so this feature flag is what selects it.
    (expect (member :structured-control-flow
                    (cl-cc/target:target-features (cl-cc/target:find-target :wasm32)))
            :to-be-truthy)
    (dolist (name '(:x86-64 :aarch64 :riscv64))
      (expect (member :structured-control-flow
                      (cl-cc/target:target-features (cl-cc/target:find-target name)))
              :to-be nil)))

  (it "gives each native target its own calling convention"
    (dolist (pair '((:x86-64 . :sysv-abi)
                    (:aarch64 . :aapcs64)
                    (:riscv64 . :riscv-elf-psabi)))
      (expect (member (cdr pair)
                      (cl-cc/target:target-features (cl-cc/target:find-target (car pair))))
              :to-be-truthy))))
(describe-sequential "ASDF entry points"
  (it "loads MIR and target from the same checkout"
    (asdf:load-system "cl-cc-mir")
    (asdf:load-system "cl-cc-target")
    (expect
      (equal
        (namestring
          (truename
            (asdf:system-source-directory
              (asdf:find-system "cl-cc-mir"))))
        (namestring
          (truename
            (asdf:system-source-directory
              (asdf:find-system "cl-cc-target")))))
      :to-be-truthy)))
