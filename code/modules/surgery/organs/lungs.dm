// / Breathing types. Lungs can access either by these or by a string, which will be considered a gas ID.
#define BREATH_OXY		/datum/breathing_class/oxygen
#define BREATH_PLASMA	/datum/breathing_class/plasma

/obj/item/organ/lungs
	var/failed = FALSE
	var/operated = FALSE	//whether we can still have our damages fixed through surgery
	name = "lungs"
	icon_state = "lungs"
	visual = FALSE
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_LUNGS
	gender = PLURAL
	w_class = WEIGHT_CLASS_SMALL

	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY

	high_threshold_passed = "<span class='warning'>You feel some sort of constriction around your chest as your breathing becomes shallow and rapid.</span>"
	now_fixed = "<span class='warning'>Your lungs seem to once again be able to hold air.</span>"
	high_threshold_cleared = "<span class='info'>The constriction around your chest loosens as your breathing calms down.</span>"


	food_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/medicine/salbutamol = 5)

	//Breath damage
	//These thresholds are checked against what amounts to total_mix_pressure * (gas_type_mols/total_mols)
	var/safe_oxygen_min = 16 // Minimum safe partial pressure of O2, in kPa
	var/safe_oxygen_max = 0
	var/safe_nitro_min = 0
	var/safe_co2_max = 10 // Yes it's an arbitrary value who cares?
	var/safe_plasma_min = 0
	///How much breath partial pressure is a safe amount of plasma. 0 means that we are immune to plasma.
	var/safe_plasma_max = 0.05
	var/n2o_detect_min = 0.08 //Minimum n2o for effects
	var/n2o_para_min = 1 //Sleeping agent
	var/n2o_sleep_min = 5 //Sleeping agent
	var/BZ_trip_balls_min = 1 //BZ gas
	var/BZ_brain_damage_min = 10 //Give people some room to play around without killing the station
	var/gas_stimulation_min = 0.002 // For, Pluoxium, Nitryl, Stimulum
	// Vars for N2O/healium induced euphoria, stun, and sleep.
	var/n2o_euphoria = EUPHORIA_LAST_FLAG

	var/oxy_breath_dam_min = MIN_TOXIC_GAS_DAMAGE
	var/oxy_breath_dam_max = MAX_TOXIC_GAS_DAMAGE
	var/oxy_damage_type = OXY
	var/nitro_breath_dam_min = MIN_TOXIC_GAS_DAMAGE
	var/nitro_breath_dam_max = MAX_TOXIC_GAS_DAMAGE
	var/nitro_damage_type = OXY
	var/co2_breath_dam_min = MIN_TOXIC_GAS_DAMAGE
	var/co2_breath_dam_max = MAX_TOXIC_GAS_DAMAGE
	var/co2_damage_type = OXY
	var/plas_breath_dam_min = MIN_TOXIC_GAS_DAMAGE
	var/plas_breath_dam_max = MAX_TOXIC_GAS_DAMAGE
	var/plas_damage_type = TOX
	var/SA_para_min = 1 //nitrous values
	var/SA_sleep_min = 5

	var/breathing_class = BREATH_OXY // can be a gas instead of a breathing class
	var/safe_breath_min = 16
	var/safe_breath_max = 50
	var/safe_breath_dam_min = MIN_TOXIC_GAS_DAMAGE
	var/safe_breath_dam_max = MAX_TOXIC_GAS_DAMAGE
	var/safe_damage_type = OXY
	var/list/gas_min = list()
	var/list/gas_max = list(
		/datum/gas/carbon_dioxide = 30, // Yes it's an arbitrary value who cares?
		/datum/breathing_class/plasma = MOLES_GAS_VISIBLE
	)
	var/list/gas_damage = list(
		"default" = list(
			min = MIN_TOXIC_GAS_DAMAGE,
			max = MAX_TOXIC_GAS_DAMAGE,
			damage_type = OXY
		),
		/datum/gas/plasma = list(
			min = MIN_TOXIC_GAS_DAMAGE,
			max = MAX_TOXIC_GAS_DAMAGE,
			damage_type = TOX
		)
	)

	var/cold_message = "your face freezing and an icicle forming"
	var/cold_level_1_threshold = 260
	var/cold_level_2_threshold = 200
	var/cold_level_3_threshold = 120
	var/cold_level_1_damage = COLD_GAS_DAMAGE_LEVEL_1 //Keep in mind with gas damage levels, you can set these to be negative, if you want someone to heal, instead.
	var/cold_level_2_damage = COLD_GAS_DAMAGE_LEVEL_2
	var/cold_level_3_damage = COLD_GAS_DAMAGE_LEVEL_3
	var/cold_damage_type = BURN

	var/hot_message = "your face burning and a searing heat"
	var/heat_level_1_threshold = 360
	var/heat_level_2_threshold = 400
	var/heat_level_3_threshold = 1000
	var/heat_level_1_damage = HEAT_GAS_DAMAGE_LEVEL_1
	var/heat_level_2_damage = HEAT_GAS_DAMAGE_LEVEL_2
	var/heat_level_3_damage = HEAT_GAS_DAMAGE_LEVEL_3
	var/heat_damage_type = BURN

	var/list/thrown_alerts

	var/crit_stabilizing_reagent = /datum/reagent/medicine/epinephrine

