// This is where the fun begins.
// These are the main datums that emit light.

/datum/light_source
	var/atom/source_atom     // The atom that we belong to.
	var/atom/movable/contained_atom		//The atom that the source atom is contained inside
	var/atom/cached_loc	//The loc where we were

	var/turf/source_turf     // The turf under the above.
	var/turf/pixel_turf      // The turf the top_atom appears to over.
	var/light_power = 0    					// Intensity of the emitter light.
	var/light_range = 0      				// The range of the emitted light.
	var/light_color = NONSENSICAL_VALUE    // The colour of the light, string, decomposed by parse_light_color()

	var/applied = FALSE // Whether we have applied our light yet or not.

	var/mask_type
	var/atom/movable/lighting_mask/our_mask

/datum/light_source/New(var/atom/movable/owner, mask_type)
	source_atom = owner // Set our new owner.
	LAZYADD(source_atom.light_sources, src)

	//Find the atom that contains us
	find_containing_atom()

	source_turf = get_turf(source_atom)

	if(!mask_type)
		mask_type = /atom/movable/lighting_mask
	src.mask_type = mask_type
	our_mask = new mask_type(source_turf)
	our_mask.attached_atom = owner
	set_light(owner.light_range, owner.light_power, owner.light_color)

	SSlighting.light_sources += src

/datum/light_source/Destroy(...)
	SSlighting.light_sources -= src
	//Remove references to ourself.
	LAZYREMOVE(source_atom?.light_sources, src)
	LAZYREMOVE(contained_atom?.light_sources, src)
	qdel(our_mask)
	. = ..()

/datum/light_source/proc/find_containing_atom()
	//we are still in the same place, no action required
	if(source_atom.loc == cached_loc)
		return
	//Store the loc so we know when we actually need to update
	cached_loc = source_atom.loc
	//Remove ourselves from the old containing atoms light sources
	if(contained_atom && contained_atom != source_atom)
		LAZYREMOVE(contained_atom.light_sources, src)
	//Find our new container
	if(isturf(source_atom) || isarea(source_atom))
		contained_atom = source_atom
		return
	contained_atom = source_atom.loc
	for(var/sanity in 1 to 20)
		if(!contained_atom)
			//Welcome to nullspace my friend.
			contained_atom = source_atom
			return
		if(istype(contained_atom.loc, /turf))
			break
		contained_atom = contained_atom.loc
	//Add ourselves to their light sources
	if(contained_atom != source_atom)
		LAZYADD(contained_atom.light_sources, src)

//Update light if changed.
/datum/light_source/proc/set_light(var/l_range, var/l_power, var/l_color = NONSENSICAL_VALUE)
	if(!our_mask)
		return
	if(l_range && l_range != light_range)
		light_range = l_range
		our_mask.set_radius(l_range)
	if(l_power && l_power != light_power)
		light_power = l_power
		our_mask.set_intensity(l_power)
	if(l_color != NONSENSICAL_VALUE && l_color != light_color)
		light_color = l_color
		our_mask.set_colour(l_color)

/datum/light_source/proc/update_position()
	our_mask?.forceMove(get_turf(source_atom))
	find_containing_atom()
