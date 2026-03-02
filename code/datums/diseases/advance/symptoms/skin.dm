/*
//////////////////////////////////////
Vitiligo

	Hidden.
	No change to resistance.
	Increases stage speed.
	Slightly increases transmittability.
	Critical Level.

BONUS
	Makes the mob lose skin pigmentation.

//////////////////////////////////////
*/

/datum/symptom/vitiligo

	name = "Vitiligo"
	desc = "The virus destroys skin pigment cells, causing rapid loss of pigmentation in the host."
	stealth = 2
	resistance = 0
	stage_speed = 3
	transmission = 1
	level = 5
	severity = 0
	symptom_delay_min = 25
	symptom_delay_max = 75
	prefixes = list("White ", "Light ")
	bodies = list("Albinism")
	var/cachedcolor = null

/datum/symptom/vitiligo/Start(datum/disease/advance/A)
	. = ..()
	var/mob/living/M = A.affected_mob
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(HAS_TRAIT(H, TRAIT_USES_SKINTONES))
			cachedcolor = H.skin_tone
		else if(HAS_TRAIT(H, TRAIT_MUTANT_COLORS) && !HAS_TRAIT(H, TRAIT_FIXED_MUTANT_COLORS))
			cachedcolor	= H.dna.features["mcolor"]

/datum/symptom/vitiligo/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.skin_tone == "albino")
			return
		if(H.dna.features["mcolor"] == COLOR_VERY_LIGHT_GRAY)
			return
		switch(A.stage)
			if(5)
				if(HAS_TRAIT(H, TRAIT_USES_SKINTONES))
					H.skin_tone = "albino"
				else if(HAS_TRAIT(H, TRAIT_MUTANT_COLORS) && !HAS_TRAIT(H, TRAIT_FIXED_MUTANT_COLORS))
					H.dna.features["mcolor"] = COLOR_VERY_LIGHT_GRAY
				H.regenerate_icons()
			else
				H.visible_message(span_notice("[H] looks a bit pale."), span_notice("Your skin suddenly appears lighter."))

/datum/symptom/vitiligo/End(datum/disease/advance/A)
	. = ..()
	var/mob/living/M = A.affected_mob
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(HAS_TRAIT(H, TRAIT_USES_SKINTONES))
			H.skin_tone = cachedcolor
		else if(HAS_TRAIT(H, TRAIT_MUTANT_COLORS) && !HAS_TRAIT(H, TRAIT_FIXED_MUTANT_COLORS))
			H.dna.features["mcolor"] = cachedcolor
		H.regenerate_icons()

/*
//////////////////////////////////////
Revitiligo

	Slightly noticeable.
	Increases resistance.
	Increases stage speed slightly.
	Increases transmission.
	Critical Level.

BONUS
	Makes the mob gain skin pigmentation.

//////////////////////////////////////
*/

/datum/symptom/revitiligo
	name = "Revitiligo"
	desc = "The virus causes increased production of skin pigment cells, making the host's skin grow darker over time."
	stealth = 1
	resistance = 2
	stage_speed = 1
	transmission = 2
	level = 5
	severity = 0
	symptom_delay_min = 7
	symptom_delay_max = 14
	prefixes = list("Black ", "Dark ")
	bodies = list("Melanism")
	var/cachedcolor = null

/datum/symptom/revitiligo/Start(datum/disease/advance/A)
	. = ..()
	var/mob/living/M = A.affected_mob
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(HAS_TRAIT(H, TRAIT_USES_SKINTONES))
			cachedcolor = H.skin_tone
		else if(HAS_TRAIT(H, TRAIT_MUTANT_COLORS) && !HAS_TRAIT(H, TRAIT_FIXED_MUTANT_COLORS))
			cachedcolor	= H.dna.features["mcolor"]

/datum/symptom/revitiligo/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.skin_tone == "african2")
			return
		if(H.dna.features["mcolor"] == COLOR_BLACK)
			return
		switch(A.stage)
			if(5)
				if(HAS_TRAIT(H, TRAIT_USES_SKINTONES))
					H.skin_tone = "african2"
				else if(HAS_TRAIT(H, TRAIT_MUTANT_COLORS) && !HAS_TRAIT(H, TRAIT_FIXED_MUTANT_COLORS))
					H.dna.features["mcolor"] = COLOR_BLACK
				H.regenerate_icons()
			else
				H.visible_message(span_notice("[H] looks a bit dark."), span_notice("Your skin suddenly appears darker."))

/datum/symptom/revitiligo/End(datum/disease/advance/A)
	. = ..()
	var/mob/living/M = A.affected_mob
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(HAS_TRAIT(H, TRAIT_USES_SKINTONES))
			H.skin_tone = cachedcolor
		else if(HAS_TRAIT(H, TRAIT_MUTANT_COLORS) && !HAS_TRAIT(H, TRAIT_FIXED_MUTANT_COLORS))
			H.dna.features["mcolor"] = cachedcolor
		H.regenerate_icons()