/obj/item/organ/lungs/New()
	. = ..()
	populate_gas_info()

/obj/item/organ/lungs/Insert(mob/living/carbon/M, special, drop_if_replaced, pref_load)
	// This may look weird, but uh, organ code is weird, so we FIRST check to see if this organ is going into a NEW person.
	// If it is going into a new person, ..() will ensure that organ is Remove()d first, and we won't run into any issues with duplicate signals.
	var/new_owner = QDELETED(owner) || owner != M
	..()
	if(new_owner)
		RegisterSignal(M, SIGNAL_ADDTRAIT(TRAIT_NOBREATH), PROC_REF(on_nobreath))

/obj/item/organ/lungs/Remove(mob/living/carbon/M, special, pref_load)
	. = ..()
	UnregisterSignal(M, SIGNAL_ADDTRAIT(TRAIT_NOBREATH))
	LAZYNULL(thrown_alerts)

/obj/item/organ/lungs/proc/populate_gas_info()
	gas_min[breathing_class] = safe_breath_min
	gas_max[breathing_class] = safe_breath_max
	gas_damage[breathing_class] = list(
		min = safe_breath_dam_min,
		max = safe_breath_dam_max,
		damage_type = safe_damage_type
	)

/obj/item/organ/lungs/proc/on_nobreath(mob/living/carbon/source)
	SIGNAL_HANDLER
	var/static/list/breath_moodlets = list("chemical_euphoria", "suffocation") // Moodlets directly caused by breathing
	if(!istype(source))
		return
	source.failed_last_breath = FALSE
	for(var/alert_category in thrown_alerts)
		source.clear_alert(alert_category)
	LAZYNULL(thrown_alerts)
	for(var/moodlet in breath_moodlets)
		SEND_SIGNAL(source, COMSIG_CLEAR_MOOD_EVENT, moodlet)

/obj/item/organ/lungs/proc/throw_alert_for(mob/living/carbon/target, alert_category, alert_type)
	if(!istype(target) || !alert_category || !alert_type)
		return
	target.throw_alert(alert_category, alert_type)
	LAZYOR(thrown_alerts, alert_category)

/obj/item/organ/lungs/proc/clear_alert_for(mob/living/carbon/target, alert_category)
	if(!istype(target) || !alert_category)
		return
	target.clear_alert(alert_category)
	LAZYREMOVE(thrown_alerts, alert_category)


/**
 * This proc tests if the lungs can breathe, if they can breathe a given gas mixture, and throws/clears gas alerts.
 * If there are moles of gas in the given gas mixture, side-effects may be applied/removed on the mob.
 * If a required gas (such as Oxygen) is missing from the breath, then it calls [proc/handle_suffocation].
 *
 * Returns TRUE if the breath was successful, or FALSE if otherwise.
 *
 * Arguments:
 * * breath: A gas mixture to test, or null.
 * * breather: A carbon mob that is using the lungs to breathe.
 */
