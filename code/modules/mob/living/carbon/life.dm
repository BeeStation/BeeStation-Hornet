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
		if(stat != DEAD)
			for(var/V in internal_organs)
				var/obj/item/organ/O = V
				O.on_life(delta_time, times_fired)
		else
			if(reagents && !reagents.has_reagent(/datum/reagent/toxin/formaldehyde, 1)) // No organ decay if the body contains formaldehyde.
				for(var/V in internal_organs)
					var/obj/item/organ/O = V
					O.on_death(delta_time, times_fired) //Needed so organs decay while inside the body.

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

	//Updates the number of stored chemicals for changeling powers
	if(hud_used?.lingchemdisplay && !isalien(src) && mind)
		var/datum/antagonist/changeling/changeling = mind.has_antag_datum(/datum/antagonist/changeling)
		if(changeling)
			changeling.regenerate(delta_time, times_fired)
			hud_used.lingchemdisplay.invisibility = 0
			hud_used.lingchemdisplay.maptext = MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#dd66dd'>[round(changeling.chem_charges)]</font></div>")
		else
			hud_used.lingchemdisplay.invisibility = INVISIBILITY_ABSTRACT

	if(stat != DEAD)
		return 1

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
	check_breath(breath, delta_time)

	if(breath)
		loc.assume_air(breath)

/mob/living/carbon/proc/has_smoke_protection()
	if(HAS_TRAIT(src, TRAIT_NOBREATH))
		return TRUE
	return FALSE

