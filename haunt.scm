(use-modules (haunt builder blog)
	     (haunt builder atom)
	     (haunt builder assets)
	     (haunt reader commonmark)
	     (haunt site))

(define (stylesheet ref)
  `(link (@ (rel "stylesheet") (href ,ref) (type "text/css"))))

(define (head title site)
  `(head
    (meta (@ (charset "utf-8")))
    (meta (@ (name "viewport") (content "width=device-width, initial-scale=1")))
    (title ,(string-append title " — " (site-title site)))
    ,(stylesheet "//fonts.googleapis.com/css?family=Open+Sans:400|Open+Sans:700|JetBrains+Mono:400")
    ,(stylesheet "//cdnjs.cloudflare.com/ajax/libs/highlight.js/11.7.0/styles/default.min.css")
    ,(stylesheet "css/main.css")
    (script (@ (src "//cdnjs.cloudflare.com/ajax/libs/highlight.js/11.7.0/highlight.min.js")))
    (script "hljs.highlightAll();")))

(define nav
  `(nav
    (ul
     (@ (class "nav"))
     (li (@ (class "title"))
	 (a (@ (href "/")) "dtg"))
     (li (@ (class "nav-right nav-link"))
	 (a (@ (href "/about.html")) "about"))
     (li (@ (class "nav-link"))
	 (a (@ (href "//github.com/dylangleason")) "github"))
     (li (@ (class "nav-link"))
	 (a (@ (href "//linkedin.com/in/dylangleason")) "linkedin")))))

(define footer
  `(footer
    (@ (class "footer"))
    (span "\u00A9 2023 Dylan Gleason")
    (span "\u22c5")
    (span "Built w/ "
	  (a (@ (href "//dthompson.us/projects/haunt.html")) "Haunt"))))

(define layout
  (theme #:name "main"
	 #:layout
	 (lambda (site title body)
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
		    ,footer)))))))

(site #:title "dtg"
      #:domain "example.com"
      #:default-metadata
      '((author . "Dylan Gleason")
	(email . "dgleason8384@gmail.com"))
      #:readers (list commonmark-reader)
      #:builders (list (blog #:theme layout)
		       (atom-feed)
		       (atom-feeds-by-tag)
		       (static-directory "css")))
