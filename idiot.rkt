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
(define (http-response content)  ; The 'content' parameter should be a string.
  (response/full
   200                  ; HTTP response code.
   #"OK"                ; HTTP response message.
   (current-seconds)    ; Timestamp.
   TEXT/HTML-MIME-TYPE  ; MIME type for content.
   '()                  ; Additional HTTP headers.
   (list                ; Content (in bytes) to send to the browser.
    (string->bytes/utf-8 content))))

(define (get-post request post-name)
  (http-response (string-append "Hello " post-name "!")))
#|(response/xexpr
   '(html
     (head (title "For Test"))
     (body (h1 "This Page is Used For Test")))))|#

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

#;(define-values (dispatch url)
  (dispatch-rules
   [("idiot.rkt") home-page]
   [("test.rkt") for-test]
   [("posts" (post-name)) get-post]
   [else not-found]))

;; URL routing table (URL dispatcher).
(define-values (dispatch generate-url)
  (dispatch-rules
   [("idiot.rkt") home-page]
   [("test.rkt") for-test]
   ;;[("posts" (string-arg)) get-post]  ; Notice this line.
   [else (error "There is no procedure to handle the url.")]))

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
               ;;#:servlet-regexp #rx""
               #:servlet-path "/idiot.rkt"
               #:extra-files-paths (list (build-path "static"))
               #:launch-browser? #t
               )

