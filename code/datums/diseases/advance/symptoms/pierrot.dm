/datum/symptom/pierrot
	name = "Pierrot's Throat"
	desc = "Causes the host to honk randomly"
	stealth = -1
	resistance = 3
	stage_speed = 1
	transmittable = 2
	level = 0
	severity = 1
	symptom_delay_min = 15
	symptom_delay_max = 30
	var/honkspread = FALSE
	var/clownshoes = FALSE
	var/clumsy = FALSE
	threshold_desc = "<b>Transmission 10:</b> There's a rare chance the disease is spread everytime the host honks.<br>\
					  <b>Resistance 10:</b> The host grows a pair of clown shoes.<br>\
					  <b>Resistance 15:</b>	Host becomes clumsy, similar to a clown."

/datum/symptom/pierrot/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["transmission"] >= 10)
		honkspread = TRUE
	if(A.properties["resistance"] >= 10)
		clownshoes = TRUE
	if(A.properties["resistance"] >= 15)
		clumsy = TRUE

/datum/symptom/pierrot/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(1)
			if(prob(15))
				to_chat(M, "<span class='danger'>You feel a little silly.</span>")
		if(2)
			if(prob(15))
				to_chat(M, "<span class='danger'>You start seeing rainbows.</span>")
		if(3)
			if(prob(15))
				to_chat(M, "<span class='danger'>Your thoughts are interrupted by a loud <b>HONK!</b></span>")
				playsound(M, 'sound/items/bikehorn.ogg', 50, 1)
		if(4, 5)
			if(clumsy)
				if(!HAS_TRAIT(M, TRAIT_CLUMSY))
					to_chat(M, "<span class='notice'>You feel dumber.</span>")
					ADD_TRAIT(M, TRAIT_CLUMSY, DISEASE_TRAIT)
			if(prob(10))
				M.say( pick( list("HONK!", "Honk!", "Honk.", "Honk?", "Honk!!", "Honk?!", "Honk...") ))
			if(A.stage == 5)
				if(prob(1)&&prob(50)&&clownshoes)
					give_clown_shoes(A)
				if(prob(5))
					playsound(M.loc, 'sound/items/bikehorn.ogg', 50, 1)
					if(honkspread && prob(25))
						A.spread(1)

/datum/symptom/pierrot/End(datum/disease/advance/A)
	..()
	if(!A.affected_mob.job == "Clown")
		to_chat(A.affected_mob, "<span class='notice'>You feel less dumb.</span>")
		REMOVE_TRAIT(A.affected_mob, TRAIT_CLUMSY, DISEASE_TRAIT)
	if(ishuman(A.affected_mob))
		var/mob/living/carbon/human/M = A.affected_mob
		if(istype(M.shoes, /obj/item/clothing/shoes/clown_shoes))
			REMOVE_TRAIT(M.shoes, TRAIT_NODROP, DISEASE_TRAIT)
		

/datum/symptom/pierrot/proc/give_clown_shoes(datum/disease/advance/A)
	if(ishuman(A.affected_mob))
		var/mob/living/carbon/human/M = A.affected_mob 
		if(!istype(M.shoes, /obj/item/clothing/shoes/clown_shoes))
			if(!M.dropItemToGround(M.shoes))
				qdel(M.shoes)
		C = new /obj/item/clothing/shoes/clown_shoes(M)
		ADD_TRAIT(C, TRAIT_NODROP, DISEASE_TRAIT)
		M.equip_to_slot_or_del(C, SLOT_SHOES)
		return
