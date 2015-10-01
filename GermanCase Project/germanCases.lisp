(defvar *response* nil)
(defvar *response-time* nil)
;; (defvar *scores* nil)
;; (defvar *times* nil)
(setf *answers* nil)
(setf *scores* nil)
(setf *times* nil)
(defvar *rounds* 12)
(setf *rounds* 12)
(defvar *model-doing-task* nil)

(defvar *definite-case-rules* '(("der" "masculine" "nominative")("die" "feminine" "nominative")
	("das" "neuter" "nominative")("den" "masculine" "accusative")
	("die" "feminine" "accusative")("das" "neuter" "accusative")
	("dem" "masculine" "dative")("der" "feminine" "dative")
	("dem" "neuter" "dative")("des" "masculine" "genitive")
	("der" "feminine" "genitive")("des" "neuter" "genitive")))
	
(defvar *indefinite-case-rules*	'(("ein" "masculine" "nominative")("eine" "feminine" "nominative")
	("ein" "neuter" "nominative")("einen" "masculine" "accusative")
	("eine" "feminine" "accusative")("ein" "neuter" "accusative")
	("einem" "masculine" "dative")("einer" "feminine" "dative")
	("einem" "neuter" "dative")("eines" "masculine" "genitive")
	("einer" "feminine" "genitive")("eines" "neuter" "genitive")))

	
	
(defvar *articles* (list (list (list "a" "der" "Z")(list "a" "ein" "A"))
					 (list (list "the" "der" "A")(list "a" "eine" "A")(list "the" "ein" "Z")(list "the" "der" "A"))
					 (list (list "a" "der" "Z")(list "a" "ein" "Z")(list "a" "ein" "A")(list "the" "der" "A")
					  (list "a" "der" "Z")(list "a" "ein" "Z"))
					(list (list "the" "der" "Z" "a" "ein" "Z")(list "the" "das" "Z" "a" "einen" "A"))
					(list (list "the" "ein" "Z" "a" "den" "A")(list "a" "ein" "Z" "a" "eine" "A")
					 (list "a" "eine" "Z" "the" "den" "Z")(list "the" "die" "A" "the" "den" "A"))
					(list (list "the" "das" "A" "a" "den" "Z")(list "the" "der" "A" "a" "einen" "Z")
					 (list "a" "eine" "Z" "a" "einen" "A")(list "the" "das" "A" "the" "den" "A")
					 (list "the" "die" "A" "a" "eine" "Z")(list "the" "das" "Z" "a" "ein" "Z"))
					(list (list "a" "ein" "A" "a" "einen" "Z" "toXa" "einem" "A")
					 (list "the" "die" "Z" "a" "ein" "Z" "toXthe" "dem" "A")
					 (list "the" "die" "A" "a" "eine" "Z" "toXa" "einen" "Z"))
					(list (list "a" "eine" "A" "a" "ein" "A" "toXthe" "dem" "Z")
					 (list "a" "eine" "A" "a" "eine" "Z" "toXa" "einer" "Z")
					 (list "a" "ein" "A" "the" "die" "A" "toXthe" "der" "A")
					 (list "a" "ein" "Z" "a" "ein" "Z" "toXa" "einer" "A")
					 (list "the" "das" "Z" "the" "das" "A" "toXa" "ein" "Z")
					 (list "the" "der" "A" "the" "der" "Z" "toXthe" "dem" "A"))
					(list (list "a" "ein" "Z" "a" "ein" "Z" "toXthe" "der" "A")
					 (list "a" "ein" "A" "a" "eine" "A" "toXa" "einer" "A")
					 (list "the" "der" "A" "the" "den" "A" "toXa" "eine" "Z")
					 (list "a" "ein" "A" "the" "den" "A" "toXthe" "dem" "A")
					 (list "the" "eine" "Z" "the" "den" "Z" "toXa" "einer" "A")
					 (list "the" "das" "Z" "a" "einen" "A" "toXthe" "der" "Z")
					 (list "the" "das" "A" "the" "den" "A" "toXthe" "der" "Z")
					 (list "the" "die" "Z" "a" "eine" "Z" "toXa" "ein" "Z")
					 (list "a" "eine" "Z" "the" "der" "Z" "toXa" "der" "Z"))
					(list (list "a" "der" "Z" "the" "das" "A" "toXa" "einer" "Z" "ofXa" "einem" "Z")
					 (list "the" "das" "Z" "a" "ein" "Z" "toXa" "ein" "Z" "ofXthe" "des" "A")
					 (list "the" "das" "A" "the" "den" "A" "toXa" "einem" "A" "ofXthe" "der" "Z")
					 (list "the" "der" "A" "the" "die" "A" "toXa" "einen" "Z" "ofXa" "eines" "A"))
					(list (list "the" "die" "A" "a" "einen" "Z" "toXthe" "der" "Z" "ofXa" "einer" "A")
					 (list "a" "der" "Z" "the" "das" "A" "toXthe" "den" "Z" "ofXthe" "des" "A")
					 (list "the" "die" "Z" "a" "eine" "Z" "toXthe" "das" "Z" "ofXthe" "der" "Z")
					 (list "a" "ein" "Z" "the" "den" "Z" "toXthe" "dem" "A" "ofXa" "eines" "A")
					 (list "a" "eine" "Z" "a" "einen" "A" "toXthe" "der" "A" "ofXthe" "der" "Z")
					 (list "the" "das" "A" "a" "eine" "A" "toXa" "einer" "A" "ofXa" "der" "Z")
					 (list "a" "eine" "Z" "a" "eine" "A" "toXa" "eine" "Z" "ofXthe" "der" "A")
					 (list "a" "ein" "A" "the" "den" "Z" "toXthe" "der" "A" "ofXa" "eines" "Z"))
					(list (list "a" "eine" "Z" "a" "ein" "Z" "toXthe" "das" "Z" "ofXthe" "des" "A")
					 (list "a" "ein" "A" "a" "ein" "A" "toXthe" "ein" "Z" "ofXa" "einer" "A")
					 (list "a" "ein" "A" "the" "das" "A" "toXthe" "dem" "A" "ofXthe" "dem" "Z")
					 (list "a" "eine" "Z" "a" "ein" "Z" "toXthe" "dem" "A" "ofXthe" "der" "A")
					 (list "the" "die" "A" "a" "einen" "Z" "toXa" "einem" "Z" "ofXa" "der" "Z")
					 (list "a" "der" "Z" "a" "ein" "A" "toXa" "einer" "A" "ofXa" "eines" "A")
					 (list "a" "eine" "A" "a" "ein" "Z" "toXa" "einem" "A" "ofXthe" "der" "Z")
					 (list "the" "der" "Z" "a" "einen" "A" "toXa" "einem" "A" "ofXthe" "des" "A")
					 (list "the" "der" "A" "the" "die" "Z" "toXa" "einem" "A" "ofXthe" "der" "Z")
					 (list "a" "ein" "A" "a" "eine" "Z" "toXthe" "dem" "Z" "ofXa" "eines" "A")
					 (list "a" "der" "Z" "a" "eine" "A" "toXthe" "dem" "A" "ofXa" "einer" "Z")
					 (list "a" "eine" "A" "a" "eine" "A" "toXa" "ein" "Z" "ofXa" "einem" "Z"))))
	
	


