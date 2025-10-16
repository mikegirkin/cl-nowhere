(asdf:defsystem "cl-nowhere"
  :author "Mike Girkin"
  :license "MIT"
  :serial t
  :description ""

  :components ((:module "src"
                :components ((:file "package")
                             (:file "application")
                             (:file "main"))))

  :depends-on (:alexandria
               :cl-liballegro
               :livesupport
               :fiveam
               :binding-arrows
               :let-plus)

  :in-order-to ((test-op (test-op "cl-nowhere/tests")))
  :entry-point "cl-nowhere:main"
  )

(defsystem "cl-nowhere/tests"
  :author ""
  :license ""
  :description "Test system for cl-nowhere"
  :depends-on ("cl-nowhere")
  :components ((:module "tests"
                :components ((:file "main"))))
  :perform (test-op (op c) (symbol-call :rove :run c)))

