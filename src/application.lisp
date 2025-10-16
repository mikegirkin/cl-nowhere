(in-package :cl-nowhere)

(defclass Application ()
  ((running :initform T
            :accessor running))
  )

(defun get-name (application)
  "noWhere"
  )

(defun quit (application)
  (setf (running application) nil))

(defun timer-tick (application timer)
  )

(defun render (application)
  )

(defun has-quitted (application)
  (not (running application)))

