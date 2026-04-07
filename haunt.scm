(use-modules (haunt asset)
	     (haunt artifact)
	     (haunt builder blog)
	     (haunt builder atom)
	     (haunt builder assets)
	     (haunt html)
	     (haunt post)
	     (haunt reader commonmark)
	     (haunt site)
	     (srfi srfi-19)
	     (srfi srfi-42))

(define (about-page site posts)
  (serialized-artifact
   "about.html"
   (with-layout
    theme
    site
    "About"
    `((h1 "Hello")
      (p "My name is Dylan Gleason and I am a software engineer.
For the most part, I work as a backend web developer and have written
web services for a variety of companies. These days, I mostly write
code in Go or Python, with the occasional JavaScript thrown in for
good measure.")
      (p "Outside of work, I enjoy learning programming languages and new
technologies that I don't get to use in my day-to-day, as well as
starting (though rarely completing) programming projects that aren't
related to web development.")
      (p "Some other hobbies of mine include video gaming, particularly retro
gaming and the emulation thereof, as well as digital audio synthesis
and making electronic music. I also enjoy reading — these days mostly high
fantasy and history — and discovering new recipes that I can cook for
(inflict upon?) my family. For better or (more likely) worse, I am
also a fan of the Portland Trail Blazers. Go "
	 (a (@ (href "//youtu.be/0L0Axk8d0QM")) "Rip City!"))))
   sxml->html))

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
     (li (a (@ (href "/index.html")) "posts"))
     (li (a (@ (href "/about.html")) "about"))
     (li (a (@ (href "//github.com/dylangleason")) "github"))
     (li (a (@ (href "//linkedin.com/in/dylangleason")) "linkedin")))
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

(define theme
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
		    ,footer)))))
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
		       about-page
		       (atom-feed)
		       (atom-feeds-by-tag)
		       (static-directory "css")
		       (static-directory "js")))
