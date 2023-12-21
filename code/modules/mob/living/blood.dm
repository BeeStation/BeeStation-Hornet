/****************************************************
				BLOOD SYSTEM
****************************************************/

/datum/status_effect/bleeding
	id = "ling_transformation"
	status_type = STATUS_EFFECT_REFRESH
	alert_type = /atom/movable/screen/alert/status_effect/bleeding
	tick_interval = 1 SECONDS

	var/bleed_rate = 0
	var/time_applied = 0

/datum/status_effect/bleeding/on_creation(mob/living/new_owner, bleed_rate)
	. = ..()
	if (.)
		src.bleed_rate = bleed_rate

/datum/status_effect/bleeding/tick()
	time_applied += tick_interval
	if (time_applied < 1 SECONDS)
		if(bleed_rate >= BLEED_DEEP_WOUND)
			owner.add_splatter_floor(owner.loc)
		else
			owner.add_splatter_floor(owner.loc, TRUE)
		return
	time_applied = 0
	if (owner.bleedsuppress > 0)
		owner.bleedsuppress = max(0, owner.bleedsuppress - 1 SECONDS)
		if (owner.bleedsuppress <= 0 && owner.stat != DEAD)
			to_chat(owner, "<span class='warning'>Your bandage falls, and blood starts pouring out of your wounds.</span>")
	if (owner.bleedsuppress > 0)
		linked_alert.name = "Bleeding (Bandaged)"
		linked_alert.desc = "You have bandages covering your wounds. They will heal slowly if they are not cauterized."
		linked_alert.icon_state = "bleed_bandage"
		linked_alert.maptext = MAPTEXT("0.0/s")
	else
		if (bleed_rate < BLEED_RATE_MINOR)
			linked_alert.name = "Bleeding (Light)"
			linked_alert.desc = "You have some minor cuts that look like they will heal themselves if you don't run out of blood first. Click to apply pressure to the wounds."
			linked_alert.icon_state = "bleed"
		else
			linked_alert.name = "Bleeding (Heavy)"
			linked_alert.desc = "Your wounds are bleeding heavily and are unlikely to heal themselves. Seek medical attention immediately! Click to apply pressure to the wounds."
			linked_alert.icon_state = "bleed_heavy"
		var/rate_string = "[round(bleed_rate, 0.1)]"
		if (length(rate_string) == 1)
			rate_string = "[rate_string].0"
		linked_alert.maptext = MAPTEXT("[rate_string]/s")
	if (bleed_rate < BLEED_RATE_MINOR || owner.bleedsuppress)
		bleed_rate -= BLEED_HEAL_RATE_MINOR
		tick_interval = 1 SECONDS
		if (bleed_rate <= 0)
			qdel(src)
			return
		if (owner.bleedsuppress)
			return
	else
		tick_interval = 2
	owner.bleed(bleed_rate * BLEED_RATE_MULTIPLIER)

/datum/status_effect/bleeding/on_remove()
	var/mob/living/carbon/human/human = owner
	if (!istype(human))
		return
	// Not bleeding anymore, no need to hold wounds
	human.stop_holding_wounds()

/atom/movable/screen/alert/status_effect/bleeding
	name = "Bleeding"
	desc = "You are bleeding, find something to bandage the wound or you will die."
	icon_state = "bleed"

/atom/movable/screen/alert/status_effect/bleeding/Click(location, control, params)
	var/mob/living/carbon/human/human = usr
	if (!istype(human))
		return
	if (locate(/obj/item/offhand/bleeding_suppress) in human.held_items)
		human.stop_holding_wounds()
	else
		human.hold_wounds()

/mob/living/carbon/proc/is_bleeding()
	return has_status_effect(STATUS_EFFECT_BLEED)

/mob/living/carbon/proc/add_bleeding(bleed_level)
	var/datum/status_effect/bleeding/bleed = has_status_effect(STATUS_EFFECT_BLEED)
	playsound(src, 'sound/surgery/blood_wound.ogg', 80, vary = TRUE)
	if (bleed)
		bleed.bleed_rate = bleed.bleed_rate + max(min(bleed_level * bleed_level, sqrt(bleed_level)) / max(bleed.bleed_rate, 1),bleed_level - bleed.bleed_rate)
	else
		apply_status_effect(STATUS_EFFECT_BLEED, bleed_level)
	if (bleed_level >= BLEED_DEEP_WOUND)
		blur_eyes(1)
		INVOKE_ASYNC(src, TYPE_PROC_REF(/mob, emote), "scream")
		to_chat(src, "<span class='user_danger'>Blood starts rushing out of the open wound!</span>")
	if(bleed_level >= BLEED_CUT)
		add_splatter_floor(src.loc)
	else
		add_splatter_floor(src.loc, 1)

