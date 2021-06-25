#lang racket
(require web-server/templates
         web-server/servlet
         web-server/servlet-env
         web-server/dispatch
         json
         ;;sha
         )

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
  (let ([file-name (string-append "static/posts/" post-name)])
    (if (file-exists? file-name)
        (http-response (file->string file-name))
        not-found)))

(define (for-test req)
  (get-post req "why-i-build-this-web.html"))

(define (not-found req)
  (begin
    (displayln "In Handler: not-found")
    (response/xexpr
     '(html
       (head (title "Page Not Found"))
       (body (h1 "You Are In My Error Handler: *Page Not Found*, Check Your URL"))))))

(define (home-page req)
  (response/output
   (lambda (op) (display (include-template "index.html") op))))

;; URL routing table (URL dispatcher).
(define-values (dispatch request)
  (dispatch-rules
   [("idiot.rkt") home-page]
   [("test.rkt") for-test]
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
               #:server-root-path "./"
               #:servlets-root	 "./"
               #:file-not-found-responder not-found
               #:servlet-path "/idiot.rkt"
               #:extra-files-paths (list (build-path "static"))
               #:launch-browser? #t
               )

