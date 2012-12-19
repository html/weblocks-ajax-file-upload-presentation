; Needed to load yaclml without warnings
(when (find-package :xml)
  (delete-package :xml))

(asdf:defsystem #:weblocks-ajax-file-upload-presentation-tests
   :serial t
   :description "Tests for weblocks-ajax-file-upload-presentation"
   :author "Olexiy Zamkoviy <olexiy.z@gmail.com>"
   :license "LLGPL"
   :version "0.0.1"
   :depends-on (#:weblocks #:weblocks-ajax-file-upload-presentation #:weblocks-selenium-tests #:yaclml)
   :components 
   ((:module tests 
     :components
     ((:file "package")
      (:file "tests" :depends-on ("package"))
      (:file "tests-app-updates" :depends-on ("package"))))))