/mob/living/carbon/proc/get_bleed_intensity()
	var/datum/status_effect/bleeding/bleed = has_status_effect(STATUS_EFFECT_BLEED)
	if (!bleed)
		return 0
	return 3 ** bleed.bleed_rate

/mob/living/carbon/proc/get_bleed_rate()
	var/datum/status_effect/bleeding/bleed = has_status_effect(STATUS_EFFECT_BLEED)
	return bleed?.bleed_rate

/mob/living/carbon/proc/cauterise_wounds()
	var/datum/status_effect/bleeding/bleed = has_status_effect(STATUS_EFFECT_BLEED)
	if (bleed)
		qdel(bleed)
		return TRUE
	return FALSE

/mob/living/carbon/proc/hold_wounds()
	if (bleedsuppress)
		balloon_alert(src, "Wounds already bandaged!")
		return
	if (locate(/obj/item/offhand/bleeding_suppress) in held_items)
		balloon_alert(src, "Already applying pressure!")
		return
	if (has_active_hand() && get_active_held_item())
		balloon_alert(src, "Active hand is full!")
		return
	var/obj/item/offhand/bleeding_suppress/supressed_thing = new()
	put_in_active_hand(supressed_thing)
	balloon_alert(src, "You apply pressure to your wounds...")

/mob/living/carbon/proc/stop_holding_wounds()
	var/located = FALSE
	for (var/obj/item/offhand/bleeding_suppress/bleed_suppression in held_items)
		qdel(bleed_suppression)
		located = TRUE
	if (located)
		balloon_alert(src, "You stop applying pressure to your wounds...")

/mob/living/carbon/proc/suppress_bloodloss(amount)
	// Stop holding the bleeding
	stop_holding_wounds()
	bleedsuppress += amount

/mob/living/carbon/monkey/handle_blood()
	if(bodytemperature >= TCRYO && !(HAS_TRAIT(src, TRAIT_HUSK))) //cryosleep or husked people do not pump the blood.
		//Blood regeneration if there is some space
		if(blood_volume < BLOOD_VOLUME_NORMAL)
			blood_volume += 0.1 // regenerate blood VERY slowly
			if(blood_volume < BLOOD_VOLUME_OKAY)
				adjustOxyLoss(round((BLOOD_VOLUME_NORMAL - blood_volume) * 0.02, 1))

// Takes care blood loss and regeneration
/mob/living/carbon/human/handle_blood()

	if(NOBLOOD in dna.species.species_traits)
		cauterise_wounds()
		return

	if(bodytemperature >= TCRYO && !(HAS_TRAIT(src, TRAIT_HUSK))) //cryosleep or husked people do not pump the blood.
		//Blood regeneration if there is some space
		if(!is_bleeding() && blood_volume < BLOOD_VOLUME_NORMAL && !HAS_TRAIT(src, TRAIT_NOHUNGER) && !HAS_TRAIT(src, TRAIT_POWERHUNGRY))
			var/nutrition_ratio = 0
			switch(nutrition)
				if(0 to NUTRITION_LEVEL_STARVING)
					nutrition_ratio = 0.2
				if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
					nutrition_ratio = 0.4
				if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
					nutrition_ratio = 0.6
				if(NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
					nutrition_ratio = 0.8
				else
					nutrition_ratio = 1
			if(satiety > 80)
				nutrition_ratio *= 1.25
			adjust_nutrition(-nutrition_ratio * HUNGER_FACTOR)
			blood_volume = min(BLOOD_VOLUME_NORMAL, blood_volume + 0.5 * nutrition_ratio)

		//Effects of bloodloss
		var/word = pick("dizzy","woozy","faint")

		// How much oxyloss we want to be on
		var/desired_health = (getMaxHealth() * 2) * CLAMP01((blood_volume - BLOOD_VOLUME_SURVIVE) / (BLOOD_VOLUME_NORMAL - BLOOD_VOLUME_SURVIVE))
		// Make it so we only go unconcious at 25% blood remaining
		desired_health = max(0, (getMaxHealth() * 2) - ((desired_health ** 0.3) / ((getMaxHealth() * 2) ** (-0.7))))
		switch(blood_volume)
			if(BLOOD_VOLUME_OKAY to BLOOD_VOLUME_SAFE)
				if(prob(5))
					to_chat(src, "<span class='warning'>You feel [word].</span>")
			if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY)
				if(prob(5))
					blur_eyes(6)
					to_chat(src, "<span class='warning'>You feel very [word].</span>")
			if(BLOOD_VOLUME_SURVIVE to BLOOD_VOLUME_BAD)
				if(prob(30))
					blur_eyes(6)
					Unconscious(rand(5,10))
					to_chat(src, "<span class='warning'>You feel extremely [word].</span>")
			if(-INFINITY to BLOOD_VOLUME_SURVIVE)
				if(!HAS_TRAIT(src, TRAIT_NODEATH))
					death()
		var/health_difference = clamp(desired_health - getOxyLoss(), 0, 5)
		adjustOxyLoss(health_difference)

