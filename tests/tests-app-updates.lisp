(in-package :weblocks-ajax-file-upload-presentation-tests)

(defun ajax-file-field-demonstration-action (&rest args)
  (do-page 
    (make-quickform 
      (defview 
        nil 
        (:caption "Ajax file form field demo" :type form :persistp nil :enctype "multipart/form-data" :use-ajax-p t)
        (file 
          :present-as ajax-file-upload 
          :parse-as (ajax-file-upload 
                      :upload-directory (weblocks-selenium-tests-app::get-upload-directory)
                      :file-name :unique)
          :writer (lambda (value item)))))))

(weblocks-selenium-tests-app::define-demo-action "Ajax file upload" #'ajax-file-field-demonstration-action :prototype-engine-p nil)
