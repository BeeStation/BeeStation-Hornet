/**
  * Internal atom that copies an appearance on to the blocker plane
  *
  * Copies an appearance vis render_target and render_source on to the emissive blocking plane.
  * This means that the atom in question will block any emissive sprites.
  * This should only be used internally. If you are directly creating more of these, you're
  * almost guaranteed to be doing something wrong.
  */
/atom/movable/emissive_blocker
	name = ""
	plane = EMISSIVE_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	//Why?
	//render_targets copy the transform of the target as well, but vis_contents also applies the transform
	//to what's in it. Applying RESET_TRANSFORM here makes vis_contents not apply the transform.
	//Since only render_target handles transform we don't get any applied transform "stacking"
	appearance_flags = EMISSIVE_APPEARANCE_FLAGS

/atom/movable/emissive_blocker/Initialize(mapload, source)
	. = ..()
	verbs.Cut() //Cargo culting from lighting object, this maybe affects memory usage?

	render_source = source
	// Set the colour to be more opaque meaning more black.
	color = GLOB.em_blocker_matrix
	// Join the layer of our source object, so that we can respect layering
	layer = loc.layer

/atom/movable/emissive_blocker/ex_act(severity)
	return FALSE

/atom/movable/emissive_blocker/singularity_act()
	return

/atom/movable/emissive_blocker/singularity_pull()
	return

/atom/movable/emissive_blocker/blob_act()
	return

/atom/movable/emissive_blocker/onTransitZ()
	return

//Prevents people from moving these after creation, because they shouldn't be.
/atom/movable/emissive_blocker/forceMove(atom/destination, no_tp=FALSE, harderforce = FALSE)
	if(harderforce)
		return ..()