/obj/item/organ/lungs/proc/check_breath(datum/gas_mixture/breath, mob/living/carbon/human/breather)
//TODO: add lung damage = less oxygen gains
	. = TRUE
	if(breather.status_flags & GODMODE)
		breather.failed_last_breath = FALSE
		breather.clear_alert(ALERT_NOT_ENOUGH_OXYGEN)
		return
	if(HAS_TRAIT(breather, TRAIT_NOBREATH))
		return

	// Breath may be null, so use a fallback "empty breath" for convenience.
	if(!breath)
		/// Fallback "empty breath" for convenience.
		var/static/datum/gas_mixture/immutable/empty_breath = new(BREATH_VOLUME)
		breath = empty_breath

	// Ensure gas volumes are present.
	for(var/gas_id in GLOB.meta_gas_info)
		breath.assert_gas(gas_id)

	#define PP_MOLES(X) ((X / total_moles) * pressure)

	#define PP(air, gas) PP_MOLES(GET_MOLES(gas, air))

	// Indicates if there are moles of gas in the breath.
	var/has_moles = breath.total_moles() != 0
	// The list of gases in the breath.
	var/list/breath_gases = breath.gases

	// Re-usable var used to remove a limited volume of each gas from the given gas mixture.
	var/gas_breathed = 0

	// Partial pressures in the breath.
	// Main Gases
	var/pluoxium_pp = 0
	var/o2_pp = 0
	var/n2_pp = 0
	var/co2_pp = 0
	var/plasma_pp = 0
	// Trace Gases, ordered alphabetically.
	var/bz_pp = 0
	var/n2o_pp = 0
	var/nitryl_pp = 0
	var/trit_pp = 0
	var/stimulum_pp = 0

	// Check for moles of gas and handle partial pressures / special conditions.
	if(has_moles)
		// Partial pressures of "main" gases.
		pluoxium_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/pluoxium][MOLES])
		o2_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/oxygen][MOLES]) + (8 * pluoxium_pp)
		n2_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/nitrogen][MOLES])
		co2_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/carbon_dioxide][MOLES])
		plasma_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/plasma][MOLES])
		// Partial pressures of "trace" gases.
		bz_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/bz][MOLES])
		n2o_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/nitrous_oxide][MOLES])
		nitryl_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/nitryl][MOLES])
		trit_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/tritium][MOLES])
		stimulum_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/stimulum][MOLES])

	else
		// Can't breathe!
		. = FALSE
		breather.failed_last_breath = TRUE

	//-- MAIN GASES --//

	//-- PLUOXIUM --//
	// Behaves like Oxygen with 8X efficacy, but metabolizes into a reagent.
	if(pluoxium_pp)
		// Inhale Pluoxium. Exhale nothing.
		breathe_gas_volume(breath_gases, /datum/gas/pluoxium)
		// Metabolize to reagent.
		if(pluoxium_pp > gas_stimulation_min)
			// Enough pluoxium to breathe.
			breather.failed_last_breath = FALSE
			breather.clear_alert(ALERT_NOT_ENOUGH_OXYGEN)
			// Heal mob if not in crit.
			if(breather.health >= breather.crit_threshold)
				breather.adjustOxyLoss(-5)

	//-- OXYGEN --//
	// Maximum Oxygen effects. "Too much O2!"
	// If too much Oxygen is poisonous.

	if(safe_oxygen_max)
		if(o2_pp && (o2_pp > safe_oxygen_max))
			// O2 side-effects.
			var/ratio = (breath_gases[/datum/gas/oxygen][MOLES] / safe_oxygen_max) * 10
			breather.apply_damage_type(clamp(ratio, oxy_breath_dam_min, oxy_breath_dam_max), oxy_damage_type)
			breather.throw_alert(ALERT_TOO_MUCH_OXYGEN, /atom/movable/screen/alert/too_much_oxy)
		else
			// Reset side-effects.
			breather.clear_alert(ALERT_TOO_MUCH_OXYGEN)

	// Minimum Oxygen effects.
	// If the lungs need Oxygen to breathe properly, O2 is exchanged with CO2.
	if(safe_oxygen_min)
		// Suffocation side-effects.
		if(o2_pp < safe_oxygen_min)
			breather.throw_alert(ALERT_NOT_ENOUGH_OXYGEN, /atom/movable/screen/alert/not_enough_oxy)
			// Inhale insufficient amount of O2, exhale CO2.
			if(o2_pp)
				gas_breathed = handle_suffocation(breather, o2_pp, safe_oxygen_min, breath_gases[/datum/gas/oxygen][MOLES])
				breathe_gas_volume(breath_gases, /datum/gas/oxygen, /datum/gas/carbon_dioxide, volume = gas_breathed)
		else
			// Enough oxygen to breathe.
			breather.failed_last_breath = FALSE
			breather.clear_alert(ALERT_NOT_ENOUGH_OXYGEN)
			// Inhale Oxygen, exhale equivalent amount of CO2.
			if(o2_pp)
				breathe_gas_volume(breath_gases, /datum/gas/oxygen, /datum/gas/carbon_dioxide)
				// Heal mob if not in crit.
				if(breather.health >= breather.crit_threshold)
					breather.adjustOxyLoss(-5)

	// Minimum Nitrogen effects.
	// If the lungs need Nitrogen to breathe properly, N2 is exchanged with CO2.
	if(safe_nitro_min)
		// Suffocation side-effects.
		if(n2_pp < safe_nitro_min)
			breather.throw_alert(ALERT_NOT_ENOUGH_NITRO, /atom/movable/screen/alert/not_enough_nitro)
			// Inhale insufficient amount of N2, exhale CO2.
			if(n2_pp)
				gas_breathed = handle_suffocation(breather, n2_pp, safe_nitro_min, breath_gases[/datum/gas/nitrogen][MOLES])
				breathe_gas_volume(breath_gases, /datum/gas/nitrogen, /datum/gas/carbon_dioxide, volume = gas_breathed)
		else
			// Enough nitrogen to breathe.
			breather.failed_last_breath = FALSE
			breather.clear_alert(ALERT_NOT_ENOUGH_NITRO)
			// Inhale N2, exhale equivalent amount of CO2. Look ma, sideways breathing!
			if(n2_pp)
				breathe_gas_volume(breath_gases, /datum/gas/nitrogen, /datum/gas/carbon_dioxide)
				// Heal mob if not in crit.
				if(breather.health >= breather.crit_threshold)
					breather.adjustOxyLoss(-5)

	//-- CARBON DIOXIDE --//
	// Maximum CO2 effects. "Too much CO2!"
	if(safe_co2_max)
		if(co2_pp && (co2_pp > safe_co2_max))
			// CO2 side-effects.
			// Give the mob a chance to notice.
			if(prob(20))
				breather.emote("cough")
			// If it's the first breath with too much CO2 in it, lets start a counter, then have them pass out after 12s or so.
			if(!breather.co2overloadtime)
				breather.co2overloadtime = world.time
			else if((world.time - breather.co2overloadtime) > 12 SECONDS)
				breather.throw_alert(ALERT_TOO_MUCH_CO2, /atom/movable/screen/alert/too_much_co2)
				breather.Unconscious(6 SECONDS)
				// Lets hurt em a little, let them know we mean business.
				breather.apply_damage_type(3, co2_damage_type)
				// They've been in here 30s now, start to kill them for their own good!
				if((world.time - breather.co2overloadtime) > 30 SECONDS)
					breather.apply_damage_type(8, co2_damage_type)
		else
			// Reset side-effects.
			breather.co2overloadtime = 0
			breather.clear_alert(ALERT_TOO_MUCH_CO2)

	//-- PLASMA --//
	// Maximum Plasma effects. "Too much Plasma!"
	if(safe_plasma_max)
		if(plasma_pp && (plasma_pp > safe_plasma_max))
			// Plasma side-effects.
			var/ratio = (breath_gases[/datum/gas/plasma][MOLES] / safe_plasma_max) * 10
			breather.apply_damage_type(clamp(ratio, plas_breath_dam_min, plas_breath_dam_max), plas_damage_type)
			breather.throw_alert(ALERT_TOO_MUCH_PLASMA, /atom/movable/screen/alert/too_much_tox)
		else
			// Reset side-effects.
			breather.clear_alert(ALERT_TOO_MUCH_PLASMA)

	// Minimum Plasma effects.
	// If the lungs need Plasma to breathe properly, Plasma is exchanged with CO2.
	if(safe_plasma_min)
		// Suffocation side-effects.
		if(plasma_pp < safe_plasma_min)
			breather.throw_alert(ALERT_NOT_ENOUGH_PLASMA, /atom/movable/screen/alert/not_enough_tox)
			// Breathe insufficient amount of Plasma, exhale CO2.
			if(plasma_pp)
				gas_breathed = handle_suffocation(breather, plasma_pp, safe_plasma_min, breath_gases[/datum/gas/plasma][MOLES])
				breathe_gas_volume(breath_gases, /datum/gas/plasma, /datum/gas/carbon_dioxide, volume = gas_breathed)
		else
			// Enough Plasma to breathe.
			breather.failed_last_breath = FALSE
			breather.clear_alert(ALERT_NOT_ENOUGH_PLASMA)
			// Inhale Plasma, exhale equivalent amount of CO2.
			if(plasma_pp)
				breathe_gas_volume(breath_gases, /datum/gas/plasma, /datum/gas/carbon_dioxide)
				// Heal mob if not in crit.
				if(breather.health >= breather.crit_threshold)
					breather.adjustOxyLoss(-5)


	//-- TRACES --//
	// If there's some other shit in the air lets deal with it here.


	//-- BZ --//
	if(bz_pp)
		if(bz_pp > BZ_trip_balls_min)
			breather.hallucination += 10
			breather.reagents.add_reagent(/datum/reagent/metabolite/bz, 5)
		if(bz_pp > BZ_brain_damage_min && prob(33))
			breather.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3, 150, ORGAN_ORGANIC)


	//-- N2O --//
	// N2O side-effects. "Too much N2O!"
	// Small amount of N2O, small side-effects. Causes random euphoria and giggling.
	if (n2o_pp > n2o_para_min)
		// More N2O, more severe side-effects. Causes stun/sleep.
		n2o_euphoria = EUPHORIA_ACTIVE
		breather.throw_alert(ALERT_TOO_MUCH_N2O, /atom/movable/screen/alert/too_much_n2o)
		// 60 gives them one second to wake up and run away a bit!
		breather.Unconscious(6 SECONDS)
		// Enough to make the mob sleep.
		if(n2o_pp > n2o_sleep_min)
			breather.Sleeping(min(breather.AmountSleeping() + 100, 200))
	else if(n2o_pp > 0.01)
		// No alert for small amounts, but the mob randomly feels euphoric.
		breather.clear_alert(ALERT_TOO_MUCH_N2O)
		if(prob(20))
			n2o_euphoria = EUPHORIA_ACTIVE
			breather.emote(pick("giggle", "laugh"))
		else
			n2o_euphoria = EUPHORIA_INACTIVE
	else
		// Reset side-effects, for zero or extremely small amounts of N2O.
		n2o_euphoria = EUPHORIA_INACTIVE
		breather.clear_alert(ALERT_TOO_MUCH_N2O)


	// Nitryl
	if (nitryl_pp)
		// Inhale nitryl. Exhale nothing.
		breathe_gas_volume(breath_gases, /datum/gas/nitryl)
		// Random chance to inflict side effects increases with pressure.
		if (prob(nitryl_pp) && nitryl_pp>10)
			breather.adjustOrganLoss(ORGAN_SLOT_LUNGS, nitryl_pp/2)
			to_chat(breather, "<span class='notice'>You feel a burning sensation in your chest</span>")
		if (prob(nitryl_pp) && nitryl_pp>10)
			breather.adjustOrganLoss(ORGAN_SLOT_LUNGS, nitryl_pp/2)
			to_chat(breather, "<span class='notice'>You feel a burning sensation in your chest</span>")
		gas_breathed = breath_gases[/datum/gas/nitryl][MOLES]
		if (gas_breathed > gas_stimulation_min)
			breather.reagents.add_reagent(/datum/reagent/nitryl,1)


	//-- TRITIUM --//
	if (trit_pp)
		// Inhale Tritium. Exhale nothing.
		gas_breathed = breathe_gas_volume(breath_gases, /datum/gas/tritium)
		// Tritium side-effects.
		var/ratio = gas_breathed * 15
		breather.adjustToxLoss(clamp(ratio, MIN_TOXIC_GAS_DAMAGE, MAX_TOXIC_GAS_DAMAGE))
		if (trit_pp > 50)
			breather.radiation += trit_pp/2 //If you're breathing in half an atmosphere of radioactive gas, you fucked up.
		else
			breather.radiation += trit_pp/10


	// Stimulum
	if (stimulum_pp)
		gas_breathed = breathe_gas_volume(breath_gases, /datum/gas/stimulum)
		if (gas_breathed > gas_stimulation_min)
			var/existing = breather.reagents.get_reagent_amount(/datum/reagent/stimulum)
			breather.reagents.add_reagent(/datum/reagent/stimulum, max(0, 5 - existing))
		REMOVE_MOLES(/datum/gas/stimulum, breath, gas_breathed)

	if(has_moles)
		handle_breath_temperature(breath, breather)
	breath.garbage_collect()

