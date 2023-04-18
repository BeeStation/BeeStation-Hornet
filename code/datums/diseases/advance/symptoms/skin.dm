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
		if(H.dna.species.use_skintones)
			cachedcolor = H.skin_tone
		else if(MUTCOLORS in H.dna.species.species_traits)
			cachedcolor	= H.dna.features["mcolor"]

/datum/symptom/vitiligo/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.skin_tone == "albino")
			return
		if(H.dna.features["mcolor"] == "EEE")
			return
		switch(A.stage)
			if(5)
				if(H.dna.species.use_skintones)
					H.skin_tone = "albino"
				else if(MUTCOLORS in H.dna.species.species_traits)
					H.dna.features["mcolor"] = "EEE" //pure white.
				H.regenerate_icons()
			else
				H.visible_message("<span class='notice'>[H] looks a bit pale.</span>", "<span class='notice'>Your skin suddenly appears lighter.</span>")

/datum/symptom/vitiligo/End(datum/disease/advance/A)
	. = ..()
	var/mob/living/M = A.affected_mob
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.dna.species.use_skintones)
			H.skin_tone = cachedcolor
		else if(MUTCOLORS in H.dna.species.species_traits)
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
		if(H.dna.species.use_skintones)
			cachedcolor = H.skin_tone
		else if(MUTCOLORS in H.dna.species.species_traits)
			cachedcolor	= H.dna.features["mcolor"]

/datum/symptom/revitiligo/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.skin_tone == "african2")
			return
		if(H.dna.features["mcolor"] == "000")
			return
		switch(A.stage)
			if(5)
				if(H.dna.species.use_skintones)
					H.skin_tone = "african2"
				else if(MUTCOLORS in H.dna.species.species_traits)
					H.dna.features["mcolor"] = "000" //pure black.
				H.regenerate_icons()
			else
				H.visible_message("<span class='notice'>[H] looks a bit dark.</span>", "<span class='notice'>Your skin suddenly appears darker.</span>")

/datum/symptom/revitiligo/End(datum/disease/advance/A)
	. = ..()
	var/mob/living/M = A.affected_mob
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.dna.species.use_skintones)
			H.skin_tone = cachedcolor
		else if(MUTCOLORS in H.dna.species.species_traits)
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
				M.visible_message("<span class='notice'>[M] looks rather vibrant.</span>", "<span class='notice'>The colors, man, the colors.</span>")

/************************************
Dermagraphic Ovulogenesis

	Extremely Noticeable
	Increases resistance slightly.
	Not Fast, Not Slow
	Transmittable.
	High Level

BONUS
	Provides Brute Healing when Egg Sacs/Eggs are eaten, simultaneously infecting anyone who eats them

***********************************/
/datum/symptom/skineggs //Thought Exolocomotive Xenomitosis was a weird symptom? Well, this is about 10x weirder.
	name = "Dermagraphic Ovulogenesis"
	desc = "The virus causes the host to grow egg-like nodules on their skin, which periodically fall off and contain the disease and some healing chemicals."
	stealth = -3 //You are basically growing these weird Egg shits on your skin, this is not stealthy in the slightest
	resistance = 1
	stage_speed = 0
	transmission = 2 //The symptom is in it of itself meant to spread
	level = 8
	severity = -1
	base_message_chance = 50
	symptom_delay_min = 60
	symptom_delay_max = 105
	prefixes = list("Ovi ")
	bodies = list("Oviposition", "Nodule")
	suffixes = list(" Mitosis")
	var/big_heal
	var/all_disease
	var/eggsplosion
	var/sneaky
	threshold_desc = "<b>Transmission 12:</b> Eggs and Egg Sacs contain all diseases on the host, instead of just the disease containing the symptom.<br>\
					  <b>Transmission 16:</b> Egg Sacs will 'explode' into eggs after a period of time, covering a larger area with infectious matter.<br>\
					  <b>Resistance 10:</b> Eggs and Egg Sacs contain more healing chems.<br>\
					  <b>Stealth 6:</b> Eggs and Egg Sacs become nearly transparent, making them more difficult to see.<br>\
					  <b>Stage Speed 10:</b> Egg Sacs fall off the host more frequently."

/datum/symptom/skineggs/severityset(datum/disease/advance/A)
	. = ..()
	if(A.resistance >= 10)
		severity -= 1
	if(A.transmission >= 12)
		severity += 1
		if(A.transmission >= 16)
			severity += 1
	if(A.stealth >= 6)
		severity += 1

