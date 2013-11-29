
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; MODULE      : latex-tools.scm
;; DESCRIPTION : Routines for expansion of macros and preamble construction
;; COPYRIGHT   : (C) 2005  Joris van der Hoeven
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; This software falls under the GNU general public license version 3 or later.
;; It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
;; in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(texmacs-module (convert latex latex-tools)
  (:use (convert latex latex-drd)
	(convert latex texout)))

(tm-define tmtex-cjk-document? #f)
(tm-define tmtex-use-catcodes? #f)
(tm-define tmtex-use-unicode? #f)
(tm-define tmtex-use-ascii? #f)
(tm-define tmtex-use-macros? #f)

(define latex-language "english")
(define latex-style "generic")
(define latex-style-hyp 'generic-style%)
(define latex-packages '())
(define latex-amsthm-hyp 'no-amsthm-package%)

(define latex-uses-table (make-ahash-table))
(define latex-catcode-table (make-ahash-table))
(define latex-macro-table (make-ahash-table))
(define latex-env-table (make-ahash-table))
(define latex-preamble-table (make-ahash-table))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Setting global parameters
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (latex-set-language lan)
  (set! latex-language lan))

(tm-define (latex-set-style sty)
  (if (list? latex-style)
    (set! latex-style (append (cDr latex-style) (list sty)))
    (set! latex-style sty))
  (set! latex-style-hyp (string->symbol (string-append sty "-style%"))))

(tm-define (latex-set-packages ps)
  (set! latex-packages ps)
  (when (in? "amsthm" ps)
    (set! latex-amsthm-hyp 'amsthm-package%)))

(tm-define (latex-book-style?)
  (in? latex-style '("book")))

(define (latex-catcode-defs-char c)
  (let* ((s (string-convert (list->string (list c)) "Cork" "UTF-8"))
         (r (string-convert s "UTF-8" "LaTeX")))
    (if (and (!= r s) (!= (string c) "\n"))
      (ahash-set! latex-catcode-table (string c) r))))

(define (latex-catcode-defs-sub doc)
  (cond ((string? doc) (for-each latex-catcode-defs-char (string->list doc)))
        ((list? doc) (for-each latex-catcode-defs-sub doc))))

(define (latex-catcode-defs-char* c)
  (if (in? c '(#\< #\> #\|))
    (ahash-set! latex-catcode-table (string c)
                (number->string (char->integer c)))))

(define (latex-catcode-defs-sub* doc)
  (cond ((string? doc) (for-each latex-catcode-defs-char* (string->list doc)))
        ((list? doc) (for-each latex-catcode-defs-sub* doc))))

(define (latex-catcode-def key im)
  (string-append "\\catcode`\\" key "=\\active \\def" key "{" im "}\n"))

(tm-define (latex-catcode-defs doc)
  (:synopsis "Return necessary catcode definitions for @doc")
  (string-append
    (if tmtex-use-catcodes?
      (begin
        (set! latex-catcode-table (make-ahash-table))
        (latex-catcode-defs-sub doc)
        (let* ((l1 (ahash-table->list latex-catcode-table))
               (l2 (list-sort l1 (lambda (x y) (string<=? (car x) (car y)))))
               (l3 (map (lambda (x) (latex-catcode-def (car x) (cdr x))) l2)))
          (apply string-append l3))) "")
    (begin
      (set! latex-catcode-table (make-ahash-table))
      (latex-catcode-defs-sub* doc)
      (let* ((l1 (ahash-table->list latex-catcode-table))
             (l2 (list-sort l1 (lambda (x y) (string<=? (car x) (car y)))))
             (keys (map car l2))
             (ims (map (lambda (x)
                         (string-append
                           "\n\\fontencoding{T1}\\selectfont\\symbol{"
                           (cdr x)
                           "}\\fontencoding{\\encodingdefault}"))
                       l2))
             (l3 (map latex-catcode-def keys ims)))
        (apply string-append l3)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Macro and environment expansion
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (env-begin? x)
  (or (func? x '!begin) (func? x '!begin*)))

(define (latex-substitute t args)
  (cond ((number? t) (list-ref args t))
	((== t '---) (car args))
	((func? t '!recurse 1)
	 (latex-expand-macros (latex-substitute (cadr t) args)))
	((func? t '!translate 1)
	 (translate-from-to (cadr t) "english" latex-language))
	((list? t) (map (cut latex-substitute <> args) t))
	(else t)))

(tm-define (latex-expand-macros t)
  (:synopsis "Expand all TeXmacs macros occurring in @t")
  (if (npair? t) t
      (let* ((head  (car t))
	     (tail  (map latex-expand-macros (cdr t)))
	     (body  (logic-ref latex-texmacs-macro% head
			     latex-style-hyp latex-amsthm-hyp))
	     (arity (logic-ref latex-texmacs-arity% head
			     latex-style-hyp latex-amsthm-hyp))
	     (env   (and (env-begin? head)
			 (logic-ref latex-texmacs-environment% (cadr head)
				  latex-style-hyp latex-amsthm-hyp)))
	     (envar (and (env-begin? head)
			 (logic-ref latex-texmacs-env-arity% (cadr head)
				  latex-style-hyp latex-amsthm-hyp))))
	(cond ((and body (== (length tail) arity))
	       (latex-substitute body t))
	      ((and env (== (length tail) 1) (== (length (cddr head)) envar))
	       (latex-substitute env (append (cdr t) (cddr head))))
	      (else (cons head tail))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Adding TeXmacs sources
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (latex-add-texmacs-sources t doc)
  (:synopsis "Add to @t the source @doc coded in base64 @t")
  (if (not (func? t '!file)) t
    (let* ((str (object->string doc))
           (d   (cpp-verbatim-snippet->texmacs (encode-base64 str) #t "ascii"))
           (d*  `(!paragraph ""
                             "-----BEGIN TEXMACS DOCUMENT-----"
                             ""
                             ,(tree->stree d)
                             ""
                             "-----END TEXMACS DOCUMENT-----")))
      `(!file ,@(cdr t) (!paragraph "" (!comment ,(tmtex d*)))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Compute macro and environment definitions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (latex-expand-def t)
  (cond ((== t '---) "#-#-#")
	((number? t) (string-append "#" (number->string t)))
	((func? t '!recurse 1) (latex-expand-def (cadr t)))
	((func? t '!translate 1)
	 (translate-from-to (cadr t) "english" latex-language))
	((list? t) (map latex-expand-def t))
	(else t)))

;; TODO: to be rewrited with better factorisation
(define (latex-macro-defs-sub t)
  (when (pair? t)
    (for-each latex-macro-defs-sub (cdr t))
    (let* ((body  (and
                    (not (logic-ref latex-needs% (car t)))
                    (logic-ref latex-texmacs-macro% (car t)
                               latex-style-hyp latex-amsthm-hyp)))
	   (arity (logic-ref latex-texmacs-arity% (car t)
			   latex-style-hyp latex-amsthm-hyp))
           (option (logic-ref latex-texmacs-option% (car t)))
           (args   (if option (filter (lambda (x)
                                        (not (and (list? x)
                                                  (== (car x) '!option))))
                                      (cdr t))
                     (cdr t))))
      (when (and body (== (length args) arity))
        (if option (set! arity (+ 1 arity)))
	(ahash-set! latex-macro-table (car t)
		    (list arity (latex-expand-def body)))
	(latex-macro-defs-sub body)))
    (let* ((body  (and (env-begin? (car t))
                       (not (logic-ref latex-needs% (string->symbol (cadar t))))
                       (logic-ref latex-texmacs-environment% (cadar t))))
	   (arity (and (env-begin? (car t))
		       (logic-ref latex-texmacs-env-arity% (cadar t))))
           (option (and (env-begin? (car t))
                        (logic-ref latex-texmacs-option% (cadar t))))
           (args   (and (env-begin? (car t))
                        (if option (filter (lambda (x)
                                             (not (and (list? x)
                                                       (== (car x) '!option))))
                                           (car t))
                            (car t)))))
      (when (and body (== (length args) (+ arity 2)))
        (if option (set! arity (+ 1 arity)))
	(ahash-set! latex-env-table (cadar t)
		    (list arity (latex-expand-def body)))
	(latex-macro-defs-sub body)))
    (with body (or (and
                     (not (logic-ref latex-needs% (car t)))
                     (logic-ref latex-texmacs-preamble% (car t)
                                latex-style-hyp latex-amsthm-hyp))
		   (and (env-begin? (car t))
                        (not (logic-ref latex-needs% (string->symbol (cadar t))))
                        (logic-ref latex-texmacs-env-preamble% (cadar t)
                                   latex-style-hyp latex-amsthm-hyp)))
      (when body
	(ahash-set! latex-preamble-table (car t) body)))))

(define (latex<=? x y)
  (if (symbol? x) (set! x (symbol->string x)))
  (if (symbol? y) (set! y (symbol->string y)))
  (if (env-begin? x) (set! x (cadr x)))
  (if (env-begin? y) (set! y (cadr y)))
  (string<=? x y))

(tm-define (latex-macro-defs t)
  (:synopsis "Return necessary macro and environment definitions for @doc")
  (set! latex-macro-table (make-ahash-table))
  (set! latex-env-table (make-ahash-table))
  (set! latex-preamble-table (make-ahash-table))
  (latex-macro-defs-sub t)
  (let* ((c1 (ahash-table->list latex-macro-table))
	 (c2 (list-sort c1 (lambda (x y) (latex<=? (car x) (car y)))))
	 (c3 (map (cut cons '!newcommand <>) c2))
	 (e1 (ahash-table->list latex-env-table))
	 (e2 (list-sort e1 (lambda (x y) (latex<=? (car x) (car y)))))
	 (e3 (map (cut cons '!newenvironment <>) e2))
	 (p1 (ahash-table->list latex-preamble-table))
	 (p2 (list-sort p1 (lambda (x y) (latex<=? (car x) (car y)))))
	 (p3 (map cdr (map latex-expand-def p2))))
    (cons '!append (append c3 e3 p3))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Serialization of TeXmacs preambles
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (latex-macro-def name arity body)
  (with option ""
    (if (and (list>1? body) (list? (car body)) (== (caar body) '!option))
      (begin
        (set! option (serialize-latex (latex-expand-def (cadar body))))
        (set! option (string-append "[" option "]"))
        (set! body (cadr body))))
    (set! body (serialize-latex (latex-expand-def body)))
    (set! body (string-replace body "\n\n" "*/!!/*"))
    (set! body (string-replace body "\n" " "))
    (set! body (string-replace body "*/!!/*" "\n\n"))
    (set! arity (if (= arity 0) ""
                  (string-append "[" (number->string arity) "]")))
    (string-append "\\newcommand{\\" (symbol->string name) "}"
                   arity option "{" body "}\n")))

(define (latex-env-def name arity body)
  (with option ""
    (if (and (list>1? body) (list? (car body)) (== (caar body) '!option))
      (begin
        (set! option (serialize-latex (latex-expand-def (cadar body))))
        (set! option (string-append "[" option "]"))
        (set! body (cadr body))))
    (set! body (serialize-latex (latex-expand-def body)))
    (set! body (string-replace body "\n\n" "*/!!/*"))
    (set! body (string-replace body "\n  " " "))
    (set! body (string-replace body "\n" " "))
    (set! body (string-replace body "   #-#-# " "}{"))
    (set! body (string-replace body "#-#-# " "}{"))
    (set! body (string-replace body "#-#-#" "}{"))
    (set! body (string-replace body "*/!!/*" "\n\n"))
    (set! arity (if (= arity 0) ""
                  (string-append "[" (number->string arity) "]")))
    (string-append "\\newenvironment{" name "}"
		   arity option "{" body "}\n")))

(tm-define (latex-serialize-preamble t)
  (:synopsis "Serialize a LaTeX preamble @t")
  (cond ((string? t) t)
	((func? t '!append)
	 (apply string-append (map latex-serialize-preamble (cdr t))))
	((func? t '!newcommand 3) (apply latex-macro-def (cdr t)))
	((func? t '!newenvironment 3) (apply latex-env-def (cdr t)))
	(else (serialize-latex t))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Compute usepackage command for a document
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (latex-command-uses s)
  (with packlist (logic-ref-list latex-needs% s)
    (when packlist
      (if (string? packlist) (set! packlist (list packlist)))
      (for-each (cut ahash-set! latex-uses-table <> #t) packlist))))

(define (latex-use-which-package l)
  (when (and (list? l) (nnull? l))
    (let ((x (car l)))
      (if (symbol? x) (latex-command-uses x))
      (if (and (list? x) (>= (length l) 2) (== (car x) '!begin))
	  (latex-command-uses (string->symbol (cadr x))))
      (if (match? x '(!begin "enumerate" (!option :%1)))
	  (ahash-set! latex-uses-table "enumerate" #t))
      (for-each latex-use-which-package (cdr l)))))

(define (latex-use-package-compare l r)
  (let* ((tl (logic-ref latex-package-priority% l))
	 (tr (logic-ref latex-package-priority% r))
	 (vl (if tl tl 999999))
	 (vr (if tr tr 999999)))
    (< vl vr)))

(define (filter-packages l)
  (filter (lambda (x) (nin? x tmtex-provided-packages)) l))

(define (latex-as-use-package l1)
  (let* ((l2 (sort l1 latex-use-package-compare))
	 (l3 (map force-string l2))
         (l4 (filter-packages l3))
	 (l5 (list-intersperse l4 ","))
	 (s  (apply string-append l5)))
    (if (== s "") "" (string-append "\\usepackage{" s "}\n"))))

(tm-define (latex-use-package-command doc)
  (:synopsis "Return the usepackage command for @doc")
  (set! latex-uses-table (make-ahash-table))
  (latex-use-which-package doc)
  (let* ((l1 latex-packages)
	 (s1 (latex-as-use-package (list-difference l1 '("amsthm"))))
	 (l2 (map car (ahash-table->list latex-uses-table)))
	 (s2 (latex-as-use-package (list-difference l2 l1))))
    (string-append s1 s2)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Page size settings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (latex-preamble-language lan)
      (string-append "\\usepackage[" lan "]{babel}\n"))

(define (latex-preamble-page-type init)
  (let* ((page-type (ahash-ref init "page-type"))
	 (page-size (logic-ref latex-paper-type% page-type)))
    (if page-size `(!append (geometry ,page-size) "\n") "")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Building the preamble
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (latex-make-option l)
  (string-append "[" (apply string-append (list-intersperse l ",")) "]"))

(tm-define (latex-preamble text style lan init)
  (:synopsis "Compute preamble for @text")
  (let* ((Page         (latex-preamble-page-type init))
	 (Macro        (latex-macro-defs text))
	 (Text         (list '!tuple Page Macro text))
	 (pre-page     (latex-serialize-preamble Page))
	 (pre-macro    (latex-serialize-preamble Macro))
	 (pre-catcode  (latex-catcode-defs Text))
	 (pre-uses     (latex-use-package-command Text)))
    (values
      (cond ((and (in? "amsthm" latex-packages)(== style "amsart")) "[amsthm]")
            ((list? style) (latex-make-option (cDr style)))
            (else ""))
      (string-append pre-uses)
      (string-append pre-page)
      (string-append pre-catcode pre-macro))))
