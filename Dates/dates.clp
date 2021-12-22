;;; ***************************
;;; * DEFTEMPLATES & DEFFACTS *
;;; ***************************

(deftemplate UI-state
   (slot id (default-dynamic (gensym*)))
   (slot display)
   (slot relation-asserted (default none))
   (slot response (default none))
   (multislot valid-answers)
   (slot state (default middle)))
   
(deftemplate state-list
   (slot current)
   (multislot sequence))
  
(deffacts startup
   (state-list))
   
;;;****************
;;;* STARTUP *
;;;****************

(defrule system-banner ""

  =>
  
  (assert (UI-state (display WelcomeMessage)
                    (relation-asserted start)
                    (state initial)
                    (valid-answers))))

;;;***************
;;;* QUESTIONS *
;;;***************

(defrule determine-in-out ""

   (logical (start))

   =>

   (assert (UI-state (display InOutQuestion)
                     (relation-asserted in-out)
                     (response StayIn)
                     (valid-answers StayIn GoOut))))
   
(defrule determine-kids ""

   (logical (in-out StayIn))

   =>

   (assert (UI-state (display KidsQuestion)
                     (relation-asserted kids)
                     (response No)
                     (valid-answers No Yes))))

(defrule determine-relax-active ""

   (or 
   (logical (kids No))
   (logical (need-sitter No))
   (logical (have-sitter Yes)))

   =>

   (assert (UI-state (display WantToQuestion)
                     (relation-asserted relax-active)
                     (response Relax)
                     (valid-answers Relax Active))))
   
(defrule determine-movie ""

   (logical (relax-active Relax))

   =>

   (assert (UI-state (display MovieQuestion)
                     (relation-asserted movie)
                     (response No)
                     (valid-answers No Yes))))
   
(defrule determine-nmovie-date-type ""

   (logical (movie No))

   =>

   (assert (UI-state (display DateTypeQuestion)
                     (relation-asserted nmovie-date-type)
                     (response Playful)
                     (valid-answers Playful Cuddle))))
                     
(defrule determine-movie-type ""

   (logical (movie Yes))

   =>

   (assert (UI-state (display MovieTypeQuestion)
                     (relation-asserted movie-type)
                     (response Funny)
                     (valid-answers Funny ChickFlick ManlyMan BothWillLove))))
                     
(defrule determine-playful-romantic ""

   (logical (relax-active Active))

   =>

   (assert (UI-state (display FeelingPlayfulRomanticQuestion)
                     (relation-asserted playful-romantic)
                     (response Playful)
                     (valid-answers Playful Romantic))))

(defrule determine-activity-type ""

   (logical (playful-romantic Playful))

   =>

   (assert (UI-state (display ActivityTypeQuestion)
                     (relation-asserted activity-type)
                     (response GetToKnowYou)
                     (valid-answers GetToKnowYou Fun Silly Sentimental))))

(defrule determine-intimate-play ""

	(or 
	(logical (playful-romantic Romantic))
	(logical (kids-involve No)))

   =>

   (assert (UI-state (display WantToQuestion)
                     (relation-asserted intimate-play)
                     (response GetIntimate)
                     (valid-answers GetIntimate Play))))

(defrule determine-sexy-playful ""
  
   (logical (intimate-play GetIntimate))

   =>
   
   (assert (UI-state (display FeelingSexyPlayfulQuestion)
                     (relation-asserted sexy-playful)
                     (response Sexy)
                     (valid-answers Sexy Playful))))

(defrule determine-need-sitter ""

   (logical (kids Yes))

   =>

   (assert (UI-state (display NeedSitterQuestion)
                     (relation-asserted need-sitter)
                     (response No)
                     (valid-answers No Yes))))

(defrule determine-have-sitter ""
	(logical (need-sitter Yes))
	
	=>
	
	(assert (UI-state (display HaveSitterQuestion)
					(relation-asserted have-sitter)
					(response No)
					(valid-answers No Yes))))

(defrule determine-kids-involve ""
	(logical (have-sitter No))
	
	=>
	
	(assert (UI-state (display InvolveKidsQuestion)
					(relation-asserted kids-involve)
					(response Yes)
					(valid-answers Yes No))))

(defrule determine-hungry-kids ""
	(logical (kids-involve Yes))
	
	=>
	
	(assert (UI-state (display HungryKidsQuestion)
					(relation-asserted hungry-kids)
					(response No)
					(valid-answers No Yes))))
					
(defrule determine-movie-kids ""
	(logical (kids-involve Yes))
	
	=>
	
	(assert (UI-state (display MovieQuestion)
					(relation-asserted movie-kids)
					(response No)
					(valid-answers No Yes))))
					


(defrule determine-money ""
	(logical (in-out GoOut))
	
	=>
	
	(assert (UI-state (display WantToQuestion)
					(relation-asserted money)
					(response SpendMoney)
					(valid-answers SpendMoney SaveMoney))))
					
