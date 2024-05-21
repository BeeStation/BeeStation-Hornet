/**
 * ## series element!
 *
 * bespoke element that assigns a series number to toys on examine, and shows their series name!
 * used for mechas and rare collectable hats, should totally be used for way more ;)
 */
/datum/element/series
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH
	id_arg_index = 2
	var/list/subtype_list
	var/series_name

/datum/element/series/Attach(datum/target, subtype, series_name)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE
	if(!subtype)
		stack_trace("series element without subtype given!")
		return ELEMENT_INCOMPATIBLE
	subtype_list = subtypesof(subtype)
	src.series_name = series_name
	var/atom/attached = target
	RegisterSignal(attached, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

/datum/element/series/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_PARENT_EXAMINE)

///signal called examining
/datum/element/series/proc/on_examine(datum/target, mob/user, list/examine_list)
	var/series_number = subtype_list.Find(target.type)
	examine_list += "<span class='boldnotice'>[target] is part of the \"[series_name]\" series!</span>"
	examine_list += "<span class='notice'>Collect them all: [series_number]/[length(subtype_list)].</span>"
