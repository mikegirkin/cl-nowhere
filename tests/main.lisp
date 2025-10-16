(defpackage cl-nowhere/tests/main
  (:use :cl
        :cl-nowhere
        :rove))
(in-package :cl-nowhere/tests/main)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-nowhere)' in your Lisp.

(deftest test-target-1
  (testing "should (= 1 1) to be true"
    (ok (= 1 1))))
