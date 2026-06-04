(define-module (reader)
  #:use-module (haunt reader)
  #:use-module (haunt reader commonmark)
  #:use-module (haunt post)
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
                          (cons sym tree))))
           (*text* . ,(lambda (sym text) text))
           (*default* . ,(lambda arg arg)))))))))