/*
//////////////////////////////////////
Polyvitiligo

	Not Noticeable.
	Increases resistance slightly.
	Increases stage speed.
	Transmittable.
	Low Level.

BONUS
	Makes the host change color

//////////////////////////////////////
*/

/datum/symptom/polyvitiligo
	name = "Polyvitiligo"
	desc = "The virus replaces the melanin in the skin with reactive pigment."
	stealth = 0
	resistance = 1
	stage_speed = 4
	transmission = 1
	level = 0
	severity = 0
	base_message_chance = 50
	symptom_delay_min = 45
	symptom_delay_max = 90
	prefixes = list("Rainbow ", "Chromatic ")
	bodies = list("Pigment")

/datum/symptom/polyvitiligo/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(5)
			var/static/list/banned_reagents = list(/datum/reagent/colorful_reagent/powder/invisible, /datum/reagent/colorful_reagent/powder/white)
			var/color = pick(subtypesof(/datum/reagent/colorful_reagent/powder) - banned_reagents)
			if(M.reagents.total_volume <= (M.reagents.maximum_volume/10)) // no flooding humans with 1000 units of colorful reagent
				M.reagents.add_reagent(color, 5)
		else
			if (prob(50)) // spam
				M.visible_message(span_notice("[M] looks rather vibrant."), span_notice("The colors, man, the colors."))


/*
//////////////////////////////////////
Spiked Skin
	Noticeable.
	Raises resistance
	Decreases stage speed
	No transmission bonus

Thresholds
	transmission 6 Can give minor armour
	resistance 6 Does more damage

//////////////////////////////////////
*/
/datum/symptom/spiked
	name = "Cornu Cutaneum"
	desc = "The virus causes the host to unpredictably grow and shed sharp spines, damaging those near them."
	stealth = -3
	resistance = 3
	stage_speed = -3
	transmission = 0
	level = 8
	symptom_delay_min = 1
	symptom_delay_max = 1
	severity = 1
	base_message_chance = 5
	prefixes = list("Thorny ", "Horned ")
	bodies = list("Horn", "Spiked")
	var/armor = 0
	var/done = FALSE
	threshold_desc = "<b>Transmission 6:</b> Spikes deal more damage.<br>\
						<b>Resistance 6:</b> Hard spines give the host armor, scaling with resistance."

/datum/symptom/spiked/severityset(datum/disease/advance/A)
	. = ..()
	if(A.resistance >= 6)
		severity -= 1

/datum/symptom/spiked/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.resistance >= 6) //armor. capped at 20, but scaling with resistance, so if you want to max out spiked skin armor, you'll have to make several sacrifices
		armor = min(20, A.resistance)
	if(A.transmission >= 6) //higher damage
		power = 1.4  //the typical +100% is waaaay too strong here when the symptom is stacked. +40% is sufficient

/datum/symptom/spiked/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/H = A.affected_mob
	switch(A.stage)
		if(1)
			if(prob(base_message_chance) && H.stat != DEAD)
				to_chat(H, span_warning("You feel goosebumps pop up on your skin."))
		if(2)
			if(prob(base_message_chance) && H.stat != DEAD)
				to_chat(H, span_warning("Small spines spread to cover your entire body."))
		if(3)
			if(prob(base_message_chance) && H.stat != DEAD)
				to_chat(H, span_warning(" Your spines pierce your jumpsuit."))
		if(4, 5)
			if(!done)
				H.AddComponent(/datum/component/spikes, 5*power, armor, A.GetDiseaseID()) //removal is handled by the component
				if(H.stat != DEAD)
					to_chat(H, span_warning(" Your spines harden, growing sharp and lethal."))
				done = TRUE
			if(H.pulling && iscarbon(H.pulling)) //grabbing is handled with the disease instead of the component, so the component doesn't have to be processed
				var/mob/living/carbon/C = H.pulling
				var/def_check = C.getarmor(type = MELEE)
				C.apply_damage(1*power, BRUTE, blocked = def_check)
				C.visible_message(span_warning("[C.name] is pricked on [H.name]'s spikes."))
				playsound(get_turf(C), 'sound/weapons/slice.ogg', 50, 1)
			for(var/mob/living/carbon/C in ohearers(1, H))
				if(C.pulling && C.pulling == H)
					var/def_check = C.getarmor(type = MELEE)
					C.apply_damage(3*power, BRUTE, blocked = def_check)
					C.visible_message(span_warning("[C.name] is pricked on [H.name]'s spikes."))
					playsound(get_turf(C), 'sound/weapons/slice.ogg', 50, 1)


