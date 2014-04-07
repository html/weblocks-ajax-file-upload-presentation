(asdf:defsystem #:weblocks-ajax-file-upload-presentation
  :serial t
  :description "Weblocks presentation for ajax file uploads"
  :author "Olexiy Zamkoviy <olexiy.z@gmail.com>"
  :license "LLGPL"
  :version "0.0.8"
  :depends-on (#:weblocks #:yaclml #:weblocks-utils)
  :components ((:file "package")
               (:file "weblocks-ajax-file-upload-presentation")))
