;;;; cl-cc-mir.asd — independent ASDF systems for Machine IR + target descriptors
;;;;
;;;; This system exposes the cl-cc/mir compatibility facade over the ir
;;;; feature. Target descriptions have their own cl-cc-target.asd entry point.
;;;;
;;;;   cl-cc-mir        — cl-cc/mir compatibility facade for cl-cc/mir/ir.
;;;; Both system families remain pure :cl leaf systems, depending on nothing
;;;; (including each other), mirroring cl-cc-ir.

(asdf:defsystem :cl-cc-mir
  :description "Machine IR: SSA CFG, builders, and analyses"
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
  ((:module "ir"
    :serial t
    :components ((:file "package")
                 (:file "mir")
                 (:file "mir-builder")
                 (:file "mir-analysis")))
   (:file "package"))
  :in-order-to ((asdf:test-op (asdf:load-op "cl-cc-mir/test")))
  :perform (asdf:test-op (op system)
             (declare (ignore op system))
             (let ((results
                    (uiop:symbol-call
                     :cl-weave
                     :run
                     nil
                     :reporter :spec
                     :location-filter
                     (labels ((source-component-pathnames (component)
                                (if (typep component 'asdf:source-file)
                                    (list (asdf:component-pathname component))
                                    (mapcan (lambda (child)
                                              (source-component-pathnames child))
                                            (asdf:component-children component)))))
                       (source-component-pathnames (asdf:find-system "cl-cc-mir/test"))))))
               (unless (and results
                            (uiop:symbol-call :cl-weave :results-status results))
                 (error "cl-cc-mir test suite failed.")))))

(asdf:defsystem "cl-cc-mir/test"
  :description "Module boundary tests for cl-cc-mir"
  :author "takeokunn <bararararatty@gmail.com>"
  :license "MIT"
  :depends-on ("cl-cc-mir" "cl-weave")
  :pathname "t"
  :serial t
  :components ((:module "ir"
                :serial t
                :components ((:file "package")
                             (:file "mir-rpo-test")
                             (:file "mir-boundary-test"))))
  :perform (asdf:test-op (op system)
             (declare (ignore op))
             (let ((results
       (uiop:symbol-call
        :cl-weave
        :run
        nil
        :reporter :spec
        :location-filter
        (labels ((source-component-pathnames (component)
                   (if (typep component 'asdf:source-file)
                       (list (asdf:component-pathname component))
                       (mapcan (lambda (child)
                                 (source-component-pathnames child))
                               (asdf:component-children component)))))
          (source-component-pathnames system)))))
  (unless (and results
               (uiop:symbol-call :cl-weave :results-status results))
    (error "cl-cc-mir test suite failed.")))))