/// Remove a volume of gas from the breath. Used to simulate absorbtion and interchange of gas in the lungs.
/// Removes all of the given gas type unless given a volume argument.
/// Returns the amount of gas theoretically removed.
/obj/item/organ/lungs/proc/breathe_gas_volume(list/breath_gases, datum/gas/remove_gas, datum/gas/exchange_gas = null, volume = INFINITY)
	volume = min(volume, breath_gases[remove_gas][MOLES])
	breath_gases[remove_gas][MOLES] -= volume
	if(exchange_gas)
		breath_gases[exchange_gas][MOLES] += volume
	return volume

/// Applies suffocation side-effects to a given Human, scaling based on ratio of required pressure VS "true" pressure.
/// If pressure is greater than 0, the return value will represent the amount of gas successfully breathed.
/obj/item/organ/lungs/proc/handle_suffocation(mob/living/carbon/human/suffocator = null, breath_pp = 0, safe_breath_min = 0, true_pp = 0)
	. = 0
	// Can't suffocate without a Human, or without minimum breath pressure.
	if(!suffocator || !safe_breath_min)
		return
	// Mob is suffocating.
	suffocator.failed_last_breath = TRUE
	// Give them a chance to notice something is wrong.

	if(prob(20))
		suffocator.emote("gasp")
	// If mob is at critical health, check if they can be damaged further.
	if(suffocator.health < suffocator.crit_threshold)
		// Mob is immune to damage at critical health.
		if(HAS_TRAIT(suffocator, TRAIT_NOCRITDAMAGE))
			return
		// Reagents like Epinephrine stop suffocation at critical health.
		if(suffocator.reagents.has_reagent(crit_stabilizing_reagent, needs_metabolizing = TRUE))
			return
	// Low pressure.
	if(breath_pp)
		var/ratio = safe_breath_min / breath_pp
		suffocator.adjustOxyLoss(min(5 * ratio, HUMAN_MAX_OXYLOSS))
		return true_pp * ratio / 6
	// Zero pressure.
	if(suffocator.health >= suffocator.crit_threshold)
		suffocator.adjustOxyLoss(HUMAN_MAX_OXYLOSS)
	else
		suffocator.adjustOxyLoss(HUMAN_CRIT_MAX_OXYLOSS)