/datum/symptom/pustule
	name = "Bubonic Infection"
	desc = "The virus causes festering infections in the host's lymph nodes, leading to festering buboes that deal toxin damage."
	stealth = -1
	resistance = -2
	stage_speed = 3
	transmission = 2
	level = 7
	severity = 3
	symptom_delay_min = 20
	symptom_delay_max = 60
	prefixes = list("Pestilent ", "Bubonic ")
	var/pustules = 0
	var/shoot = FALSE
	threshold_desc = "<b>Transmission 4:</b>Buboes will occasionally burst when disturbed or left too long, shooting out toxic pus.<br>\
					<b>Transmission 6:</b> Pustules appear on the host more frequently, dealing more damage."

/datum/symptom/pustule/severityset(datum/disease/advance/A)
	. = ..()
	if(A.transmission >= 4)
		severity += 1
		prefixes = list("Ballistic ", "Pestilent ", "Bubonic ")

/datum/symptom/pustule/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.transmission >= 4)
		shoot = TRUE
	if(A.transmission >= 6)
		power += 1
	RegisterSignal(A.affected_mob, COMSIG_HUMAN_ATTACKED, PROC_REF(pop_pustules))


/datum/symptom/pustule/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob

	switch(A.stage)
		if(2, 3)
			var/buboes = (rand(1, 3) * power)
			M.adjustBruteLoss(buboes / 2)
			M.adjustToxLoss(buboes)
			pustules = min(pustules + buboes, 10)
			if(M.stat != DEAD)
				to_chat(M, span_warning("painful sores open on your skin!"))
		if(4, 5)
			var/buboes = (rand(3, 6) * power)
			M.adjustBruteLoss(buboes / 2)
			M.adjustToxLoss(buboes)
			pustules = min(pustules + buboes, 20)
			if(M.stat != DEAD)
				to_chat(M, span_warning("painful sores open on your skin!"))
			if((prob(pustules * 5) || pustules >= 20) && (shoot || CONFIG_GET(flag/unconditional_virus_spreading) || A.event))
				var/popped = rand(1, pustules)
				var/pusdir = pick(GLOB.alldirs)
				var/T = get_step(get_turf(M), pusdir)
				var/obj/item/ammo_casing/caseless/pimple/pustule = new(get_turf(M))
				for(var/datum/disease/advance/D in M.diseases) //spreads all diseases in the host, but only if they have fluid spread or higher
					if(A.spread_flags & DISEASE_SPREAD_CONTACT_FLUIDS || CONFIG_GET(flag/unconditional_virus_spreading) || A.event)
						pustule.diseases += D
				pustule.pellets = popped
				pustule.variance = rand(50, 200)
				pustule.fire_casing(T, M, fired_from = M)
				pustules -= popped
				M.visible_message(span_warning("[popped] pustules on [M]'s body burst open!"))


/datum/symptom/pustule/proc/pop_pustules(datum/source, AM, attack_text, damage)
	SIGNAL_HANDLER
	var/popped = min(rand(-10, pustules), damage)
	var/turf/T = get_turf(source)
	if(!shoot)
		return
	if(iscarbon(source) && popped)
		var/mob/living/carbon/C = source
		var/obj/item/ammo_casing/caseless/pimple/pustule = new(T)
		for(var/datum/disease/advance/A in C.diseases) //spreads all diseases in the host, but only if they have fluid spread or higher
			if(A.spread_flags & DISEASE_SPREAD_CONTACT_FLUIDS)
				pustule.diseases += A
		pustule.pellets = popped
		pustule.fire_casing(AM, C, fired_from = T)
		C.visible_message(span_warning("[attack_text] bursts [popped] pustules on [source]'s body!"))
		pustules -= popped


/datum/symptom/pustule/End(datum/disease/advance/A)
	. = ..()
	UnregisterSignal(A.affected_mob, COMSIG_HUMAN_ATTACKED)


/obj/item/ammo_casing/caseless/pimple
	variance = 120
	projectile_type = /obj/projectile/pimple
	var/list/diseases

/obj/item/ammo_casing/caseless/pimple/ready_proj(atom/target, mob/living/user, quiet, zone_override, atom/fired_from)
	. = ..()
	if(!BB)
		return
	if(istype(BB, /obj/projectile/pimple))
		var/obj/projectile/pimple/P = BB
		P.diseases = diseases


/obj/projectile/pimple
	name = "high-velocity pustule"
	damage = 4 //and very easily blocked with some bio armor
	range = 5
	speed = 5
	damage_type = TOX
	icon_state = "energy2"
	armor_flag = BIO
	var/list/diseases

/obj/projectile/pimple/on_hit(atom/target, blocked)
	. = ..()
	var/turf/T = get_turf(target)
	playsound(T, 'sound/effects/splat.ogg', 50, 1)
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		for(var/datum/disease/advance/A in diseases)
			C.ContactContractDisease(A)
