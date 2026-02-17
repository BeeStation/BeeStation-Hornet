/mob/living/carbon/Life(delta_time = SSMOBS_DT, times_fired)
	set invisibility = 0

	if(notransform)
		return

	if(damageoverlaytemp)
		damageoverlaytemp = 0
		update_damage_hud()

	if(IS_IN_STASIS(src))
		. = ..()
	else
		//Reagent processing needs to come before breathing, to prevent edge cases.
		//handle_dead_metabolization(delta_time, times_fired) //Dead metabolization first since it can modify life metabolization.
		handle_organs(delta_time, times_fired)

		. = ..()
		if(QDELETED(src))
			return

		if(.) //not dead
			handle_blood(delta_time, times_fired)

		if(stat != DEAD) //Handle brain damage
			for(var/T in get_traumas())
				var/datum/brain_trauma/BT = T
				BT.on_life(delta_time, times_fired)

		if(stat != DEAD && has_dna())
			for(var/datum/mutation/HM as() in dna.mutations)
				HM.on_life(delta_time, times_fired)

	if(stat == DEAD)
		stop_sound_channel(CHANNEL_HEARTBEAT)
	else
		var/bprv = handle_bodyparts()
		if(bprv & BODYPART_LIFE_UPDATE_HEALTH)
			update_stamina() //needs to go before updatehealth to remove stamcrit
			updatehealth()

	if(. && mind) //. == not dead
		for(var/key in mind.addiction_points)
			var/datum/addiction/addiction = SSaddiction.all_addictions[key]
			addiction.process_addiction(src, delta_time, times_fired)
	if(stat != DEAD)
		return TRUE

///////////////
// BREATHING //
///////////////

//Start of a breath chain, calls breathe()
/mob/living/carbon/handle_breathing(delta_time, times_fired)
	var/next_breath = 4
	var/obj/item/organ/lungs/L = get_organ_slot(ORGAN_SLOT_LUNGS)
	var/obj/item/organ/heart/H = get_organ_slot(ORGAN_SLOT_HEART)
	if(L)
		if(L.damage > L.high_threshold)
			next_breath--
	if(H)
		if(H.damage > H.high_threshold)
			next_breath--

	if((times_fired % next_breath) == 0 || failed_last_breath)
		breathe(delta_time, times_fired) //Breathe per 4 ticks if healthy, down to 2 if our lungs or heart are damaged, unless suffocating
		if(failed_last_breath)
			SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "suffocation", /datum/mood_event/suffocation)
		else
			SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "suffocation")
	else
		if(istype(loc, /obj/))
			var/obj/location_as_object = loc
			location_as_object.handle_internal_lifeform(src,0)

//Second link in a breath chain, calls check_breath()
/mob/living/carbon/proc/breathe(delta_time, times_fired)
	var/obj/item/organ/lungs = get_organ_slot(ORGAN_SLOT_LUNGS)
	if(reagents.has_reagent(/datum/reagent/toxin/lexorin, needs_metabolizing = TRUE))
		return

	var/datum/gas_mixture/environment
	if(loc)
		environment = loc.return_air()

	var/datum/gas_mixture/breath

	if(!get_organ_slot(ORGAN_SLOT_BREATHING_TUBE))
		if(health <= HEALTH_THRESHOLD_FULLCRIT || (pulledby && pulledby.grab_state >= GRAB_KILL) || HAS_TRAIT(src, TRAIT_MAGIC_CHOKE) || !lungs || lungs.organ_flags & ORGAN_FAILING)
			losebreath++  //You can't breath at all when in critical or when being choked, so you're going to miss a breath

		else if(health <= crit_threshold)
			losebreath += 0.25 //You're having trouble breathing in soft crit, so you'll miss a breath one in four times

	//Suffocate
	if(losebreath >= 1) //You've missed a breath, take oxy damage
		losebreath--
		if(prob(10))
			emote("gasp")
		if(istype(loc, /obj/))
			var/obj/loc_as_obj = loc
			loc_as_obj.handle_internal_lifeform(src,0)
	else
		//Breathe from internal
		breath = get_breath_from_internal(BREATH_VOLUME)

		if(isnull(breath)) //in case of 0 pressure internals

			if(isobj(loc)) //Breathe from loc as object
				var/obj/loc_as_obj = loc
				breath = loc_as_obj.handle_internal_lifeform(src, BREATH_VOLUME)

			else if(isturf(loc)) //Breathe from loc as turf
				var/breath_moles = 0
				if(environment)
					breath_moles = environment.total_moles()*BREATH_PERCENTAGE

				breath = loc.remove_air(breath_moles)
		else //Breathe from loc as obj again
			if(isobj(loc))
				var/obj/loc_as_obj = loc
				loc_as_obj.handle_internal_lifeform(src,0)

	if(breath)
		breath.volume = BREATH_VOLUME
	check_breath(breath)

	if(breath)
		loc.assume_air(breath)

