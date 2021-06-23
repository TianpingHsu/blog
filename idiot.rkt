#lang racket

(require web-server/templates
         web-server/servlet
         web-server/servlet-env
         web-server/dispatch
         )

#;(define (for-test req)
  (begin
    (displayln "This is For Test")
    (response/xexpr
     '(html
       (head (title "For Test"))
       (body (h1 "This Page is Used For Test"))))))

(define (for-test req)
  (get-post req "why-i-build-this-web.html"))

(define (http-response content)  ; The 'content' parameter should be a string.
  (response/full
   200                  ; HTTP response code.
   #"OK"                ; HTTP response message.
   (current-seconds)    ; Timestamp.
   TEXT/HTML-MIME-TYPE  ; MIME type for content.
   '()                  ; Additional HTTP headers.
   (list                ; Content (in bytes) to send to the browser.
    (string->bytes/utf-8 content))))

(define (say-hello request name)
  (http-response (string-append "Hello " name "!")))

(define (get-post request post-name)
  (http-response (file->string (string-append "static/posts/" post-name))))

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

;; URL routing table (URL dispatcher).
(define-values (dispatch generate-url)
  (dispatch-rules
   [("") not-found]
   [("idiot.rkt") home-page]
   [("test.rkt") for-test]
   [("hello" (string-arg)) say-hello]
   [("posts" (string-arg)) get-post]
   [else not-found]))
  ;[else (error "There is no procedure to handle the url.")]))

(define (request-handler request)
  (begin
    (displayln request)
    (dispatch request)))

(serve/servlet request-handler
               #:port 8765
               #:listen-ip #f
               ;;#:servlet-regexp #rx""
               #:servlet-regexp #rx".*\\.[(rkt)(html)]"
               ;;#:servlet-regexp #rx".*\\.[(rkt)]"
               #:server-root-path "./"
               #:servlets-root	 "./"
               ;;#:file-not-found-responder "./"
               #:servlet-path "/idiot.rkt"
               #:extra-files-paths (list (build-path "static"))
               #:launch-browser? #t
               )

