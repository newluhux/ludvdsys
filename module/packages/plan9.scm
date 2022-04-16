(use-modules
 (gnu packages)
 (gnu packages base)
 (gnu packages bash)
 (gnu packages fontutils)
 (gnu packages perl)
 (gnu packages xorg)
 (guix build-system gnu)
 (guix git-download)
 (guix gexp)
 (guix packages)
 (guix utils))


(define-public plan9port
  (let ((revision "0")
        (commit "bab7b73b85f865d20a5c4f2d78ac9e81b3d39109"))
    (package
      (name "plan9port")
      (version (git-version "20220124" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/9fans/plan9port.git")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "17h6xdij3h00j87lc94q887sq45540lcp9h3kbxwxisd020h1i3v"))))
      (build-system gnu-build-system)
      (arguments
       `(#:make-flags (list (string-append "CC=" ,(cc-for-target)))
         #:tests? #f                    ; no tests
         #:phases
         (modify-phases %standard-phases
           (delete 'configure)          ; no configure script
           (delete 'build)
           (replace 'install            ; configure & build & install
             (lambda* (#:key outputs native-inputs inputs #:allow-other-keys)
               (let* ((out (assoc-ref outputs "out"))
                      (libxt (assoc-ref inputs "libxt"))
                      (system ,(%current-system))
                      (freetype-inc (string-append (assoc-ref inputs "freetype") "/include/freetype2/"))
                      (cflags (string-append "-I" freetype-inc " "))
                      (builder (assoc-ref inputs "builder")))
                 (copy-file builder "./builder.sh")
                 (setenv "CFLAGS" cflags)
                 (setenv "out" out)
                 (setenv "libxt" libxt)
                 (setenv "system" system)
                 (invoke "bash" "builder.sh")))))))
      (inputs
       `(("fontconfig" ,fontconfig)
         ("freetype" ,freetype)
         ("libx11" ,libx11)
         ("libxt" ,libxt)
         ("libxext" ,libxext)
         ("xorgproto" ,xorgproto)
         ("builder" ,(local-file "aux-files/plan9port/builder.sh"))))
      (native-inputs
       `(("perl" ,perl)
         ("which" ,which)
         ("bash" ,bash)))
      (synopsis "Plan 9 from User Space")
      (home-page "https://9fans.github.io/plan9port/")
      (description "Plan 9 from User Space (aka plan9port) is a port of many Plan 9 programs from their native Plan 9 environment to Unix-like operating systems")
      (license #t))))

(define-public plan9port-with-ime
  (let ((revision "0")
        (commit "36d491884a45be024d71a9a78ae005b1280af650"))
    (package
     (inherit plan9port)
     (name "plan9port-with-ime")
     (version (git-version "20220124" revision commit))
     (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://github.com/newluhux/plan9port.git")
              (commit commit)))
        (file-name (git-file-name name version))
        (sha256
         (base32 "0l7hmdd13q9ih9qiaix9vq1bn3bw5xcx5h2rqkz3lvvlvnlhrh6h")))))))

plan9port-with-ime