(defrule determine-hungry ""
	(logical (money SpendMoney))
	
	=>
	
	(assert (UI-state (display HungryQuestion)
					(relation-asserted hungry)
					(response No)
					(valid-answers No Yes))))
					
					
(defrule determine-weather ""
	(and
	(logical (hungry No))
	(logical (nature-indoors InNature)))
	
	=>
	
	(assert (UI-state (display WeatherQuestion)
					(relation-asserted weather)
					(response Cold)
					(valid-answers Cold Warm))))
                     
(defrule determine-silly-sweet ""
	(and
	(logical (hungry No))
	(logical (nature-indoors Indoors)))
	
	=>
	
	(assert (UI-state (display FeelingSillySweetQuestion)
					(relation-asserted silly-sweet)
					(response Silly)
					(valid-answers Silly Sweet))))    
					
(defrule determine-adventure-lowkey ""
	(logical (money SaveMoney))
	
	=>
	
	(assert (UI-state (display AdventureLowkeyQuestion)
					(relation-asserted adventure-lowkey)
					(response Adventurous)
					(valid-answers Adventurous LowKey))))                 

(defrule determine-travel-close ""
	(logical (adventure-lowkey Adventurous))
	
	=>
	
	(assert (UI-state (display WantToQuestion)
					(relation-asserted travel-close)
					(response StayClose)
					(valid-answers StayClose Travel)))) 

(defrule determine-date-type ""
	(logical (travel-close StayClose))
	
	=>
	
	(assert (UI-state (display DateTypeQuestion)
					(relation-asserted date-type)
					(response Playful)
					(valid-answers Playful Unique Funny Game Cheap)))) 
			
(defrule determine-nature-indoors ""
	(or
	(logical (hungry No))
	(logical (adventure-lowkey LowKey)))
	
	=>
	
	(assert (UI-state (display WantToBeQuestion)
					(relation-asserted nature-indoors)
					(response InNature)
					(valid-answers InNature Indoors))))		
;;;***********
;;;* RESULTS *
;;;***********

(defrule lowkey-nature-result ""
	(and
	(logical (adventure-lowkey LowKey))
   (logical (nature-indoors InNature)))
   
   =>

   (assert (UI-state (display LowkeyNatureResult)
                     (state final))))

(defrule lowkey-indoors-result ""

	(and
	(logical (adventure-lowkey LowKey))
   (logical (nature-indoors Indoors)))
   
   =>

   (assert (UI-state (display LowkeyIndoorsResult)
                     (state final))))

(defrule hungry-result ""

   (logical (hungry Yes))
   
   =>

   (assert (UI-state (display HungryResult)
                     (state final))))

(defrule weather-cold-result ""

   (logical (weather Cold))
   
   =>

   (assert (UI-state (display WatherColdResult)
                     (state final))))

(defrule weather-warm-result ""

   (logical (weather Warm))
   
   =>

   (assert (UI-state (display WeatherWarmResult)
                     (state final))))
                     
(defrule silly-result ""

   (logical (silly-sweet Silly))
   
   =>

   (assert (UI-state (display SillyResult)
                     (state final))))

(defrule sweet-result ""

   (logical (silly-sweet Sweet))
   
   =>

   (assert (UI-state (display SweetResult)
                     (state final))))

(defrule travel-result ""

   (logical (travel-close Travel))
   
   =>

   (assert (UI-state (display TravelResult)
                     (state final))))
 
(defrule playful-result ""

   (logical (date-type Playful))
   
   =>

   (assert (UI-state (display PlayfulResult)
                     (state final))))

(defrule unique-result ""

   (logical (date-type Unique))
   
   =>

   (assert (UI-state (display UniqueResult)
                     (state final))))

(defrule funny-result ""

   (logical (date-type Funny))
   
   =>

   (assert (UI-state (display FunnyResult)
                     (state final))))
                     
(defrule game-result ""

   (logical (date-type Game))
   
   =>

   (assert (UI-state (display GameResult)
                     (state final))))

(defrule cheap-result ""

   (logical (date-type Cheap))
   
   =>

   (assert (UI-state (display CheapResult)
                     (state final))))

(defrule funny-movie-result ""

   (logical (movie-type Funny))
   
   =>

   (assert (UI-state (display FunnyMovieResult)
                     (state final))))

(defrule chick-flick-movie-result ""

   (logical (movie-type ChickFlick))
   
   =>

   (assert (UI-state (display ChickFlickMovieResult)
                     (state final))))

(defrule manly-man-movie-result ""

   (logical (movie-type ManlyMan))
   
   =>

   (assert (UI-state (display ManlyManMovieResult)
                     (state final))))

(defrule both-will-love-movie-result ""

   (logical (movie-type BothWillLove))
   
   =>

   (assert (UI-state (display BothWillLoveMovieResult)
                     (state final))))

(defrule playful-nmovie-result ""

   (logical (nmovie-date-type Playful))
   
   =>

   (assert (UI-state (display PlayfulNmovieResult)
                     (state final))))
                    

