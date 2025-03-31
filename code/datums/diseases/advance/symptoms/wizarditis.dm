/datum/symptom/wizarditis
	name = "Wizarditis"
	desc = "Causes the host to subconsciously believe they are in fact, a wizard."
	stealth = 1
	resistance = -2
	stage_speed = -3
	transmission = -1
	level = 0
	severity = 0
	symptom_delay_min = 15
	symptom_delay_max = 45
	prefixes = list("Wizard's ", "Magic ", "Accursed ")
	bodies = list("Wizard")
	var/teleport = FALSE
	var/robes = FALSE
	threshold_desc = "<b>Transmission 8:</b> The host teleports occasionally.<br>\
						<b>Stage Speed 7:</b> The host grows a set of wizard robes."

/datum/symptom/wizarditis/severityset(datum/disease/advance/A)
	. = ..()
	if(A.transmission >= 8)
		severity += 1
	if(A.stage_rate >= 7)
		severity += 1

/datum/symptom/wizarditis/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.transmission >= 8)
		teleport = TRUE
	if(A.stage_rate >= 7)
		robes = TRUE

/datum/symptom/wizarditis/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	if(M.stat == DEAD)
		return
	switch(A.stage)
		if(2)
			if(prob(15) && M.stat != DEAD)
				M.say(pick("You shall not pass!", "Expeliarmus!", "By Merlins beard!", "Feel the power of the Dark Side!"), forced = "wizarditis")
			if(prob(15))
				to_chat(M, span_danger("You feel [pick("that you don't have enough mana", "that the winds of magic are gone", "an urge to summon familiar")]."))


		if(3)
			if(prob(15) && M.stat != DEAD)
				M.say(pick("NEC CANTIO!","AULIE OXIN FIERA!", "STI KALY!", "TARCOL MINTI ZHERI!"), forced = "wizarditis")
			if(prob(15))
				to_chat(M, span_danger("You feel [pick("the magic bubbling in your veins","that this location gives you a +1 to INT","an urge to summon familiar")]."))

		if(4, 5)

			if(prob(50) && M.stat != DEAD)
				M.say(pick("NEC CANTIO!","AULIE OXIN FIERA!","STI KALY!","EI NATH!"), forced = "wizarditis")
				return
			if(robes)
				to_chat(M, span_danger("You feel [pick("the tidal wave of raw power building inside","that this location gives you a +2 to INT and +1 to WIS","an urge to teleport")]."))
				spawn_wizard_clothes(50, A)
			if(prob(20) && teleport)
				wizarditis_teleport(A.affected_mob)
	return



/datum/symptom/wizarditis/proc/spawn_wizard_clothes(chance = 0, datum/disease/advance/A)
	if(ishuman(A.affected_mob))
		var/mob/living/carbon/human/H = A.affected_mob
		var/obj/item/clothing/C
		if(prob(chance))
			if(!istype(H.head, /obj/item/clothing/head/wizard))
				if(!H.dropItemToGround(H.head))
					qdel(H.head)
				C = new /obj/item/clothing/head/wizard/fake(H)
				ADD_TRAIT(C, TRAIT_NODROP, DISEASE_TRAIT)
				H.equip_to_slot_or_del(C, ITEM_SLOT_HEAD)
			return
		if(prob(chance))
			if(!istype(H.wear_suit, /obj/item/clothing/suit/wizrobe))
				if(!H.dropItemToGround(H.wear_suit))
					qdel(H.wear_suit)
				C = new /obj/item/clothing/suit/wizrobe/fake(H)
				ADD_TRAIT(C, TRAIT_NODROP, DISEASE_TRAIT)
				H.equip_to_slot_or_del(C, ITEM_SLOT_OCLOTHING)
			return
		if(prob(chance))
			if(!istype(H.shoes, /obj/item/clothing/shoes/sandal))
				if(!H.dropItemToGround(H.shoes))
					qdel(H.shoes)
				C = new /obj/item/clothing/shoes/sandal(H)
				ADD_TRAIT(C, TRAIT_NODROP, DISEASE_TRAIT)
				H.equip_to_slot_or_del(C, ITEM_SLOT_FEET)
			return
	else
		var/mob/living/carbon/H = A.affected_mob
		if(prob(chance))
			var/obj/item/staff/S = new(H)
			if(!H.put_in_hands(S))
				qdel(S)


/datum/symptom/wizarditis/End(datum/disease/advance/A)
	if(ishuman(A.affected_mob))
		var/mob/living/carbon/human/H = A.affected_mob
		if(istype(H.head, /obj/item/clothing/head/wizard))
			REMOVE_TRAIT(H.head, TRAIT_NODROP, DISEASE_TRAIT)
		if(istype(H.wear_suit, /obj/item/clothing/suit/wizrobe))
			REMOVE_TRAIT(H.wear_suit, TRAIT_NODROP, DISEASE_TRAIT)
		if(istype(H.shoes, /obj/item/clothing/shoes/sandal))
			REMOVE_TRAIT(H.shoes, TRAIT_NODROP, DISEASE_TRAIT)



