/**
 * # Xeno snare
 *
 * Resin gumming up a mech's legs. While attached, the mech is TRAIT_MECHA_ROOTED:
 * it can't step or turn, but its weapons still fire within its facing arc.
 * Strength is counted in seconds of hold. It dries out on its own, and every move
 * the pilot tries tears some of it away. Washing does not dissolve resin.
 */
/datum/component/xeno_snare
	// PASSARGS: a throwaway duplicate would remove TRAIT_MECHA_ROOTED from our source on its way out
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// Seconds of hold left if the pilot never struggles
	var/strength = XENO_SNARE_HOLD_SECONDS
	/// Resin strands drawn over the mech
	var/mutable_appearance/resin_overlay
	COOLDOWN_DECLARE(struggle_cooldown)

/datum/component/xeno_snare/Initialize()
	if(!ismecha(parent))
		return COMPONENT_INCOMPATIBLE
	resin_overlay = mutable_appearance('icons/mob/alien.dmi', "nestoverlay")

/datum/component/xeno_snare/InheritComponent(datum/component/new_component, i_am_original)
	strength = XENO_SNARE_HOLD_SECONDS

/datum/component/xeno_snare/RegisterWithParent()
	var/obj/vehicle/sealed/mecha/mech = parent
	ADD_TRAIT(mech, TRAIT_MECHA_ROOTED, XENO_SNARE_TRAIT)
	RegisterSignal(mech, COMSIG_MECHA_ROOTED_MOVE_ATTEMPT, PROC_REF(on_struggle))
	RegisterSignal(mech, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(mech, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))
	RegisterSignal(mech, COMSIG_VEHICLE_OCCUPANT_ADDED, PROC_REF(on_occupant_added))
	RegisterSignal(mech, COMSIG_VEHICLE_OCCUPANT_REMOVED, PROC_REF(on_occupant_removed))
	for(var/mob/occupant as anything in mech.occupants)
		occupant.throw_alert(ALERT_MECH_SNARED, /atom/movable/screen/alert/mech_snared)
	mech.update_appearance(UPDATE_OVERLAYS)
	START_PROCESSING(SSprocessing, src)

/datum/component/xeno_snare/UnregisterFromParent()
	var/obj/vehicle/sealed/mecha/mech = parent
	REMOVE_TRAIT(mech, TRAIT_MECHA_ROOTED, XENO_SNARE_TRAIT)
	UnregisterSignal(mech, list(
		COMSIG_MECHA_ROOTED_MOVE_ATTEMPT,
		COMSIG_ATOM_EXAMINE,
		COMSIG_ATOM_UPDATE_OVERLAYS,
		COMSIG_VEHICLE_OCCUPANT_ADDED,
		COMSIG_VEHICLE_OCCUPANT_REMOVED,
	))
	for(var/mob/occupant as anything in mech.occupants)
		occupant.clear_alert(ALERT_MECH_SNARED)
	if(!QDELETED(mech))
		mech.update_appearance(UPDATE_OVERLAYS)

/datum/component/xeno_snare/Destroy(force)
	STOP_PROCESSING(SSprocessing, src)
	resin_overlay = null
	return ..()

/datum/component/xeno_snare/process(delta_time)
	weaken(delta_time)

/// Removes some of the snare's hold, and frees the mech once none is left.
/datum/component/xeno_snare/proc/weaken(amount)
	strength -= amount
	if(strength > 0)
		return
	var/obj/vehicle/sealed/mecha/mech = parent
	to_chat(mech.occupants, span_notice("You tear free of the resin!"))
	qdel(src)

/datum/component/xeno_snare/proc/on_struggle(datum/source, direction)
	SIGNAL_HANDLER
	if(!COOLDOWN_FINISHED(src, struggle_cooldown))
		return
	COOLDOWN_START(src, struggle_cooldown, XENO_SNARE_STRUGGLE_COOLDOWN)
	// Audible to everyone nearby, so both sides can hear the mech working itself loose
	playsound(parent, 'sound/effects/attackblob.ogg', 50, TRUE)
	weaken(XENO_SNARE_STRUGGLE_STRENGTH)

/datum/component/xeno_snare/proc/on_occupant_added(datum/source, mob/occupant)
	SIGNAL_HANDLER
	occupant.throw_alert(ALERT_MECH_SNARED, /atom/movable/screen/alert/mech_snared)

/datum/component/xeno_snare/proc/on_occupant_removed(datum/source, mob/occupant)
	SIGNAL_HANDLER
	occupant.clear_alert(ALERT_MECH_SNARED)

/datum/component/xeno_snare/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_warning("It's stuck fast in a mass of hardened resin! Its pilot can struggle free by trying to move, or wait for the resin to dry.")
	if(isalien(user))
		examine_list += span_alertalien("Our resin holds it. It cannot move or turn.")

/datum/component/xeno_snare/proc/on_update_overlays(atom/source, list/overlays)
	SIGNAL_HANDLER
	overlays += resin_overlay