/datum/symptom/skineggs/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.resistance >= 10)
		big_heal = TRUE
	if(A.transmission >= 12)
		all_disease = TRUE
		if(A.transmission >= 16)
			eggsplosion = TRUE //Haha get it?
	if(A.stealth >= 6)
		sneaky = TRUE
	if(A.stage_rate >= 10)
		symptom_delay_min -= 10
		symptom_delay_max -= 20


/datum/symptom/skineggs/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	var/list/diseases = list(A)
	switch(A.stage)
		if(5)
			if(all_disease)
				for(var/datum/disease/D in M.diseases)
					if((D.spread_flags & DISEASE_SPREAD_SPECIAL) || (D.spread_flags & DISEASE_SPREAD_NON_CONTAGIOUS) || (D.spread_flags & DISEASE_SPREAD_FALTERED))
						continue
					if(D == A)
						continue
					diseases += D
			new /obj/item/reagent_containers/food/snacks/eggsac(M.loc, diseases, eggsplosion, sneaky, big_heal)

#define EGGSPLODE_DELAY 100 SECONDS
/obj/item/reagent_containers/food/snacks/eggsac
	name = "Fleshy Egg Sac"
	desc = "A small Egg Sac which appears to be made out of someone's flesh!"
	customfoodfilling = FALSE //Not Used For Filling
	icon = 'icons/obj/food/food.dmi'
	icon_state = "eggsac"
	bitesize = 4
	var/list/diseases = list()
	var/sneaky_egg
	var/big_heal

//Constructor
/obj/item/reagent_containers/food/snacks/eggsac/New(loc, var/list/disease, var/eggsplodes, var/sneaky, var/large_heal)
	..()
	for(var/datum/disease/D in disease)
		diseases += D
	if(large_heal)
		reagents.add_reagent_list(list(/datum/reagent/medicine/bicaridine = 20, /datum/reagent/medicine/tricordrazine = 10))
		reagents.add_reagent(/datum/reagent/blood, 10, diseases)
		big_heal = TRUE
	else
		reagents.add_reagent_list(list(/datum/reagent/medicine/bicaridine = 10, /datum/reagent/medicine/tricordrazine = 10))
		reagents.add_reagent(/datum/reagent/blood, 15, diseases)
	if(sneaky)
		icon_state = "eggsac-sneaky"
		sneaky_egg = sneaky
	if(eggsplodes)
		addtimer(CALLBACK(src, PROC_REF(eggsplode)), EGGSPLODE_DELAY)
	if(LAZYLEN(diseases))
		AddComponent(/datum/component/infective, diseases)

#undef EGGSPLODE_DELAY

/obj/item/reagent_containers/food/snacks/eggsac/proc/eggsplode()
	for(var/i = 1, i <= rand(4,8), i++)
		var/list/directions = GLOB.alldirs
		var/obj/item/I = new /obj/item/reagent_containers/food/snacks/fleshegg(src.loc, diseases, sneaky_egg, big_heal)
		var/turf/thrown_at = get_ranged_target_turf(I, pick(directions), rand(2, 4))
		I.throw_at(thrown_at, rand(2,4), 4)

/obj/item/reagent_containers/food/snacks/fleshegg
	name = "Fleshy Egg"
	desc = "An Egg which appears to be made out of someone's flesh!"
	customfoodfilling = FALSE //Not Used For Filling
	icon = 'icons/obj/food/food.dmi'
	icon_state = "fleshegg"
	bitesize = 1
	var/list/diseases = list()

/obj/item/reagent_containers/food/snacks/fleshegg/New(loc, var/list/disease, var/sneaky, var/large_heal)
	..()
	for(var/datum/disease/D in disease)
		diseases += D
	if(large_heal)
		reagents.add_reagent_list(list(/datum/reagent/medicine/bicaridine = 20, /datum/reagent/medicine/tricordrazine = 10))
		reagents.add_reagent(/datum/reagent/blood, 10, diseases)
	else
		reagents.add_reagent_list(list(/datum/reagent/medicine/bicaridine = 10, /datum/reagent/medicine/tricordrazine = 10))
		reagents.add_reagent(/datum/reagent/blood, 15, diseases)
	if(sneaky)
		icon_state = "fleshegg-sneaky"
	if(LAZYLEN(diseases))
		AddComponent(/datum/component/infective, diseases)

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

