/datum/symptom/wizarditis
	name = "Wizarditis"
	desc = "Causes the host's brain cells to naturally die off, causing severe brain damage."
	stealth = 1
	resistance = -2
	stage_speed = -3
	transmittable = -1
	level = 0
	severity = 3
	symptom_delay_min = 15
	symptom_delay_max = 30
	var/teleport = FALSE
	var/robes = FALSE
	threshold_desc = "<b>Transmission 14:</b> The host teleports occasionally.<br>\
					  <b>Speed 7:</b> The host grows a set of wizard robes."

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
	switch(A.stage)
		if(2)
			if(prob(1)&&prob(50))
				A.affected_mob.say(pick("You shall not pass!", "Expeliarmus!", "By Merlins beard!", "Feel the power of the Dark Side!"), forced = "wizarditis")
			if(prob(1)&&prob(50))
				to_chat(A.affected_mob, "<span class='danger'>You feel [pick("that you don't have enough mana", "that the winds of magic are gone", "an urge to summon familiar")].</span>")


		if(3)
			if(prob(1)&&prob(50))
				A.affected_mob.say(pick("NEC CANTIO!","AULIE OXIN FIERA!", "STI KALY!", "TARCOL MINTI ZHERI!"), forced = "wizarditis")
			if(prob(1)&&prob(50))
				to_chat(A.affected_mob, "<span class='danger'>You feel [pick("the magic bubbling in your veins","that this location gives you a +1 to INT","an urge to summon familiar")].</span>")

		if(4)

			if(prob(1))
				A.affected_mob.say(pick("NEC CANTIO!","AULIE OXIN FIERA!","STI KALY!","EI NATH!"), forced = "wizarditis")
				return
			if(prob(1)&&robes)
				to_chat(A.affected_mob, "<span class='danger'>You feel [pick("the tidal wave of raw power building inside","that this location gives you a +2 to INT and +1 to WIS","an urge to teleport")].</span>")
				spawn_wizard_clothes(50)
			if(prob(1)&&prob(50)&&teleport)
				teleport()
	return



/datum/disease/wizarditis/proc/spawn_wizard_clothes(chance = 0)
	if(ishuman(A.affected_mob))
		var/mob/living/carbon/human/H = A.affected_mob
		if(prob(chance))
			if(!istype(H.head, /obj/item/clothing/head/wizard))
				if(!H.dropItemToGround(H.head))
					qdel(H.head)
				H.equip_to_slot_or_del(new /obj/item/clothing/head/wizard(H), SLOT_HEAD)
			return
		if(prob(chance))
			if(!istype(H.wear_suit, /obj/item/clothing/suit/wizrobe))
				if(!H.dropItemToGround(H.wear_suit))
					qdel(H.wear_suit)
				H.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe(H), SLOT_WEAR_SUIT)
			return
		if(prob(chance))
			if(!istype(H.shoes, /obj/item/clothing/shoes/sandal/magic))
				if(!H.dropItemToGround(H.shoes))
					qdel(H.shoes)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal/magic(H), SLOT_SHOES)
			return
	else
		var/mob/living/carbon/H = A.affected_mob
		if(prob(chance))
			var/obj/item/staff/S = new(H)
			if(!H.put_in_hands(S))
				qdel(S)


/datum/disease/wizarditis/proc/teleport()
	var/list/theareas = get_areas_in_range(80, A.affected_mob)
	for(var/area/space/S in theareas)
		theareas -= S

	if(!theareas||!theareas.len)
		return

	var/area/thearea = pick(theareas)

	var/list/L = list()
	for(var/turf/T in get_area_turfs(thearea.type))
		if(T.z != A.affected_mob.z)
			continue
		if(T.name == "space")
			continue
		if(!T.density)
			var/clear = 1
			for(var/obj/O in T)
				if(O.density)
					clear = 0
					break
			if(clear)
				L+=T

	if(!L)
		return

	A.affected_mob.say("SCYAR NILA [uppertext(thearea.name)]!", forced = "wizarditis teleport")
	A.affected_mob.forceMove(pick(L))

	return