/mob/living/proc/bleed(amt)
	add_splatter_floor(src.loc, 1)

//Makes a blood drop, leaking amt units of blood from the mob
/mob/living/carbon/bleed(amt)
	if(blood_volume)
		blood_volume = max(blood_volume - amt, 0)
		if(isturf(src.loc)) //Blood loss still happens in locker, floor stays clean
			if(amt >= BLEED_DEEP_WOUND)
				add_splatter_floor(src.loc)
			else
				add_splatter_floor(src.loc, 1)

/mob/living/carbon/human/bleed(amt)
	amt *= physiology.bleed_mod
	if(!(NOBLOOD in dna.species.species_traits))
		..()

/mob/living/proc/restore_blood()
	blood_volume = initial(blood_volume)

/mob/living/carbon/human/restore_blood()
	blood_volume = BLOOD_VOLUME_NORMAL
	cauterise_wounds()

/****************************************************
				BLOOD TRANSFERS
****************************************************/

//Gets blood from mob to a container or other mob, preserving all data in it.
/mob/living/proc/transfer_blood_to(atom/movable/AM, amount, forced)
	if(!blood_volume || !AM.reagents)
		return 0
	if(blood_volume < BLOOD_VOLUME_BAD && !forced)
		return 0

	if(blood_volume < amount)
		amount = blood_volume

	var/blood_id = get_blood_id()
	if(!blood_id)
		return 0

	blood_volume -= amount

	var/list/blood_data = get_blood_data(blood_id)

	if(iscarbon(AM))
		var/mob/living/carbon/C = AM
		if(blood_id == C.get_blood_id())//both mobs have the same blood substance
			if(blood_id == /datum/reagent/blood) //normal blood
				if(blood_data["viruses"])
					for(var/thing in blood_data["viruses"])
						var/datum/disease/D = thing
						if((D.spread_flags & DISEASE_SPREAD_SPECIAL) || (D.spread_flags & DISEASE_SPREAD_NON_CONTAGIOUS)|| (D.spread_flags & DISEASE_SPREAD_FALTERED))
							continue
						C.ForceContractDisease(D)
				if(!(blood_data["blood_type"] in get_safe_blood(C.dna.blood_type)))
					C.reagents.add_reagent(/datum/reagent/toxin, amount * 0.5)
					return 1

			C.blood_volume = min(C.blood_volume + round(amount, 0.1), BLOOD_VOLUME_MAXIMUM)
			return 1

	AM.reagents.add_reagent(blood_id, amount, blood_data, bodytemperature)
	return 1


/mob/living/proc/get_blood_data(blood_id)
	return

/mob/living/carbon/get_blood_data(blood_id)
	if(blood_id == /datum/reagent/blood) //actual blood reagent
		var/blood_data = list()
		//set the blood data
		blood_data["viruses"] = list()

		for(var/thing in diseases)
			var/datum/disease/D = thing
			blood_data["viruses"] += D.Copy()

		blood_data["blood_DNA"] = dna.unique_enzymes
		if(disease_resistances?.len)
			blood_data["resistances"] = disease_resistances.Copy()
		var/list/temp_chem = list()
		for(var/datum/reagent/R in reagents.reagent_list)
			temp_chem[R.type] = R.volume
		blood_data["trace_chem"] = list2params(temp_chem)
		if(mind)
			blood_data["mind"] = mind
		else if(last_mind)
			blood_data["mind"] = last_mind
		if(ckey)
			blood_data["ckey"] = ckey
		else if(last_mind)
			blood_data["ckey"] = ckey(last_mind.key)

		if(!suiciding)
			blood_data["cloneable"] = 1
		blood_data["blood_type"] = dna.blood_type
		blood_data["gender"] = gender
		blood_data["real_name"] = real_name
		blood_data["features"] = dna.features
		blood_data["factions"] = faction
		return blood_data

