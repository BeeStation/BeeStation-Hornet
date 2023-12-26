/proc/WEAKREF(datum/input)
	if(istype(input) && !QDELETED(input))
		if(istype(input, /datum/weakref))
			return input

		if(!input.weak_reference)
			input.weak_reference = new /datum/weakref(input)
		return input.weak_reference

/datum/proc/create_weakref()		//Forced creation for admin proccalls
	return WEAKREF(src)

/datum/weakref
	var/reference

	/*
		variables to store some helpful information by opening vv window
		"aa_" makes them placed at top, so we can see it at glance.
	*/
	var/aa0_hint_ref_path
	var/aa1_hint_ref_creation_worldtime

/datum/weakref/New(datum/thing)
	reference = REF(thing)
	aa1_hint_ref_creation_worldtime = world.time
	if(istype(thing))
		aa0_hint_ref_path = thing.type

/datum/weakref/Destroy(force)
	var/datum/target = resolve()
	qdel(target)
	if(!force)
		return QDEL_HINT_LETMELIVE	//Let BYOND autoGC thiswhen nothing is using it anymore.
	target?.weak_reference = null
	return ..()

/datum/weakref/proc/resolve()
	var/datum/D = locate(reference)
	return (!QDELETED(D) && D.weak_reference == src) ? D : null

/datum/weakref/vv_get_dropdown()
	. = list()
	VV_DROPDOWN_OPTION(VV_HK_TRACK_REF, "View the original reference")
	. += ..()

/datum/weakref/vv_do_topic(list/href_list)
	. = ..()

	if(href_list[VV_HK_TRACK_REF])
		var/datum/original = resolve()
		if(!original)
			to_chat(usr, "<span class='warning'>Failed to resolve. It might be qdeleted already.</span>")
			return
		usr.client.debug_variables(original)