/mob/living/carbon/proc/has_smoke_protection()
	if(HAS_TRAIT(src, TRAIT_NOBREATH))
		return TRUE
	return FALSE


//Third link in a breath chain, calls handle_breath_temperature()
/mob/living/carbon/proc/check_breath(datum/gas_mixture/breath)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		failed_last_breath = FALSE
		clear_alert(ALERT_NOT_ENOUGH_OXYGEN)
		return
	if(HAS_TRAIT(src, TRAIT_NOBREATH))
		return

	var/obj/item/organ/lungs = get_organ_slot(ORGAN_SLOT_LUNGS)
	if(!lungs)
		adjustOxyLoss(2)

	//CRIT
	if(!breath || (breath.total_moles() == 0) || !lungs)
		if(reagents.has_reagent(/datum/reagent/medicine/epinephrine, needs_metabolizing = TRUE) && lungs)
			return
		adjustOxyLoss(1)

		failed_last_breath = 1
		throw_alert("not_enough_oxy", /atom/movable/screen/alert/not_enough_oxy)
		return 0

	var/safe_oxy_min = 16
	var/safe_co2_max = 10
	var/safe_tox_max = 0.05
	var/SA_para_min = 1
	var/SA_sleep_min = 5
	var/oxygen_used = 0
	var/moles = breath.total_moles()
	var/breath_pressure = (moles*R_IDEAL_GAS_EQUATION*breath.return_temperature())/BREATH_VOLUME
	var/O2_partialpressure = ((GET_MOLES(/datum/gas/oxygen, breath)/moles)*breath_pressure) + (((GET_MOLES(/datum/gas/pluoxium, breath)*8)/moles)*breath_pressure)
	var/Toxins_partialpressure = (GET_MOLES(/datum/gas/plasma, breath)/moles)*breath_pressure
	var/CO2_partialpressure = (GET_MOLES(/datum/gas/carbon_dioxide, breath)/moles)*breath_pressure


	//OXYGEN
	if(O2_partialpressure < safe_oxy_min) //Not enough oxygen
		if(prob(20))
			emote("gasp")
		if(O2_partialpressure > 0)
			var/ratio = 1 - O2_partialpressure/safe_oxy_min
			adjustOxyLoss(min(5*ratio, 3))
			failed_last_breath = 1
			oxygen_used = GET_MOLES(/datum/gas/oxygen, breath)*ratio
		else
			adjustOxyLoss(3)
			failed_last_breath = 1
		throw_alert("not_enough_oxy", /atom/movable/screen/alert/not_enough_oxy)

	else //Enough oxygen
		failed_last_breath = 0
		if(health >= crit_threshold)
			adjustOxyLoss(-5)
		oxygen_used = GET_MOLES(/datum/gas/oxygen, breath)
		clear_alert("not_enough_oxy")

	ADD_MOLES(/datum/gas/carbon_dioxide, breath, oxygen_used)
	REMOVE_MOLES(/datum/gas/oxygen, breath, oxygen_used)

	//CARBON DIOXIDE
	if(CO2_partialpressure > safe_co2_max)
		if(!co2overloadtime)
			co2overloadtime = world.time
		else if(world.time - co2overloadtime > 120)
			Unconscious(60)
			adjustOxyLoss(3)
			if(world.time - co2overloadtime > 300)
				adjustOxyLoss(8)
		if(prob(20))
			emote("cough")

	else
		co2overloadtime = 0

	//TOXINS/PLASMA
	if(Toxins_partialpressure > safe_tox_max)
		var/ratio = (GET_MOLES(/datum/gas/plasma, breath)/safe_tox_max) * 10
		adjustToxLoss(clamp(ratio, MIN_TOXIC_GAS_DAMAGE, MAX_TOXIC_GAS_DAMAGE))
		throw_alert("too_much_tox", /atom/movable/screen/alert/too_much_plas)
	else
		clear_alert("too_much_tox")

	//NITROUS OXIDE
	if(GET_MOLES(/datum/gas/nitrous_oxide, breath))
		var/SA_partialpressure = (GET_MOLES(/datum/gas/nitrous_oxide, breath)/breath.total_moles())*breath_pressure
		if(SA_partialpressure > SA_para_min)
			Unconscious(60)
			if(SA_partialpressure > SA_sleep_min)
				Sleeping(max(AmountSleeping() + 40, 200))
		else if(SA_partialpressure > 0.01)
			if(prob(20))
				emote(pick("giggle","laugh"))
			SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "chemical_euphoria", /datum/mood_event/chemical_euphoria)
	else
		SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "chemical_euphoria")

	//BZ (Facepunch port of their Agent B)
	if(GET_MOLES(/datum/gas/bz, breath))
		var/bz_partialpressure = (GET_MOLES(/datum/gas/bz, breath)/breath.total_moles())*breath_pressure
		if(bz_partialpressure > 1)
			adjust_hallucinations(20)
		else if(bz_partialpressure > 0.01)
			adjust_hallucinations(10 SECONDS)

	//NITRIUM
	if(GET_MOLES(/datum/gas/nitrium, breath))
		var/nitrium_partialpressure = (GET_MOLES(/datum/gas/nitrium, breath)/breath.total_moles())*breath_pressure
		if(nitrium_partialpressure > 0.5)
			adjustFireLoss(nitrium_partialpressure * 0.15)
		if(nitrium_partialpressure > 5)
			adjustToxLoss(nitrium_partialpressure * 0.05)

	//BREATH TEMPERATURE
	handle_breath_temperature(breath)

	breath.garbage_collect()

	return TRUE

