/**
 * # Mecha acid
 *
 * Xeno Corrosive Acid on a mech. Mechs are acid-proof, so this bypasses acid_act() entirely.
 * Every dose burns MECHA_ACID_DOSE_FRACTION of the mech's max integrity over MECHA_ACID_BURN_SECONDS,
 * ignoring armor, and may break one of its systems. Washing the mech (CLEAN_TYPE_ACID) neutralizes it.
 *
 * The smear always outlasts the burn and every dose resets it, so while this component exists
 * every occupant has the smear and the "Acid on Hull" alert.
 */
/datum/component/mecha_acid
	// PASSARGS: never build a throwaway duplicate that registers on and unregisters from the mech
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// Damage each burning dose still has to deal, one entry per dose
	var/list/doses = list()
	/// Seconds left before the pilots' optics clear
	var/smear_seconds_left = 0

/datum/component/mecha_acid/Initialize()
	if(!ismecha(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/mecha_acid/RegisterWithParent()
	var/obj/vehicle/sealed/mecha/mech = parent
	RegisterSignal(mech, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_wash))
	RegisterSignal(mech, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(mech, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))
	RegisterSignal(mech, COMSIG_VEHICLE_OCCUPANT_ADDED, PROC_REF(on_occupant_added))
	RegisterSignal(mech, COMSIG_VEHICLE_OCCUPANT_REMOVED, PROC_REF(on_occupant_removed))
	for(var/mob/occupant as anything in mech.occupants)
		apply_to_occupant(occupant)
	START_PROCESSING(SSprocessing, src)

/datum/component/mecha_acid/UnregisterFromParent()
	var/obj/vehicle/sealed/mecha/mech = parent
	UnregisterSignal(mech, list(
		COMSIG_COMPONENT_CLEAN_ACT,
		COMSIG_ATOM_EXAMINE,
		COMSIG_ATOM_UPDATE_OVERLAYS,
		COMSIG_VEHICLE_OCCUPANT_ADDED,
		COMSIG_VEHICLE_OCCUPANT_REMOVED,
	))
	for(var/mob/occupant as anything in mech.occupants)
		clear_from_occupant(occupant)
	if(!QDELETED(mech))
		mech.update_appearance(UPDATE_OVERLAYS)

/datum/component/mecha_acid/Destroy(force)
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/// Adds one dose of acid. Returns TRUE if the dose broke one of the mech's systems.
/datum/component/mecha_acid/proc/add_dose()
	var/obj/vehicle/sealed/mecha/mech = parent
	doses += CEILING(mech.max_integrity * MECHA_ACID_DOSE_FRACTION, 1)
	smear_seconds_left = MECHA_ACID_SMEAR_SECONDS
	mech.update_appearance(UPDATE_OVERLAYS)
	to_chat(mech.occupants, span_userdanger("Acid sears across the hull and smears your optics!"))
	if(!prob(MECHA_ACID_FAILURE_CHANCE))
		return FALSE
	return break_system()

/// Breaks one random system the mech can lose and hasn't lost yet. Returns TRUE if one broke.
/datum/component/mecha_acid/proc/break_system()
	var/obj/vehicle/sealed/mecha/mech = parent
	var/available = mech.possible_int_damage & ~mech.internal_damage
	if(!available)
		return FALSE
	var/flag = pick(bitfield_to_list(available))
	mech.set_internal_damage(flag)
	to_chat(mech.occupants, span_userdanger("Acid eats into the [system_name(flag)]!"))
	return TRUE

/// Pilot-facing name of the system a MECHA_INT_* flag stands for.
/datum/component/mecha_acid/proc/system_name(flag)
	switch(flag)
		if(MECHA_INT_FIRE)
			return "internal wiring"
		if(MECHA_INT_TEMP_CONTROL)
			return "temperature regulator"
		if(MECHA_CABIN_AIR_BREACH)
			return "cabin seals"
		if(MECHA_INT_CONTROL_LOST)
			return "coordination servos"
	return "internal systems"

/// How many doses are still burning.
/datum/component/mecha_acid/proc/dose_count()
	return length(doses)

/datum/component/mecha_acid/process(delta_time)
	var/obj/vehicle/sealed/mecha/mech = parent
	smear_seconds_left = max(smear_seconds_left - delta_time, 0)
	var/had_doses = length(doses)
	// Whole numbers only, so four doses always add up to at least max_integrity.
	var/burn_per_dose = CEILING(mech.max_integrity * MECHA_ACID_DOSE_FRACTION / MECHA_ACID_BURN_SECONDS * delta_time, 1)
	var/total_burn = 0
	for(var/i = length(doses), i >= 1, i--)
		var/burn = min(doses[i], burn_per_dose)
		total_burn += burn
		doses[i] -= burn
		if(doses[i] <= 0)
			doses.Cut(i, i + 1)
	if(total_burn)
		// damage_flag 0: acid ignores armor. No attack_dir: no facing modifier.
		mech.take_damage(total_burn, BURN, 0, FALSE)
		if(QDELETED(src)) // the acid destroyed the mech, and us with it
			return PROCESS_KILL
	if(had_doses && !length(doses))
		mech.update_appearance(UPDATE_OVERLAYS)
	if(!length(doses) && !smear_seconds_left)
		qdel(src)
		return PROCESS_KILL

/// Smears an occupant's view and shows them the "Acid on Hull" alert.
/datum/component/mecha_acid/proc/apply_to_occupant(mob/occupant)
	occupant.overlay_fullscreen(FULLSCREEN_MECHA_ACID, /atom/movable/screen/fullscreen/impaired, 2)
	occupant.throw_alert(ALERT_MECH_ACID, /atom/movable/screen/alert/mech_acid)

/// Clears the smear and the alert from an occupant.
/datum/component/mecha_acid/proc/clear_from_occupant(mob/occupant)
	occupant.clear_fullscreen(FULLSCREEN_MECHA_ACID)
	occupant.clear_alert(ALERT_MECH_ACID)

/datum/component/mecha_acid/proc/on_occupant_added(datum/source, mob/occupant)
	SIGNAL_HANDLER
	apply_to_occupant(occupant)

/datum/component/mecha_acid/proc/on_occupant_removed(datum/source, mob/occupant)
	SIGNAL_HANDLER
	clear_from_occupant(occupant)

/datum/component/mecha_acid/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(!length(doses))
		examine_list += span_warning("Its optics are smeared with acid residue. Washing will clear them.")
		return
	examine_list += span_danger("It's coated in bubbling alien acid that is eating through its hull! Wash it off with space cleaner, soap, foam or a shower.")
	if(isalien(user))
		examine_list += span_alertalien("[length(doses)] dose\s of our acid [length(doses) == 1 ? "is" : "are"] eating it. Four doses will melt it.")

/datum/component/mecha_acid/proc/on_update_overlays(atom/source, list/overlays)
	SIGNAL_HANDLER
	if(length(doses))
		overlays += GLOB.acid_overlay

/datum/component/mecha_acid/proc/on_wash(datum/source, clean_types)
	SIGNAL_HANDLER
	if(!(clean_types & CLEAN_TYPE_ACID))
		return NONE
	var/obj/vehicle/sealed/mecha/mech = parent
	to_chat(mech.occupants, span_notice("The acid is washed away and your optics clear."))
	qdel(src)
	return COMPONENT_CLEANED
