#define BLOOD_DRIP_RATE_MOD 90 //Greater number means creating blood drips more often while bleeding

/****************************************************
				BLOOD SYSTEM

https://www.desmos.com/calculator/vxrevmdvfx

To calculate the blood loss rate, use the following formula:
n = starting amount of blood in your mob
b = bleed rate of your mob
h = Rate at which bleeding decreases over time (0.02 constant, 0.08 for non-human mobs)

This function calculates the amount of blood left in your system at time x
q\left(x\right)=\left\{b<2.4:ne^{-\frac{1}{560}\left(bx-\frac{1}{2}x^{2}h\right)},ne^{-\frac{bx}{560}}\right\}

Hide this function
d\left(x\right)=\max\left(0,120-\frac{\left(120\cdot\max\left(0,\min\left(1,\frac{x-122}{560-122}\right)\right)\right)^{0.3}}{\left(120\right)^{-0.7}}\right)

This function calculates the amount of health that your mob has at time x
y=d\left(q\left(x\right)\right)

**Notes for porting/search:**
bleedsuppress has been replaced for is_bandaged(). Note that is_bleeding() returns if you are not bleeding, even if you have active bandages.

****************************************************/

/datum/status_effect/bleeding
	id = "bleeding"
	status_type = STATUS_EFFECT_MERGE
	alert_type = /atom/movable/screen/alert/status_effect/bleeding
	tick_interval = 1 SECONDS

	var/bandaged_bleeding = 0
	var/bleed_rate = 0
	var/time_applied = 0
	var/bleed_heal_multiplier = 1

/datum/status_effect/bleeding/merge(bleed_level)
	src.bleed_rate = src.bleed_rate + max(min(bleed_level * bleed_level, sqrt(bleed_level)) / max(src.bleed_rate, 1), bleed_level - src.bleed_rate)

/datum/status_effect/bleeding/on_creation(mob/living/new_owner, bleed_rate)
	src.bleed_rate = bleed_rate
	return ..()

/datum/status_effect/bleeding/tick()
	if (HAS_TRAIT(owner, TRAIT_NO_BLOOD))
		qdel(src)
		return
	time_applied += tick_interval
	if (time_applied < 1 SECONDS)
		if(bleed_rate >= BLEED_DEEP_WOUND)
			owner.add_splatter_floor(owner.loc)
		else
			owner.add_splatter_floor(owner.loc, TRUE)
		return
	time_applied = 0
	// Non-humans stop bleeding a lot quicker, even if it is not a minor cut
	if (!ishuman(owner))
		bleed_rate -= BLEED_HEAL_RATE_MINOR * 4 * bleed_heal_multiplier
	// Set the rate at which we process, so we bleed more on the ground when heavy bleeding
	tick_interval = bleed_rate <= BLEED_RATE_MINOR ? 1 SECONDS : 0.2 SECONDS
	// Reduce the actual rate of bleeding
	if (ishuman(owner))
		if (bleed_rate > 0 && bleed_rate < BLEED_RATE_MINOR)
			bleed_rate -= BLEED_HEAL_RATE_MINOR * bleed_heal_multiplier
		else
			bandaged_bleeding -= BLEED_HEAL_RATE_MINOR * bleed_heal_multiplier
	// We have finished bleeding
	if (bleed_rate <= 0 && bandaged_bleeding <= 0)
		qdel(src)
		return
	// The actual rate of bleeding, can be reduced by holding wounds
	var/final_bleed_rate = bleed_rate
	if (HAS_TRAIT(owner, TRAIT_BLEED_HELD))
		final_bleed_rate = max(0, final_bleed_rate - BLEED_RATE_MINOR)
	// We aren't actually bleeding
	if (final_bleed_rate <= 0)
		return
	// Actually do the bleeding
	owner.bleed(min(MAX_BLEED_RATE, final_bleed_rate))