//Fourth and final link in a breath chain
/mob/living/carbon/proc/handle_breath_temperature(datum/gas_mixture/breath)
	// The air you breathe out should match your body temperature
	breath.temperature = bodytemperature

/// Attempts to take a breath from the external or internal air tank.
/mob/living/carbon/proc/get_breath_from_internal(volume_needed)
	if(invalid_internals())
		// Unexpectely lost breathing apparatus and ability to breathe from the internal air tank.
		cutoff_internals()
		return
	if(external)
		. = external.remove_air_volume(volume_needed)
	else if(internal)
		. = internal.remove_air_volume(volume_needed)
	else
		// Return without taking a breath if there is no air tank.
		return
	// To differentiate between no internals and active, but empty internals.
	return . || FALSE

/mob/living/carbon/proc/handle_blood(delta_time, times_fired)
	return

/mob/living/carbon/proc/handle_bodyparts(delta_time, times_fired)
	var/stam_regen = FALSE
	if(stam_regen_start_time <= world.time)
		stam_regen = TRUE
		if(HAS_TRAIT_FROM(src, TRAIT_INCAPACITATED, STAMINA))
			. |= BODYPART_LIFE_UPDATE_HEALTH //make sure we remove the stamcrit
	var/bodyparts_with_stam = 0
	var/stam_heal_multiplier = 1
	var/total_stamina_loss = 0	//Quicker to put it here too than do it again with getStaminaLoss
	var/force_heal = 0
	//Find how many bodyparts we have with stamina damage
	if(stam_regen)
		for(var/obj/item/bodypart/BP as() in bodyparts)
			if(BP.stamina_dam >= DAMAGE_PRECISION)
				bodyparts_with_stam++
				total_stamina_loss += BP.stamina_dam * BP.stam_damage_coeff
		//Force bodyparts to heal if we have more than 120 stamina damage (6 seconds)
		force_heal = max(0, total_stamina_loss - 120) / max(bodyparts_with_stam, 1)
	//Increase damage the more stam damage
	//Incraesed stamina healing when above 50 stamloss, up to 2x healing rate when at 100 stamloss.
	stam_heal_multiplier = clamp(total_stamina_loss / 50, 1, 2)
	//Heal bodypart stamina damage
	for(var/obj/item/bodypart/BP as() in bodyparts)
		if(BP.needs_processing)
			. |= BP.on_life(delta_time, times_fired, stam_regen = (force_heal + ((stam_regen * stam_heal * stam_heal_multiplier) / max(bodyparts_with_stam, 1))))

