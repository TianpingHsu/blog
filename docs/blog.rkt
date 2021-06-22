#lang racket

(require web-server/templates  ;; check: https://docs.racket-lang.org/web-server/templates.html
         web-server/servlet
         web-server/servlet-env
         )

(define (start request)
  (response/output
    (lambda (op) (display (include-template "index.html") op))))

(define (not-found req)
  (response/xexpr
   '(html
     (head (title "Page Not Found"))
     (body (h1 "Sorry Page Not Found")))))

;;(static-files-path "static")  ;; https://docs.racket-lang.org/continue/index.html?q=web%20applications
(define launch-browser? #t)  ;; for test

(serve/servlet start
               #:port 8765
               #:listen-ip #f
               ;;#:servlet-regexp #rx""
               #:servlet-path "/index.html"
               #:extra-files-paths (list (build-path "static"))
               #:launch-browser? launch-browser?
               )

;;#lang web-server/insta
#;(define (start request)
  (response/xexpr
   '(html
     (head (title "My Blog"))
     (body (h1 "Under construction")))))

;`(html ,(include-template "static.html"))
