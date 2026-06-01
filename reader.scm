(define-module (reader)
  #:use-module (haunt reader)
  #:use-module (haunt reader commonmark)
  #:use-module (haunt post)
  #:use-module (ice-9 match)
  #:use-module (srfi srfi-11)
  #:use-module (sxml transform)
  #:export (dg-markdown-reader))

(define (make-video-iframe code)
  `(iframe
    (@ (src ,(string-concatenate
              (list
               "https://www.youtube.com/embed"
               "/"
               (cadr (string-split code (lambda (c) (char=? c #\:)))))))
       (title "YouTube Video Player")
       (frameborder "0")
       (allow "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share")
       (referrerpolicy "strict-origin-when-cross-origin")
       (allowfullscreen ""))))

;; info-language : string -> (or string #f)
;;
;; Returns the first whitespace-separated word of INFO, e.g.
;;
;;   (info-language "go")               => "go"
;;   (info-language "go title=main.go") => "go"
;;   (info-language "  go ")            => "go"
;;
;; Returns #f when INFO has no words (""  or whitespace), so the caller can
;; omit the language class instead of emitting "language-".
(define (info-language info)
  (let ((lst (string-tokenize info)))
    (if (null? lst)
        #f
        (car lst))))

;; Haunt emits `(code (@ (infostring "go")) ...)` for fenced code blocks;
;; Prism expects `(code (@ (class "language-go")) ...)`.
(define (prism-code-attrs tree)
  (match tree
    ((('@ . attrs) . rest)
     (let* ((info (assq 'infostring attrs))
            (lang (and info
                       (pair? (cdr info))
                       (string? (cadr info))
                       (info-language (cadr info))))
            (others (filter (lambda (a) (not (eq? (car a) 'infostring))) attrs)))
       (cond (lang `((@ (class ,(string-append "language-" lang)) ,@others)
                     ,@rest))
             (info (if (null? others) rest `((@ ,@others) ,@rest)))
             (else tree))))
    (_ tree)))

(define dg-markdown-reader
  (make-reader
   (make-file-extension-matcher "md")
   (lambda (file-name)
     (let-values (((metadata sxml)
                   (reader-read commonmark-reader file-name)))
       (values
        metadata
        (pre-post-order
         sxml
         `((code . ,(lambda (sym . tree)
                      (if (and (pair? tree)
                               (null? (cdr tree))
                               (string? (car tree)))
                          (if (string-prefix? "youtube:" (car tree))
                              (make-video-iframe (car tree))
                              (cons sym tree))
                          (cons sym (prism-code-attrs tree)))))
           (*text* . ,(lambda (sym text) text))
           (*default* . ,(lambda arg arg)))))))))
