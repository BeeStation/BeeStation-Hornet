

//NOTE: Breathing happens once per FOUR TICKS, unless the last breath fails. In which case it happens once per ONE TICK! So oxyloss healing is done once per 4 ticks while oxyloss damage is applied once per tick!

/mob/living/carbon/human/Life()
	set invisibility = 0
	if (notransform)
		return

	. = ..()

	if (QDELETED(src))
		return 0

	if(!IsInStasis())
		if(stat != DEAD && undergoing_cardiac_arrest())
			//heart attack stuff
			var/we_breath = !HAS_TRAIT_FROM(src, TRAIT_NOBREATH, SPECIES_TRAIT)

			if(we_breath)
				adjustOxyLoss(8)
				Unconscious(80)
			// Tissues die without blood circulation
			adjustBruteLoss(2)

		dna.species.spec_life(src) // for mutantraces

	//Update our name based on whether our face is obscured/disfigured
	name = get_visible_name()

	if(stat != DEAD)
		return 1


/mob/living/carbon/human/calculate_affecting_pressure(pressure)
	var/chest_covered = FALSE
	var/head_covered = FALSE
	for(var/obj/item/clothing/equipped in get_equipped_items())
		if((equipped.body_parts_covered & CHEST) && (equipped.clothing_flags & STOPSPRESSUREDAMAGE))
			chest_covered = TRUE
		if((equipped.body_parts_covered & HEAD) && (equipped.clothing_flags & STOPSPRESSUREDAMAGE))
			head_covered = TRUE

	if(chest_covered && head_covered)
		return ONE_ATMOSPHERE
	return pressure


/mob/living/carbon/human/handle_traits(delta_time)
	if (getOrganLoss(ORGAN_SLOT_BRAIN) >= 60)
		SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "brain_damage", /datum/mood_event/brain_damage)
	else
		SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "brain_damage")

	if(eye_blind)			//blindness, heals slowly over time
		if(HAS_TRAIT_FROM(src, TRAIT_BLIND, EYES_COVERED)) //covering your eyes heals blurry eyes faster
			adjust_blindness(-3 * delta_time)
		else
			adjust_blindness(-delta_time)
		//If you have blindness from a trait, heal blurryness too, otherwise return and ignore that.
		if(!(HAS_TRAIT(src, TRAIT_BLIND)))
			return
	if(eye_blurry)			//blurry eyes heal slowly
		adjust_blurriness(-delta_time)

/mob/living/carbon/human/handle_mutations_and_radiation()
	if(!dna || !dna.species.handle_mutations_and_radiation(src))
		..()

/mob/living/carbon/human/breathe()
	if(!dna.species.breathe(src))
		..()

/mob/living/carbon/human/check_breath(datum/gas_mixture/breath)

	var/L = getorganslot(ORGAN_SLOT_LUNGS)

	if(!L)
		if(health >= crit_threshold)
			adjustOxyLoss(HUMAN_MAX_OXYLOSS + 1)
		else if(!HAS_TRAIT(src, TRAIT_NOCRITDAMAGE))
			adjustOxyLoss(HUMAN_CRIT_MAX_OXYLOSS)

		failed_last_breath = 1

		var/datum/species/S = dna.species

		if(S.breathid == "o2")
			throw_alert("not_enough_oxy", /atom/movable/screen/alert/not_enough_oxy)
		else if(S.breathid == "tox")
			throw_alert("not_enough_tox", /atom/movable/screen/alert/not_enough_tox)
		else if(S.breathid == "co2")
			throw_alert("not_enough_co2", /atom/movable/screen/alert/not_enough_co2)
		else if(S.breathid == "n2")
			throw_alert("not_enough_nitro", /atom/movable/screen/alert/not_enough_nitro)

		return FALSE
	else
		if(istype(L, /obj/item/organ/lungs))
			var/obj/item/organ/lungs/lun = L
			lun.check_breath(breath,src)

/mob/living/carbon/human/handle_environment(datum/gas_mixture/environment)
	dna.species.handle_environment(environment, src)

///FIRE CODE
/mob/living/carbon/human/handle_fire()
	. = ..()
	if(.) //if the mob isn't on fire anymore
		return

	if(dna)
		. = dna.species.handle_fire(src) //do special handling based on the mob's species. TRUE = they are immune to the effects of the fire.

	if(!last_fire_update)
		last_fire_update = fire_stacks
	if((fire_stacks > HUMAN_FIRE_STACK_ICON_NUM && last_fire_update <= HUMAN_FIRE_STACK_ICON_NUM) || (fire_stacks <= HUMAN_FIRE_STACK_ICON_NUM && last_fire_update > HUMAN_FIRE_STACK_ICON_NUM))
		last_fire_update = fire_stacks
		update_fire()


/mob/living/carbon/human/proc/get_thermal_protection()
	if(istype(dna.species))
		return dna.species.get_thermal_protection(src)
	var/thermal_protection = 0 //Simple check to estimate how protected we are against multiple temperatures
	if(wear_suit)
		if(wear_suit.max_heat_protection_temperature >= FIRE_SUIT_MAX_TEMP_PROTECT)
			thermal_protection += (wear_suit.max_heat_protection_temperature*THERMAL_PROTECTION_SUIT)
	if(head)
		if(head.max_heat_protection_temperature >= FIRE_HELM_MAX_TEMP_PROTECT)
			thermal_protection += (head.max_heat_protection_temperature*THERMAL_PROTECTION_HEAD)
	thermal_protection = round(thermal_protection)
	return thermal_protection

/mob/living/carbon/human/IgniteMob()
	//If have no DNA or can be Ignited, call parent handling to light user
	//If firestacks are high enough
	if(!dna || dna.species.CanIgniteMob(src))
		return ..()
	. = FALSE //No ignition

/mob/living/carbon/human/ExtinguishMob()
	if(!dna || !dna.species.ExtinguishMob(src))
		last_fire_update = null
		..()
//END FIRE CODE

/mob/living/carbon/human/handle_random_events()
	//Puke if toxloss is too high
	if(!stat)
		if(getToxLoss() >= 45 && nutrition > 20)
			lastpuke += prob(50)
			if(lastpuke >= 50) // about 25 second delay I guess
				vomit(20, toxic = TRUE)
				lastpuke = 0


/mob/living/carbon/human/has_smoke_protection()
	if(wear_mask)
		if(wear_mask.clothing_flags & BLOCK_GAS_SMOKE_EFFECT)
			return TRUE
	if(glasses)
		if(glasses.clothing_flags & BLOCK_GAS_SMOKE_EFFECT)
			return TRUE
	if(head && isclothing(head))
		var/obj/item/clothing/CH = head
		if(CH.clothing_flags & BLOCK_GAS_SMOKE_EFFECT)
			return TRUE
	return ..()
