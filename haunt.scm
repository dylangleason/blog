(use-modules (haunt builder blog)
             (haunt builder atom)
             (haunt builder assets)
             (haunt builder flat-pages)
             (haunt html)
             (haunt post)
             (haunt reader commonmark)
             (haunt site)
             (srfi srfi-19)
             (srfi srfi-42)
             (icons))

(define (stylesheet ref)
  `(link (@ (rel "stylesheet")
            (href ,(string-append "/css/" ref))
            (type "text/css"))))

(define (script src)
  `(script (@ (src ,(string-append "/js/" src))
              (type "text/javascript"))))

(define (format-date date)
  (date->string date "~B ~d, ~Y"))

(define (head title site)
  `(head
    (meta (@ (charset "utf-8")))
    (meta (@ (name "viewport")
             (content "width=device-width, initial-scale=1")))
    (title ,(string-append title " — " (site-title site)))
    ,(stylesheet "normalize.css")
    ,(stylesheet "main.css")
    ,(script "main.js")))

(define nav
  `(nav
    (@ (class "nav"))
    (ul
     (@ (class "title"))
     (li (a (@ (href "/")) "dylan gleason")))
    (button (@ (class "nav-toggle")
               (aria-label "Toggle navigation")
               (aria-expanded "false"))
            (span))
    (ul
     (@ (class "links"))
     (li (a (@ (href "/index.html")) ,posts-icon "posts"))
     (li (a (@ (href "/feed.xml")) ,feed-icon "feed"))
     (li (a (@ (href "/about.html")) ,about-icon "about"))
     (li (a (@ (href "//github.com/dylangleason")) ,github-icon "github"))
     (li (a (@ (href "//linkedin.com/in/dylangleason")) ,linkedin-icon "linkedin")))
    (button (@ (class "theme-toggle")))))

(define (post-preview post)
  (let loop ((lst (post-sxml post)))
    (cond ((nil? lst) lst)
          ((eq? 'p (caar lst)) (car lst))
          (else (loop (cdr lst))))))

(define (collection-template site title posts prefix)
  `((h1 ,title)
    (div (@ (class "posts"))
         ,(list-ec (:list post posts)
                   (let ((path (string-append
                                prefix "/"
                                (site-post-slug site post) ".html")))
                     `(article (@ (class "preview"))
                               (h2
                                (a (@ (href ,path))
                                   ,(post-ref post 'title)))
                               (div (@ (class "date"))
                                    ,(format-date (post-date post)))
                               (div (@ (class "opener"))
                                    ,(post-preview post))
                               (a (@ (href ,path)) "more…")))))))

(define (post-template post)
  `((article
     (@ (class "post"))
     (h1
      ,(post-ref post 'title))
     (p (@ (class "byline"))
        ,(string-concatenate
          (list
           "by "
           (post-ref post 'author)
           " — "
           (format-date (post-date post)))))
     (div (@ (class "tags"))
          "Tags:"
          ,(list-ec (:list tag (post-tags post))
                    `(a (@ (href ,(string-append "/feeds/tags/" tag ".xml")))
                        ,tag)))
     ,(post-sxml post))))

(define (pagination-template site body prev-page next-page)
  `(,@body
    (div (@ (class "pagination"))
         ,(if prev-page
              `(a (@ (class "prev-page") (href ,prev-page))
                  "← Newer")
              '())
         ,(if next-page
              `(a (@ (class "next-page") (href ,next-page))
                  "Older →")
              '()))))

(define footer
  `(footer
    (@ (class "footer"))
    (span "\u00A9 2026 Dylan Gleason")
    (span "\u22c5")
    (span "Built w/ "
          (a (@ (href "//dthompson.us/projects/haunt.html")) "Haunt"))))

(define (layout site title body)
  `((doctype "html")
    (html
     (@ (lang "en"))
     ,(head title site)
     (body
      (div (@ (class "container"))
           ,nav
           (main
            (@ (class "main"))
            ,body)
           ,footer)))))

(define theme
  (theme #:name "main"
         #:layout layout
         #:post-template post-template
         #:collection-template collection-template
         #:pagination-template pagination-template))

(site #:title "dtg"
      #:domain "example.com"
      #:default-metadata '((author . "Dylan Gleason"))
      #:posts-directory "posts"
      #:readers (list commonmark-reader)
      #:builders (list (blog #:theme theme
                             #:post-prefix "/posts"
                             #:posts-per-page 10)
                       (atom-feed)
                       (atom-feeds-by-tag)
                       (flat-pages "pages" #:template layout)
                       (static-directory "css")
                       (static-directory "js")))
