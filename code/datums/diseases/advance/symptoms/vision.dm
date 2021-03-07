/*
//////////////////////////////////////

Hyphema (Eye bleeding)

	Slightly noticable.
	Lowers resistance tremendously.
	Decreases stage speed tremendously.
	Decreases transmittablity.
	Critical Level.

Bonus
	Causes blindness.

//////////////////////////////////////
*/

/datum/symptom/visionloss

	name = "Hyphema"
	desc = "The virus causes inflammation of the retina, leading to eye damage and eventually blindness."
	stealth = -1
	resistance = -3
	stage_speed = -4
	transmittable = -2
	level = 5
	severity = 3
	base_message_chance = 50
	symptom_delay_min = 25
	symptom_delay_max = 80
	var/remove_eyes = FALSE
	threshold_desc = "<b>Resistance 12:</b> Weakens extraocular muscles, eventually leading to complete detachment of the eyes.<br>\
					  <b>Stealth 4:</b> The symptom remains hidden until active."

/datum/symptom/visionloss/severityset(datum/disease/advance/A)
	. = ..()
	if(A.properties["resistance"] >= 12) //goodbye eyes
		severity += 1

/datum/symptom/visionloss/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["stealth"] >= 4)
		suppress_warning = TRUE
	if(A.properties["resistance"] >= 12) //goodbye eyes
		remove_eyes = TRUE

/datum/symptom/visionloss/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	var/obj/item/organ/eyes/eyes = M.getorganslot(ORGAN_SLOT_EYES)
	if(eyes)
		switch(A.stage)
			if(1, 2)
				if(prob(base_message_chance) && !suppress_warning)
					to_chat(M, "<span class='warning'>Your eyes itch.</span>")
			if(3, 4)
				to_chat(M, "<span class='warning'><b>Your eyes burn!</b></span>")
				M.blur_eyes(10)
				eyes.applyOrganDamage(1)
			else
				M.blur_eyes(20)
				eyes.applyOrganDamage(5)
				if(eyes.damage >= 10)
					M.become_nearsighted(EYE_DAMAGE)
				if(prob(eyes.damage - 10 + 1))
					if(!remove_eyes)
						if(!HAS_TRAIT(M, TRAIT_BLIND))
							to_chat(M, "<span class='userdanger'>You go blind!</span>")
							eyes.applyOrganDamage(eyes.maxHealth)
					else
						M.visible_message("<span class='warning'>[M]'s eyes fall out of their sockets!</span>", "<span class='userdanger'>Your eyes fall out of their sockets!</span>")
						eyes.Remove(M)
						eyes.forceMove(get_turf(M))
				else
					to_chat(M, "<span class='userdanger'>Your eyes burn horrifically!</span>")

/datum/symptom/ocularsensitivity
	name = "Ocular Hyper-reception"
	desc = "The virus increases the sensitivity of the rods and cones to light, allowing better vision in the dark"
	stealth = 1
	resistance = -2
	stage_speed = -2
	transmittable = 0
	level = 9
	severity = 0
	base_message_chance = 50
	symptom_delay_min = 15
	symptom_delay_max = 50
	var/better_vis = FALSE
	var/nvgs = FALSE
	var/thermal = FALSE
	var/xray = FALSE
	var/nvision_buff = FALSE //Toggles TRUE when the Night Vision Buffs are Applied
	var/other_buff = FALSE //Toggles TRUE when Thermal/Xray is applied
	threshold_desc = "<b>Resistance 10:</b> Vision in the dark is even better.<br>\
					  <b>Resistance 14:</b> The host will grow a pair of NVGs.<br>\
					  <b>Stage Speed 10:</b> The host's eyes are able to percieve infrared radiation.<br>\
					  <b>Stage Speed 18:</b> The host's eyes are able to percieve xray radiation. This overrides the thermal vision threshhold."

/datum/symptom/ocularsensitivity/severityset(datum/disease/advance/A)
	. = ..()
	if(A.properties["resistance"] >= 10) //Better Night Vision
		severity -= 1
	if(A.properties["resistance"] >= 14)
		severity += 2 //Disregards the decrease from other resistance threshold, in fact is probably borderline antagonistic.
	if(A.properties["stage_rate"] >= 10) //Thermal Vision
		severity -= 1
	if(A.properties["stage_rate"] >= 18) //Xray Vision
		severity -= 2

/datum/symptom/ocularsensitivity/Start(datum/disease/advance/A)
	. = ..()
	if(A.properties["resistance"] >= 10) //Better Night Vision
		better_vis = TRUE
	if(A.properties["resistance"] >= 14) //Grow a pair of NVGS
		nvgs = TRUE
	if(A.properties["stage_rate"] >= 10) //Thermal Vision
		thermal = TRUE
	if(A.properties["stage_rate"] >= 18) //Xray Vision
		xray = TRUE

/datum/symptom/ocularsensitivity/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/L = A.affected_mob
	switch(A.stage)
		if(4)
			if(!nvision_buff)
				to_chat(L, "<span class='userdanger'>Your vision becomes better!</span>")
				if(better_vis)
					L.see_in_dark += 4
					nvision_buff = TRUE
				else
					L.see_in_dark += 2
					nvision_buff = TRUE
			if(thermal && !xray && !other_buff)
				ADD_TRAIT(L, TRAIT_THERMAL_VISION, DISEASE_TRAIT)
			if(xray && !other_buff)
				ADD_TRAIT(L, TRAIT_XRAY_VISION, DISEASE_TRAIT)
		if(5)
			if(nvgs)
				giveNVGS(A)

/datum/symptom/ocularsensitivity/proc/giveNVGS(datum/disease/advance/A)
	if(ishuman(A.affected_mob))
		var/mob/living/carbon/human/M = A.affected_mob
		if(!istype(M.glasses, /obj/item/clothing/glasses/night))
			if(!M.dropItemToGround(M.glasses))
				qdel(M.glasses)
			var/obj/item/clothing/C = new /obj/item/clothing/glasses/night(M)
			ADD_TRAIT(C, TRAIT_NODROP, DISEASE_TRAIT)
			M.equip_to_slot_or_del(C, SLOT_WEAR_MASK)
			return

/datum/symptom/ocularsensitivity/End(datum/disease/advance/A)
	..()
	var/mob/living/L = A.affected_mob
	if(better_vis)
		L.see_in_dark -= 4
	else
		L.see_in_dark -= 2
	if(thermal && !xray)
		REMOVE_TRAIT(L, TRAIT_THERMAL_VISION, DISEASE_TRAIT)
	if(xray)
		REMOVE_TRAIT(L, TRAIT_XRAY_VISION, DISEASE_TRAIT)
	if(ishuman(A.affected_mob))
		var/mob/living/carbon/human/M = A.affected_mob
		if(istype(M.glasses, /obj/item/clothing/glasses/night))
			REMOVE_TRAIT(M.glasses, TRAIT_NODROP, DISEASE_TRAIT)