/datum/status_effect/bleeding/update_icon()
	// The actual rate of bleeding, can be reduced by holding wounds
	// Calculate the message to show to the user
	if (HAS_TRAIT(owner, TRAIT_BLEED_HELD))
		linked_alert.name = "Bleeding (Held)"
		if (bleed_rate > BLEED_RATE_MINOR)
			linked_alert.desc = "You have serious wounds which are unlikely to heal themselves. You are applying pressure to them, slowing the rate of blood loss."
		else
			linked_alert.desc = "You are bleeding and are applying pressure to the wounds, preventing blood from pouring out."
		linked_alert.icon_state = "bleed_held"
	else if (bleed_rate == 0 && bandaged_bleeding > 0)
		linked_alert.name = "Bleeding (Bandaged)"
		linked_alert.desc = "You have bandages covering your wounds. They will heal slowly if they are not cauterized."
		linked_alert.icon_state = "bleed_bandage"
	else
		if (bleed_rate < BLEED_RATE_MINOR)
			linked_alert.name = "Bleeding (Light)"
			linked_alert.desc = "You have some minor cuts that look like they will heal themselves if you don't run out of blood first.[ishuman(owner) ? " Click to apply pressure to the wounds." : ""]"
			linked_alert.icon_state = "bleed"
		else
			linked_alert.name = "Bleeding (Heavy)"
			linked_alert.desc = "Your wounds are bleeding heavily and are unlikely to heal themselves. Seek medical attention immediately![ishuman(owner) ? " Click to apply pressure to the wounds." : ""]"
			linked_alert.icon_state = "bleed_heavy"

	if (HAS_TRAIT(owner, TRAIT_NO_BLEEDING) || IS_IN_STASIS(owner))
		linked_alert.maptext = MAPTEXT("<s>[owner.get_bleed_rate_string()]</s>")
	else
		linked_alert.maptext = MAPTEXT(owner.get_bleed_rate_string())

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

/mob/living/carbon/proc/is_bandaged()
	if (HAS_TRAIT(src, TRAIT_NO_BLOOD))
		return FALSE
	var/datum/status_effect/bleeding/bleed = has_status_effect(/datum/status_effect/bleeding)
	if (!bleed)
		return FALSE
	return bleed.bandaged_bleeding > 0

/mob/living/carbon/proc/is_bleeding()
	if (HAS_TRAIT(src, TRAIT_NO_BLOOD))
		return FALSE
	var/datum/status_effect/bleeding/bleed = has_status_effect(/datum/status_effect/bleeding)
	if (!bleed)
		return FALSE
	return bleed.bleed_rate > 0

/mob/living/carbon/proc/add_bleeding(bleed_level)
	if (HAS_TRAIT(src, TRAIT_NO_BLOOD))
		return
	playsound(src, 'sound/surgery/blood_wound.ogg', 80, vary = TRUE)
	apply_status_effect(dna?.species?.bleed_effect || /datum/status_effect/bleeding, bleed_level)
	if (bleed_level >= BLEED_DEEP_WOUND)
		blur_eyes(1)
		to_chat(src, "[span_userdanger("Blood starts rushing out of the open wound!")]")
	if(bleed_level >= BLEED_CUT)
		add_splatter_floor(src.loc)
	else
		add_splatter_floor(src.loc, 1)

/mob/living/carbon/human/add_bleeding(bleed_level)
	if(HAS_TRAIT(src, TRAIT_NOBLOOD))
		return
	..()

/mob/living/carbon/proc/get_bleed_intensity()
	var/datum/status_effect/bleeding/bleed = has_status_effect(/datum/status_effect/bleeding)
	if (!bleed)
		return 0
	return 3 ** bleed.bleed_rate

/mob/living/carbon/proc/get_bleed_rate()
	var/datum/status_effect/bleeding/bleed = has_status_effect(/datum/status_effect/bleeding)
	return bleed?.bleed_rate

/// Can we heal bleeding using a welding tool?
/mob/living/carbon/proc/has_mechanical_bleeding()
	var/obj/item/bodypart/chest = get_bodypart(BODY_ZONE_CHEST)
	return chest.bodytype & BODYTYPE_ROBOTIC

/mob/living/proc/get_bleed_rate_string()
	return "0.0/s"

/mob/living/carbon/get_bleed_rate_string()
	var/datum/status_effect/bleeding/bleed = has_status_effect(/datum/status_effect/bleeding)
	if (!bleed)
		return "0.0/s"
	var/final_bleed_rate = bleed.bleed_rate
	if (HAS_TRAIT(src, TRAIT_BLEED_HELD))
		final_bleed_rate = max(0, final_bleed_rate - BLEED_RATE_MINOR)

	// Set the text to the final bleed rate
	final_bleed_rate = round(final_bleed_rate, 0.1)
	if ((final_bleed_rate * 10) % 10 == 0)
		return "[final_bleed_rate].0/s"
	return "[final_bleed_rate]/s"