/mob/living/carbon/proc/handle_organs(delta_time, times_fired)
	if(stat == DEAD)
		if(reagents.has_reagent(/datum/reagent/toxin/formaldehyde, 1)) // No organ decay if the body contains formaldehyde.
			return
		for(var/obj/item/organ/organ in internal_organs)
			// On-death is where organ decay is handled
			if(organ?.owner) // organ + owner can be null due to reagent metabolization causing organ shuffling
				organ.on_death(delta_time, times_fired)
			// We need to re-check the stat every organ, as one of our others may have revived us
			if(stat != DEAD)
				break
		return

	// NOTE: organs_slot is sorted by GLOB.organ_process_order on insertion
	for(var/slot in internal_organs_slot)
		// We don't use get_organ_slot here because we know we have the organ we want, since we're iterating the list containing em already
		// This code is hot enough that it's just not worth the time
		var/obj/item/organ/organ = internal_organs_slot[slot]
		if(organ?.owner) // This exist mostly because reagent metabolization can cause organ reshuffling
			organ.on_life(delta_time, times_fired)

/mob/living/carbon/handle_diseases(delta_time, times_fired)
	for(var/thing in diseases)
		var/datum/disease/D = thing
		if(DT_PROB(D.infectivity, delta_time))
			D.spread()

		if(stat != DEAD || D.process_dead)
			D.stage_act(delta_time, times_fired)

/mob/living/carbon/handle_mutations(delta_time, times_fired)
	if(!length(dna?.temporary_mutations))
		return

	for(var/mut in dna.temporary_mutations)
		if(dna.temporary_mutations[mut] < world.time)
			if(mut == UI_CHANGED)
				if(dna.previous["UI"])
					dna.unique_identity = merge_text(dna.unique_identity,dna.previous["UI"])
					updateappearance(mutations_overlay_update=1)
					dna.previous.Remove("UI")
				dna.temporary_mutations.Remove(mut)
				continue
			if(mut == UE_CHANGED)
				if(dna.previous["name"])
					real_name = dna.previous["name"]
					name = real_name
					dna.previous.Remove("name")
				if(dna.previous["UE"])
					dna.unique_enzymes = dna.previous["UE"]
					dna.previous.Remove("UE")
				if(dna.previous["blood_type"])
					dna.blood_type = dna.previous["blood_type"]
					dna.previous.Remove("blood_type")
				dna.temporary_mutations.Remove(mut)
				continue
			if(mut == UF_CHANGED)
				if(dna.previous["UF"])
					dna.unique_features = dna.previous["UF"]
					updateappearance(mutations_overlay_update=1)
					dna.previous.Remove("UF")
				dna.temporary_mutations.Remove(mut)
				continue

	for(var/datum/mutation/HM as() in dna.mutations)
		if(HM?.timeout)
			dna.remove_mutation(HM.type)

/// Base carbon environment handler, adds natural stabilization
/mob/living/carbon/handle_environment(datum/gas_mixture/environment, delta_time, times_fired)
	var/areatemp = get_temperature(environment)

	if(stat != DEAD) // If you are dead your body does not stabilize naturally
		natural_bodytemperature_stabilization(environment, delta_time, times_fired)

	if(!on_fire || areatemp > bodytemperature) // If we are not on fire or the area is hotter
		adjust_bodytemperature((areatemp - bodytemperature), use_insulation=TRUE, use_steps=TRUE)

/**
 * Used to stabilize the body temperature back to normal on living mobs
 *
 * Arguments:
 * - [environemnt][/datum/gas_mixture]: The environment gas mix
 * - delta_time: The amount of time that has elapsed since the last tick
 * - times_fired: The number of times SSmobs has ticked
 */