//Third link in a breath chain, calls handle_breath_temperature()
/mob/living/carbon/proc/check_breath(datum/gas_mixture/breath)
	. = TRUE

	if(status_flags & GODMODE)
		return
	if(HAS_TRAIT(src, TRAIT_NOBREATH))
		return

	// Breath may be null, so use a fallback "empty breath" for convenience.
	if(!breath)
		/// Fallback "empty breath" for convenience.
		var/static/datum/gas_mixture/immutable/empty_breath = new(BREATH_VOLUME)
		breath = empty_breath

	// Ensure gas volumes are present.
	breath.assert_gases(/datum/gas/bz, /datum/gas/carbon_dioxide, /datum/gas/freon, /datum/gas/plasma, /datum/gas/pluoxium, /datum/gas/miasma, /datum/gas/nitrous_oxide, /datum/gas/nitrium, /datum/gas/oxygen)

	/// The list of gases in the breath.
	var/list/breath_gases = breath.gases
	/// Indicates if there are moles of gas in the breath.
	var/has_moles = breath.total_moles() != 0

	var/obj/item/organ/lungs = get_organ_slot(ORGAN_SLOT_LUNGS)
	if(!lungs)
		// Lungs are missing! Can't breathe.
		// Simulates breathing zero moles of gas.
		has_moles = FALSE
		// Extra damage, let God sort ’em out!
		adjustOxyLoss(2)

	/// Minimum O2 before suffocation.
	var/safe_oxygen_min = 16
	/// Maximum CO2 before side-effects.
	var/safe_co2_max = 10
	/// Maximum Plasma before side-effects.
	var/safe_plas_max = 0.05
	/// Maximum Pluoxum before side-effects.
	var/gas_stimulation_min = 0.002 // For Pluoxium
	// Vars for N2O induced euphoria, stun, and sleep.
	var/n2o_euphoria = EUPHORIA_LAST_FLAG
	var/n2o_para_min = 1
	var/n2o_sleep_min = 5

	// Partial pressures in our breath
	// Main gases.
	var/pluoxium_pp = 0
	var/o2_pp = 0
	var/plasma_pp = 0
	var/co2_pp = 0
	// Trace gases ordered alphabetically.
	var/bz_pp = 0
	var/freon_pp = 0
	var/n2o_pp = 0
	var/nitrium_pp = 0
	var/miasma_pp = 0

	// Check for moles of gas and handle partial pressures / special conditions.
	if(has_moles)
		// Breath has more than 0 moles of gas.
		// Partial pressures of "main gases".
		pluoxium_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/pluoxium][MOLES])
		o2_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/oxygen][MOLES] + (PLUOXIUM_PROPORTION * pluoxium_pp))
		plasma_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/plasma][MOLES])
		co2_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/carbon_dioxide][MOLES])
		// Partial pressures of "trace" gases.
		bz_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/bz][MOLES])
		freon_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/freon][MOLES])
		miasma_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/miasma][MOLES])
		n2o_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/nitrous_oxide][MOLES])
		nitrium_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/nitrium][MOLES])
	else
		// Can't breathe! Lungs are missing, and/or breath is empty.
		. = FALSE
		failed_last_breath = TRUE

	//-- PLUOXIUM --//
	// Behaves like Oxygen with 8X efficacy, but metabolizes into a reagent.
	if(pluoxium_pp)
		// Inhale Pluoxium. Exhale nothing.
		breath_gases[/datum/gas/pluoxium][MOLES] = 0
		// Metabolize to reagent.
		if(pluoxium_pp > gas_stimulation_min)
			var/existing = reagents.get_reagent_amount(/datum/reagent/pluoxium)
			reagents.add_reagent(/datum/reagent/pluoxium, max(0, 1 - existing))

	//-- OXYGEN --//
	// Carbons need only Oxygen to breathe properly.
	var/oxygen_used = 0
	// Minimum Oxygen effects. "Too little oxygen!"
	if(o2_pp < safe_oxygen_min)
		// Breathe insufficient amount of O2.
		oxygen_used = handle_suffocation(o2_pp, safe_oxygen_min, breath_gases[/datum/gas/oxygen][MOLES])
		throw_alert(ALERT_NOT_ENOUGH_OXYGEN, /atom/movable/screen/alert/not_enough_oxy)
	else
		// Enough oxygen to breathe.
		failed_last_breath = FALSE
		clear_alert(ALERT_NOT_ENOUGH_OXYGEN)
		if(o2_pp)
			// Inhale O2.
			oxygen_used = breath_gases[/datum/gas/oxygen][MOLES]
			// Heal mob if not in crit.
			if(health >= crit_threshold)
				adjustOxyLoss(-5)
	// Exhale equivalent amount of CO2.
	if(o2_pp)
		breath_gases[/datum/gas/oxygen][MOLES] -= oxygen_used
		breath_gases[/datum/gas/carbon_dioxide][MOLES] += oxygen_used

	//-- CARBON DIOXIDE --//
	// Maximum CO2 effects. "Too much CO2!"
	if(co2_pp > safe_co2_max)
		// CO2 side-effects.
		// Give the mob a chance to notice.
		if(prob(20))
			emote("cough")
		// If it's the first breath with too much CO2 in it, lets start a counter, then have them pass out after 12s or so.
		if(!co2overloadtime)
			co2overloadtime = world.time
		else if((world.time - co2overloadtime) > 12 SECONDS)
			throw_alert(ALERT_TOO_MUCH_CO2, /atom/movable/screen/alert/too_much_co2)
			Unconscious(6 SECONDS)
			// Lets hurt em a little, let them know we mean business.
			adjustOxyLoss(3)
			// They've been in here 30s now, start to kill them for their own good!
			if((world.time - co2overloadtime) > 30 SECONDS)
				adjustOxyLoss(8)
	else
		// Reset side-effects.
		co2overloadtime = 0
		clear_alert(ALERT_TOO_MUCH_CO2)

	//-- PLASMA --//
	// Maximum Plasma effects. "Too much Plasma!"
	if(plasma_pp > safe_plas_max)
		// Plasma side-effects.
		var/ratio = (breath_gases[/datum/gas/plasma][MOLES] / safe_plas_max) * 10
		adjustToxLoss(clamp(ratio, MIN_TOXIC_GAS_DAMAGE, MAX_TOXIC_GAS_DAMAGE))
		throw_alert(ALERT_TOO_MUCH_PLASMA, /atom/movable/screen/alert/too_much_plas)
	else
		// Reset side-effects.
		clear_alert(ALERT_TOO_MUCH_PLASMA)

	//-- TRACES --//
	// If there's some other funk in the air lets deal with it here.

	//-- BZ --//
	// (Facepunch port of their Agent B)
	if(bz_pp)
		if(bz_pp > 1)
			hallucination += 20 SECONDS
		else if(bz_pp > 0.01)
			hallucination += 10 SECONDS

	//-- FREON --//
	if(freon_pp)
		adjustFireLoss(freon_pp * 0.25)

	//-- MIASMA --//
	if(!miasma_pp)
	// Clear moodlet if no miasma at all.
		SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "smell")
	else
		// Miasma side-effects.
		switch(miasma_pp)
			if(0.25 to 5)
				// At lower pp, give out a little warning
				SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "smell")
				if(prob(5))
					to_chat(src, span_notice("There is an unpleasant smell in the air."))
			if(5 to 20)
				//At somewhat higher pp, warning becomes more obvious
				if(prob(15))
					to_chat(src, span_warning("You smell something horribly decayed inside this room."))
					SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "smell", /datum/mood_event/disgust/bad_smell)
			if(15 to 30)
				//Small chance to vomit. By now, people have internals on anyway
				if(prob(5))
					to_chat(src, span_warning("The stench of rotting carcasses is unbearable!"))
					SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "smell", /datum/mood_event/disgust/nauseating_stench)
					vomit()
			if(30 to INFINITY)
				//Higher chance to vomit. Let the horror start
				if(prob(25))
					to_chat(src, span_warning("The stench of rotting carcasses is unbearable!"))
					SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "smell", /datum/mood_event/disgust/nauseating_stench)
					vomit()
			else
				SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "smell")

	//-- NITROUS OXIDE --//
	if(n2o_pp > n2o_para_min)
		// More N2O, more severe side-effects. Causes stun/sleep.
		n2o_euphoria = EUPHORIA_ACTIVE
		throw_alert(ALERT_TOO_MUCH_N2O, /atom/movable/screen/alert/too_much_n2o)
		// give them one second of grace to wake up and run away a bit!
		if(!HAS_TRAIT(src, TRAIT_SLEEPIMMUNE))
			Unconscious(6 SECONDS)
		// Enough to make the mob sleep.
		if(n2o_pp > n2o_sleep_min)
			Sleeping(max(AmountSleeping() + 40, 200))
	else if(n2o_pp > 0.01)
		// No alert for small amounts, but the mob randomly feels euphoric.
		if(prob(20))
			n2o_euphoria = EUPHORIA_ACTIVE
			emote(pick("giggle","laugh"))
		else
			n2o_euphoria = EUPHORIA_INACTIVE
	else
	// Reset side-effects, for zero or extremely small amounts of N2O.
		n2o_euphoria = EUPHORIA_INACTIVE
		clear_alert(ALERT_TOO_MUCH_N2O)

	//-- NITRIUM --//
	if(nitrium_pp)
		var/need_mob_update = FALSE
		if(nitrium_pp > 0.5)
			need_mob_update += adjustFireLoss(nitrium_pp * 0.15, updating_health = FALSE)
		if(nitrium_pp > 5)
			need_mob_update += adjustToxLoss(nitrium_pp * 0.05, updating_health = FALSE)
		if(need_mob_update)
			updatehealth()

	// Handle chemical euphoria mood event, caused by N2O.
	if (n2o_euphoria == EUPHORIA_ACTIVE)
		SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "chemical_euphoria", /datum/mood_event/chemical_euphoria)
	else if (n2o_euphoria == EUPHORIA_INACTIVE)
		SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "chemical_euphoria")
	// Activate mood on first flag, remove on second, do nothing on third.

	if(has_moles)
		handle_breath_temperature(breath)

	breath.garbage_collect()

