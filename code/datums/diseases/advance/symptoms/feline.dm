//I am actually going insane from a second project so I am writing a meme symptom for an uplink item to avoid burnout.
/datum/symptom/feline
	name = "Feline Minor Retrovirus"
	desc = "A derivative of the fabled felinid virus"
	stealth = -2
	resistance = -2
	stage_speed = 1
	transmittable = 2
	level = -1 //Uplink Symptom
	severity = 3 //Class F Biohazard
	symptom_delay_max = 20
	symptom_delay_max = 60
	var/nya_transmit = FALSE //Var that stores the transmission threshhold
	var/full_feline = FALSE //Var that checks the stage speed and resistance threshold
	threshold_desc = "<b>Transmission 12:</b> Chance for virus to spread when nyaaa ing. <br>\
	<b>Stage Speed 12 and Resistance 10:</b> Will mutate the species into felinid."

/datum/symptom/feline/severityset(datum/disease/advance/A)
	if(A.properties["transmittable"] >= 12)
		severity+= 1
	if(A.properties["stage_speed"] >= 12 && A.properties["resistance"] >= 10)
		severity+= 99 //Sets Severity to a Custom Felinid Virus Biohazard Classification
	..()

/datum/symptom/feline/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["transmittable"] >= 12)
		nya_transmit = TRUE
	if(A.properties["stage_speed"] >= 12 && A.properties["resistance"] >= 10)
		full_feline = TRUE //OH NYOOO WE NEED TO LYNCH THE VIWOLOGIST

/datum/symptom/feline/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/M = A.affected_mob
	switch(A.stage)
		if(2)
			if(prob(40))
				M.say(pick("Nya!", "Nya~", "~meow~", "N-nya"))
			if(prob(40))
				to_chat(M, "<span class='danger'>You feel [pick("catlike", "like eating chocolate isn't a good idea", "an urge to chase after lasers")].</span>")
		if(3)
			if(prob(45))
				M.say(pick("Nya!", "Nya~", "~meow~", "N-nya", "MIAOW!", "N-NYAAAAA!", "NYAAAAAAA~"))
			if(prob(45))
				to_chat(M, "<span class='danger'>You feel [pick("very catlike", "like avoiding chocolate entirely", "a constant urge to chase after lasers")].</span>")
		if(4, 5)
			if(prob(50))
				M.say(pick("Nya!", "Nya~", "~meow~", "N-nya", "MIAOW!", "N-NYAAAAA!", "NYAAAAAAA~", "Mew - NYAAAAAAA!~", "N- meow", "M- NYAAAA"))
			if(prob(50))
				to_chat(M, "<span class='danger'>You feel [pick("incredibly catlike", "like eating chocolate would kill you", "an insatiable urge to chase after lasers", "joining a metagang")].</span>")
			if(A.stage == 5)
				if(nya_transmit)
					if(prob(15))
						M.say(pick("Nya!", "Nya~", "~meow~", "N-nya", "MIAOW!", "N-NYAAAAA!", "NYAAAAAAA~", "Mew - NYAAAAAAA!~", "N- meow", "M- NYAAAA"))
						A.spread(5)
				if(full_feline)
					if(ishuman(M))
						M.reagents.add_reagent_list(list(/datum/reagent/mutationtoxin/felinid = 1, /datum/reagent/medicine/mutadone = 1))
