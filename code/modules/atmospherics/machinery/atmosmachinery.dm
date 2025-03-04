// Quick overview:
//
// Pipes combine to form pipenets
// Pipenets and other atmospheric objects combine to form pipe_networks
//   Note: A single pipe_network represents a completely open space
//
// Pipes -> Pipenets
// Pipenets + Other Objects -> Pipe network

#define PIPE_VISIBLE_LEVEL 2
#define PIPE_HIDDEN_LEVEL 1

/obj/machinery/atmospherics
	anchored = TRUE
	move_resist = INFINITY				//Moving a connected machine without actually doing the normal (dis)connection things will probably cause a LOT of issues.  (this imply moving machines with something that can push turfs like a megafauna)
	idle_power_usage = 0
	active_power_usage = 0
	power_channel = AREA_USAGE_ENVIRON
	layer = GAS_PIPE_HIDDEN_LAYER //under wires
	armor_type = /datum/armor/machinery_atmospherics
	resistance_flags = FIRE_PROOF
	max_integrity = 200
	obj_flags = CAN_BE_HIT | ON_BLUEPRINTS
	flags_1 = STAT_UNIQUE_1
	///Check if the object can be unwrenched
	var/can_unwrench = FALSE
	///Bitflag of the initialized directions (NORTH | SOUTH | EAST | WEST)
	var/initialize_directions = NONE
	///The color of the pipe
	var/pipe_color = COLOR_VERY_LIGHT_GRAY
	///What layer the pipe is in (from 1 to 5, default 3)
	var/piping_layer = PIPING_LAYER_DEFAULT
	///The flags of the pipe/component (PIPING_ALL_LAYER | PIPING_ONE_PER_TURF | PIPING_DEFAULT_LAYER_ONLY | PIPING_CARDINAL_AUTONORMALIZE)
	var/pipe_flags = NONE

	///This only works on pipes, because they have 1000 subtypes which need to be visible and invisible under tiles, so we track this here
	var/hide = TRUE

	///The image of the pipe/device used for ventcrawling
	var/image/pipe_vision_img = null

	///The type of the device (UNARY, BINARY, TRINARY, QUATERNARY)
	var/device_type = NONE
	///The lists of nodes that a pipe/device has, depends on the device_type var (from 1 to 4)
	var/list/obj/machinery/atmospherics/nodes

	///The path of the pipe/device that will spawn after unwrenching it (such as pipe fittings)
	var/construction_type
	///icon_state as a pipe item
	var/pipe_state
	///Check if the device should be on or off (mostly used in processing for machines)
	var/on = FALSE///Whether it can be painted
	var/paintable = TRUE

	///Is the thing being rebuilt by SSair or not. Prevents list bloat
	var/rebuilding = FALSE

	///The bitflag that's being checked on ventcrawling. Default is to allow ventcrawling and seeing pipes.
	var/vent_movement = VENTCRAWL_ALLOWED | VENTCRAWL_CAN_SEE

	///keeps the name of the object from being overridden if it's vareditted.
	var/override_naming

	///If we should init and immediately start processing
	var/init_processing = FALSE

/datum/armor/machinery_atmospherics
	melee = 25
	bullet = 10
	laser = 10
	energy = 100
	rad = 100
	fire = 100
	acid = 70

/obj/machinery/atmospherics/LateInitialize()
	. = ..()
	update_name()

/obj/machinery/atmospherics/examine(mob/user)
	. = ..()
	. += span_notice("[src] is on layer [piping_layer].")
	if(is_type_in_list(src, GLOB.ventcrawl_machinery) && isliving(user))
		var/mob/living/L = user
		if(L.ventcrawler)
			. += span_notice("Alt-click to crawl through it.")

/obj/machinery/atmospherics/New(loc, process = TRUE, setdir, init_dir = ALL_CARDINALS)
	if(!isnull(setdir))
		setDir(setdir)
	if(pipe_flags & PIPING_CARDINAL_AUTONORMALIZE)
		normalize_cardinal_directions()
	nodes = new(device_type)
	init_processing = process
	..()
	set_init_directions(init_dir)

/obj/machinery/atmospherics/Initialize(mapload)
	if(mapload && name != initial(name))
		override_naming = TRUE
	if(init_processing)
		SSair.start_processing_machine(src)
	return ..()

