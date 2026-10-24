;;;; cl-cc-target.asd -- ASDF entry point for target descriptors.

(asdf:defsystem :cl-cc-target
  :description "Target descriptions for compiler backends"
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
  ((:module "target"
    :serial t
    :components ((:file "package")
                 (:file "target")))
   (:file "target-package"))
  :in-order-to ((asdf:test-op (asdf:load-op "cl-cc-target/test")))
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
                       (source-component-pathnames (asdf:find-system "cl-cc-target/test"))))))
               (unless (and results
                            (uiop:symbol-call :cl-weave :results-status results))
                 (error "cl-cc-target test suite failed.")))))

(asdf:defsystem "cl-cc-target/test"
  :description "Module boundary tests for cl-cc-target"
  :author "takeokunn <bararararatty@gmail.com>"
  :license "MIT"
  :depends-on ("cl-cc-target" "cl-weave")
  :pathname "t"
  :serial t
  :components ((:module "target"
                :serial t
                :components ((:file "package")
                             (:file "target-boundary-test"))))
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
    (error "cl-cc-target test suite failed.")))))
