(define-module (publisher)
  #:use-module (haunt publisher)
  #:use-module (haunt site)
  #:export (cloudflare-pages-publisher))

(define %deploy-command "npx")
(define %deploy-args '("wrangler" "pages" "deploy"))

(define* (cloudflare-pages-publisher #:key (name %default-publisher-name))
  (define (publish site)
    (let ((args (append %deploy-args
                        (list (site-build-directory site)))))
      (apply run-command %deploy-command
             (if (not (eq? name %default-publisher-name))
                 (append args
                         (list (string-append "--branch=" (symbol->string name))))
                 args))))
  (make-publisher name publish))