/mob/living/carbon/proc/cauterise_wounds(amount = INFINITY)
	var/datum/status_effect/bleeding/bleed = has_status_effect(/datum/status_effect/bleeding)
	if (!bleed)
		return FALSE
	bleed.bleed_rate -= amount
	if (bleed.bleed_rate <= 0)
		remove_status_effect(/datum/status_effect/bleeding)
	return TRUE

/mob/living/carbon/proc/hold_wounds()
	if (stat >= UNCONSCIOUS)
		return
	if (!is_bleeding())
		if (is_bandaged())
			balloon_alert(src, "Wounds already bandaged!")
		else
			balloon_alert(src, "You are not wounded!")
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
	var/datum/status_effect/bleeding/bleed = has_status_effect(/datum/status_effect/bleeding)
	if (!bleed)
		return
	bleed.update_icon()

/mob/living/carbon/proc/stop_holding_wounds()
	var/located = FALSE
	for (var/obj/item/offhand/bleeding_suppress/bleed_suppression in held_items)
		qdel(bleed_suppression)
		located = TRUE
	if (located)
		balloon_alert(src, "You stop applying pressure to your wounds...")
	var/datum/status_effect/bleeding/bleed = has_status_effect(/datum/status_effect/bleeding)
	if (!bleed)
		return
	bleed.update_icon()

/mob/living/carbon/proc/suppress_bloodloss(amount)
	var/datum/status_effect/bleeding/bleed = has_status_effect(/datum/status_effect/bleeding)
	if (!bleed)
		return
	var/reduced_amount = min(bleed.bleed_rate, amount)
	bleed.bleed_rate -= reduced_amount
	bleed.bandaged_bleeding += reduced_amount
	bleed.update_icon()
	if (bleed.bleed_rate <= 0)
		stop_holding_wounds()

/mob/living/carbon/monkey/handle_blood()
	if(bodytemperature >= TCRYO && !(HAS_TRAIT(src, TRAIT_HUSK))) //cryosleep or husked people do not pump the blood.
		//Blood regeneration if there is some space
		if(blood_volume < BLOOD_VOLUME_NORMAL)
			blood_volume += 0.1 // regenerate blood VERY slowly
			if(blood_volume < BLOOD_VOLUME_OKAY)
				adjustOxyLoss(round((BLOOD_VOLUME_NORMAL - blood_volume) * 0.02, 1))

// Takes care blood loss and regeneration
/mob/living/carbon/human/handle_blood(delta_time, times_fired)

	if(HAS_TRAIT(src, TRAIT_NOBLOOD) || HAS_TRAIT(src, TRAIT_NOBLOOD))
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
			adjust_nutrition(-nutrition_ratio * HUNGER_FACTOR * delta_time)
			blood_volume = min(blood_volume + (BLOOD_REGEN_FACTOR * nutrition_ratio * delta_time), BLOOD_VOLUME_NORMAL)

		//Effects of bloodloss
		var/word = pick("dizzy","woozy","faint")

		// How much oxyloss we want to be on
		var/desired_damage = (getMaxHealth() * 1.2) * CLAMP01((blood_volume - BLOOD_VOLUME_SURVIVE) / (BLOOD_VOLUME_NORMAL - BLOOD_VOLUME_SURVIVE))
		// Make it so we only go unconcious at 25% blood remaining
		desired_damage = max(0, (getMaxHealth() * 1.2) - ((desired_damage ** 0.3) / ((getMaxHealth() * 1.2) ** (-0.7))))
		if (desired_damage >= getMaxHealth() * 1.2)
			desired_damage = getMaxHealth() * 2.0
		if (HAS_TRAIT(src, TRAIT_BLOOD_COOLANT))
			switch(blood_volume)
				if(BLOOD_VOLUME_SURVIVE to BLOOD_VOLUME_SAFE)
					if(prob(3))
						to_chat(src, span_warning("Your sensors indicate [pick("overheating", "thermal throttling", "coolant issues")]."))
				if(-INFINITY to BLOOD_VOLUME_SURVIVE)
					desired_damage = getMaxHealth() * 2.0
					// Rapidly die with no saving you
					adjustFireLoss(clamp(getMaxHealth() * 2.0 - getFireLoss(), 0, 10))
			var/health_difference = clamp(desired_damage - getFireLoss(), 0, 5)
			adjustFireLoss(health_difference)
			return
		switch(blood_volume)
			if(BLOOD_VOLUME_OKAY to BLOOD_VOLUME_SAFE)
				if(DT_PROB(2.5, delta_time))
					to_chat(src, span_warning("You feel [word]."))
				//adjustOxyLoss(round(0.005 * (BLOOD_VOLUME_NORMAL - blood_volume) * delta_time, 1))
			if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY)
				//adjustOxyLoss(round(0.01 * (BLOOD_VOLUME_NORMAL - blood_volume) * delta_time, 1))
				if(DT_PROB(2.5, delta_time))
					blur_eyes(6)
					to_chat(src, span_warning("You feel very [word]."))
			if(BLOOD_VOLUME_SURVIVE to BLOOD_VOLUME_BAD)
				//adjustOxyLoss(2.5 * delta_time)
				if(DT_PROB(15, delta_time))
					blur_eyes(6)
					Unconscious(rand(3,6))
					to_chat(src, span_warning("You feel extremely [word]."))
			if(-INFINITY to BLOOD_VOLUME_SURVIVE)
				desired_damage = getMaxHealth() * 2.0
				// Rapidly die with no saving you
				adjustOxyLoss(clamp(getMaxHealth() * 2.0 - getOxyLoss(), 0, 10))
		var/health_difference = clamp(desired_damage - getOxyLoss(), 0, 5)
		adjustOxyLoss(health_difference)

