#lang racket
(require web-server/servlet
         web-server/servlet-env
         web-server/dispatch)

(require "routes/index.rkt")

(define (app req)
  (define-values (blog-dispatch blog-url)
    (dispatch-rules
     [("") page-index]
     [("buildhistory") page-build-history]
     [("build" (string-arg)) page-build-detail]
     [("host") page-host]
     [("get") get-data]
     [("test") page-test]))
  (blog-dispatch req))

(define (run)  
  (serve/servlet app
                 #:port 8080
                 #:listen-ip #f
                 #:servlet-path "/"
                 #:servlet-regexp #rx""
                 #:command-line? #t
                 #:extra-files-paths (list
                                      (build-path "./public"))
                 #:log-file "./log.txt"
                 #:stateless? #f))

(run)