/obj/machinery/atmospherics/Destroy()
	for(var/i in 1 to device_type)
		nullify_node(i)

	SSair.stop_processing_machine(src)
	SSair.rebuild_queue -= src

	QDEL_NULL(pipe_vision_img)

	return ..()

/**
 * Run when you update the conditions in which an /atom might want to start reacting to its turf's air
 */
/atom/proc/atmos_conditions_changed()
	return

/atom/movable/atmos_conditions_changed()
	var/turf/open/open_loc = loc
	if(!isopenturf(open_loc))
		return
	var/datum/gas_mixture/turf_gas = open_loc.air
	if(isnull(turf_gas))
		return
	check_atmos_process(open_loc, turf_gas, turf_gas.temperature)

/turf/open/atmos_conditions_changed()
	if(isnull(air))
		return
	check_atmos_process(src, air, air.temperature)

/**
 * Called by the machinery disconnect(), custom for each type
 */
/obj/machinery/atmospherics/proc/destroy_network()
	return

/obj/machinery/atmospherics/proc/set_on(active)
	on = active
	SEND_SIGNAL(src, COMSIG_ATMOS_MACHINE_SET_ON, on)

/// This should only be called by SSair as part of the rebuild queue.
/// Handles rebuilding pipenets after init or they've been changed.
/obj/machinery/atmospherics/proc/rebuild_pipes()
	var/list/targets = get_rebuild_targets()
	rebuilding = FALSE
	for(var/datum/pipenet/build_off as anything in targets)
		build_off.build_pipenet(src) //This'll add to the expansion queue

/**
 * Returns a list of new pipenets that need to be built up
 */
/obj/machinery/atmospherics/proc/get_rebuild_targets()
	return

/**
 * Called on destroy(mostly deconstruction) and when moving nodes around, disconnect the nodes from the network
 * Arguments:
 * * i - is the current iteration of the node, based on the device_type (from 1 to 4)
 */
/obj/machinery/atmospherics/proc/nullify_node(i)
	if(!nodes[i])
		return
	var/obj/machinery/atmospherics/node_machine = nodes[i]
	node_machine.disconnect(src)
	nodes[i] = null

/**
 * Getter for node_connects
 *
 * Return a list of the nodes that can connect to other machines, get called by atmos_init()
 */
/obj/machinery/atmospherics/proc/get_node_connects()
	var/list/node_connects[device_type] //empty list of size device_type

	var/init_directions = get_init_directions()
	for(var/i in 1 to device_type)
		for(var/direction in GLOB.cardinals)
			if(!(direction & init_directions))
				continue
			if(direction in node_connects)
				continue
			node_connects[i] = direction
			break

	return node_connects

/**
 * Setter for device direction
 *
 * Set the direction to either SOUTH or WEST if the pipe_flag is set to PIPING_CARDINAL_AUTONORMALIZE, called in New(), used mostly by layer manifolds
 */
/obj/machinery/atmospherics/proc/normalize_cardinal_directions()
	switch(dir)
		if(SOUTH)
			setDir(NORTH)
		if(WEST)
			setDir(EAST)


/**
 * Initialize for atmos devices
 *
 * initialize the nodes for each pipe/device, this is called just after the air controller sets up turfs
 * Arguments:
 * * list/node_connects - a list of the nodes on the device that can make a connection to other machines
 */
/obj/machinery/atmospherics/proc/atmos_init(list/node_connects)
	if(!node_connects) //for pipes where order of nodes doesn't matter
		node_connects = get_node_connects()

	for(var/i in 1 to device_type)
		for(var/obj/machinery/atmospherics/target in get_step(src,node_connects[i]))
			if(can_be_node(target))
				nodes[i] = target
				break
	update_icon()

/**
 * setter for pipe layers
 *
 * Set the layer of the pipe that the device has to a new_layer
 * Arguments:
 * * new_layer - the layer at which we want the piping_layer to be (1 to 5)
 */
/obj/machinery/atmospherics/proc/set_piping_layer(new_layer)
	piping_layer = (pipe_flags & PIPING_DEFAULT_LAYER_ONLY) ? PIPING_LAYER_DEFAULT : new_layer
	update_icon()