//get the id of the substance this mob use as blood.
/mob/proc/get_blood_id()
	return

/mob/living/simple_animal/get_blood_id()
	if(blood_volume)
		return /datum/reagent/blood

/mob/living/carbon/monkey/get_blood_id()
	if(!(HAS_TRAIT(src, TRAIT_HUSK)))
		return /datum/reagent/blood

/mob/living/carbon/human/get_blood_id()
	if(HAS_TRAIT(src, TRAIT_HUSK))
		return
	if(dna.species.exotic_blood)
		return dna.species.exotic_blood
	else if((NOBLOOD in dna.species.species_traits))
		return
	return /datum/reagent/blood

// This is has more potential uses, and is probably faster than the old proc.
/proc/get_safe_blood(bloodtype)
	. = list()
	if(!bloodtype)
		return

	var/static/list/bloodtypes_safe = list(
		"A-" = list("A-", "O-"),
		"A+" = list("A-", "A+", "O-", "O+"),
		"B-" = list("B-", "O-"),
		"B+" = list("B-", "B+", "O-", "O+"),
		"AB-" = list("A-", "B-", "O-", "AB-"),
		"AB+" = list("A-", "A+", "B-", "B+", "O-", "O+", "AB-", "AB+"),
		"O-" = list("O-"),
		"O+" = list("O-", "O+"),
		"L" = list("L"),
		"U" = list("A-", "A+", "B-", "B+", "O-", "O+", "AB-", "AB+", "L", "U")
	)

	var/safe = bloodtypes_safe[bloodtype]
	if(safe)
		. = safe

//to add a splatter of blood or other mob liquid.
/mob/living/proc/add_splatter_floor(turf/T, small_drip)
	if(get_blood_id() != /datum/reagent/blood)
		return
	if(!T)
		T = get_turf(src)

	var/list/temp_blood_DNA
	if(small_drip)
		// Only a certain number of drips (or one large splatter) can be on a given turf.
		var/obj/effect/decal/cleanable/blood/drip/drop = locate() in T
		if(drop)
			if(drop.drips < 5)
				drop.drips++
				drop.add_overlay(pick(drop.random_icon_states))
				drop.transfer_mob_blood_dna(src)
				return
			else
				temp_blood_DNA = drop.return_blood_DNA() //we transfer the dna from the drip to the splatter
				qdel(drop)//the drip is replaced by a bigger splatter
		else
			drop = new(T, get_static_viruses())
			drop.transfer_mob_blood_dna(src)
			return

	// Find a blood decal or create a new one.
	var/obj/effect/decal/cleanable/blood/B = locate() in T
	if(!B)
		B = new /obj/effect/decal/cleanable/blood/splatter(T, get_static_viruses())
	if(QDELETED(B)) //Give it up
		return
	if (B.bloodiness < MAX_SHOE_BLOODINESS) //add more blood, up to a limit
		B.bloodiness += BLOOD_AMOUNT_PER_DECAL
	B.transfer_mob_blood_dna(src) //give blood info to the blood decal.
	if(temp_blood_DNA)
		B.add_blood_DNA(temp_blood_DNA)

/mob/living/carbon/human/add_splatter_floor(turf/T, small_drip)
	if(!(NOBLOOD in dna.species.species_traits))
		..()

/mob/living/carbon/alien/add_splatter_floor(turf/T, small_drip)
	if(!T)
		T = get_turf(src)
	var/obj/effect/decal/cleanable/xenoblood/B = locate() in T.contents
	if(!B)
		B = new(T)
	B.add_blood_DNA(list("UNKNOWN DNA" = "X*"))

/mob/living/silicon/robot/add_splatter_floor(turf/T, small_drip)
	if(!T)
		T = get_turf(src)
	var/obj/effect/decal/cleanable/oil/B = locate() in T.contents
	if(!B)
		B = new(T)

/**
 * Item to represent the fact that we are covering a wound
 */
/obj/item/offhand/bleeding_suppress
	name = "Applying pressure"
	desc = "You are applying pressure to your wounds."
	icon_state = "bleed_held"

/obj/item/offhand/bleeding_suppress/equipped(mob/living/carbon/user, slot)
	. = ..()
	if (istype(user))
		user.bleedsuppress = INFINITY

/obj/item/offhand/bleeding_suppress/dropped(mob/living/carbon/user, silent)
	if (istype(user))
		user.bleedsuppress = 0
	return ..()
