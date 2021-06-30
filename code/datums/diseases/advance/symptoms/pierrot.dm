/datum/symptom/pierrot
	name = "Pierrot's Throat"
	desc = "Causes the host to honk randomly"
	stealth = -1
	resistance = 3
	stage_speed = 1
	transmission = 2
	level = 0
	severity = 0
	symptom_delay_min = 2
	symptom_delay_max = 15
	var/honkspread = FALSE
	var/clownmask = FALSE
	var/clumsy = FALSE
	threshold_desc = "<b>Transmission 10:</b> There's a rare chance the disease is spread everytime the host honks.<br>\
					  <b>Resistance 10:</b> The host grows a peculiar clown mask.<br>\
					  <b>Resistance 15:</b>	Host becomes clumsy, similar to a clown."

/datum/symptom/pierrot/severityset(datum/disease/advance/A)
	. = ..()
	if(A.resistance >= 10)
		severity +=1
		if(A.resistance >= 15)
			severity += 2

/datum/symptom/pierrot/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.transmission >= 10)
		honkspread = TRUE
	if(A.resistance >= 10)
		clownmask = TRUE
		if(A.resistance >= 15)
			clumsy = TRUE

/datum/symptom/pierrot/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(1)
			if(prob(30))
				to_chat(M, "<span class='danger'>You feel a little silly.</span>")
		if(2)
			if(prob(30))
				to_chat(M, "<span class='danger'>You start seeing rainbows.</span>")
		if(3)
			if(prob(30))
				to_chat(M, "<span class='danger'>Your thoughts are interrupted by a loud <b>HONK!</b></span>")
				playsound(M, 'sound/items/bikehorn.ogg', 50, 1)
		if(4, 5)
			if(clumsy)
				if(!HAS_TRAIT(M, TRAIT_CLUMSY))
					to_chat(M, "<span class='notice'>You feel dumber.</span>")
					ADD_TRAIT(M, TRAIT_CLUMSY, DISEASE_TRAIT)
			if(prob(30))
				M.say( pick( list("HONK!", "Honk!", "Honk.", "Honk?", "Honk!!", "Honk?!", "Honk...") ))
			if(A.stage == 5)
				if(clownmask)
					give_clown_mask(A)
				if(prob(5))
					playsound(M.loc, 'sound/items/bikehorn.ogg', 100, 1)
					if(honkspread)
						A.spread(5)

/datum/symptom/pierrot/End(datum/disease/advance/A)
	..()
	if(!A.affected_mob.job == "Clown")
		to_chat(A.affected_mob, "<span class='notice'>You feel less dumb.</span>")
		REMOVE_TRAIT(A.affected_mob, TRAIT_CLUMSY, DISEASE_TRAIT)
	if(ishuman(A.affected_mob))
		var/mob/living/carbon/human/M = A.affected_mob
		if(istype(M.wear_mask, /obj/item/clothing/mask/gas/clown_hat))
			REMOVE_TRAIT(M.wear_mask, TRAIT_NODROP, DISEASE_TRAIT)


/datum/symptom/pierrot/proc/give_clown_mask(datum/disease/advance/A)
	if(ishuman(A.affected_mob))
		var/mob/living/carbon/human/M = A.affected_mob
		if(!istype(M.wear_mask, /obj/item/clothing/mask/gas/clown_hat))
			if(!M.dropItemToGround(M.wear_mask))
				qdel(M.wear_mask)
		var/obj/item/clothing/C = new /obj/item/clothing/mask/gas/clown_hat(M)
		ADD_TRAIT(C, TRAIT_NODROP, DISEASE_TRAIT)
		M.equip_to_slot_or_del(C, ITEM_SLOT_MASK)
		return