/obj/item/organ/lungs/proc/handle_breath_temperature(datum/gas_mixture/breath, mob/living/carbon/human/H) // called by human/life, handles temperatures
	var/breath_temperature = breath.return_temperature()

	if(!HAS_TRAIT(H, TRAIT_RESISTCOLD)) // COLD DAMAGE
		var/cold_modifier = H.dna.species.coldmod
		if(breath_temperature < cold_level_3_threshold)
			H.apply_damage_type(cold_level_3_damage*cold_modifier, cold_damage_type)
		if(breath_temperature > cold_level_3_threshold && breath_temperature < cold_level_2_threshold)
			H.apply_damage_type(cold_level_2_damage*cold_modifier, cold_damage_type)
		if(breath_temperature > cold_level_2_threshold && breath_temperature < cold_level_1_threshold)
			H.apply_damage_type(cold_level_1_damage*cold_modifier, cold_damage_type)
		if(breath_temperature < cold_level_1_threshold)
			if(prob(20))
				to_chat(H, "<span class='warning'>You feel [cold_message] in your [name]!</span>")

	if(!HAS_TRAIT(H, TRAIT_RESISTHEAT)) // HEAT DAMAGE
		var/heat_modifier = H.dna.species.heatmod
		if(breath_temperature > heat_level_1_threshold && breath_temperature < heat_level_2_threshold)
			H.apply_damage_type(heat_level_1_damage*heat_modifier, heat_damage_type)
		if(breath_temperature > heat_level_2_threshold && breath_temperature < heat_level_3_threshold)
			H.apply_damage_type(heat_level_2_damage*heat_modifier, heat_damage_type)
		if(breath_temperature > heat_level_3_threshold)
			H.apply_damage_type(heat_level_3_damage*heat_modifier, heat_damage_type)
		if(breath_temperature > heat_level_1_threshold)
			if(prob(20))
				to_chat(H, "<span class='warning'>You feel [hot_message] in your [name]!</span>")

	// The air you breathe out should match your body temperature
	breath.temperature = H.bodytemperature