/// Applies suffocation side-effects to a given Human, scaling based on ratio of required pressure VS "true" pressure.
/// If pressure is greater than 0, the return value will represent the amount of gas successfully breathed.
/mob/living/carbon/proc/handle_suffocation(breath_pp = 0, safe_breath_min = 0, true_pp = 0)
	. = 0
	// Can't suffocate without minimum breath pressure.
	if(!safe_breath_min)
		return
	// Mob is suffocating.
	failed_last_breath = TRUE
	// Give them a chance to notice something is wrong.
	if(prob(20))
		emote("gasp")
	// Mob is at critical health, check if they can be damaged further.
	if(health < crit_threshold)
		// Mob is immune to damage at critical health.
		if(HAS_TRAIT(src, TRAIT_NOCRITDAMAGE))
			return
		// Reagents like Epinephrine stop suffocation at critical health.
		if(reagents.has_reagent(/datum/reagent/medicine/epinephrine, needs_metabolizing = TRUE))
			return
	// Low pressure.
	if(breath_pp)
		var/ratio = safe_breath_min / breath_pp
		adjustOxyLoss(min(5 * ratio, 3))
		return true_pp * ratio / 6
	// Zero pressure.
	if(health >= crit_threshold)
		adjustOxyLoss(3)
	else
		adjustOxyLoss(1)

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
		if(HM?.timed)
			dna.remove_mutation(HM.type)