/obj/machinery/atmospherics/update_icon()
	update_layer()
	return ..()

/**
 * Check if a node can actually exists by connecting to another machine
 * called on atmosinit()
 * Arguments:
 * * obj/machinery/atmospherics/target - the machine we are connecting to
 * * iteration - the current node we are checking (from 1 to 4)
 */
/obj/machinery/atmospherics/proc/can_be_node(obj/machinery/atmospherics/target)
	return connection_check(target, piping_layer)


/**
 * Find a connecting /obj/machinery/atmospherics in specified direction, called by relaymove()
 * used by ventcrawling mobs to check if they can move inside a pipe in a specific direction
 * Arguments:
 * * direction - the direction we are checking against
 * * prompted_layer - the piping_layer we are inside
 */
/obj/machinery/atmospherics/proc/find_connecting(direction, prompted_layer)
	for(var/obj/machinery/atmospherics/target in get_step_multiz(src, direction))
		if(!(target.initialize_directions & get_dir(target,src)))
			continue
		if(connection_check(target, prompted_layer))
			return target

/**
 * Check the connection between two nodes
 *
 * Check if our machine and the target machine are connectable by both calling isConnectable and by checking that the directions and piping_layer are compatible
 * called by can_be_node() (for building a network) and find_connecting() (for ventcrawling)
 * Arguments:
 * * obj/machinery/atmospherics/target - the machinery we want to connect to
 * * given_layer - the piping_layer we are checking
 */
/obj/machinery/atmospherics/proc/connection_check(obj/machinery/atmospherics/target, given_layer)
	//if target is not multiz then we have to check if the target & src connect in the same direction
	if(!istype(target, /obj/machinery/atmospherics/pipe/multiz) && !((initialize_directions & get_dir(src, target)) && (target.initialize_directions & get_dir(target, src))))
		return FALSE

	//both target & src can't be connected either way
	if(!is_connectable(target, given_layer) || !target.is_connectable(src, given_layer))
		return FALSE
	return TRUE

/**
 * check if the piping layer and color are the same on both sides (grey can connect to all colors)
 * returns TRUE or FALSE if the connection is possible or not
 * Arguments:
 * * obj/machinery/atmospherics/target - the machinery we want to connect to
 * * given_layer - the piping_layer we are connecting to
 */
/obj/machinery/atmospherics/proc/is_connectable(obj/machinery/atmospherics/target, given_layer)
	if(isnull(given_layer))
		given_layer = piping_layer

	// you can't place the machine on the same location as the target cause it blocks
	if(target.loc == loc)
		return FALSE

	//if the target is not in the same piping layer & it does not have the all layer connection flag[which allows it to be connected regardless of layer] then we are out
	if(target.pipe_flags & PIPING_DISTRO_AND_WASTE_LAYERS)
		if(ISODD(given_layer))
			return FALSE
	else if(target.piping_layer != given_layer && !(target.pipe_flags & PIPING_ALL_LAYER))
		return FALSE

	//if the target does not have the same color and it does not have all color connection flag[which allows it to be connected regardless of color] & one of the pipes is not gray[allowing for connection regardless] then we are out
	if(target.pipe_color != pipe_color && !((target.pipe_flags | pipe_flags) & PIPING_ALL_COLORS) && target.pipe_color != COLOR_VERY_LIGHT_GRAY && pipe_color != COLOR_VERY_LIGHT_GRAY)
		return FALSE

	return TRUE

/**
 * Called on construction and when expanding the datum_pipenet, returns the nodes of the device
 */
/obj/machinery/atmospherics/proc/pipenet_expansion()
	return nodes

/**
 * Set the initial directions of the device (NORTH || SOUTH || EAST || WEST), called on New()
 */
/obj/machinery/atmospherics/proc/set_init_directions(init_dir)
	return

/**
 * Getter of initial directions
 */
/obj/machinery/atmospherics/proc/get_init_directions()
	return initialize_directions

/**
 * Called by addMember() in datum_pipenet.dm, returns the parent network the device is connected to
 */
/obj/machinery/atmospherics/proc/return_pipenet()
	return

/*
 * Called by add_machinery_member() in datum_pipenet.dm, returns a list of gas_mixtures and assigns them into other_airs (by add_machinery_member) to allow pressure redistribution for the machineries.
 */
