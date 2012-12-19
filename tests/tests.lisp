(in-package :weblocks-ajax-file-upload-presentation-tests)

(def-test-suite weblocks-ajax-file-upload-presentation-tests)

(deftest uploads-file-with-ajax ()
  (weblocks-selenium-tests:require-firefox
    (let ((old-files-list (cl-fad:list-directory (weblocks-selenium-tests-app::get-upload-directory)))
          (new-files-list))
      (with-new-or-existing-selenium-session-on-jquery-site
        (do-click-and-wait "link=Ajax file upload")
        (selenium:do-attach-file "name=file" (format nil "~A/pub/test-data/test-file" (string-right-trim "/" *site-root-url*)))
        (do-click-and-wait "name=submit")
        (setf new-files-list (cl-fad:list-directory (weblocks-selenium-tests-app::get-upload-directory)))
        (is (= (length new-files-list)
               (1+ (length old-files-list))))
        (mapcar #'delete-file new-files-list)))))