(defvar *masculine-nouns* (list (list "Mann" "man" 'red) (list "Hund" "dog" 'red) (list "Konig" "king" 'red)
				(list "Fisch" "fish" 'red) (list "Apfel" "apple" 'red) (list "Elefant" "elephant" 'red)
				(list "Schuh" "shoe" 'red) (list "Krebs" "crab" 'red) (list "Honig" "honey" 'red) 
				(list "Ball" "ball" 'red)))

(defvar *first-verbs* '(("bricht" "breaks")("schlagt" "hits") 
						("wirft" "throws")("totet" "kills") 
						("trinkt" "drinks")("isst" "eats")
						("greift" "grabs") ("hat" "has")
						("kitzelt" "tickles") ("braucht" "needs")))
				
(defvar *second-verbs* '(("gibt" "gives") ("zeigt" "shows")
                  ("schickt" "sends")))
				  
(defvar *neuter-nouns* (list (list "Madchen" "girl" 'green) (list "Bett" "bed" 'green) (list "Hemd" "shirt" 'green)
				(list "Fenster" "window" 'green) (list "Brett" "board" 'green) (list "Geld" "money" 'green)
				(list "Wasser" "water" 'green) (list "Holz" "wood" 'green) (list "Getrank" "drink" 'green) 
				(list "Tier" "animal" 'green)))

(defvar *feminine-nouns* (list (list "Frau" "woman" 'blue) (list "Konigin" "queen" 'blue) (list "Katze" "cat" 'blue)
				(list "Ente" "duck" 'blue) (list "Flasche" "bottle" 'blue) (list "Kuh" "cow" 'blue)
				(list "Milch" "milk" 'blue) (list "Frucht" "fruit" 'blue) (list "Schussel" "bowl" 'blue) 
				(list "Gitarre" "guitar" 'blue)))

(defvar *nouns* (list (list (list (nth (random 10) *masculine-nouns*))(list (nth (random 10) *masculine-nouns*)))
	(list (list (nth (random 10) *masculine-nouns*)) (list (nth (random 10) *feminine-nouns*))
	 (list (nth (random 10) *feminine-nouns*)) (list (nth (random 10) *masculine-nouns*)))
	(list (list (nth (random 10) *neuter-nouns*)) (list (nth (random 10) *feminine-nouns*))
	 (list (nth (random 10) *masculine-nouns*)) (list (nth (random 10) *masculine-nouns*))
	 (list (nth (random 10) *neuter-nouns*)) (list (nth (random 10) *feminine-nouns*)))
	(list (list (nth (random 10) *neuter-nouns*)(nth (random 10) *masculine-nouns*))
     (list (nth (random 10) *masculine-nouns*)(nth (random 10) *masculine-nouns*)))
	(list (list (nth (random 10) *feminine-nouns*)(nth (random 10) *masculine-nouns*))
	 (list (nth (random 10) *feminine-nouns*)(nth (random 10) *feminine-nouns*))
	 (list (nth (random 10) *masculine-nouns*)(nth (random 10) *feminine-nouns*))
	 (list (nth (random 10) *feminine-nouns*)(nth (random 10) *masculine-nouns*)))
	(list (list (nth (random 10) *neuter-nouns*)(nth (random 10) *neuter-nouns*))
	 (list (nth (random 10) *masculine-nouns*)(nth (random 10) *feminine-nouns*))
	 (list (nth (random 10) *feminine-nouns*)(nth (random 10) *masculine-nouns*))
	 (list (nth (random 10) *neuter-nouns*)(nth (random 10) *masculine-nouns*))
	 (list (nth (random 10) *feminine-nouns*)(nth (random 10) *neuter-nouns*))
	 (list (nth (random 10) *feminine-nouns*)(nth (random 10) *feminine-nouns*)))
	(list (list (nth (random 10) *neuter-nouns*)(nth (random 10) *feminine-nouns*)(nth (random 10) *masculine-nouns*))
	 (list (nth (random 10) *masculine-nouns*)(nth (random 10) *feminine-nouns*)(nth (random 10) *masculine-nouns*))
	 (list (nth (random 10) *feminine-nouns*)(nth (random 10) *neuter-nouns*)(nth (random 10) *masculine-nouns*)))
	(list ( list (nth (random 10) *feminine-nouns*)(nth (random 10) *masculine-nouns*)(nth (random 10) *feminine-nouns*))
	 (list (nth (random 10) *feminine-nouns*)(nth (random 10) *neuter-nouns*)(nth (random 10) *masculine-nouns*))
	 (list (nth (random 10) *masculine-nouns*)(nth (random 10) *feminine-nouns*)(nth (random 10) *feminine-nouns*))
	 (list (nth (random 10) *feminine-nouns*)(nth (random 10) *masculine-nouns*)(nth (random 10) *feminine-nouns*))
	 (list (nth (random 10) *masculine-nouns*)(nth (random 10) *neuter-nouns*)(nth (random 10) *masculine-nouns*))
	 (list (nth (random 10) *masculine-nouns*)(nth (random 10) *masculine-nouns*)(nth (random 10) *masculine-nouns*)))
	(list (list (nth (random 10) *feminine-nouns*)(nth (random 10) *masculine-nouns*)(nth (random 10) *feminine-nouns*))
	 (list (nth (random 10) *neuter-nouns*)(nth (random 10) *feminine-nouns*)(nth (random 10) *masculine-nouns*))
	 (list (nth (random 10) *masculine-nouns*)(nth (random 10) *masculine-nouns*)(nth (random 10) *feminine-nouns*))
	 (list (nth (random 10) *masculine-nouns*)(nth (random 10) *masculine-nouns*)(nth (random 10) *neuter-nouns*))
	 (list (nth (random 10) *feminine-nouns*)(nth (random 10) *feminine-nouns*)(nth (random 10) *masculine-nouns*))
	 (list (nth (random 10) *neuter-nouns*)(nth (random 10) *masculine-nouns*)(nth (random 10) *masculine-nouns*))
	 (list (nth (random 10) *neuter-nouns*)(nth (random 10) *masculine-nouns*)(nth (random 10) *neuter-nouns*))
	 (list (nth (random 10) *feminine-nouns*)(nth (random 10) *neuter-nouns*)(nth (random 10) *feminine-nouns*))
	 (list (nth (random 10) *neuter-nouns*)(nth (random 10) *masculine-nouns*)(nth (random 10) *neuter-nouns*)))
	(list (list (nth (random 10) *feminine-nouns*)(nth (random 10) *neuter-nouns*)
	  (nth (random 10) *neuter-nouns*)(nth (random 10) *masculine-nouns*))
	 (list (nth (random 10) *masculine-nouns*)(nth (random 10) *masculine-nouns*)
	  (nth (random 10) *neuter-nouns*)(nth (random 10) *masculine-nouns*))
	 (list (nth (random 10) *neuter-nouns*)(nth (random 10) *masculine-nouns*)
	  (nth (random 10) *neuter-nouns*)(nth (random 10) *masculine-nouns*))
	 (list (nth (random 10) *masculine-nouns*)(nth (random 10) *feminine-nouns*)
	  (nth (random 10) *neuter-nouns*)(nth (random 10) *masculine-nouns*)))
	(list (list (nth (random 10) *feminine-nouns*)(nth (random 10) *neuter-nouns*)
	  (nth (random 10) *masculine-nouns*)(nth (random 10) *feminine-nouns*))
	 (list (nth (random 10) *neuter-nouns*)(nth (random 10) *neuter-nouns*)
	  (nth (random 10) *masculine-nouns*)(nth (random 10) *masculine-nouns*))
	 (list (nth (random 10) *neuter-nouns*)(nth (random 10) *neuter-nouns*)
	  (nth (random 10) *feminine-nouns*)(nth (random 10) *feminine-nouns*))
	 (list (nth (random 10) *feminine-nouns*)(nth (random 10) *feminine-nouns*)
	  (nth (random 10) *masculine-nouns*)(nth (random 10) *masculine-nouns*))
	 (list (nth (random 10) *masculine-nouns*)(nth (random 10) *masculine-nouns*)
	  (nth (random 10) *feminine-nouns*)(nth (random 10) *masculine-nouns*))
	 (list (nth (random 10) *neuter-nouns*)(nth (random 10) *feminine-nouns*)
	  (nth (random 10) *feminine-nouns*)(nth (random 10) *masculine-nouns*))
	 (list (nth (random 10) *masculine-nouns*)(nth (random 10) *feminine-nouns*)
	  (nth (random 10) *neuter-nouns*)(nth (random 10) *feminine-nouns*))
	 (list (nth (random 10) *neuter-nouns*)(nth (random 10) *neuter-nouns*)
	  (nth (random 10) *feminine-nouns*)(nth (random 10) *feminine-nouns*)))
	(list (list (nth (random 10) *masculine-nouns*)(nth (random 10) *feminine-nouns*)
	  (nth (random 10) *neuter-nouns*)(nth (random 10) *masculine-nouns*))
	 (list (nth (random 10) *neuter-nouns*)(nth (random 10) *neuter-nouns*)
	  (nth (random 10) *neuter-nouns*)(nth (random 10) *feminine-nouns*))
	 (list (nth (random 10) *masculine-nouns*)(nth (random 10) *neuter-nouns*)
	  (nth (random 10) *masculine-nouns*)(nth (random 10) *feminine-nouns*))
	 (list (nth (random 10) *neuter-nouns*)(nth (random 10) *masculine-nouns*)
	  (nth (random 10) *neuter-nouns*)(nth (random 10) *feminine-nouns*))
	 (list (nth (random 10) *feminine-nouns*)(nth (random 10) *masculine-nouns*)
	  (nth (random 10) *feminine-nouns*)(nth (random 10) *feminine-nouns*))
	 (list (nth (random 10) *masculine-nouns*)(nth (random 10) *neuter-nouns*)
	  (nth (random 10) *feminine-nouns*)(nth (random 10) *neuter-nouns*))
	 (list (nth (random 10) *feminine-nouns*)(nth (random 10) *masculine-nouns*)
	  (nth (random 10) *masculine-nouns*)(nth (random 10) *masculine-nouns*))
	 (list (nth (random 10) *neuter-nouns*)(nth (random 10) *masculine-nouns*)
	  (nth (random 10) *neuter-nouns*)(nth (random 10) *masculine-nouns*))
	 (list (nth (random 10) *masculine-nouns*)(nth (random 10) *feminine-nouns*)
	  (nth (random 10) *neuter-nouns*)(nth (random 10) *neuter-nouns*))
	 (list (nth (random 10) *masculine-nouns*)(nth (random 10) *neuter-nouns*)
	  (nth (random 10) *feminine-nouns*)(nth (random 10) *neuter-nouns*))
	 (list (nth (random 10) *neuter-nouns*)(nth (random 10) *feminine-nouns*)
	  (nth (random 10) *masculine-nouns*)(nth (random 10) *neuter-nouns*))
	 (list (nth (random 10) *feminine-nouns*)(nth (random 10) *masculine-nouns*)
	  (nth (random 10) *feminine-nouns*)(nth (random 10) *masculine-nouns*)))))
				
				
				
(defvar *verbs* (list (nth (random 10) *first-verbs*)(nth (random 10) *first-verbs*)
		(nth (random 10) *first-verbs*)(nth (random 10) *first-verbs*)(nth (random 10) *first-verbs*)
		(nth (random 10) *first-verbs*)(nth (random 10) *first-verbs*)(nth (random 10) *first-verbs*)
		(nth (random 10) *first-verbs*)(nth (random 10) *first-verbs*)(nth (random 10) *first-verbs*)
		(nth (random 10) *first-verbs*)(nth (random 10) *first-verbs*)(nth (random 10) *first-verbs*)
		(nth (random 10) *first-verbs*)(nth (random 10) *first-verbs*)(nth (random 10) *first-verbs*)
		(nth (random 10) *first-verbs*)(nth (random 10) *first-verbs*)(nth (random 10) *first-verbs*)
		(nth (random 10) *first-verbs*)(nth (random 10) *first-verbs*)(nth (random 10) *first-verbs*)
		(nth (random 10) *first-verbs*)(nth (random 3) *second-verbs*)(nth (random 3) *second-verbs*)
		(nth (random 3) *second-verbs*)(nth (random 3) *second-verbs*)(nth (random 3) *second-verbs*)
		(nth (random 3) *second-verbs*)(nth (random 3) *second-verbs*)(nth (random 3) *second-verbs*)
		(nth (random 3) *second-verbs*)(nth (random 3) *second-verbs*)(nth (random 3) *second-verbs*)
		(nth (random 3) *second-verbs*)(nth (random 3) *second-verbs*)(nth (random 3) *second-verbs*)
		(nth (random 3) *second-verbs*)(nth (random 3) *second-verbs*)(nth (random 3) *second-verbs*)
		(nth (random 3) *second-verbs*)(nth (random 3) *second-verbs*)(nth (random 3) *second-verbs*)
		(nth (random 3) *second-verbs*)(nth (random 3) *second-verbs*)(nth (random 3) *second-verbs*)
		(nth (random 3) *second-verbs*)(nth (random 3) *second-verbs*)(nth (random 3) *second-verbs*)
		(nth (random 3) *second-verbs*)(nth (random 3) *second-verbs*)(nth (random 3) *second-verbs*)
		(nth (random 3) *second-verbs*)(nth (random 3) *second-verbs*)(nth (random 3) *second-verbs*)
		(nth (random 3) *second-verbs*)(nth (random 3) *second-verbs*)(nth (random 3) *second-verbs*)
		(nth (random 3) *second-verbs*)(nth (random 3) *second-verbs*)(nth (random 3) *second-verbs*)
		(nth (random 3) *second-verbs*)(nth (random 3) *second-verbs*)(nth (random 3) *second-verbs*)
		(nth (random 3) *second-verbs*)))
		
		
(defun germanCase-experiment (&optional who)
	(if (not (eq who 'human))
      (do-experiment-model)
   (do-experiment-person)))
   
(defun many-times (amount)
	(dotimes (i amount)
		(do-experiment-model)))

(defun do-experiment-model ()
  (let ((result 1)
	(window (open-exp-window "German-Case Experiment" :visible nil)))
    
    (setf *model-doing-task* t)
	(setf times '())
	(setf scores '())
	(setf *times* '())
	(setf *scores* '())
	(setf rounds *rounds*)
	
    (reset)
	(install-device window)
	(setf count 0)
	(dotimes (trial rounds)
		(let ((nouns (nth trial *nouns*))(articles (nth trial *articles*))
	      (round-scores '())(round-times '())(round-results '()))
			(add-study-fact-to-memory trial)
			(setf *answers* nil)
			(cond ((< trial 3)
				(dotimes (j (length articles))
					(setf k 0)
					(setf verbs (nth count *verbs*))
					(display-trial trial j k nouns verbs articles)
					(setf *response* nil)                   
					(setf *response-time* nil)
					(setf start-time (get-time t))
					(proc-display)
					(run 60)
					(mod-focus state start)
					(while (null *response-time*)
						(allow-event-manager window))
					(push (/ (- *response-time* start-time) 1000.0) round-times)
					(if (equal (nth (+ (* k 3) 2) (nth j articles)) *response*)
						(push 1.0 round-scores)
						(push 0.0 round-scores))
					;;(print *response*)
					(push (nth (+ (* k 3) 2) (nth j articles)) *answers*)
					(setf count (+ count 1))))
			((< trial 6)
				(dotimes (j (length articles))
					(dotimes (k 2)
						(setf verbs (nth count *verbs*))
						(display-trial trial j k nouns verbs articles)
						(setf *response* nil)                   
						(setf *response-time* nil)
						(setf start-time (get-time t))
						(proc-display)
						(run 60)
						(mod-focus state start)
						(while (null *response-time*)
							(allow-event-manager window))
						(push (/ (- *response-time* start-time) 1000.0) round-times)
						(if (equal (nth (+ (* k 3) 2) (nth j articles)) *response*)
							(push 1.0 round-scores)
							(push 0.0 round-scores))
						(push (nth (+ (* k 3) 2) (nth j articles)) *answers*))
					(setf count (+ count 1))))
			((< trial 9)
				(dotimes (j (length articles))
					(dotimes (k 3)
						(setf verbs (nth count *verbs*))
						(display-trial trial j k nouns verbs articles)
						(setf *response* nil)                   
						(setf *response-time* nil)
						(setf start-time (get-time t))
						(proc-display)
						(run 60)
						(mod-focus state start)
						(while (null *response-time*)
							(allow-event-manager window))
						(push (/ (- *response-time* start-time) 1000.0) round-times)
						(if (equal (nth (+ (* k 3) 2) (nth j articles)) *response*)
							(push 1.0 round-scores)
							(push 0.0 round-scores))
						(push (nth (+ (* k 3) 2) (nth j articles)) *answers*))
					(setf count (+ count 1))))
			(t
				(dotimes (j (length articles))
					(dotimes (k 4)
						(setf verbs (nth count *verbs*))
						(display-trial trial j k nouns verbs articles)
						(setf *response* nil)                   
						(setf *response-time* nil)
						(setf start-time (get-time t))
						(proc-display)
						(run 60)
						(mod-focus state start)
						(while (null *response-time*)
							(allow-event-manager window))
						(push (/ (- *response-time* start-time) 1000.0) round-times)
						(if (equal (nth (+ (* k 3) 2) (nth j articles)) *response*)
							(push 1.0 round-scores)
							(push 0.0 round-scores))
						(push (nth (+ (* k 3) 2) (nth j articles)) *answers*))
					(setf count (+ count 1)))))
			(print round-scores)
			(print round-times)
			;;(setf sumT (/ (apply '+ round-times) (length round-times)))
			;;(setf sumS (/ (apply '+ round-scores) (length round-scores)))
			;;(print sumS)
			;;(print sumT)
			;;(print *answers*)
			(push round-scores *scores*)
			(push round-times *times*)
			))
	(with-open-file (f (concatenate 'string "data" (write-to-string (random 10000)) ".txt") :direction :output :if-does-not-exist :create)
		(dotimes (s (length *scores*))
			(print (nth s *scores*) f)
			(print (nth s *times*) f)))		
	  
   ))
   
(defun do-experiment-person ()
  (let ((result 1)
	(window (open-exp-window "German-Case Experiment" :visible t)))
    
    (setf *model-doing-task* nil)
    (setf *times* '())
	(setf *scores* '())
	(setf rounds *rounds*)
	
	;; (clear-exp-window)
	(add-text-to-exp-window :text "The experiment will begin shortly" :x 150 :y 150)
	(sleep 20.0)
	
	(setf count 0)
	;; (clear-exp-window)
	(dotimes (trial rounds)
		(let ((nouns (nth trial *nouns*))(articles (nth trial *articles*))
	      (round-scores '())(round-times '())(round-results '()))
			
			(clear-exp-window)
			(add-text-to-exp-window :text "the/of the/to the" :x 100 :y 100 :width 25)
			(add-text-to-exp-window :text (concatenate 'string (nth 0 (nth trial *definite-case-rules*))
                                       " is the " (nth 1 (nth trial *definite-case-rules*)) ", "
									   (nth 2 (nth trial *definite-case-rules*)) " case") :x 100 :y 150 :width 25)
			(sleep 10.0)
			
			(clear-exp-window)
			(add-text-to-exp-window :text "a/an/of an/to an" :x 100 :y 100 :width 25)
			(add-text-to-exp-window :text (concatenate 'string (nth 0 (nth trial *indefinite-case-rules*))
                                       " is the " (nth 1 (nth trial *indefinite-case-rules*)) ", "
									   (nth 2 (nth trial *indefinite-case-rules*)) " case") :x 100 :y 150 :width 25)
			(sleep 10.0)
			(setf *answers* nil)
			(cond ((< trial 3)
				(dotimes (j (length articles))
					(setf k 0)
					(setf verbs (nth count *verbs*))
					(display-trial trial j k nouns verbs articles)
					(setf *response* nil)                   
					(setf *response-time* nil)
					(setf start-time (get-time nil))
				
					(while (null *response-time*)
						(allow-event-manager window))
					(push (/ (- *response-time* start-time) 1000.0) round-times)
					(if (equal (nth (+ (* k 3) 2) (nth j articles)) *response*)
						(push 1.0 round-scores)
						(push 0.0 round-scores))
					
					(push (nth (+ (* k 3) 2) (nth j articles)) *answers*)
					(setf count (+ count 1))))
			((< trial 6)
				(dotimes (j (length articles))
					(dotimes (k 2)
					    (setf verbs (nth count *verbs*))
						(display-trial trial j k nouns verbs articles)
						(setf *response* nil)
						(setf *response-time* nil)
						(setf start-time (get-time nil))
				
						(while (null *response-time*)
							(allow-event-manager window))
						(push (/ (- *response-time* start-time) 1000.0) round-times)
						(if (equal (nth (+ (* k 3) 2) (nth j articles)) *response*)
							(push 1.0 round-scores)
							(push 0.0 round-scores))
						(push (nth (+ (* k 3) 2) (nth j articles)) *answers*))
					(setf count (+ count 1))))
			((< trial 9)
				(dotimes (j (length articles))
					(dotimes (k 3)
					    (setf verbs (nth count *verbs*))
						(display-trial trial j k nouns verbs articles)
						(setf *response* nil)
						(setf *response-time* nil)
						(setf start-time (get-time nil))
				
						(while (null *response-time*)
							(allow-event-manager window))
						(push (/ (- *response-time* start-time) 1000.0) round-times)
						(if (equal (nth (+ (* k 3) 2) (nth j articles)) *response*)
							(push 1.0 round-scores)
							(push 0.0 round-scores))
						(push (nth (+ (* k 3) 2) (nth j articles)) *answers*))
					(setf count (+ count 1))))
			(t
				(dotimes (j (length articles))
					(dotimes (k 4)
						(setf verbs (nth count *verbs*))
						(display-trial trial j k nouns verbs articles)
						(setf *response* nil)                   
						(setf *response-time* nil)
						(setf start-time (get-time nil))
				
						(while (null *response-time*)
							(allow-event-manager window))
						(push (/ (- *response-time* start-time) 1000.0) round-times)
						(if (equal (nth (+ (* k 3) 2) (nth j articles)) *response*)
							(push 1.0 round-scores)
							(push 0.0 round-scores))
						(push (nth (+ (* k 3) 2) (nth j articles)) *answers*))
					(setf count (+ count 1)))))
			(print round-scores)
			(print round-times)
			;;(with-open-file (f (concatenate 'string "data" (write-to-string trial) ".txt") :direction :output :if-does-not-exist :create)
			;;	(print round-scores f)
			;;	(print round-times f))
			(print *answers*)
			(push round-scores *scores*)
			(push round-times *times*)
			;;(dotimes (s (length round-scores))
			;;    (print-data round-scores " ")
			;;    (print-data round-times " "))
			))
	;; (dotimes (s (length *scores*))
	;;		    (print-data (nth s *scores*) (concatenate 'string "Round Scores" (write-to-string s)))
	;;		    (print-data (nth s *times*) (concatenate 'string "Round Scores" (write-to-string s))))
	(with-open-file (f "data.txt" :direction :output :if-does-not-exist :create)
		(dotimes (s (length *scores*))
			(print (nth s *scores*) f)
			(print (nth s *times*) f)))
	))
	
(defun display-trial (trial i j nouns verbs articles)
	(cond ((< trial 3)
		(clear-exp-window)
		(add-text-to-exp-window :text "English:" :x 50 :y 100 :width 25)
		(add-text-to-exp-window :text (nth 0 (nth i articles)) :x 125 :y 100 :width 25 :color 'pink)
		(add-text-to-exp-window :text (nth 1 (nth 0 (nth i nouns))) :x 175 :y 100 :width 25)
		(add-text-to-exp-window :text (nth 1 verbs) :x 250 :y 100 :width 25)
		(add-text-to-exp-window :text "German:" :x 50 :y 150 :width 25)
		(add-text-to-exp-window :text (nth 1 (nth i articles)) :x 125 :y 150 :width 25 :color 'pink)
		(add-text-to-exp-window :text (nth 0 (nth 0 (nth i nouns))) :x 175 :y 150 :width 25 :color (nth 2 (nth 0 (nth i nouns))))
		(add-text-to-exp-window :text (nth 0 verbs) :x 250 :y 150 :width 25))
	((< trial 6)
		(clear-exp-window)
		(setf articles-sentence (nth i articles))
		(setf nouns-sentence (nth i nouns))
		(if (= 0 (mod j 2))
			(add-text-to-exp-window :text (nth 1 articles-sentence) :x 125 :y 150 :width 25 :color 'pink)
			(add-text-to-exp-window :text (nth 4 articles-sentence) :x 325 :y 150 :width 25 :color 'pink))
		(if (= 0 (mod j 2))
			 (add-text-to-exp-window :text (nth 4 articles-sentence) :x 325 :y 150 :width 25)
			 (add-text-to-exp-window :text (nth 1 articles-sentence) :x 125 :y 150 :width 25))
		(if (= 0 (mod j 2))
			(add-text-to-exp-window :text (nth 0 articles-sentence) :x 125 :y 100 :width 25 :color 'pink)
			(add-text-to-exp-window :text (nth 3 articles-sentence) :x 325 :y 100 :width 25 :color 'pink))
		(if (= 0 (mod j 2))
			 (add-text-to-exp-window :text (nth 3 articles-sentence) :x 325 :y 100 :width 25)
			 (add-text-to-exp-window :text (nth 0 articles-sentence) :x 125 :y 100 :width 25))
		(add-text-to-exp-window :text "English:" :x 50 :y 100 :width 25)
		;;(add-text-to-exp-window :text (nth 0 articles-sentence) :x 125 :y 100 :width 25)
		(add-text-to-exp-window :text (nth 1 (nth 0 nouns-sentence)) :x 175 :y 100 :width 25)
		(add-text-to-exp-window :text (nth 1 verbs) :x 250 :y 100 :width 25)
		;;(add-text-to-exp-window :text (nth 3 articles-sentence) :x 325 :y 100 :width 25)
		(add-text-to-exp-window :text (nth 1 (nth 1 nouns-sentence)) :x 375 :y 100 :width 25)
		(add-text-to-exp-window :text "German:" :x 50 :y 150 :width 25)
		(add-text-to-exp-window :text (nth 0 (nth 0 nouns-sentence)) :x 175 :y 150 :width 25 :color (nth 2 (nth 0 nouns-sentence)))
		(add-text-to-exp-window :text (nth 0 verbs) :x 250 :y 150 :width 25)
		(add-text-to-exp-window :text (nth 0 (nth 1 nouns-sentence)) :x 375 :y 150 :width 25 :color (nth 2 (nth 1 nouns-sentence))))
	((< trial 9)
		(clear-exp-window)
		(setf articles-sentence (nth i articles))
		(setf nouns-sentence (nth i nouns))
		(cond ((= 0 (mod j 3))
				(add-text-to-exp-window :text (nth 1 articles-sentence) :x 125 :y 150 :width 25 :color 'pink)
				(add-text-to-exp-window :text (nth 4 articles-sentence) :x 325 :y 150 :width 25)
				(add-text-to-exp-window :text (nth 7 articles-sentence) :x 450 :y 150 :width 25)
				(add-text-to-exp-window :text (nth 0 articles-sentence) :x 125 :y 100 :width 25 :color 'pink)
				(add-text-to-exp-window :text (nth 3 articles-sentence) :x 325 :y 100 :width 25)
				(add-text-to-exp-window :text (nth 6 articles-sentence) :x 450 :y 100 :width 25))
			  ((= 1 (mod j 3))
				(add-text-to-exp-window :text (nth 4 articles-sentence) :x 325 :y 150 :width 25 :color 'pink)
				(add-text-to-exp-window :text (nth 1 articles-sentence) :x 125 :y 150 :width 25)
				(add-text-to-exp-window :text (nth 7 articles-sentence) :x 450 :y 150 :width 25)
				(add-text-to-exp-window :text (nth 3 articles-sentence) :x 325 :y 100 :width 25 :color 'pink)
				(add-text-to-exp-window :text (nth 0 articles-sentence) :x 125 :y 100 :width 25)
				(add-text-to-exp-window :text (nth 6 articles-sentence) :x 450 :y 100 :width 25))
			  ((= 2 (mod j 3))
			    (add-text-to-exp-window :text (nth 7 articles-sentence) :x 450 :y 150 :width 25 :color 'pink)
				(add-text-to-exp-window :text (nth 4 articles-sentence) :x 325 :y 150 :width 25)
				(add-text-to-exp-window :text (nth 1 articles-sentence) :x 125 :y 150 :width 25)
				(add-text-to-exp-window :text (nth 6 articles-sentence) :x 450 :y 100 :width 25 :color 'pink)
				(add-text-to-exp-window :text (nth 3 articles-sentence) :x 325 :y 100 :width 25)
				(add-text-to-exp-window :text (nth 0 articles-sentence) :x 125 :y 100 :width 25)))
		(add-text-to-exp-window :text "English:" :x 50 :y 100 :width 25)
		;;(add-text-to-exp-window :text (nth 0 articles-sentence) :x 125 :y 100 :width 25)
		(add-text-to-exp-window :text (nth 1 (nth 0 nouns-sentence)) :x 175 :y 100 :width 25)
		(add-text-to-exp-window :text (nth 1 verbs) :x 250 :y 100 :width 25)
		;;(add-text-to-exp-window :text (nth 3 articles-sentence) :x 325 :y 100 :width 25)
		(add-text-to-exp-window :text (nth 1 (nth 1 nouns-sentence)) :x 375 :y 100 :width 25)
		;;(add-text-to-exp-window :text (nth 6 articles-sentence) :x 450 :y 100 :width 25)
		(add-text-to-exp-window :text (nth 1 (nth 0 nouns-sentence)) :x 525 :y 100 :width 25)
		(add-text-to-exp-window :text "German:" :x 50 :y 150 :width 25)
		(add-text-to-exp-window :text (nth 0 (nth 0 nouns-sentence)) :x 175 :y 150 :width 25 :color (nth 2 (nth 0 nouns-sentence)))
		(add-text-to-exp-window :text (nth 0 verbs) :x 250 :y 150 :width 25)
		(add-text-to-exp-window :text (nth 0 (nth 1 nouns-sentence)) :x 375 :y 150 :width 25 :color (nth 2 (nth 1 nouns-sentence)))
		(add-text-to-exp-window :text (nth 0 (nth 2 nouns-sentence)) :x 525 :y 150 :width 25 :color (nth 2 (nth 2 nouns-sentence))))
	(t
	(clear-exp-window)
	(setf articles-sentence (nth i articles))
	(setf nouns-sentence (nth i nouns))
	(cond ((= 0 (mod j 4))
				(add-text-to-exp-window :text (nth 1 articles-sentence) :x 125 :y 150 :width 25 :color 'pink)
				(add-text-to-exp-window :text (nth 4 articles-sentence) :x 325 :y 150 :width 25)
				(add-text-to-exp-window :text (nth 7 articles-sentence) :x 450 :y 150 :width 25)
				(add-text-to-exp-window :text (nth 10 articles-sentence) :x 600 :y 150 :width 25)
				(add-text-to-exp-window :text (nth 0 articles-sentence) :x 125 :y 100 :width 25 :color 'pink)
				(add-text-to-exp-window :text (nth 3 articles-sentence) :x 325 :y 100 :width 25)
				(add-text-to-exp-window :text (nth 6 articles-sentence) :x 450 :y 100 :width 25)
				(add-text-to-exp-window :text (nth 9 articles-sentence) :x 600 :y 100 :width 25))
		 ((= 1 (mod j 4))
				(add-text-to-exp-window :text (nth 4 articles-sentence) :x 325 :y 150 :width 25 :color 'pink)
				(add-text-to-exp-window :text (nth 1 articles-sentence) :x 125 :y 150 :width 25)
				(add-text-to-exp-window :text (nth 7 articles-sentence) :x 450 :y 150 :width 25)
				(add-text-to-exp-window :text (nth 10 articles-sentence) :x 600 :y 150 :width 25)
				(add-text-to-exp-window :text (nth 3 articles-sentence) :x 325 :y 100 :width 25 :color 'pink)
				(add-text-to-exp-window :text (nth 0 articles-sentence) :x 125 :y 100 :width 25)
				(add-text-to-exp-window :text (nth 6 articles-sentence) :x 450 :y 100 :width 25)
				(add-text-to-exp-window :text (nth 9 articles-sentence) :x 600 :y 100 :width 25))
	    ((= 2 (mod j 4))
			    (add-text-to-exp-window :text (nth 7 articles-sentence) :x 450 :y 150 :width 25 :color 'pink)
				(add-text-to-exp-window :text (nth 4 articles-sentence) :x 325 :y 150 :width 25)
				(add-text-to-exp-window :text (nth 1 articles-sentence) :x 125 :y 150 :width 25)
				(add-text-to-exp-window :text (nth 10 articles-sentence) :x 600 :y 150 :width 25)
				(add-text-to-exp-window :text (nth 6 articles-sentence) :x 450 :y 100 :width 25 :color 'pink)
				(add-text-to-exp-window :text (nth 3 articles-sentence) :x 325 :y 100 :width 25)
				(add-text-to-exp-window :text (nth 0 articles-sentence) :x 125 :y 100 :width 25)
				(add-text-to-exp-window :text (nth 9 articles-sentence) :x 600 :y 100 :width 25))
		((= 3 (mod j 4))
				(add-text-to-exp-window :text (nth 1 articles-sentence) :x 125 :y 150 :width 25)
				(add-text-to-exp-window :text (nth 4 articles-sentence) :x 325 :y 150 :width 25)
				(add-text-to-exp-window :text (nth 7 articles-sentence) :x 450 :y 150 :width 25)
				(add-text-to-exp-window :text (nth 10 articles-sentence) :x 600 :y 150 :width 25 :color 'pink)
				(add-text-to-exp-window :text (nth 0 articles-sentence) :x 125 :y 100 :width 25)
				(add-text-to-exp-window :text (nth 3 articles-sentence) :x 325 :y 100 :width 25)
				(add-text-to-exp-window :text (nth 6 articles-sentence) :x 450 :y 100 :width 25)
				(add-text-to-exp-window :text (nth 9 articles-sentence) :x 600 :y 100 :width 25 :color 'pink)))
		(add-text-to-exp-window :text "English:" :x 50 :y 100 :width 25)
		;;(add-text-to-exp-window :text (nth 0 articles-sentence) :x 125 :y 100 :width 25)
		(add-text-to-exp-window :text (nth 1 (nth 0 nouns-sentence)) :x 175 :y 100 :width 25)
		(add-text-to-exp-window :text (nth 1 verbs) :x 250 :y 100 :width 25)
		;;(add-text-to-exp-window :text (nth 3 articles-sentence) :x 325 :y 100 :width 25)
		(add-text-to-exp-window :text (nth 1 (nth 1 nouns-sentence)) :x 375 :y 100 :width 25)
		;;(add-text-to-exp-window :text (nth 6 articles-sentence) :x 450 :y 100 :width 25)
		(add-text-to-exp-window :text (nth 1 (nth 2 nouns-sentence)) :x 525 :y 100 :width 25)
		;;(add-text-to-exp-window :text (nth 9 articles-sentence) :x 600 :y 100 :width 25)
		(add-text-to-exp-window :text (nth 1 (nth 3 nouns-sentence)) :x 675 :y 100 :width 25)
		(add-text-to-exp-window :text "German:" :x 50 :y 150 :width 25)
		(add-text-to-exp-window :text (nth 0 (nth 0 nouns-sentence)) :x 175 :y 150 :width 25 :color (nth 2 (nth 0 nouns-sentence)))
		(add-text-to-exp-window :text (nth 0 verbs) :x 250 :y 150 :width 25)
		(add-text-to-exp-window :text (nth 0 (nth 1 nouns-sentence)) :x 375 :y 150 :width 25 :color (nth 2 (nth 1 nouns-sentence)))
		(add-text-to-exp-window :text (nth 0 (nth 2 nouns-sentence)) :x 525 :y 150 :width 25 :color (nth 2 (nth 2 nouns-sentence)))
		(add-text-to-exp-window :text (nth 0 (nth 3 nouns-sentence)) :x 675 :y 150 :width 25 :color (nth 2 (nth 3 nouns-sentence)))))

		)
	
(defun print-data(data label)
	(format t "~%~%~A:~%" label)
		data)
		
(defmethod rpm-window-key-event-handler ((win rpm-window) key)
	(setf *response* (string-upcase (string key)))
	(setf *response-time* (get-time *model-doing-task*)))
	
(defun add-study-fact-to-memory (round)
  (merge-dm-fct (list (list 'isa 'grammar-fact
                         'word (nth 0 (nth round *definite-case-rules*))
                         'gender (nth 1 (nth round *definite-case-rules*))
                         'gcase (nth 2 (nth round *definite-case-rules*)) 
                         'definite "1")))
  (merge-dm-fct (list (list 'isa 'grammar-fact
                         'word (nth 0 (nth round *indefinite-case-rules*))
                         'gender (nth 1 (nth round *indefinite-case-rules*))
                         'gcase (nth 2 (nth round *indefinite-case-rules*)) 
                         'definite "0"))))
(clear-all)

(define-model germanCases
(sgp :rt -3 :esc t :v nil :act nil :ans 0.5 :mp 2.35 :lf 2.85 :bll 0.25 :mas 1.6)

(chunk-type goal state start attending articlesearch gendersearch casesearch respond final end)
(chunk-type grammar-fact word gender gcase definite)
(chunk-type gender-fact col gender)

(add-dm
 
 (fem isa gender-fact col blue gender "feminine")
 (neut isa gender-fact col green gender "neuter")
 (man isa gender-fact col red gender "masculine")
 (goal isa goal state start))

 
(p find-unattended
    =goal>
      ISA         goal
      state       start
     ==>
     +visual-location>
        ISA         visual-location
		;;:attended      nil
		color       pink
		< screen-y    125
	=goal>
		state    attending)
		
(p attend-to-english-article
    =goal>
	  isa      goal
	  state    attending
    =visual-location>
      ISA         visual-location
   ?visual>
       state      free
==>
   =goal>
      state       articlesearch
   =visual-location>
   +visual>
      cmd         move-attention
      screen-pos  =visual-location)		
	  
   (p is-definite
    =goal>
	   ISA       goal
	   state     articlesearch
	=visual>
     ISA         visual-object
     value       =char
	 - value     "a"
	 - value     "ofXa"
	 - value     "toXa"
	=visual-location>
	   < screen-y  125
	   screen-x  =currx
	?imaginal>
	   buffer   empty
	   state    free
	==>
	+imaginal>
	   isa    grammar-fact
	   definite "1"
	+visual-location>
	   > screen-y   125
	   > screen-x  =currx
	   - color      pink
	   - color      black
	   :nearest   current-x
	=goal>
	   isa     goal
	   state   gendersearch)
	    
	(p not-definite
    =goal>
	   ISA       goal
	   state     articlesearch
	=visual>
     ISA         visual-object
     value       =char
	 - value     "the"
	 - value     "ofXthe"
	 - value     "toXthe"
	=visual-location>
	   < screen-y  125
	   screen-x  =currx
	?imaginal>
	   buffer   empty
	   state    free
	==>
	+imaginal>
	   isa     grammar-fact
	   definite "0"
	+visual-location>
	   > screen-y   125
	   > screen-x   =currx
	   - color      pink
	   - color      black
	   :nearest  current-x
	=goal>
	   isa     goal
	   state   gendersearch)
	   
   (p find-gender
     =goal>
	   isa     goal
	   state   gendersearch
	=visual-location>
	   color   =col
	   - color pink
	   - color black
	=imaginal>
	?retrieval>
	   buffer   empty
	   state    free
	==>
	+retrieval>
	   isa      gender-fact
	   col    =col
	=imaginal>
	=visual-location>
	=goal>
	   isa      goal
	   state    casesearch)
	   
   (p is-nominative
    =goal>
	   isa     goal
	   state   casesearch
	=visual-location>
	   - color pink
	   - color black
	   < screen-x 250
	=imaginal>
	   isa      grammar-fact
	   definite =val
	=retrieval>
       isa      gender-fact
	   gender  =gen
	==>
	+retrieval>
	   isa      grammar-fact
	   gender   =gen
	   gcase    "nominative"
	   definite =val
	-imaginal>
	+visual-location>
	   color    pink
	   > screen-y 125
	=goal>
	   isa      goal
	   state    respond)
	   
   (p is-dative
    =goal>
	   isa     goal
	   state   casesearch
	=visual-location>
	   > screen-x 450
	   < screen-x 600
	   - screen-x highest
	   - color    pink
	   - color    black
	=imaginal>
	   isa    grammar-fact
	   definite =val
	=retrieval>
       isa      gender-fact
	   gender  =gen
	==>
	+retrieval>
	   isa      grammar-fact
	   gender   =gen
	   gcase    "dative"
	   definite =val
	-imaginal>
	   ;;isa     grammar-fact
	   ;;gender   =gen
	   ;;gcase    "dative"
	   ;;definite =val
	+visual-location>
	   ;;:attended  nil
	   color      pink
	   > screen-y 125
	=goal>
	   isa      goal
	   state    respond)
   
   (p is-accusative
    =goal>
	   isa     goal
	   state   casesearch
	=visual-location>
	   < screen-x 450
	   > screen-x 250
	   - color    pink
	   - color    black
	=imaginal>
	   isa      grammar-fact
	   definite =val
	=retrieval>
       isa      gender-fact
	   gender  =gen
	==>
	+retrieval>
	   isa      grammar-fact
	   gender   =gen
	   gcase    "accusative"
	   definite =val
	-imaginal>
	   ;;isa     grammar-fact
	   ;;gender   =gen
	   ;;gcase    "accusative"
	   ;;definite =val
	+visual-location>
	   ;;:attended  nil
	   color      pink
	   > screen-y 125
	=goal>
	   isa      goal
	   state    respond)
	   
	(p is-genitive
    =goal>
	   isa     goal
	   state   casesearch
	=visual-location>
	   - color  pink
	   - color  black
	   > screen-x 600
	=imaginal>
	   isa    grammar-fact
	   definite =val
	=retrieval>
       isa     gender-fact
	   gender  =gen
	==>
	+retrieval>
	   isa      grammar-fact
	   gender   =gen
	   gcase    "genitive"
	   definite =val
	-imaginal>
	   ;; isa     grammar-fact
	   ;;gender   =gen
	   ;;gcase    "genitive"
	   ;;definite =val
	+visual-location>
	   ;;:attended  nil
	   color    pink
	   > screen-y 125
	=goal>
	   isa      goal
	   state    respond)
	   
(p attend-to-german-article
    =goal>
	   isa      goal
	   state    respond
    =visual-location>
      ISA         visual-location
   ?visual>
       state      free
==>
   =visual-location>
   +visual>
      cmd         move-attention
      screen-pos  =visual-location
	=goal>
	   isa    goal
	   state  final)	
   
   (p recall-false
	=goal>
	   isa     goal
	   state   final
	=visual-location>
	   color    pink
	   > screen-y 125
	=visual>
	   value     =arg2
	=retrieval>
	   isa      grammar-fact
	   gender   =col
	   gcase    =garg
	   definite =val
	   word     =arg1
	   - word    =arg2
	?manual>
	   state   free
	==>
	+manual>
	  cmd press-key
	  key "Z"
	=goal>
	  isa     goal
	  state   end)
	;;)
	;;=goal>
	;;  isa     goal
	;;  state   start)
   
   
   (p cant-recall
    =goal>
	   ISA     goal
       state   final
    ?retrieval>
       state   error
	?manual>
	   state   free
	==>
	+manual>
	  cmd press-key
	  key "Z"
	=goal>
	  isa     goal
	  state   end)
	;;)
	;;=goal>
	;;  isa     goal
	;;  state   start)
	   
   (p recall-true
	=goal>
	   isa     goal
	   state   final
	=visual>
	   value     =arg2
	=visual-location>
	   color    pink
	   > screen-y 125
	=retrieval>
	   isa      grammar-fact
	   gender   =col
	   gcase    =gcase
	   definite =val
	   word     =arg1
	   word     =arg2
	?manual>
	   state   free
	==>
	+manual>
	  cmd press-key
	  key "A"
	=goal>
	  isa     goal
	  state   end)
	;;)
	;;=goal>
	;;  isa     goal
	;;  state   start)
	   
(set-base-levels 
 (man 5)(fem 5)(neut 5))
	   
	   
(goal-focus goal)
)