/obj/machinery/atmospherics/proc/return_pipenet_airs()
	return

/**
 * Called by build_pipenet() and addMember() in datum_pipenet.dm, set the network the device is connected to, to the datum pipenet it has reference
 */
/obj/machinery/atmospherics/proc/set_pipenet()
	return

/**
 * Replaces the connection to the old_pipenet with the new_pipenet
 */
/obj/machinery/atmospherics/proc/replace_pipenet(datum/pipenet/old_pipenet, datum/pipenet/new_pipenet)
	return

/**
 * Disconnects the nodes
 *
 * Called by nullify_node(), it disconnects two nodes by removing the reference id from the node itself that called this proc
 * Arguments:
 * * obj/machinery/atmospherics/reference - the machinery we are removing from the node connection
 */
/obj/machinery/atmospherics/proc/disconnect(obj/machinery/atmospherics/reference)
	if(istype(reference, /obj/machinery/atmospherics/pipe))
		var/obj/machinery/atmospherics/pipe/P = reference
		P.destroy_network()
	nodes[nodes.Find(reference)] = null
	update_icon()

/obj/machinery/atmospherics/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/pipe)) //lets you autodrop
		var/obj/item/pipe/pipe = W
		if(user.dropItemToGround(pipe))
			pipe.set_piping_layer(piping_layer) //align it with us
			return TRUE
	else
		return ..()

/obj/machinery/atmospherics/wrench_act(mob/living/user, obj/item/I)
	if(!can_unwrench(user))
		return ..()

	var/datum/gas_mixture/int_air = return_air()
	var/datum/gas_mixture/env_air = loc.return_air()
	add_fingerprint(user)

	var/unsafe_wrenching = FALSE
	var/internal_pressure = int_air.return_pressure()-env_air.return_pressure()
	var/empty_pipe = FALSE
	if(istype(src, /obj/machinery/atmospherics/components))
		var/list/datum/gas_mixture/all_gas_mixes = return_analyzable_air()
		var/empty_mixes = 0
		for(var/gas_mix_number in 1 to device_type)
			var/datum/gas_mixture/gas_mix = all_gas_mixes[gas_mix_number]
			if(!(gas_mix.total_moles() > 0))
				empty_mixes++
			if(!nodes[gas_mix_number] || (istype(nodes[gas_mix_number], /obj/machinery/atmospherics/components/unary/portables_connector) && !portable_device_connected(gas_mix_number)))
				var/pressure_delta = all_gas_mixes[gas_mix_number].return_pressure() - env_air.return_pressure()
				internal_pressure = internal_pressure > pressure_delta ? internal_pressure : pressure_delta
		if(empty_mixes == device_type)
			empty_pipe = TRUE
	if(!(int_air.total_moles() > 0))
		empty_pipe = TRUE

	if(!empty_pipe)
		to_chat(user, span_notice("You begin to unfasten \the [src]..."))

	if (internal_pressure > 2*ONE_ATMOSPHERE)
		to_chat(user, span_warning("As you begin unwrenching \the [src] a gush of air blows in your face... maybe you should reconsider?"))
		unsafe_wrenching = TRUE //Oh dear oh dear

	var/time_taken = empty_pipe ? 0 : 20
	if(I.use_tool(src, user, time_taken, volume=50))
		user.visible_message( \
			"[user] unfastens \the [src].", \
			span_notice("You unfasten \the [src]."), \
			span_italics("You hear ratchet."))
		investigate_log("was [span_warning("REMOVED")] by [key_name(usr)]", INVESTIGATE_ATMOS)

		//You unwrenched a pipe full of pressure? Let's splat you into the wall, silly.
		if(unsafe_wrenching)
			unsafe_pressure_release(user, internal_pressure)
			if (user.client)
				user.client.give_award(/datum/award/achievement/misc/pressure, user)
		return deconstruct(TRUE)
	return TRUE

/**
 * Getter for can_unwrench
 *
 * Called by wrench_act() to check if the device can be unwrenched, each device override this with custom code (like if on/operating can't unwrench)
 * Arguments:
 * * mob/user - the mob doing the act
 */
/obj/machinery/atmospherics/proc/can_unwrench(mob/user)
	return can_unwrench

