/datum/symptom/cockroach

	name = "SBG Syndrome"
	desc = "Causes bluespace synchronicity with nearby air channels, making the roaches infesting the station's scrubbers crawl from the host's face"
	stealth = 0
	resistance = 3
	stage_speed = 3
	transmittable = 1
	level = 0
	severity = 0 //rip funy
	symptom_delay_min = 10
	symptom_delay_max = 30
	var/death_roaches = FALSE
	threshold_desc = "<b>Stage Speed 8:</b>Increases roach speed<br>\
	<b>Transmission 8:</b>When the host dies, more roaches spawn<br>" 
            
/datum/symptom/cockroach/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["stage_rate"] >= 8)
		symptom_delay_min = 5
		symptom_delay_max = 15
	if(A.properties["transmittable"] >= 8) 
		death_roaches = TRUE

/datum/symptom/cockroach/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(2)
			if(prob(50))
				to_chat(M, "<span class='notice'>You feel a tingle under your skin</span>")
		if(3)
			if(prob(50))
				to_chat(M, "<span class='notice'>Your pores feel drafty.</span>")
			if(prob(5))
				to_chat(M, "<span class='notice'>You feel attuned to the atmosphere</span>")
		if(4)
			if(prob(50))
				to_chat(M, "<span class='notice'>You feel in tune with the station</span>")
		if(5)
			if(prob(30))
				M.visible_message("<span class='danger'>[M] squirms as a cockroach crawls from their pores!</span>", \
								  "<span class='userdanger'>A cockroach crawls out of your face!!</span>")
				new /mob/living/simple_animal/cockroach(M.loc)
			if(prob(50))
				to_chat(M, "<span class='notice'>You feel something crawling in your pipes!</span>")
	
/datum/symptom/cockroach/OnDeath(datum/disease/advance/A)
	if(!..())
		return
	if(death_roaches)
		var/mob/living/M = A.affected_mob
		to_chat(M, "<span class='warning'>Your pores explode into a colony of roaches!</span>")
		for(var/i in 1 to rand(1,5))
			new /mob/living/simple_animal/cockroach(M.loc)