/mob/living/carbon/proc/natural_bodytemperature_stabilization(datum/gas_mixture/environment, delta_time, times_fired)
	var/areatemp = get_temperature(environment)
	var/body_temperature_difference = get_body_temp_normal() - bodytemperature
	var/natural_change = 0

	// We are very cold, increase body temperature
	if(bodytemperature <= BODYTEMP_COLD_DAMAGE_LIMIT)
		natural_change = max((body_temperature_difference * metabolism_efficiency / BODYTEMP_AUTORECOVERY_DIVISOR), \
			BODYTEMP_AUTORECOVERY_MINIMUM)

	// we are cold, reduce the minimum increment and do not jump over the difference
	else if(bodytemperature > BODYTEMP_COLD_DAMAGE_LIMIT && bodytemperature < get_body_temp_normal())
		natural_change = max(body_temperature_difference * metabolism_efficiency / BODYTEMP_AUTORECOVERY_DIVISOR, \
			min(body_temperature_difference, BODYTEMP_AUTORECOVERY_MINIMUM / 4))

	// We are hot, reduce the minimum increment and do not jump below the difference
	else if(bodytemperature > get_body_temp_normal() && bodytemperature <= BODYTEMP_HEAT_DAMAGE_LIMIT)
		natural_change = min(body_temperature_difference * metabolism_efficiency / BODYTEMP_AUTORECOVERY_DIVISOR, \
			max(body_temperature_difference, -(BODYTEMP_AUTORECOVERY_MINIMUM / 4)))

	// We are very hot, reduce the body temperature
	else if(bodytemperature >= BODYTEMP_HEAT_DAMAGE_LIMIT)
		natural_change = min((body_temperature_difference / BODYTEMP_AUTORECOVERY_DIVISOR), -BODYTEMP_AUTORECOVERY_MINIMUM)

	var/thermal_protection = 1 - get_insulation_protection(areatemp) // invert the protection
	if(areatemp > bodytemperature) // It is hot here
		if(bodytemperature < get_body_temp_normal())
			// Our bodytemp is below normal we are cold, insulation helps us retain body heat
			// and will reduce the heat we lose to the environment
			natural_change = (thermal_protection + 1) * natural_change
		else
			// Our bodytemp is above normal and sweating, insulation hinders out ability to reduce heat
			// but will reduce the amount of heat we get from the environment
			natural_change = (1 / (thermal_protection + 1)) * natural_change
	else // It is cold here
		if(!on_fire) // If on fire ignore ignore local temperature in cold areas
			if(bodytemperature < get_body_temp_normal())
				// Our bodytemp is below normal, insulation helps us retain body heat
				// and will reduce the heat we lose to the environment
				natural_change = (thermal_protection + 1) * natural_change
			else
				// Our bodytemp is above normal and sweating, insulation hinders out ability to reduce heat
				// but will reduce the amount of heat we get from the environment
				natural_change = (1 / (thermal_protection + 1)) * natural_change

	// Apply the natural stabilization changes
	adjust_bodytemperature(natural_change * delta_time)

/**
 * Get the insulation that is appropriate to the temperature you're being exposed to.
 * All clothing, natural insulation, and traits are combined returning a single value.
 *
 * required temperature The Temperature that you're being exposed to
 *
 * return the percentage of protection as a value from 0 - 1
**/
/mob/living/carbon/proc/get_insulation_protection(temperature)
	return (temperature > bodytemperature) ? get_heat_protection(temperature) : get_cold_protection(temperature)

/// This returns the percentage of protection from heat as a value from 0 - 1
/// temperature is the temperature you're being exposed to
/mob/living/carbon/proc/get_heat_protection(temperature)
	return heat_protection

/// This returns the percentage of protection from cold as a value from 0 - 1
/// temperature is the temperature you're being exposed to
/mob/living/carbon/proc/get_cold_protection(temperature)
	return cold_protection

/**
 * Have two mobs share body heat between each other.
 * Account for the insulation and max temperature change range for the mob
 *
 * vars:
 * * M The mob/living/carbon that is sharing body heat
 */
/mob/living/carbon/proc/share_bodytemperature(mob/living/carbon/M)
	var/temp_diff = bodytemperature - M.bodytemperature
	if(temp_diff > 0) // you are warm share the heat of life
		M.adjust_bodytemperature((temp_diff * 0.5), use_insulation=TRUE, use_steps=TRUE) // warm up the giver
		adjust_bodytemperature((temp_diff * -0.5), use_insulation=TRUE, use_steps=TRUE) // cool down the reciver

	else // they are warmer leech from them
		adjust_bodytemperature((temp_diff * -0.5) , use_insulation=TRUE, use_steps=TRUE) // warm up the reciver
		M.adjust_bodytemperature((temp_diff * 0.5), use_insulation=TRUE, use_steps=TRUE) // cool down the giver