/obj/item/organ/lungs/on_life()
	..()
	if((!failed) && ((organ_flags & ORGAN_FAILING)))
		if(owner.stat == CONSCIOUS)
			owner.visible_message("<span class='userdanger'>[owner] grabs [owner.p_their()] throat, struggling for breath!</span>")
		failed = TRUE
	else if(!(organ_flags & ORGAN_FAILING))
		failed = FALSE
	return

/obj/item/organ/lungs/get_availability(datum/species/S)
	return !(TRAIT_NOBREATH in S.species_traits)

/obj/item/organ/lungs/plasmaman
	name = "plasma filter"
	desc = "A spongy rib-shaped mass for filtering plasma from the air."
	icon_state = "lungs-plasma"

	breathing_class = BREATH_PLASMA

/obj/item/organ/lungs/plasmaman/populate_gas_info()
	..()
	gas_max -= /datum/breathing_class/plasma

/obj/item/organ/lungs/slime
	name = "vacuole"
	desc = "A large organelle designed to store oxygen and filter toxins."

/obj/item/organ/lungs/cybernetic
	name = "cybernetic lungs"
	desc = "A cybernetic version of the lungs found in traditional humanoid entities. Allows for greater intakes of oxygen than organic lungs, requiring slightly less pressure."
	icon_state = "lungs-c"
	organ_flags = ORGAN_SYNTHETIC
	status = ORGAN_ROBOTIC
	maxHealth = 1.1 * STANDARD_ORGAN_THRESHOLD
	safe_breath_min = 13
	safe_breath_max = 100

