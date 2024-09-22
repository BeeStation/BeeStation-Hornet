/**
 * Component that allows an object to register for fallthrough interactions,
 * that is when an item interaction finds nothing to interact with, it will
 * interact with anything registered to the turf as a fallthrough interaction.
 *
 * This is used for multitools on turfs to analyse wires, for example.
 */
/datum/component/interaction_fallthrough
	var/priority = 0

/datum/component/interaction_fallthrough/New(priority)
	. = ..()
	src.priority = priority

/datum/component/interaction_fallthrough/RegisterWithParent()
	. = ..()
	if (!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	var/atom/atom_source = parent
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(parent_moved))
	RegisterSignal(atom_source.loc, COMSIG_TURF_ATTACK_FALLTHROUGH, PROC_REF(attack_fallthrough))

/datum/component/interaction_fallthrough/UnregisterFromParent()
	. = ..()
	if (!isatom(source))
		CRASH("An interaction fallthrough element somehow ended up on a /datum!")
	var/atom/atom_source = source
	UnregisterSignal(atom_source, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(atom_source.loc, COMSIG_TURF_ATTACK_FALLTHROUGH)

/datum/component/interaction_fallthrough/proc/parent_moved(atom/source, atom/oldloc, dir, forced)
	UnregisterSignal(oldloc, COMSIG_TURF_ATTACK_FALLTHROUGH)
	RegisterSignal(source.loc, COMSIG_TURF_ATTACK_FALLTHROUGH, PROC_REF(attack_fallthrough))

/datum/component/interaction_fallthrough/proc/attack_fallthrough(turf/source, mob/living/user, obj/item/item, atom/target, params, datum/fallthrough_reference/target_pointer)
	if (target_pointer.priority > priority)
		return
	target_pointer.priority = priority
	target_pointer.target = parent