/**
 * Adjust the body temperature of a mob
 * expanded for carbon mobs allowing the use of insulation and change steps
 *
 * vars:
 * * amount The amount of degrees to change body temperature by
 * * min_temp (optional) The minimum body temperature after adjustment
 * * max_temp (optional) The maximum body temperature after adjustment
 * * use_insulation (optional) modifies the amount based on the amount of insulation the mob has
 * * use_steps (optional) Use the body temp divisors and max change rates
 * * capped (optional) default True used to cap step mode
 */
/mob/living/carbon/adjust_bodytemperature(amount, min_temp=0, max_temp=INFINITY, use_insulation=FALSE, use_steps=FALSE, capped=TRUE)
	// apply insulation to the amount of change
	if(use_insulation)
		amount *= (1 - get_insulation_protection(bodytemperature + amount))

	// Use the bodytemp divisors to get the change step, with max step size
	if(use_steps)
		amount = (amount > 0) ? (amount / BODYTEMP_HEAT_DIVISOR) : (amount / BODYTEMP_COLD_DIVISOR)
		// Clamp the results to the min and max step size
		if(capped)
			amount = (amount > 0) ? min(amount, BODYTEMP_HEATING_MAX) : max(amount, BODYTEMP_COOLING_MAX)

	if(bodytemperature >= min_temp && bodytemperature <= max_temp)
		bodytemperature = clamp(bodytemperature + amount, min_temp, max_temp)

/////////
//LIVER//
/////////

///Decides if the liver is failing or not.
/mob/living/carbon/proc/handle_liver(delta_time, times_fired)
	if(!dna)
		return
	var/obj/item/organ/liver/liver = get_organ_slot(ORGAN_SLOT_LIVER)
	if(!liver)
		liver_failure(delta_time, times_fired)

/mob/living/carbon/proc/undergoing_liver_failure()
	var/obj/item/organ/liver/liver = get_organ_slot(ORGAN_SLOT_LIVER)
	if(liver && (liver.organ_flags & ORGAN_FAILING))
		return TRUE

/mob/living/carbon/proc/liver_failure(delta_time, times_fired)
	reagents.end_metabolization(src, keep_liverless = TRUE) //Stops trait-based effects on reagents, to prevent permanent buffs
	reagents.metabolize(src, delta_time, times_fired, can_overdose=FALSE, liverless = TRUE)
	if(HAS_TRAIT(src, TRAIT_STABLELIVER) || HAS_TRAIT(src, TRAIT_NOMETABOLISM))
		return
	adjustToxLoss(2 * delta_time, TRUE,  TRUE)
	if(DT_PROB(15, delta_time))
		to_chat(src, span_warning("You feel a stabbing pain in your abdomen!"))

/////////////////////////////////////
//MONKEYS WITH TOO MUCH CHOLOESTROL//
/////////////////////////////////////

/mob/living/carbon/proc/can_heartattack()
	if(!needs_heart())
		return FALSE
	var/obj/item/organ/heart/heart = get_organ_slot(ORGAN_SLOT_HEART)
	if(!heart || (heart.organ_flags & ORGAN_SYNTHETIC))
		return FALSE
	return TRUE

/mob/living/carbon/proc/needs_heart()
	if(HAS_TRAIT(src, TRAIT_STABLEHEART))
		return FALSE
	if(dna && dna.species && (HAS_TRAIT(src, TRAIT_NOBLOOD) || isnull(dna.species.mutantheart))) //not all carbons have species!
		return FALSE
	return TRUE

/*
 * The mob is having a heart attack
 *
 * NOTE: this is true if the mob has no heart and needs one, which can be suprising,
 * you are meant to use it in combination with can_heartattack for heart attack
 * related situations (i.e not just cardiac arrest)
 */
/mob/living/carbon/proc/undergoing_cardiac_arrest()
	var/obj/item/organ/heart/heart = get_organ_slot(ORGAN_SLOT_HEART)
	if(istype(heart) && heart.beating)
		return FALSE
	else if(!needs_heart())
		return FALSE
	return TRUE

/mob/living/carbon/proc/set_heartattack(status)
	if(!can_heartattack())
		return FALSE

	var/obj/item/organ/heart/heart = get_organ_slot(ORGAN_SLOT_HEART)
	if(!istype(heart))
		return

	heart.beating = !status