/mob/living/proc/bleed(amt)
	add_splatter_floor(src.loc, 1)

//Makes a blood drop, leaking amt units of blood from the mob
/mob/living/carbon/bleed(amt)
	if(blood_volume && !HAS_TRAIT(src, TRAIT_NO_BLOOD) && !HAS_TRAIT(src, TRAIT_NO_BLEEDING) && !IS_IN_STASIS(src))
		// As you get less bloodloss, you bleed slower
		// See the top of this file for desmos lines
		var/decrease_multiplier = BLEED_RATE_MULTIPLIER
		var/obj/item/organ/heart/heart = get_organ_slot(ORGAN_SLOT_HEART)
		if (!heart || !heart.beating)
			decrease_multiplier = BLEED_RATE_MULTIPLIER_NO_HEART
		var/blood_loss_amount = blood_volume - blood_volume * NUM_E ** (-(amt * decrease_multiplier)/BLOOD_VOLUME_NORMAL)
		blood_volume = max(blood_volume - blood_loss_amount, 0)
		if(isturf(src.loc) && prob(sqrt(blood_loss_amount)*BLOOD_DRIP_RATE_MOD)) //Blood loss still happens in locker, floor stays clean
			if(blood_loss_amount >= 2)
				add_splatter_floor(src.loc)
			else
				add_splatter_floor(src.loc, 1)

/mob/living/carbon/human/bleed(amt)
	amt *= physiology.bleed_mod
	if(!HAS_TRAIT(src, TRAIT_NOBLOOD))
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
						if((D.spread_flags & DISEASE_SPREAD_SPECIAL) || (D.spread_flags & DISEASE_SPREAD_NON_CONTAGIOUS))
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
	else if(HAS_TRAIT(src, TRAIT_NOBLOOD))
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
	if (HAS_TRAIT(src, TRAIT_NO_BLOOD) || HAS_TRAIT(src, TRAIT_NO_BLEEDING) || IS_IN_STASIS(src))
		return
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
	B.bloodiness = min((B.bloodiness + BLOOD_AMOUNT_PER_DECAL), BLOOD_POOL_MAX)
	B.transfer_mob_blood_dna(src) //give blood info to the blood decal.
	if(temp_blood_DNA)
		B.add_blood_DNA(temp_blood_DNA)

/mob/living/carbon/human/add_splatter_floor(turf/T, small_drip)
	if(!HAS_TRAIT(src, TRAIT_NOBLOOD))
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
		ADD_TRAIT(user, TRAIT_BLEED_HELD, ACTION_TRAIT)

/obj/item/offhand/bleeding_suppress/dropped(mob/living/carbon/user, silent)
	if (istype(user))
		REMOVE_TRAIT(user, TRAIT_BLEED_HELD, ACTION_TRAIT)
	return ..()

#undef BLOOD_DRIP_RATE_MOD