/obj/item/organ/lungs/cybernetic/emp_act()
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	owner.losebreath = 20


/obj/item/organ/lungs/cybernetic/upgraded
	name = "upgraded cybernetic lungs"
	desc = "A more advanced version of the stock cybernetic lungs. Features the ability to filter out lower levels of toxins and carbon dioxide."
	icon_state = "lungs-c-u"
	safe_breath_min = 4
	safe_breath_max = 250
	gas_max = list(
		/datum/gas/plasma = 30,
		/datum/gas/carbon_dioxide = 30
	)
	maxHealth = 2 * STANDARD_ORGAN_THRESHOLD

	cold_level_1_threshold = 200
	cold_level_2_threshold = 140
	cold_level_3_threshold = 100

/obj/item/organ/lungs/apid
	name = "apid lungs"
	desc = "Lungs from an apid, or beeperson. Thanks to the many spiracles an apid has, these lungs are capable of gathering more oxygen from low-pressure environments."
	icon_state = "lungs"
	safe_breath_min = 8

/obj/item/organ/lungs/ashwalker
	name = "ash walker lungs"
	desc = "Lungs belonging to the tribal group of lizardmen that have adapted to Lavaland's atmosphere, and thus can breathe its air safely but find the station's \
	air to be oversaturated with oxygen."
	safe_breath_min = 4
	safe_breath_max = 20
	gas_max = list(
		/datum/gas/carbon_dioxide = 45,
		/datum/gas/plasma = MOLES_GAS_VISIBLE
	)

/obj/item/organ/lungs/diona
	name = "diona leaves"
	desc = "A small mass concentrated leaves, used for breathing."
	icon_state = "diona_lungs"

#undef PP
#undef PP_MOLES

#undef BREATH_OXY
#undef BREATH_PLASMA
