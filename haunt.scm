(use-modules (haunt asset)
	     (haunt artifact)
	     (haunt builder blog)
	     (haunt builder atom)
	     (haunt builder assets)
	     (haunt html)
	     (haunt reader commonmark)
	     (haunt site))

(define about-page
  (lambda (site posts)
    (serialized-artifact
     "about.html"
     (with-layout
      layout
      site
      "About"
      `((h2 "Hello!")
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
     sxml->html)))

(define (stylesheet ref)
  `(link (@ (rel "stylesheet") (href ,ref) (type "text/css"))))

(define (head title site)
  `(head
    (meta (@ (charset "utf-8")))
    (meta (@ (name "viewport") (content "width=device-width, initial-scale=1")))
    (title ,(string-append title " — " (site-title site)))
    ,(stylesheet "//fonts.googleapis.com/css?family=Open+Sans:400|Open+Sans:700|JetBrains+Mono:400")
    ,(stylesheet "//cdnjs.cloudflare.com/ajax/libs/highlight.js/11.7.0/styles/default.min.css")
    ,(stylesheet "css/normalize.css")
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
		       about-page
		       (atom-feed)
		       (atom-feeds-by-tag)
		       (static-directory "css")))
