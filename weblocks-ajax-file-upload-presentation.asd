(asdf:defsystem #:weblocks-ajax-file-upload-presentation
  :serial t
  :description "Weblocks presentation for ajax file uploads"
  :author "Olexiy Zamkoviy <olexiy.z@gmail.com>"
  :license "LLGPL"
  :version "0.0.7"
  :depends-on (#:weblocks #:yaclml)
  :components ((:file "package")
               (:file "weblocks-ajax-file-upload-presentation")))
