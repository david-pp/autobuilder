#lang racket

(require web-server/servlet
         web-server/servlet-env
         web-server/templates
         xml)

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

(define (render-page pagecontent)
	(define-syntax-rule (template file)
		(make-cdata #f #f (include-template file)))

	(response/xexpr
     `(html (head ,(template "../view/header.html"))
            (body 
            	,(template "../view/nav-top.html")
            	,(let ([leftside (include-template "../view/nav-side.html")] [content pagecontent]) 
            		(template "../view/body.html"))
            	,(template "../view/body-bottom.html")))))

(define (page-test request)
	(render-page "<h1>测试一下</h1>"))

;;
;; Main Page
;;
(define (page-index request)
	(response/template (include-template "../view/dashboard.html")))

;;
;; Building Histories, Show all building info & time usage;
;;
(define (page-build-history request)
	(response/template (include-template "../view/dashboard.html")))

;;
;; Building Detail.
;;
(define (page-build-detail request build)
	(response/xexpr
     `(html (head (title "Build"))
            (body (p "Build:")
            	(p ,build)))))

;;
;; Host Info
;;
(define (page-host request host)
	(response/xexpr
     `(html (head (title "Host"))
            (body (p "Host:")
            	(p ,host)))))

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