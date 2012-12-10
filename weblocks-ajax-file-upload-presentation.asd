;;;; weblocks-ajax-file-upload-presentation.asd

(asdf:defsystem #:weblocks-ajax-file-upload-presentation
  :serial t
  :description "Describe weblocks-ajax-file-upload-presentation here"
  :author "Olexiy Zamkoviy <olexiy.z@gmail.com>"
  :license "LLGPL"
  :version "0.0.1"
  :depends-on (#:weblocks #:yaclml)
  :components ((:file "package")
               (:file "weblocks-ajax-file-upload-presentation")))