/*
Alcohol Poisoning Chart
Note that all higher effects of alcohol poisoning will inherit effects for smaller amounts (i.e. light poisoning inherts from slight poisoning)
In addition, severe effects won't always trigger unless the drink is poisonously strong
All effects don't start immediately, but rather get worse over time; the rate is affected by the imbiber's alcohol tolerance

0: Non-alcoholic
1-10: Barely classifiable as alcohol - occasional slurring
11-20: Slight alcohol content - slurring
21-30: Below average - imbiber begins to look slightly drunk
31-40: Just below average - no unique effects
41-50: Average - mild disorientation, imbiber begins to look drunk
51-60: Just above average - disorientation, vomiting, imbiber begins to look heavily drunk
61-70: Above average - small chance of blurry vision, imbiber begins to look smashed
71-80: High alcohol content - blurry vision, imbiber completely shitfaced
81-90: Extremely high alcohol content - light brain damage, passing out
91-100: Dangerously toxic - swift death
*/
#define BALLMER_POINTS 5
GLOBAL_LIST_INIT(ballmer_good_msg, list("Hey guys, what if we rolled out a bluespace wiring system so mice can't destroy the powergrid anymore?",
										"Hear me out here. What if, and this is just a theory, we made R&D controllable from our PDAs?",
										"I'm thinking we should roll out a git repository for our research under the AGPLv3 license so that we can share it among the other stations freely.",
										"I dunno about you guys, but IDs and PDAs being separate is clunky as fuck. Maybe we should merge them into a chip in our arms? That way they can't be stolen easily.",
										"Why the fuck aren't we just making every pair of shoes into galoshes? We have the technology."))
GLOBAL_LIST_INIT(ballmer_windows_me_msg, list("Yo man, what if, we like, uh, put a webserver that's automatically turned on with default admin passwords into every PDA?",
												"So like, you know how we separate our codebase from the master copy that runs on our consumer boxes? What if we merged the two and undid the separation between codebase and server?",
												"Dude, radical idea: H.O.N.K mechs but with no bananium required.",
												"Best idea ever: Disposal pipes instead of hallways.",
												"We should store bank records in a webscale datastore, like /dev/null.",
												"You ever wonder if /dev/null supports sharding?",
												"What if we use a language that was written on a napkin and created over 1 weekend for all of our servers?"))