(defrule cuddle-result ""

   (logical (nmovie-date-type Cuddle))
   
   =>

   (assert (UI-state (display CuddleResult)
                     (state final))))


(defrule get-to-know-you-result ""

   (logical (activity-type Get-to-know-you))
   
   =>

   (assert (UI-state (display GetToKnowYouResult)
                     (state final))))

(defrule fun-result ""

   (logical (activity-type Fun))
   
   =>

   (assert (UI-state (display FunResult)
                     (state final))))

(defrule silly-activity-result ""

   (logical (activity-type Silly))
   
   =>

   (assert (UI-state (display SillyActivityResult)
                     (state final))))

(defrule Sentimental-activity-result ""

   (logical (activity-type Sentimental))
   
   =>

   (assert (UI-state (display SentimentalResult)
                     (state final))))

(defrule sexy-result ""

   (logical (sexy-playful Sexy))
   
   =>

   (assert (UI-state (display SexyResult)
                     (state final))))

(defrule playful-intimate-result ""

   (logical (sexy-playful Playful))
   
   =>

   (assert (UI-state (display PlayfulIntimateResult)
                     (state final))))

(defrule hungry-kids-result ""

   (logical (hungry-kids Yes))
   
   =>

   (assert (UI-state (display HungryKidsResult)
                     (state final))))

(defrule movie-kids-result ""

   (logical (movie-kids Yes))
   
   =>

   (assert (UI-state (display MovieKidsResult)
                     (state final))))

(defrule nmovie-kids-result ""

   (logical (movie-kids No))
   
   =>

   (assert (UI-state (display NMovieKidsResult)
                     (state final))))

(defrule play-result ""

   (logical (intimate-play Play))
   
   =>

   (assert (UI-state (display PlayResult)
                     (state final))))
               
;;;*************************
;;;* GUI INTERACTION RULES *
;;;*************************

(defrule ask-question

   (declare (salience 5))
   
   (UI-state (id ?id))
   
   ?f <- (state-list (sequence $?s&:(not (member$ ?id ?s))))
             
   =>
   
   (modify ?f (current ?id)
              (sequence ?id ?s))
   
   (halt))

(defrule handle-next-no-change-none-middle-of-chain

   (declare (salience 10))
   
   ?f1 <- (next ?id)

   ?f2 <- (state-list (current ?id) (sequence $? ?nid ?id $?))
                      
   =>
      
   (retract ?f1)
   
   (modify ?f2 (current ?nid))
   
   (halt))

(defrule handle-next-response-none-end-of-chain

   (declare (salience 10))
   
   ?f <- (next ?id)

   (state-list (sequence ?id $?))
   
   (UI-state (id ?id)
             (relation-asserted ?relation))
                   
   =>
      
   (retract ?f)

   (assert (add-response ?id)))   

(defrule handle-next-no-change-middle-of-chain

   (declare (salience 10))
   
   ?f1 <- (next ?id ?response)

   ?f2 <- (state-list (current ?id) (sequence $? ?nid ?id $?))
     
   (UI-state (id ?id) (response ?response))
   
   =>
      
   (retract ?f1)
   
   (modify ?f2 (current ?nid))
   
   (halt))

(defrule handle-next-change-middle-of-chain

   (declare (salience 10))
   
   (next ?id ?response)

   ?f1 <- (state-list (current ?id) (sequence ?nid $?b ?id $?e))
     
   (UI-state (id ?id) (response ~?response))
   
   ?f2 <- (UI-state (id ?nid))
   
   =>
         
   (modify ?f1 (sequence ?b ?id ?e))
   
   (retract ?f2))
   
(defrule handle-next-response-end-of-chain

   (declare (salience 10))
   
   ?f1 <- (next ?id ?response)
   
   (state-list (sequence ?id $?))
   
   ?f2 <- (UI-state (id ?id)
                    (response ?expected)
                    (relation-asserted ?relation))
                
   =>
      
   (retract ?f1)

   (if (neq ?response ?expected)
      then
      (modify ?f2 (response ?response)))
      
   (assert (add-response ?id ?response)))   

(defrule handle-add-response

   (declare (salience 10))
   
   (logical (UI-state (id ?id)
                      (relation-asserted ?relation)))
   
   ?f1 <- (add-response ?id ?response)
                
   =>
      
   (str-assert (str-cat "(" ?relation " " ?response ")"))
   
   (retract ?f1))   

(defrule handle-add-response-none

   (declare (salience 10))
   
   (logical (UI-state (id ?id)
                      (relation-asserted ?relation)))
   
   ?f1 <- (add-response ?id)
                
   =>
      
   (str-assert (str-cat "(" ?relation ")"))
   
   (retract ?f1))   

(defrule handle-prev

   (declare (salience 10))
      
   ?f1 <- (prev ?id)
   
   ?f2 <- (state-list (sequence $?b ?id ?p $?e))
                
   =>
   
   (retract ?f1)
   
   (modify ?f2 (current ?p))
   
   (halt))
   
