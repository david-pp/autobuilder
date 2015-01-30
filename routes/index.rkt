#lang racket

(require web-server/servlet
         web-server/servlet-env
         web-server/templates
         xml)

(require "../model.rkt")

(provide (all-defined-out))

;;
;; 取得URL的参数
;;
(define (request-para request key)
	(if (exists-binding? key (request-bindings request))
		(extract-binding/single key (request-bindings request))
		empty))

(define (response/template template)
	(response/full
		200 
		#"Okay"
		(current-seconds) 
		TEXT/HTML-MIME-TYPE
		empty
		(list (string->bytes/utf-8 template))))


(define (render-navside)
	(let ([hosts (get-qa-hosts)])
		(include-template "../view/nav-side.html")))

(define (render-page pagecontent)
	(define-syntax-rule (template file)
		(make-cdata #f #f (include-template file)))

	(response/xexpr
     `(html (head ,(template "../view/header.html"))
            (body 
            	,(template "../view/nav-top.html")
            	,(let ([leftside (render-navside)] [content pagecontent]) 
            		(template "../view/body.html"))
            	,(template "../view/body-bottom.html")))))

(define (page-test request)
	(render-page "<h1>测试一下</h1>"))

;;
;; Main Page
;;
(define (page-index request)
	(page-build-history request))
	

;;
;; Building Histories, Show all building info & time usage;
;;
(define (page-build-history request)
	(render-page 
		(let ([builds (get-build-history)])
			(include-template "../view/content-buildhistory.html"))))
	

;;
;; Building Detail.
;;
(define (page-build-detail request build)
	(page-build-history request))

;;
;; Host Info
;;
(define (page-host request)
	(render-page (include-template "../view/content-hostinfo.html")))

#|
(define (page-index request)
	(response/xexpr
     `(html (head (title "AutoBuilder"))
            (body (p "AutoBUilder .............Index")))))
|#



(define (get-data request)
    (response/xexpr
     `(html (head (title "Hello!"))
            (body (p "Hey:")
                  (p ,(request-para request 'name))))))