//this updates all special effects: stun, sleeping, knockdown, druggy, stuttering, etc..
//this updates all special effects: stun, sleeping, knockdown, druggy, stuttering, etc..
/mob/living/carbon/handle_status_effects(delta_time, times_fired)
	..()

	var/restingpwr = 0.5 + 2 * resting

	//Dizziness
	if(dizziness)
		var/client/C = client
		var/pixel_x_diff = 0
		var/pixel_y_diff = 0
		var/temp
		var/saved_dizz = dizziness
		if(C)
			var/oldsrc = src
			var/amplitude = dizziness*(sin(dizziness * world.time) + 1) // This shit is annoying at high strength
			src = null
			spawn(0)
				if(C)
					temp = amplitude * sin(saved_dizz * world.time)
					pixel_x_diff += temp
					C.pixel_x += temp
					temp = amplitude * cos(saved_dizz * world.time)
					pixel_y_diff += temp
					C.pixel_y += temp
					sleep(3)
					if(C)
						temp = amplitude * sin(saved_dizz * world.time)
						pixel_x_diff += temp
						C.pixel_x += temp
						temp = amplitude * cos(saved_dizz * world.time)
						pixel_y_diff += temp
						C.pixel_y += temp
					sleep(3)
					if(C)
						C.pixel_x -= pixel_x_diff
						C.pixel_y -= pixel_y_diff
			src = oldsrc
		dizziness = max(dizziness - (restingpwr * delta_time), 0)

	if(drowsyness)
		drowsyness = max(drowsyness - (restingpwr * delta_time), 0)
		blur_eyes(1 * delta_time)
		if(DT_PROB(2.5, delta_time))
			AdjustSleeping(100)
			Unconscious(100)

	//Jitteriness
	if(jitteriness)
		do_jitter_animation(jitteriness)
		jitteriness = max(jitteriness - (restingpwr * delta_time), 0)
		SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "jittery", /datum/mood_event/jittery)
	else
		SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "jittery")

	if(stuttering)
		stuttering = max(stuttering - (0.5 * delta_time), 0)

	if(slurring)
		slurring = max(slurring - (0.5 * delta_time),0)

	if(cultslurring)
		cultslurring = max(cultslurring - (0.5 * delta_time), 0)

	if(clockslurring)
		clockslurring = max(clockslurring - (0.5 * delta_time), 0)

	if(silent)
		silent = max(silent - (0.5 * delta_time), 0)

	if(druggy)
		adjust_drugginess(-0.5 * delta_time)

	if(hallucination)
		handle_hallucinations(delta_time, times_fired)

	if(drunkenness)
		drunkenness = max(drunkenness - ((0.005 + (drunkenness * 0.02)) * delta_time), 0)
		if(drunkenness >= 6)
			SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "drunk", /datum/mood_event/drunk)
			if(DT_PROB(16, delta_time))
				slurring += 2
			jitteriness = max(jitteriness - (1.5 * delta_time), 0)
			throw_alert("drunk", /atom/movable/screen/alert/drunk)
		else
			SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "drunk")
			sound_environment_override = SOUND_ENVIRONMENT_NONE
			clear_alert("drunk")

		if(drunkenness >= 11 && slurring < 5)
			slurring += 0.6 * delta_time

		if(mind && (mind.assigned_role == JOB_NAME_SCIENTIST || mind.assigned_role == JOB_NAME_RESEARCHDIRECTOR))
			if(SSresearch.science_tech)
				if(drunkenness >= 12.9 && drunkenness <= 13.8)
					drunkenness = round(drunkenness, 0.01)
					var/ballmer_percent = 0
					if(drunkenness == 13.35) // why run math if I dont have to
						ballmer_percent = 1
					else
						ballmer_percent = (-abs(drunkenness - 13.35) / 0.9) + 1
					if(DT_PROB(2.5, delta_time))
						say(pick(GLOB.ballmer_good_msg), forced = "ballmer")
					SSresearch.science_tech.add_point_list(list(TECHWEB_POINT_TYPE_GENERIC = BALLMER_POINTS * ballmer_percent))
				if(drunkenness > 26) // by this point you're into windows ME territory
					if(DT_PROB(2.5, delta_time))
						SSresearch.science_tech.remove_point_list(list(TECHWEB_POINT_TYPE_GENERIC = BALLMER_POINTS))
						say(pick(GLOB.ballmer_windows_me_msg), forced = "ballmer")

		if(drunkenness >= 41)
			if(DT_PROB(16, delta_time))
				confused += 2
			Dizzy(5 * delta_time)

		if(drunkenness >= 51)
			if(DT_PROB(1.5, delta_time))
				confused += 15
				vomit() // vomiting clears toxloss, consider this a blessing
			Dizzy(12.5 * delta_time)

		if(drunkenness >= 61)
			if(DT_PROB(30, delta_time))
				blur_eyes(5)

		if(drunkenness >= 71)
			blur_eyes(2.5 * delta_time)

		if(drunkenness >= 81)
			adjustToxLoss(0.5 * delta_time)
			if(!stat && DT_PROB(2.5, delta_time))
				to_chat(src, span_warning("Maybe you should lie down for a bit."))

		if(drunkenness >= 91)
			adjustToxLoss(0.5 * delta_time)
			adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.2 * delta_time)
			if(DT_PROB(10, delta_time) && !stat)
				if(SSshuttle.emergency.mode == SHUTTLE_DOCKED && is_station_level(z)) //QoL mainly
					to_chat(src, span_warning("You're so tired, but you can't miss that shuttle."))
				else
					to_chat(src, span_warning("Just a quick nap."))
					Sleeping(900)

		if(drunkenness >= 101)
			adjustToxLoss(1 * delta_time) //Let's be honest you shouldn't be alive by now

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
	if(dna && dna.species && HAS_TRAIT(src, TRAIT_NOBLOOD)) //not all carbons have species!
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

#undef BALLMER_POINTS
