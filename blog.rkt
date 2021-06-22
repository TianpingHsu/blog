#lang racket

(require web-server/templates
         web-server/servlet
         web-server/servlet-env
         web-server/dispatch
         )

(define (for-test req)
  (begin
    (displayln "This is For Test")
    (response/xexpr
    '(html
      (head (title "For Test"))
      (body (h1 "This Page is Used For Test"))))))

(define (not-found req)
  (begin
    (displayln "In Handler: not-found")
    (response/xexpr
    '(html
      (head (title "Page Not Found"))
      (body (h1 "Handler: Page Not Found"))))))

(define (home-page req)
  (response/output
    (lambda (op) (display (include-template "index.html") op))))

#;(define (home-page req)
  (response/xexpr
   '(html
     (head (title "Home Page"))
     (body (h1 "This is Home Page")))))

(define-values (dispatch url)
  (dispatch-rules
    [("") home-page]
    [("/") home-page]
    [("blog.rkt") home-page]
    [("test.rkt") for-test]
    [else not-found]))

(define (request-handler request)
  (begin
    (displayln request)
    (dispatch request)))

#;(define (start request)
  (response/output
   (lambda (op) (display (include-template "index.html") op))))

(serve/servlet request-handler
               #:port 8765
               #:listen-ip #f
               #:servlet-regexp #rx".*\\.rkt"
               #:servlet-path "/blog.rkt"
               #:extra-files-paths (list (build-path "static"))
               #:launch-browser? #t
               )

