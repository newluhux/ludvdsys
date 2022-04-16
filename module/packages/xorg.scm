(use-modules
 (gnu packages)
 (gnu packages wm)
 (guix build-system gnu)
 (guix git-download)
 (guix gexp)
 (guix packages)
 (guix utils))


(define-public xinitrc-xsession-modify
 (package
  (inherit xinitrc-xsession)
  (source
   (local-file "src/xinitrc-xsession" #:recursive? #t))))
      

xinitrc-xsession-modify