/datum/symptom/spiked/Activate(var/datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/H = A.affected_mob
	switch(A.stage)
		if(1)
			if(prob(base_message_chance))
				to_chat(H, "<span class='warning'>You feel goosebumps pop up on your skin.</span>")
		if(2)
			if(prob(base_message_chance))
				to_chat(H, "<span class='warning'>Small spines spread to cover your entire body.</span>")
		if(3)
			if(prob(base_message_chance))
				to_chat(H, "<span class='warning'> Your spines pierce your jumpsuit.</span>")
		if(4, 5)
			if(!done)
				H.AddComponent(/datum/component/spikes, 5*power, armor, A.GetDiseaseID()) //removal is handled by the component
				to_chat(H, "<span class='warning'> Your spines harden, growing sharp and lethal.</span>")
				done = TRUE
			if(H.pulling && iscarbon(H.pulling)) //grabbing is handled with the disease instead of the component, so the component doesn't have to be processed
				var/mob/living/carbon/C = H.pulling
				var/def_check = C.getarmor(type = MELEE)
				C.apply_damage(1*power, BRUTE, blocked = def_check)
				C.visible_message("<span class='warning'>[C.name] is pricked on [H.name]'s spikes.</span>")
				playsound(get_turf(C), 'sound/weapons/slice.ogg', 50, 1)
			for(var/mob/living/carbon/C in ohearers(1, H))
				if(C.pulling && C.pulling == H)
					var/def_check = C.getarmor(type = MELEE)
					C.apply_damage(3*power, BRUTE, blocked = def_check)
					C.visible_message("<span class='warning'>[C.name] is pricked on [H.name]'s spikes.</span>")
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
			to_chat(M, "<span class='warning'>painful sores open on your skin!</span>")
		if(4, 5)
			var/buboes = (rand(3, 6) * power)
			M.adjustBruteLoss(buboes / 2)
			M.adjustToxLoss(buboes)
			pustules = min(pustules + buboes, 20)
			to_chat(M, "<span class='warning'>painful sores open on your skin!</span>")
			if((prob(pustules * 5) || pustules >= 20) && shoot)
				var/popped = rand(1, pustules)
				var/pusdir = pick(GLOB.alldirs)
				var/T = get_step(get_turf(M), pusdir)
				var/obj/item/ammo_casing/caseless/pimple/pustule = new(get_turf(M))
				for(var/datum/disease/advance/D in M.diseases) //spreads all diseases in the host, but only if they have fluid spread or higher
					if(A.spread_flags & DISEASE_SPREAD_CONTACT_FLUIDS)
						pustule.diseases += D
				pustule.pellets = popped
				pustule.variance = rand(50, 200)
				pustule.fire_casing(T, M, (get_turf(M)))
				pustules -= popped
				M.visible_message("<span class='warning'>[popped] pustules on [M]'s body burst open!</span>")


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
		C.visible_message("<span class='warning'>[attack_text] bursts [popped] pustules on [source]'s body!</span>")
		pustules -= popped


/datum/symptom/pustule/End(datum/disease/advance/A)
	. = ..()
	UnregisterSignal(A.affected_mob, COMSIG_HUMAN_ATTACKED)


/obj/item/ammo_casing/caseless/pimple
	variance = 120
	projectile_type = /obj/item/projectile/pimple
	var/list/diseases

/obj/item/ammo_casing/caseless/pimple/ready_proj(atom/target, mob/living/user, quiet, zone_override, atom/fired_from)
	. = ..()
	if(!BB)
		return
	if(istype(BB, /obj/item/projectile/pimple))
		var/obj/item/projectile/pimple/P = BB
		P.diseases = diseases


/obj/item/projectile/pimple
	name = "high-velocity pustule"
	damage = 4 //and very easily blocked with some bio armor
	range = 5
	speed = 5
	damage_type = TOX
	icon_state = "energy2"
	armor_flag = BIO
	var/list/diseases

/obj/item/projectile/pimple/on_hit(atom/target, blocked)
	. = ..()
	var/turf/T = get_turf(target)
	playsound(T, 'sound/effects/splat.ogg', 50, 1)
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		for(var/datum/disease/advance/A in diseases)
			C.ContactContractDisease(A)
