;;;; weblocks-ajax-file-upload-presentation.lisp

(in-package #:weblocks-ajax-file-upload-presentation)

(defclass ajax-file-upload-presentation (file-upload-presentation)
  ())

(defclass ajax-file-upload-parser (file-upload-parser)
  ())

(defmethod parse-view-field-value :around ((parser ajax-file-upload-parser) value obj
                                                                            (view form-view) (field form-view-field) &rest args)
  (let ((original-filename (third (webapp-session-value 'upload-file-post-information))))
    (apply #'call-next-method (list* parser (list (webapp-session-value 'upload-file-pathname) original-filename) obj view field args))))

(defun weblocks-supports-jquery-p ()
  t)

(defmacro with-yaclml (&body body)
  "A wrapper around cl-yaclml with-yaclml-stream macro."
  `(yaclml:with-yaclml-stream *weblocks-output-stream*
     ,@body))

(defun first-uploaded-file-data ()
  (loop for i in (hunchentoot:post-parameters*) if (listp (cdr i)) do
        (return-from first-uploaded-file-data i)))

(defun file-upload-endpoint (&rest args)
  (declare (special hunchentoot::*tmp-files*))
  (setf hunchentoot::*tmp-files* (remove (webapp-session-value 'upload-file-pathname) hunchentoot::*tmp-files*))
  (let ((file-size (with-open-file (file (webapp-session-value 'upload-file-pathname)) (file-length file))))
    ; It didn't show correct content-length, setting it right to fix bug
    (setf (webapp-session-value 'upload-file-post-information) (first-uploaded-file-data))
    (setf (webapp-session-value 'upload-file-content-length) file-size))
  nil)

(defun upload-ajax-progress-endpoint (&rest args)
  (setf (hunchentoot:header-out :content-type) "text/plain")
  (when (not (webapp-session-value 'upload-file-pathname))
    (hunchentoot:abort-request-handler "{\"state\": \"error\", \"reason\":\"Upload not started\"}"))
  (let ((file-name (webapp-session-value 'upload-file-pathname))
        (file-size))
    (if (not (probe-file file-name)) 
      (hunchentoot:abort-request-handler "{\"state\": \"error\"}")
      (progn 
        (setf file-size (with-open-file (file file-name) (file-length file)))
        (if (= file-size (webapp-session-value 'upload-file-content-length))
          (hunchentoot:abort-request-handler 
            (format nil "{\"state\": \"done\"}"))
          (hunchentoot:abort-request-handler 
            (format nil "{\"state\": \"uploading\", \"received\": ~A, \"size\": ~A}" file-size (webapp-session-value 'upload-file-content-length))))))))

(defmethod render-view-field-value :around (value (presentation ajax-file-upload-presentation)
                                                  (field form-view-field) (view form-view) widget obj
                                                  &rest args &key intermediate-values &allow-other-keys)
  (if (weblocks-supports-jquery-p)
    (with-yaclml 
      (<:div :style "display:inline-block;" :id "ajax-upload-field"
             (<:input :type "file" :name (attributize-name (view-field-slot-name field)))
             (<:script :type "text/javascript"
                       (<:as-is 
                         (ps:ps 
                           (with-scripts 
                             "/pub/scripts/jquery.iframe-transport.js" 
                             (lambda ()
                               (let* ((form (ps:chain (j-query "#ajax-upload-field") (parents "form")))
                                      (on-submit-code (ps:chain form (attr "onsubmit")))
                                      (form-action (ps:chain form (attr "action"))))
                                 ;"progressUrl" (ps:LISP (make-action-url (make-action #'upload-ajax-progress-endpoint "upload-endpoint")))

                                 (flet ((execute-standard-form-action ()
                                          (ps:chain form 
                                                    (attr "target" "_self")
                                                    (attr "onsubmit" on-submit-code)
                                                    (attr "action" form-action)) 
                                          (set-timeout (lambda ()
                                                         (ps:chain form (submit))) 100)))
                                   (ps:chain 
                                     form
                                     (attr "onsubmit" "")
                                     (attr "method" "POST")
                                     (attr "action" (ps:LISP 
                                                      (add-get-param-to-url 
                                                        (make-action-url 
                                                          (make-action #'file-upload-endpoint "upload-target"))
                                                        "pure" "true")))
                                     (bind "submit" (lambda ()
                                                      (if (not (string= (ps:chain (j-query "input:submit[clicked=true]") (attr "name")) "submit"))
                                                        (execute-standard-form-action)
                                                        (ps:chain 
                                                          j-query
                                                          (ajax 
                                                            (ps:chain form (attr "action"))
                                                            (ps:create 
                                                              :files (ps:chain form (find ":file"))
                                                              :iframe t
                                                              "dataType" "json"))
                                                          (done (lambda ()
                                                                  (execute-standard-form-action))))) 
                                                      ps:false))))))))))))
    (call-next-method)))

; Situation where upload-hook is already set not supported yet.
(assert (not hunchentoot:*file-upload-hook*))

(setf hunchentoot:*file-upload-hook* 
      (lambda (upload-pathname)
        (setf (webapp-session-value 'upload-file-pathname) upload-pathname)
        (setf (webapp-session-value 'upload-file-content-length) (parse-integer (hunchentoot:header-in* :content-length)))
        upload-pathname))

(push (hunchentoot:create-static-file-dispatcher-and-handler 
        "/pub/scripts/jquery.iframe-transport.js" 
        (merge-pathnames 
          "jquery-iframe-transport/jquery.iframe-transport.js"
          (asdf-system-directory :weblocks-ajax-file-upload-presentation))) weblocks::*dispatch-table*)
