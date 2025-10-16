(in-package :cl-nowhere)

(defparameter +game-screen-width+ 800)
(defparameter +game-screen-height+ 600)
(defparameter +scale+ 2)
(defparameter +window-width+ (* +game-screen-width+ +scale+))
(defparameter +window-height+ (* +game-screen-height+ +scale+))
(defun initialize ()
  (unless (al:init)
    (error "Initializing liballegro failed"))
  (unless (al:init-primitives-addon)
    (error "Initializing primitives addon failed"))
  (unless (al:init-image-addon)
   (error "Initializing image addon failed"))
  ;; (unless (al:init-font-addon)
  ;;   (error "Initializing liballegro font addon failed"))
  ;; (unless (al:init-ttf-addon)
  ;;   (error "Initializing liballegro TTF addon failed"))
  ;; (unless (al:install-audio)
  ;;   (error "Intializing audio addon failed"))
  ;; (unless (al:init-acodec-addon)
  ;;   (error "Initializing audio codec addon failed"))
  ;; (unless (al:restore-default-mixer)
  ;;   (error "Initializing default audio mixer failed"))
  )

(defun shutdown (display event-queue)
  (al:inhibit-screensaver nil)
  (al:destroy-display display)
  (al:destroy-event-queue event-queue)
  (al:stop-samples)
  (al:uninstall-system)
  (al:uninstall-audio)
  (al:shutdown-ttf-addon)
  (al:shutdown-font-addon)
  (al:shutdown-image-addon)
  (al:shutdown-primitives-addon))

(cffi:defcallback %main :int ((argc :int) (argv :pointer))
  (declare (ignore argc argv))
  (handler-bind
      ((error #'(lambda (e) (unless *debugger-hook*
                              (al:show-native-message-box
                               (cffi:null-pointer) "Hey guys"
                               "We got a big error here :("
                               (with-output-to-string (s)
                                 (uiop:print-condition-backtrace e :stream s))
                               (cffi:null-pointer) :error)))))
    ;;     (let ((config (al:load-config-file +config-path+)))
    ;;       (unless (cffi:null-pointer-p config)
    ;;         (al:merge-config-into (al:get-system-config) config)))
    ;; ;    (setf *fpsp* (al:get-config-value (al:get-system-config)
                                        ;                                      "game" "show-fps"))
    (initialize)
    (al:set-new-display-flags '(:windowed :opengl))
    (al:set-new-display-option :vsync 0 :require)
    (let* ((application (mk-application))
           (_ (al:set-app-name (get-name application)))
           (display (al:create-display +window-width+ +window-height+))
           (event-queue (al:create-event-queue)))
      (when (cffi:null-pointer-p display)
        (error "Initializing display failed"))
      (al:inhibit-screensaver t)
      (al:set-window-title display (get-name application))
      (al:register-event-source event-queue
                                (al:get-display-event-source display))
      (al:install-keyboard)
      (al:register-event-source event-queue
                                (al:get-keyboard-event-source))
      (unwind-protect
           (progn
             (livesupport:setup-lisp-repl)
             ;(trivial-garbage:gc :full t)
             (al:with-current-keyboard-state state
               (loop :named event-loop
                     :while (not (has-quitted application))
                     :do (let ((timer (al:get-time)))
                           (process-event-queue event-queue application)
                           (timer-tick application timer)
                           (render application)))))
        (shutdown display event-queue))))
  0)

(defun process-event-queue (event-queue application)
  (cffi:with-foreign-object (event '(:union al:event))
    (loop :while (al:get-next-event event-queue event)
          :do (let ((event-type (cffi:foreign-slot-value event '(:union al:event) 'al::type)))
                (case event-type
                  ;; (:key-down (handle-key-down-event (cffi:foreign-slot-value event
                  ;;                                                            '(:struct al:keyboard-event)
                  ;;                                                            'al::keycode)
                  ;;                                   game-state))
                  ;; (:key-up (handle-key-up-event (cffi:foreign-slot-value event
                  ;;                                                        '(:struct al:keyboard-event)
                  ;;                                                        'al::keycode)
                  ;;                               game-state))
                  (:display-close (quit application)))))))


(defun main ()
  (float-features:with-float-traps-masked
      (:divide-by-zero :invalid :inexact :overflow :underflow)
    (al:run-main 0 (cffi:null-pointer) (cffi:callback %main))))

(defun mk-application ()
  (make-instance 'Application))

