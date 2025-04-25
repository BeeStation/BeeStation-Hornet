/obj/machinery/atmospherics/pipe
	icon = 'icons/obj/atmospherics/pipes/!pipes_bitmask.dmi'
	damage_deflection = 12
	/// Temporary holder for gases in the absence of a pipenet
	var/datum/gas_mixture/air_temporary
	/// The gas capacity this pipe contributes to a pipenet
	var/volume = 0

	use_power = NO_POWER_USE
	can_unwrench = 1
	/// The pipenet this pipe is a member of
	var/datum/pipenet/parent = null

	paintable = TRUE

	/// Determines if this pipe will be given gas visuals
	var/has_gas_visuals = TRUE

	//Buckling
	can_buckle = 1
	buckle_requires_restraints = 1
	buckle_lying = NO_BUCKLE_LYING

	vis_flags = VIS_INHERIT_PLANE

/obj/machinery/atmospherics/pipe/New()
	add_atom_colour(pipe_color, FIXED_COLOUR_PRIORITY)
	if(!volume) // Pipes can have specific volumes or have it determined by their device_type.
		volume = UNARY_PIPE_VOLUME * device_type
	..()

///I have no idea why there's a new and at this point I'm too afraid to ask
/obj/machinery/atmospherics/pipe/Initialize(mapload)
	. = ..()

	if(hide)
		AddElement(/datum/element/undertile, TRAIT_T_RAY_VISIBLE) //if changing this, change the subtypes RemoveElements too, because thats how bespoke works

/obj/machinery/atmospherics/pipe/on_deconstruction(disassembled)
	//we delete the parent here so it initializes air_temporary for us. See /datum/pipenet/Destroy() which calls temporarily_store_air()
	QDEL_NULL(parent)

	if(air_temporary)
		var/turf/T = loc
		T.assume_air(air_temporary)

	return ..()

/obj/machinery/atmospherics/proc/update_node_icon()
	for(var/i in 1 to device_type)
		if(nodes[i])
			var/obj/machinery/atmospherics/N = nodes[i]
			N.update_icon()

/obj/machinery/atmospherics/pipe/paint(paint_color)
	if(paintable)
		add_atom_colour(paint_color, FIXED_COLOUR_PRIORITY)
		pipe_color = paint_color
		update_node_icon()
	return paintable

/obj/machinery/atmospherics/pipe/Destroy()
	QDEL_NULL(parent)

	//releaseAirToTurf()

	var/turf/local_turf = loc
	for(var/obj/machinery/meter/meter in local_turf)
		if(meter.target != src)
			continue
		var/obj/item/pipe_meter/meter_object = new (local_turf)
		meter.transfer_fingerprints_to(meter_object)
		qdel(meter)
	return ..()

//-----------------
// PIPENET STUFF

/obj/machinery/atmospherics/pipe/nullify_node(i)
	var/obj/machinery/atmospherics/old_node = nodes[i]
	. = ..()
	if(old_node)
		SSair.add_to_rebuild_queue(old_node)

/obj/machinery/atmospherics/pipe/destroy_network()
	QDEL_NULL(parent)

/obj/machinery/atmospherics/pipe/get_rebuild_targets()
	if(!QDELETED(parent))
		return
	replace_pipenet(parent, new /datum/pipenet)
	return list(parent)

/obj/machinery/atmospherics/pipe/return_air()
	if(air_temporary)
		return air_temporary
	return parent.air

/obj/machinery/atmospherics/pipe/return_analyzable_air()
	if(air_temporary)
		return air_temporary
	return parent.air

/obj/machinery/atmospherics/pipe/remove_air(amount)
	if(air_temporary)
		return air_temporary.remove(amount)
	return parent.air.remove(amount)

/obj/machinery/atmospherics/pipe/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/pipe_meter))
		var/obj/item/pipe_meter/meter = item
		user.dropItemToGround(meter)
		meter.set_attach_layer(piping_layer)
	else
		return ..()

/obj/machinery/atmospherics/pipe/return_pipenet()
	return parent

/obj/machinery/atmospherics/pipe/replace_pipenet(datum/pipenet/old_pipenet, datum/pipenet/new_pipenet)
	if(parent && has_gas_visuals)
		vis_contents -= parent.GetGasVisual('icons/obj/atmospherics/pipes/!pipe_gas_overlays.dmi')

	parent = new_pipenet

	if(parent && has_gas_visuals) // null is a valid argument here
		vis_contents += parent.GetGasVisual('icons/obj/atmospherics/pipes/!pipe_gas_overlays.dmi')

/obj/machinery/atmospherics/pipe/return_pipenets()
	. = list(parent)

//--------------------
// APPEARANCE STUFF

/obj/machinery/atmospherics/pipe/update_icon()
	update_pipe_icon()
	update_layer()
	return ..()

/obj/machinery/atmospherics/pipe/proc/update_pipe_icon()
	switch(initialize_directions)
		if(NORTH, EAST, SOUTH, WEST) // Pipes with only a single connection aren't handled by this system
			icon = null
			return
		else
			icon = 'icons/obj/atmospherics/pipes/!pipes_bitmask.dmi'
	var/connections = NONE
	var/bitfield = NONE
	for(var/i in 1 to device_type)
		if(!nodes[i])
			continue
		var/obj/machinery/atmospherics/node = nodes[i]
		var/connected_dir = get_dir(src, node)
		connections |= connected_dir
	bitfield = CARDINAL_TO_FULLPIPES(connections)
	bitfield |= CARDINAL_TO_SHORTPIPES(initialize_directions & ~connections)
	icon_state = "[bitfield]_[piping_layer]"

/obj/machinery/atmospherics/pipe/update_layer()
	layer = (HAS_TRAIT(src, TRAIT_T_RAY_VISIBLE) ? ABOVE_OPEN_TURF_LAYER : initial(layer)) + (piping_layer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_LCHANGE + (GLOB.pipe_colors_ordered[pipe_color] * 0.0001)
