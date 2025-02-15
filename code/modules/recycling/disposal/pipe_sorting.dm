// A three-way junction that sorts objects based on check_sorting(H) proc
// This is a base type, use subtypes on the map.
/obj/structure/disposalpipe/sorting
	name = "sorting disposal pipe"
	desc = "An underfloor disposal pipe with a sorting mechanism."
	icon_state = "pipe-j1s"
	initialize_dirs = DISP_DIR_RIGHT | DISP_DIR_FLIP

/obj/structure/disposalpipe/sorting/nextdir(obj/structure/disposalholder/H)
	var/sortdir = dpdir & ~(dir | turn(dir, 180))
	var/input_direction = dir
	// probably came from the negdir
	if(H.dir == input_direction)
		// if destination matches filtered type...
		if(check_sorting(H))
			H.unsorted = FALSE
			// exit through sortdirection
			return sortdir
	// If we are entering backwards, continue onwards
	if (H.dir == turn(input_direction, 180))
		return H.dir
	// go with the flow to positive direction
	return dir

// Sorting check, to be overridden in subtypes
/obj/structure/disposalpipe/sorting/proc/check_sorting(obj/structure/disposalholder/H)
	return FALSE



// Mail sorting junction, uses package tags to sort objects.
/obj/structure/disposalpipe/sorting/mail
	desc = "An underfloor disposal pipe that sorts wrapped objects based on their destination tags. Objects passing through it become sorted."
	flip_type = /obj/structure/disposalpipe/sorting/mail/flip
	var/sortType = 0
	// sortType is to be set in map editor.
	// Supports both singular numbers and strings of numbers similar to access level strings.
	// Look at the list called TAGGERLOCATIONS in /_globalvars/lists/flavor_misc.dm
	var/list/sortTypes = list()

/obj/structure/disposalpipe/sorting/mail/flip
	flip_type = /obj/structure/disposalpipe/sorting/mail
	icon_state = "pipe-j2s"
	initialize_dirs = DISP_DIR_LEFT | DISP_DIR_FLIP

/obj/structure/disposalpipe/sorting/mail/Initialize(mapload)
	. = ..()
	// Generate a list of soring tags.
	if(sortType)
		if(isnum_safe(sortType))
			sortTypes |= sortType
		else if(istext(sortType))
			var/list/sorts = splittext(sortType,";")
			for(var/x in sorts)
				var/n = text2num(x)
				if(n)
					sortTypes |= n

/obj/structure/disposalpipe/sorting/mail/examine(mob/user)
	. = ..()
	if(sortTypes.len)
		. += span_notice("It is tagged with the following tags:")
		for(var/t in sortTypes)
			. += "[span_notice("\t[GLOB.TAGGERLOCATIONS[t]]")]."
	else
		. += span_notice("It has no sorting tags set. You can use a destination tagger on it to set its sorting tags.")

/obj/structure/disposalpipe/sorting/mail/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/dest_tagger))
		var/obj/item/dest_tagger/O = I

		if(O.currTag)// Tagger has a tag set
			if(O.currTag in sortTypes)
				sortTypes -= O.currTag
				to_chat(user, span_notice("Removed \"[GLOB.TAGGERLOCATIONS[O.currTag]]\" filter."))
			else
				sortTypes |= O.currTag
				to_chat(user, span_notice("Added \"[GLOB.TAGGERLOCATIONS[O.currTag]]\" filter."))
			playsound(src, 'sound/machines/twobeep_high.ogg', 100, 1)
	else
		return ..()

/obj/structure/disposalpipe/sorting/mail/check_sorting(obj/structure/disposalholder/H)
	return (H.destinationTag in sortTypes)




// Wrap sorting junction, sorts objects destined for the mail office mail table (tomail = 1)
/obj/structure/disposalpipe/sorting/wrap
	name = "package sorting disposal pipe"
	desc = "An underfloor disposal pipe which sorts wrapped and unwrapped objects. Objects passing through it become sorted."
	flip_type = /obj/structure/disposalpipe/sorting/wrap/flip
	initialize_dirs = DISP_DIR_RIGHT | DISP_DIR_FLIP

/obj/structure/disposalpipe/sorting/wrap/check_sorting(obj/structure/disposalholder/H)
	return H.tomail

/obj/structure/disposalpipe/sorting/wrap/flip
	icon_state = "pipe-j2s"
	flip_type = /obj/structure/disposalpipe/sorting/wrap
	initialize_dirs = DISP_DIR_LEFT | DISP_DIR_FLIP

// Unsorted junction, will divert things based on whether or not they have been sorted.
/obj/structure/disposalpipe/sorting/unsorted
	name = "unsorted sorting disposal pipe"
	desc = "An underfloor disposal pipe which sorts sorted and unsorted objects. Objects passing through it become sorted."
	flip_type = /obj/structure/disposalpipe/sorting/unsorted/flip
	initialize_dirs = DISP_DIR_RIGHT | DISP_DIR_FLIP

/obj/structure/disposalpipe/sorting/unsorted/check_sorting(obj/structure/disposalholder/H)
	return H.unsorted && (H.destinationTag > 1 || H.tomail)

/obj/structure/disposalpipe/sorting/unsorted/flip
	icon_state = "pipe-j2s"
	flip_type = /obj/structure/disposalpipe/sorting/unsorted
	initialize_dirs = DISP_DIR_LEFT | DISP_DIR_FLIP

