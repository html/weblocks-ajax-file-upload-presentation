This is weblocks ajax file upload presentation. It just uploads file before actual submitting form using ajax.
It was tested only with single file at a form and and single upload form.
Here is example of using.

(defun get-upload-directory ()
  (merge-pathnames 
    (make-pathname :directory '(:relative "upload"))
    (compute-webapp-public-files-path (weblocks:get-webapp 'my-webapp))))

(defview 'upload-form-view 
  (:type form 
    :caption ""
    :buttons '((:submit . "Upload file") (:cancel . "Close"))
    :persistp nil 
    :enctype "multipart/form-data" 
    :use-ajax-p t)
  (upload-image :present-as (ajax-file-upload)
    :parse-as (ajax-file-upload 
      :upload-directory (get-upload-directory)
      :file-name :unique)
    :reader (lambda (item) 
      nil)
    :writer (lambda (value object)
      (when value 
        (push value (slot-value item 'files))))))

It works with jquery-iframe-transport (http://cmlenz.github.com/jquery-iframe-transport/), for me it worked after google-chrome fix (https://github.com/html/jquery-iframe-transport/tree/google-chrome-fix)