/**
 * Pipe pressure release calculations
 *
 * Throws the user when they unwrench a pipe with a major difference between the internal and environmental pressure.
 * Called by wrench_act() before deconstruct()
 * Arguments:
 * * mob_user - the mob doing the act
 * * pressures - it can be passed on from wrench_act(), it's the pressure difference between the enviroment pressure and the pipe internal pressure
 */
/obj/machinery/atmospherics/proc/unsafe_pressure_release(mob/living/carbon/user, pressures = null)
	if(!user)
		return
	if(ishuman(user)) //other carbons like monkeys can unwrench but cant wear magboots
		if(istype(user.shoes, /obj/item/clothing/shoes/magboots))
			var/obj/item/clothing/shoes/magboots/M = user.shoes
			if(M.negates_gravity())
				return
	if(!pressures)
		var/datum/gas_mixture/int_air = return_air()
		var/datum/gas_mixture/env_air = loc.return_air()
		pressures = int_air.return_pressure() - env_air.return_pressure()

	user.visible_message(span_danger("[user] is sent flying by pressure!"),span_userdanger("The pressure sends you flying!"))

	// if get_dir(src, user) is not 0, target is the edge_target_turf on that dir
	// otherwise, edge_target_turf uses a random cardinal direction
	// range is pressures / 250
	// speed is pressures / 1250
	user.throw_at(get_edge_target_turf(user, get_dir(src, user) || pick(GLOB.cardinals)), pressures / 250, pressures / 1250)

/// Pipe deconstruction proc. Return created pipe fitting.
/obj/machinery/atmospherics/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(can_unwrench)
			var/obj/item/pipe/stored = new construction_type(loc, null, dir, src, pipe_color)
			stored.set_piping_layer(piping_layer)
			if(!disassembled)
				stored.take_damage(stored.max_integrity * 0.5, sound_effect=FALSE)
			transfer_fingerprints_to(stored)
			. = stored
	..()

/**
 * Getter for piping layer shifted, pipe colored overlays
 *
 * Creates the image for the pipe underlay that all components use, called by get_pipe_underlay() in components_base.dm
 * Arguments:
 * * iconfile  - path of the iconstate we are using (ex: 'icons/obj/atmospherics/components/thermomachine.dmi')
 * * iconstate - the image we are using inside the file
 * * direction - the direction of our device
 * * color - the color (in hex value, like #559900) that the pipe should have
 * * piping_layer - the piping_layer the device is in, used inside PIPING_LAYER_SHIFT
 * * trinary - if TRUE we also use PIPING_FORWARD_SHIFT on layer 1 and 5 for trinary devices (filters and mixers)
 */
/obj/machinery/atmospherics/proc/get_pipe_image(iconfile, iconstate, direction, color = COLOR_VERY_LIGHT_GRAY, piping_layer = 3, trinary = FALSE)
	var/image/pipe_overlay = image(iconfile, iconstate, dir = direction)
	pipe_overlay.color = color
	PIPING_LAYER_SHIFT(pipe_overlay, piping_layer)
	if(trinary == TRUE && (piping_layer == 1 || piping_layer == 5))
		PIPING_FORWARD_SHIFT(pipe_overlay, piping_layer, 2)
	return pipe_overlay

/obj/machinery/atmospherics/on_construction(mob/user, obj_color, set_layer = PIPING_LAYER_DEFAULT)
	if(can_unwrench)
		add_atom_colour(obj_color, FIXED_COLOUR_PRIORITY)
		set_pipe_color(obj_color)
	set_piping_layer(set_layer)
	atmos_init()
	var/list/nodes = pipenet_expansion()
	for(var/obj/machinery/atmospherics/A in nodes)
		A.atmos_init()
		A.add_member(src)
	SSair.add_to_rebuild_queue(src)

/obj/machinery/atmospherics/update_name()
	if(!override_naming)
		name = "[GLOB.pipe_color_name[pipe_color]] [initial(name)]"
	return ..()

/obj/machinery/atmospherics/vv_edit_var(vname, vval)
	if(vname == NAMEOF(src, name))
		override_naming = TRUE
	return ..()

/obj/machinery/atmospherics/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	if(istype(arrived, /mob/living))
		var/mob/living/L = arrived
		L.ventcrawl_layer = piping_layer
	return ..()

