/obj/machinery/atmospherics/pipe
	var/datum/gas_mixture/air_temporary //used when reconstructing a pipeline that broke
	var/volume = 0

	use_power = NO_POWER_USE
	can_unwrench = 1
	var/datum/pipeline/parent = null
	paintable = TRUE

	//Buckling
	can_buckle = 1
	buckle_requires_restraints = 1
	buckle_lying = -1

	FASTDMM_PROP(\
		set_instance_vars(\
			icon_state = INSTANCE_VAR_DEFAULT\
        ),\
    )

/obj/machinery/atmospherics/pipe/New()
	log_debug("[get_obj_info()]new pipe created")
	add_atom_colour(pipe_color, FIXED_COLOUR_PRIORITY)
	volume = 35 * device_type
	..()

///I have no idea why there's a new and at this point I'm too afraid to ask
/obj/machinery/atmospherics/pipe/Initialize(mapload)
	. = ..()

	if(hide)
		AddElement(/datum/element/undertile, TRAIT_T_RAY_VISIBLE)
	log_debug("[get_obj_info()]new pipe initialized")

/obj/machinery/atmospherics/pipe/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[src] is on layer [piping_layer].</span>"

/obj/machinery/atmospherics/pipe/nullifyNode(i)
	log_debug("[get_obj_info()] pro call: nullifyNode([i]) -- pipe")
	var/obj/machinery/atmospherics/oldN = nodes[i]
	..()
	if(oldN)
		SSair.add_to_rebuild_queue(oldN)
	log_debug("[get_obj_info()] pro escape: nullifyNode([i]) -- pipe")

/obj/machinery/atmospherics/pipe/destroy_network()
	log_debug("[get_obj_info()]proc call: destroy_network() -- parent qdelnull")
	QDEL_NULL(parent)
	log_debug("[get_obj_info()]proc escape: destroy_network()")

/obj/machinery/atmospherics/pipe/build_network()
	log_debug("[get_obj_info()]proc call: build_network()")
	if(QDELETED(parent))
		log_debug("[get_obj_info()]build_network() has no parent")
		parent = new
		parent.build_pipeline(src)
	log_debug("[get_obj_info()]proc escape: build_network()")

/obj/machinery/atmospherics/pipe/proc/releaseAirToTurf()
	if(air_temporary)
		var/turf/T = loc
		T.assume_air(air_temporary)
		air_update_turf()

/obj/machinery/atmospherics/pipe/return_air()
	if(parent)
		return parent.air

/obj/machinery/atmospherics/pipe/return_analyzable_air()
	if(parent)
		return parent.air

/obj/machinery/atmospherics/pipe/remove_air(amount)
	return parent.air.remove(amount)

/obj/machinery/atmospherics/pipe/remove_air_ratio(ratio)
	return parent.air.remove_ratio(ratio)

/obj/machinery/atmospherics/pipe/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/pipe_meter))
		var/obj/item/pipe_meter/meter = W
		user.dropItemToGround(meter)
		meter.setAttachLayer(piping_layer)
	else
		return ..()

/obj/machinery/atmospherics/pipe/returnPipenet()
	if(parent)
		return parent.air

/obj/machinery/atmospherics/pipe/setPipenet(datum/pipeline/P)
	log_debug("[get_obj_info()]proc call: setPipenet() / refs: src [FAST_REF(src)] / pipe P [FAST_REF(P)]")
	parent = P
	log_debug("[get_obj_info()]proc escape: setPipenet()")

/obj/machinery/atmospherics/pipe/Destroy()
	log_debug("[get_obj_info()]proc call: Destroy() -- parent qdelnull")
	QDEL_NULL(parent)

	releaseAirToTurf()
	QDEL_NULL(air_temporary)

	var/turf/T = loc
	for(var/obj/machinery/meter/meter in T)
		if(meter.target == src)
			var/obj/item/pipe_meter/PM = new (T)
			meter.transfer_fingerprints_to(PM)
			qdel(meter)
	log_debug("[get_obj_info()]proc parent: Destroy()")
	. = ..()
	log_debug("[get_obj_info()]proc escape: Destroy()")

/obj/machinery/atmospherics/pipe/proc/update_node_icon()
	for(var/i in 1 to device_type)
		if(nodes[i])
			var/obj/machinery/atmospherics/N = nodes[i]
			N.update_icon()

/obj/machinery/atmospherics/pipe/returnPipenets()
	log_debug("[get_obj_info()]proc call: returnPipenets()")
	. = list(parent)
	log_debug("[get_obj_info()]proc escape: returnPipenets()")

/obj/machinery/atmospherics/pipe/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(damage_flag == MELEE && damage_amount < 12)
		return 0
	. = ..()

/obj/machinery/atmospherics/pipe/paint(paint_color)
	if(paintable)
		add_atom_colour(paint_color, FIXED_COLOUR_PRIORITY)
		pipe_color = paint_color
		update_node_icon()
	return paintable

/obj/machinery/atmospherics/pipe/check_parent()
	if(!parent)
		return " / info: parent removed"
	else if(QDELING(parent) || QDESTROYING(parent))
		return " / info: parent under qdel"
