/datum/symptom/wizarditis
	name = "Wizarditis"
	desc = "Causes the host to subconciously believe they are in fact, a wizard."
	stealth = 1
	resistance = -2
	stage_speed = -3
	transmittable = -1
	level = 0
	severity = 0
	symptom_delay_min = 15
	symptom_delay_max = 45
	var/teleport = FALSE
	var/robes = FALSE
	threshold_desc = "<b>Transmission 14:</b> The host teleports occasionally.<br>\
					  <b>Speed 7:</b> The host grows a set of wizard robes."

/datum/symptom/wizarditis/severityset(datum/disease/advance/A)
	. = ..()
	if(A.properties["transmittable"] >= 12)
		severity += 1
	if(A.properties["speed"] >= 7)
		severity += 1

/datum/symptom/wizarditis/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["transmission"] >= 14)
		teleport = TRUE
	if(A.properties["speed"] >= 7)
		robes = TRUE

/datum/symptom/wizarditis/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(2)
			if(prob(30) && prob(50))
				M.say(pick("You shall not pass!", "Expeliarmus!", "By Merlins beard!", "Feel the power of the Dark Side!"))
			if(prob(30) && prob(50))
				to_chat(M, "<span class='danger'>You feel [pick("that you don't have enough mana", "that the winds of magic are gone", "an urge to summon familiar")].</span>")


		if(3)
			if(prob(30) && prob(50))
				M.say(pick("NEC CANTIO!","AULIE OXIN FIERA!", "STI KALY!", "TARCOL MINTI ZHERI!"))
			if(prob(30) && prob(50))
				to_chat(M, "<span class='danger'>You feel [pick("the magic bubbling in your veins","that this location gives you a +1 to INT","an urge to summon familiar")].</span>")

		if(4)

			if(prob(50))
				M.say(pick("NEC CANTIO!","AULIE OXIN FIERA!","STI KALY!","EI NATH!"))
				return
			if(robes)
				to_chat(M, "<span class='danger'>You feel [pick("the tidal wave of raw power building inside","that this location gives you a +2 to INT and +1 to WIS","an urge to teleport")].</span>")
				spawn_wizard_clothes(50, A)
			if(prob(20) && teleport)
				teleport(A)
	return



/datum/symptom/wizarditis/proc/spawn_wizard_clothes(chance = 0, datum/disease/advance/A)
	if(ishuman(A.affected_mob))
		var/mob/living/carbon/human/H = A.affected_mob
		var/obj/item/clothing/C
		if(prob(chance))
			if(!istype(H.head, /obj/item/clothing/head/wizard))
				if(!H.dropItemToGround(H.head))
					qdel(H.head)
				C = new /obj/item/clothing/head/wizard(H)
				ADD_TRAIT(C, TRAIT_NODROP, DISEASE_TRAIT)
				H.equip_to_slot_or_del(C, SLOT_HEAD)
			return
		if(prob(chance))
			if(!istype(H.wear_suit, /obj/item/clothing/suit/wizrobe))
				if(!H.dropItemToGround(H.wear_suit))
					qdel(H.wear_suit)
				C = new /obj/item/clothing/suit/wizrobe(H)
				ADD_TRAIT(C, TRAIT_NODROP, DISEASE_TRAIT)
				H.equip_to_slot_or_del(C, SLOT_WEAR_SUIT)
			return
		if(prob(chance))
			if(!istype(H.shoes, /obj/item/clothing/shoes/sandal/magic))
				if(!H.dropItemToGround(H.shoes))
					qdel(H.shoes)
				C = new /obj/item/clothing/shoes/sandal/magic(H)
				ADD_TRAIT(C, TRAIT_NODROP, DISEASE_TRAIT)
				H.equip_to_slot_or_del(C, SLOT_SHOES)
			return
	else
		var/mob/living/carbon/H = A.affected_mob
		if(prob(chance))
			var/obj/item/staff/S = new(H)
			if(!H.put_in_hands(S))
				qdel(S)


/datum/symptom/wizarditis/proc/teleport(datum/disease/advance/A)
	var/turf/L = get_safe_random_station_turf()
	A.affected_mob.say("SCYAR NILA!")
	do_teleport(A.affected_mob, L, forceMove = TRUE, channel = TELEPORT_CHANNEL_MAGIC)
	playsound(get_turf(A.affected_mob), 'sound/weapons/zapbang.ogg', 50,1)	
	
/datum/symptom/wizarditis/End(datum/disease/advance/A)
	if(ishuman(A.affected_mob))
		var/mob/living/carbon/human/H = A.affected_mob
		if(istype(H.head, /obj/item/clothing/head/wizard))
			REMOVE_TRAIT(H.head, TRAIT_NODROP, DISEASE_TRAIT)
		if(istype(H.wear_suit, /obj/item/clothing/suit/wizrobe))
			REMOVE_TRAIT(H.wear_suit, TRAIT_NODROP, DISEASE_TRAIT)
		if(istype(H.shoes, /obj/item/clothing/shoes/sandal/magic))
			REMOVE_TRAIT(H.shoes, TRAIT_NODROP, DISEASE_TRAIT)

		