/obj/machinery/atmospherics/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		deconstruct(FALSE)
	return ..()

#define VENT_SOUND_DELAY 30

/obj/machinery/atmospherics/relaymove(mob/living/user, direction)
	if(!(direction & initialize_directions) || !(direction in GLOB.cardinals_multiz)) //cant go this way.
		return
	if(user in buckled_mobs)// fixes buckle ventcrawl edgecase fuck bug
		return
	var/obj/machinery/atmospherics/target_move = find_connecting(direction, user.ventcrawl_layer)
	if(target_move)
		if(target_move.can_crawl_through())
			if(is_type_in_typecache(target_move, GLOB.ventcrawl_machinery))
				user.forceMove(target_move.loc) //handle entering and so on.
				user.visible_message(span_notice("You hear something squeezing through the ducts..."), span_notice("You climb out the ventilation system."))
			else
				var/list/pipenetdiff = return_pipenets() ^ target_move.return_pipenets()
				if(pipenetdiff.len)
					user.update_pipe_vision(target_move)
				user.forceMove(target_move)
				user.client.set_eye(target_move)  //Byond only updates the eye every tick, This smooths out the movement
				if(world.time - user.last_played_vent > VENT_SOUND_DELAY)
					user.last_played_vent = world.time
					playsound(src, 'sound/machines/ventcrawl.ogg', 50, 1, -3)
					if(prob(1))
						audible_message(span_warning("You hear something crawling through the ducts..."))
	else if(is_type_in_typecache(src, GLOB.ventcrawl_machinery) && can_crawl_through()) //if we move in a way the pipe can connect, but doesn't - or we're in a vent
		user.forceMove(loc)
		user.visible_message(span_notice("You hear something squeezing through the ducts..."), span_notice("You climb out the ventilation system."))

	//PLACEHOLDER COMMENT FOR ME TO READD THE 1 (?) DS DELAY THAT WAS IMPLEMENTED WITH A... TIMER?

/obj/machinery/atmospherics/AltClick(mob/living/L)
	. = ..()
	if(istype(L) && is_type_in_list(src, GLOB.ventcrawl_machinery))
		L.handle_ventcrawl(src)
		return

/**
 * Getter for vent crawling
 *
 * returns TRUE or FALSE, many devices overrides this (like cryo, or vents)
 * called by relaymove()
 */
/obj/machinery/atmospherics/proc/can_crawl_through()
	return TRUE

/**
 * Getter of a list of pipenets
 *
 * called in relaymove() to create the image for vent crawling
 */
/obj/machinery/atmospherics/proc/return_pipenets()
	return list()

/obj/machinery/atmospherics/update_remote_sight(mob/user)
	user.sight |= (SEE_TURFS|BLIND)

/**
 * Used for certain children of obj/machinery/atmospherics to not show pipe vision when mob is inside it.
 */
/obj/machinery/atmospherics/proc/can_see_pipes()
	return TRUE

/**
 * Update the layer in which the pipe/device is in, that way pipes have consistent layer depending on piping_layer
 */
/obj/machinery/atmospherics/proc/update_layer()
	return

/**
 * Called by the RPD.dm pre_attack()
 * Arguments:
 * * paint_color - color that the pipe will be painted in (colors in hex like #4f4f4f)
 */
/obj/machinery/atmospherics/proc/paint(paint_color)
	if(paintable)
		add_atom_colour(paint_color, FIXED_COLOUR_PRIORITY)
		set_pipe_color(paint_color)
		update_node_icon()
	return paintable

/// Setter for pipe color, so we can ensure it's all uniform and save cpu time
/obj/machinery/atmospherics/proc/set_pipe_color(pipe_colour)
	src.pipe_color = uppertext(pipe_colour)
	update_name()

/// Return TRUE if there is device connected to portables_connector
/obj/machinery/atmospherics/proc/portable_device_connected(node)
	var/obj/machinery/atmospherics/components/unary/portables_connector/portable_devices_connector = nodes[node]
	if(portable_devices_connector.connected_device)
		return TRUE
	return FALSE

#undef PIPE_VISIBLE_LEVEL
#undef PIPE_HIDDEN_LEVEL
#undef VENT_SOUND_DELAY
