//Landmarks and other helpers which speed up the mapping process and reduce the number of unique instances/subtypes of items/turf/ect

CREATION_TEST_IGNORE_SUBTYPES(/obj/effect/baseturf_helper)

/obj/effect/baseturf_helper //Set the baseturfs of every turf in the /area/ it is placed.
	name = "baseturf editor"
	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = ""

	var/list/baseturf_to_replace
	var/baseturf

	plane = POINT_PLANE

/obj/effect/baseturf_helper/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/baseturf_helper/LateInitialize()
	if(!baseturf_to_replace)
		baseturf_to_replace = typecacheof(/turf/open/space)
	else if(!length(baseturf_to_replace))
		baseturf_to_replace = list(baseturf_to_replace = TRUE)
	else if(baseturf_to_replace[baseturf_to_replace[1]] != TRUE) // It's not associative
		var/list/formatted = list()
		for(var/i in baseturf_to_replace)
			formatted[i] = TRUE
		baseturf_to_replace = formatted

	var/area/our_area = get_area(src)
	for(var/i in get_area_turfs(our_area, z))
		replace_baseturf(i)

	qdel(src)

/obj/effect/baseturf_helper/proc/replace_baseturf(turf/thing)
	if(length(thing.baseturfs))
		var/list/baseturf_cache = thing.baseturfs.Copy()
		for(var/i in baseturf_cache)
			if(baseturf_to_replace[i])
				baseturf_cache -= i
		thing.baseturfs = baseturfs_string_list(baseturf_cache, thing)
		if(!baseturf_cache.len)
			thing.assemble_baseturfs(baseturf)
		else
			thing.PlaceOnBottom(null, baseturf)
	else if(baseturf_to_replace[thing.baseturfs])
		thing.assemble_baseturfs(baseturf)
	else
		thing.PlaceOnBottom(null, baseturf)



/obj/effect/baseturf_helper/space
	name = "space baseturf editor"
	baseturf = /turf/open/space

/obj/effect/baseturf_helper/asteroid
	name = "asteroid baseturf editor"
	baseturf = /turf/open/floor/plating/asteroid

/obj/effect/baseturf_helper/asteroid/airless
	name = "asteroid airless baseturf editor"
	baseturf = /turf/open/floor/plating/asteroid/airless

/obj/effect/baseturf_helper/asteroid/basalt
	name = "asteroid basalt baseturf editor"
	baseturf = /turf/open/floor/plating/asteroid/basalt

/obj/effect/baseturf_helper/asteroid/snow
	name = "asteroid snow baseturf editor"
	baseturf = /turf/open/floor/plating/asteroid/snow

/obj/effect/baseturf_helper/beach/sand
	name = "beach sand baseturf editor"
	baseturf = /turf/open/floor/plating/beach/sand

/obj/effect/baseturf_helper/beach/water
	name = "water baseturf editor"
	baseturf = /turf/open/floor/plating/beach/water

/obj/effect/baseturf_helper/lava
	name = "lava baseturf editor"
	baseturf = /turf/open/lava/smooth

/obj/effect/baseturf_helper/lava_land/surface
	name = "lavaland baseturf editor"
	baseturf = /turf/open/lava/smooth/lava_land_surface

CREATION_TEST_IGNORE_SUBTYPES(/obj/effect/mapping_helpers)

/obj/effect/mapping_helpers
	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = ""
	var/late = FALSE

/obj/effect/mapping_helpers/Initialize(mapload)
	..()
	return late ? INITIALIZE_HINT_LATELOAD : INITIALIZE_HINT_QDEL

//airlock helpers
/obj/effect/mapping_helpers/airlock
	layer = DOOR_HELPER_LAYER

/obj/effect/mapping_helpers/airlock/Initialize(mapload)
	. = ..()
	if(!mapload)
		log_mapping("[src] spawned outside of mapload!")
		return
	var/obj/machinery/door/airlock/airlock = locate(/obj/machinery/door/airlock) in loc
	if(!airlock)
		log_mapping("[src] failed to find an airlock at [AREACOORD(src)]")
	else
		payload(airlock)

/obj/effect/mapping_helpers/airlock/proc/payload(obj/machinery/door/airlock/payload)
	return

/obj/effect/mapping_helpers/airlock/cyclelink_helper
	name = "airlock cyclelink helper"
	icon_state = "airlock_cyclelink_helper"

/obj/effect/mapping_helpers/airlock/cyclelink_helper/payload(obj/machinery/door/airlock/airlock)
	if(airlock.cyclelinkeddir)
		log_mapping("[src] at [AREACOORD(src)] tried to set [airlock] cyclelinkeddir, but it's already set!")
	else
		airlock.cyclelinkeddir = dir

/obj/effect/mapping_helpers/airlock/cyclelink_helper_multi
	name = "airlock multi-cyclelink helper"
	icon_state = "airlock_multicyclelink_helper"
	var/cycle_id

/obj/effect/mapping_helpers/airlock/cyclelink_helper_multi/payload(obj/machinery/door/airlock/airlock)
	if(airlock.closeOtherId)
		log_mapping("[src] at [AREACOORD(src)] tried to set [airlock] closeOtherId, but it's already set!")
	else
		airlock.closeOtherId = cycle_id

/obj/effect/mapping_helpers/airlock/locked
	name = "airlock lock helper"
	icon_state = "airlock_locked_helper"

/obj/effect/mapping_helpers/airlock/locked/payload(obj/machinery/door/airlock/airlock)
	if(airlock.locked)
		log_mapping("[src] at [AREACOORD(src)] tried to bolt [airlock] but it's already locked!")
	else
		airlock.locked = TRUE


/obj/effect/mapping_helpers/airlock/unres
	name = "airlock unresctricted side helper"
	icon_state = "airlock_unres_helper"

/obj/effect/mapping_helpers/airlock/unres/payload(obj/machinery/door/airlock/airlock)
	airlock.unres_sides ^= dir

/obj/effect/mapping_helpers/airlock/abandoned
	name = "airlock abandoned helper"
	icon_state = "airlock_abandoned"

/obj/effect/mapping_helpers/airlock/abandoned/payload(obj/machinery/door/airlock/airlock)
	if(airlock.abandoned)
		log_mapping("[src] at [AREACOORD(src)] tried to make [airlock] abandoned but it's already abandoned!")
	else
		airlock.abandoned = TRUE

//APC helpers
/obj/effect/mapping_helpers/apc

/obj/effect/mapping_helpers/apc/Initialize(mapload)
	. = ..()
	if(!mapload)
		log_mapping("[src] spawned outside of mapload!")
		return
	var/obj/machinery/power/apc/apc = locate(/obj/machinery/power/apc) in loc
	if(!apc)
		log_mapping("[src] failed to find an APC at [AREACOORD(src)]")
	else
		payload(apc)

/obj/effect/mapping_helpers/apc/proc/payload(obj/machinery/power/apc/payload)
	return

/obj/effect/mapping_helpers/apc/discharged
	name = "apc zero change helper"
	icon_state = "apc_nopower"

/obj/effect/mapping_helpers/apc/discharged/payload(obj/machinery/power/apc/apc)
	var/obj/item/stock_parts/cell/C = apc.get_cell()
	C.charge = 0
	C.update_icon()


//needs to do its thing before spawn_rivers() is called
INITIALIZE_IMMEDIATE(/obj/effect/mapping_helpers/no_lava)

/obj/effect/mapping_helpers/no_lava
	icon_state = "no_lava"

/obj/effect/mapping_helpers/no_lava/Initialize(mapload)
	. = ..()
	var/turf/T = get_turf(src)
	T.flags_1 |= NO_LAVA_GEN_1

//This helper applies components to things on the map directly.
/obj/effect/mapping_helpers/component_injector
	name = "Component Injector"
	late = TRUE
	var/target_type
	var/target_name
	var/component_type

//Late init so everything is likely ready and loaded (no warranty)
/obj/effect/mapping_helpers/component_injector/LateInitialize()
	if(!ispath(component_type,/datum/component))
		CRASH("Wrong component type in [type] - [component_type] is not a component")
	var/turf/T = get_turf(src)
	for(var/atom/A in T.GetAllContents())
		if(A == src)
			continue
		if(target_name && A.name != target_name)
			continue
		if(target_type && !istype(A,target_type))
			continue
		var/cargs = build_args()
		A._AddComponent(cargs)
		qdel(src)
		return

/obj/effect/mapping_helpers/component_injector/proc/build_args()
	return list(component_type)

/obj/effect/mapping_helpers/component_injector/infective
	name = "Infective Injector"
	icon_state = "component_infective"
	component_type = /datum/component/infective
	var/disease_type

/obj/effect/mapping_helpers/component_injector/infective/build_args()
	if(!ispath(disease_type,/datum/disease))
		CRASH("Wrong disease type passed in.")
	var/datum/disease/D = new disease_type()
	return list(component_type,D)

/obj/effect/mapping_helpers/dead_body_placer
	name = "Dead Body placer"
	late = TRUE
	icon_state = "deadbodyplacer"
	/// number of bodies to spawn
	var/bodycount = 1
	/// -1: area search (VERY expensive - do not use this in maint/ruin type)
	/// 0: spawns onto itself
	/// +1: turfs from this dead body placer
	var/search_view_range = 0
	/// the list of container typepath which accepts dead bodies
	var/list/accepted_list = list(
		/obj/structure/bodycontainer/morgue,
		/obj/structure/closet
	)

/// as long as this body placer is contained within medbay morgue, this is fine to be expensive.
/// DO NOT USE this outside of medbay morgue
/obj/effect/mapping_helpers/dead_body_placer/medbay_morgue
	bodycount = 2
	accepted_list = list(/obj/structure/bodycontainer/morgue)
	search_view_range = -1

/obj/effect/mapping_helpers/dead_body_placer/ruin_morgue
	bodycount = 2
	accepted_list = list(/obj/structure/bodycontainer/morgue)
	search_view_range = 7

/obj/effect/mapping_helpers/dead_body_placer/maint_fridge
	bodycount = 2
	accepted_list = list(/obj/structure/closet)
	search_view_range = 0

/obj/effect/mapping_helpers/dead_body_placer/LateInitialize()
	var/area/current_area = get_area(src)
	var/list/found_container = list()

	// search_view_range
	//   [Negative]: area search, get_contained_turfs()
	if(search_view_range < 0)
		for(var/turf/each_turf in current_area.get_contained_turfs())
			for(var/obj/each_container in each_turf)
				for(var/acceptable_path in accepted_list)
					if(istype(each_container, acceptable_path))
						found_container += each_container
						break
	//  [Positive]: view range search, view()
	//      [Zero]: onto itself, get_turf()
	else
		for(var/obj/each_container in (search_view_range ? view(search_view_range, get_turf(src)) : get_turf(src)))
			if(get_area(each_container) != current_area)
				continue // we don't want to put a deadbody to a wrong area
			for(var/acceptable_path in accepted_list)
				if(istype(each_container, acceptable_path))
					found_container += each_container
					break

	while(bodycount-- > 0)
		if(length(found_container))
			spawn_dead_human_in_tray(pick(found_container))
		else // if we have found no container, just spawn onto a turf
			spawn_dead_human_in_tray(get_turf(src))

	qdel(src)

/obj/effect/mapping_helpers/dead_body_placer/proc/spawn_dead_human_in_tray(atom/container)
	var/mob/living/carbon/human/corpse = new(container)
	var/list/possible_alt_species = GLOB.roundstart_races.Copy() - list(SPECIES_HUMAN, SPECIES_IPC, SPECIES_DIONA)
	if(prob(15) && length(possible_alt_species))
		corpse.set_species(GLOB.species_list[pick(possible_alt_species)])
	corpse.regenerate_organs()
	corpse.give_random_dormant_disease(25, min_symptoms = 1, max_symptoms = 5) // slightly more likely that an average stationgoer to have a dormant disease, bc who KNOWS how they died?
	corpse.death()
	for (var/obj/item/organ/organ in corpse.internal_organs) //randomly remove organs from each body, set those we keep to be in stasis
		if (prob(40))
			qdel(organ)
		else
			organ.organ_flags |= ORGAN_FROZEN
	container.update_icon()

/obj/effect/mapping_helpers/simple_pipes
	name = "Simple Pipes"
	late = TRUE
	icon_state = "pipe-3"
	alpha = 175
	layer = GAS_PIPE_VISIBLE_LAYER
	var/piping_layer = 3
	var/pipe_color = ""
	var/hide = FALSE

	FASTDMM_PROP(\
		pipe_type = PIPE_TYPE_AUTO,\
		pipe_interference_group = "atmos-[piping_layer]"\
	)

	var/list/pipe_types = list(
		/obj/machinery/atmospherics/pipe/simple/general/visible,
		/obj/machinery/atmospherics/pipe/simple/general/visible,
		/obj/machinery/atmospherics/pipe/manifold/general/visible,
		/obj/machinery/atmospherics/pipe/manifold4w/general/visible
	)

/obj/effect/mapping_helpers/simple_pipes/Initialize(mapload)
	preform_layer(piping_layer, pipe_color)
	qdel(src)

/obj/effect/mapping_helpers/simple_pipes/proc/preform_layer(override_layer, override_color, override_name = null)
	var/list/connections = list( dir2text(NORTH)  = FALSE, dir2text(SOUTH) = FALSE , dir2text(EAST) = FALSE , dir2text(WEST) = FALSE)
	var/list/valid_connectors = typecacheof(/obj/machinery/atmospherics)
	var/connection_num = 0
	for(var/direction in connections)
		var/turf/T = get_step(src,  text2dir(direction))
		for(var/thing in T.contents)
			// If it is a mapping helper
			if(istype(thing, /obj/effect/mapping_helpers/simple_pipes))
				var/obj/effect/mapping_helpers/simple_pipes/found = thing

				// If it is a supply_scrubber mapping helper
				if(istype(found, /obj/effect/mapping_helpers/simple_pipes/supply_scrubber))
					if(override_layer != 2 && override_layer != 4 && !istype(src, /obj/effect/mapping_helpers/simple_pipes/supply_scrubber))
						continue // We allow it if we're also a supply_scrubber helper, otherwise we gotta be on layers 2 or 4.

				// If it is a regular mapping helper
				else
					if(found.piping_layer != override_layer)
						continue // We have to have the same layer to allow it.

				connections[direction] = TRUE
				connection_num++
				break

			if(!is_type_in_typecache(thing, valid_connectors))
				continue

			var/obj/machinery/atmospherics/AM = thing
			if(AM.piping_layer != override_layer && !istype(AM, /obj/machinery/atmospherics/pipe/layer_manifold))
				continue

			if(angle2dir(dir2angle(text2dir(direction))+180) & AM.initialize_directions)
				connections[direction] = TRUE
				connection_num++
				break

	switch(connection_num)
		if(1)
			for(var/direction in connections)
				if(connections[direction] != TRUE)
					continue
				spawn_pipe(direction, connection_num, override_layer, override_color, override_name)
				return
		if(2)
			for(var/direction in connections)
				if(connections[direction] != TRUE)
					continue
				//Detects straight pipes connected from east to west , north to south etc.
				if(connections[dir2text(angle2dir(dir2angle(text2dir(direction))+180))] == TRUE)
					spawn_pipe(direction, connection_num, override_layer, override_color, override_name)
					return

				for(var/direction2 in (connections - direction))
					if(connections[direction2] != TRUE)
						continue
					spawn_pipe(dir2text(text2dir(direction)+text2dir(direction2)), connection_num, override_layer, override_color, override_name)
					return
		if(3)
			for(var/direction in connections)
				if(connections[direction] == FALSE)
					spawn_pipe(direction, connection_num, override_layer, override_color, override_name)
					return
		if(4)
			spawn_pipe(dir2text(NORTH), connection_num, override_layer, override_color, override_name)
			return

/// Spawn the pipe on the layer we specify
/obj/effect/mapping_helpers/simple_pipes/proc/spawn_pipe(direction, connection_num, override_layer, override_color, override_name = null)
	var/T = pipe_types[connection_num]
	var/obj/machinery/atmospherics/pipe/pipe = new T(get_turf(src), TRUE, text2dir(direction))

	if(!isnull(override_name))
		pipe.name = override_name
	pipe.piping_layer = override_layer
	pipe.update_layer()
	pipe.paint(override_color)
	// prevents duplicates on the station blueprints mode since the effect is on
	pipe.obj_flags &= ~ON_BLUEPRINTS

/obj/effect/mapping_helpers/simple_pipes/supply_scrubber
	name = "Simple Supply/Scrubber Pipes"
	icon_state = "pipe-2-4"
	color = rgb(128, 0, 128) // purple in-between pipe

// Instead of using our current layer, we use
/obj/effect/mapping_helpers/simple_pipes/supply_scrubber/Initialize(mapload)
	preform_layer(2, rgb(0, 0, 255), override_name = "air supply pipe")
	preform_layer(4, rgb(255, 0, 0), override_name = "scrubbers pipe")

	qdel(src)

/obj/effect/mapping_helpers/simple_pipes/supply_scrubber/hidden
	name = "Hidden Simple Supply/Scrubber Pipes"
	hide = TRUE
	pipe_types = list(
		/obj/machinery/atmospherics/pipe/simple/general/hidden,
		/obj/machinery/atmospherics/pipe/simple/general/hidden,
		/obj/machinery/atmospherics/pipe/manifold/general/hidden,
		/obj/machinery/atmospherics/pipe/manifold4w/general/hidden
	)

//Color correction helper - only use of these per area, it will convert the entire area
/obj/effect/mapping_helpers/color_correction
	name = "color correction helper"
	icon_state = "color_correction"
	late = TRUE
	var/color_correction = /datum/client_colour/area_color/cold

/obj/effect/mapping_helpers/color_correction/LateInitialize()
	var/area/A = get_area(get_turf(src))
	A.color_correction = color_correction
	qdel(src)

//Make any turf non-slip
/obj/effect/mapping_helpers/make_non_slip
	name = "non slip helper"
	icon_state = "no_slip"
	late = TRUE
	///Do we add the grippy visual
	var/grip_visual = TRUE

/obj/effect/mapping_helpers/make_non_slip/LateInitialize()
	var/turf/open/T = get_turf(src)
	if(isopenturf(T))
		T?.make_traction(grip_visual)
	qdel(src)

//Change this areas turf texture
/obj/effect/mapping_helpers/tile_breaker
	name = "area turf texture helper"
	icon_state = "tile_breaker"
	late = TRUE

/obj/effect/mapping_helpers/tile_breaker/LateInitialize()
	var/turf/open/floor/T = get_turf(src)
	if(istype(T, /turf/open/floor))
		T.break_tile()
	qdel(src)

//Virology helper- if virologist is enabled, set airlocks to virology access, set
/obj/effect/mapping_helpers/virology
	name = "virology mapping helper"
	desc = "Place this on each viro airlock to change its access, a smoke machine to turn it to a pet, and a plant to turn it to a virodrobe when virologist is enabled."
/obj/effect/mapping_helpers/virology/Initialize(mapload)
	.=..()
	if(CONFIG_GET(flag/allow_virologist))
		for(var/obj/A in loc)
			if(istype(A, /obj/machinery/door/airlock/))
				var/obj/machinery/door/airlock/airlock = A
				airlock.req_access_txt = "39"
				if(airlock.type == /obj/machinery/door/airlock/maintenance || airlock.type == /obj/machinery/door/airlock/maintenance_hatch)
					airlock.name = "Virology Maintenance"
				else
					airlock.name = "Virology Lab"
			if(istype(A, /obj/machinery/smoke_machine))
				qdel(A)
				new /obj/structure/bed/dogbed/vector(src.loc)
				new /mob/living/simple_animal/pet/hamster/vector(src.loc)
			if(istype(A, /obj/item/kirbyplants/random))
				qdel(A)
				new /obj/machinery/vending/wardrobe/viro_wardrobe(src.loc)

// automatically connects any portable atmospherics to the connector on the same tile
/obj/effect/mapping_helpers/atmos_auto_connect
	name = "atmos auto-connect helper"
	desc = "Place this on a portable atmospherics like canister to automatically connect it to the connector on the same tile."
	late = TRUE

/obj/effect/mapping_helpers/atmos_auto_connect/LateInitialize()
	. = ..()
	var/obj/machinery/portable_atmospherics/PortAtmos = locate(/obj/machinery/portable_atmospherics) in loc
	var/obj/machinery/atmospherics/components/unary/portables_connector/Connector = locate(/obj/machinery/atmospherics/components/unary/portables_connector) in loc
	if(PortAtmos && Connector)
		Connector.connect_to = PortAtmos
		qdel(src)
		return
	CRASH("Failed to find a portable atmospherics or a portables connector at [AREACOORD(src)]")

// This will put directional windows to adjucant turfs if airs will likely be vaccuumed.
// Putting this on a space turf is recommended. If you put this on an open tile, it will place directional windows anyway.
// If a turf is not valid to put a tile, it will automatically make a turf for failsafe.
// NOTE: This helper is specialised for space-proof, not just for standard mapping.
/obj/effect/mapping_helpers/space_window_placer
	name = "Placer: Spaceproof directional windows"
	icon_state = "space_directional_window_placer"
	late = TRUE

	/** Mapper options **/
	/// Determines which window type it will create
	var/window_type = /obj/structure/window/reinforced

	/** internal code variables - not for mappers **/
	/// used to skip a direction on a turf
	var/skip_direction
	/// there are a few stuff that "CanAtmosPass()" is not reliable
	var/static/list/unliable_atmos_blockers


/obj/effect/mapping_helpers/space_window_placer/Initialize(mapload)
	. = ..()
	if(!unliable_atmos_blockers)
		unliable_atmos_blockers = typecacheof(list(/obj/machinery/door))

/obj/effect/mapping_helpers/space_window_placer/LateInitialize()
	. = ..()
	if(!z || !x || !y)
		CRASH("It's not unable to place Spaceproof directional windoe placer - xyz is null.")

	var/turf/my_turf = get_turf(src)
	if(!my_turf)
		CRASH("Spaceproof directional windoe placer failed to find a turf.")

	// checks if turfs are fine to place a directional window
	var/unliable_atmos_blocking
	for(var/turf/each_turf in get_adjacent_open_turfs(my_turf))
		if(isspaceturf(each_turf) || isopenspace(each_turf))
			continue

		if(!each_turf.CanAtmosPass(my_turf))
			for(var/atom/movable/movable_content as anything in each_turf.contents)
				if(is_type_in_typecache(movable_content, unliable_atmos_blockers))
					unliable_atmos_blocking = TRUE
					break
			if(unliable_atmos_blocking)
				break

	var/list/nearby_turfs = list()
	for(var/turf/each_turf in get_adjacent_open_turfs(my_turf))
		if(unliable_atmos_blocking)
			var/obj/effect/mapping_helpers/space_window_placer/nearby_placer = locate() in each_turf
			if(nearby_placer) // we don't place windows there + give a value to skip directon
				nearby_placer.skip_direction |= get_dir(each_turf, my_turf)
				continue
			if(skip_direction & get_dir(my_turf, each_turf))
				continue
		nearby_turfs += each_turf


	// well, it's a bad idea to put a directional window here. Mapping failsafe process here.
	if(unliable_atmos_blocking && (isspaceturf(my_turf) || isopenspace(my_turf)))
		my_turf.PlaceOnTop(list(/turf/open/floor/plating, /turf/open/floor/iron), flags = CHANGETURF_INHERIT_AIR)
		for(var/turf/each_turf in nearby_turfs)
			if(isspaceturf(each_turf) || isopenspace(each_turf))
				var/obj/d_glass = new window_type(my_turf)
				d_glass.dir = get_dir(my_turf, each_turf)
			else
				var/improper_dir = get_dir(each_turf, my_turf)
				for(var/obj/structure/window/d_glass in each_turf.contents)
					if(d_glass.dir == improper_dir)
						qdel(d_glass)
		qdel(src)
		return

	// puts a directional window for each direction.
	for(var/turf/each_turf in nearby_turfs)
		if(!each_turf.CanAtmosPass(my_turf) || isspaceturf(each_turf) || isopenspace(each_turf))
			continue

		var/obj/d_glass = new window_type(each_turf)
		d_glass.dir = get_dir(d_glass, my_turf)

	qdel(src)

/obj/effect/mapping_helpers/group_window_placer
	name = "Placer: Grouped directional windows"
	icon_state = "group_directional_window_placer"
	late = TRUE

	/** Mapper options **/
	/// Determines which window type it will create.
	/// Make a subtype of this mapping helper to change this value instead of manual change in DMM.
	var/window_type = /obj/structure/window/reinforced
	/// Directional window will not be placed to a direction from the adjacent turf where a fulltile glass exists.
	/// If you set this TRUE, the windows will be placed.
	var/place_onto_fulltile_window
	/// Set TRUE to ignore group chain initialization
	var/single

	/** internal code variables - not for mappers **/
	/// failsafe var to prevent it to run a code
	var/to_be_initialized
	/// a list of mappers that will be initialized together.
	var/list/init_group

/obj/effect/mapping_helpers/group_window_placer/LateInitialize()
	. = ..()
	if(to_be_initialized)
		return

	if(!z || !x || !y)
		CRASH("It's not unable to use group_window_placer - xyz is null.")

	var/turf/my_turf = get_turf(src)
	if(!my_turf)
		CRASH("group_window_placer failed to find a turf.")

	if(single)
		to_be_initialized = TRUE
		finish_late_init(list(WEAKREF(src)))
		return

	init_group = list()
	build_group(init_group)
	finish_late_init()

/obj/effect/mapping_helpers/group_window_placer/proc/build_group(list/chain_init_group)
	if(to_be_initialized) // shouldn't reach here but just in case
		return
	to_be_initialized = TRUE
	chain_init_group[WEAKREF(src)] = TRUE
	for(var/turf/each_turf in get_adjacent_open_turfs(get_turf(src)))
		var/obj/effect/mapping_helpers/group_window_placer/placer = locate() in each_turf
		if(!placer || chain_init_group[WEAKREF(placer)] || placer.to_be_initialized)
			continue
		placer.build_group(chain_init_group)

/obj/effect/mapping_helpers/group_window_placer/proc/finish_late_init()
	for(var/datum/weakref/each_ref in init_group)
		var/obj/effect/mapping_helpers/group_window_placer/each_placer = each_ref.resolve()
		var/turf/my_turf = get_turf(each_placer)
		var/list/nearby_turfs = list()
		for(var/turf/each_turf in get_adjacent_open_turfs(my_turf))
			if(each_turf.density)
				continue
			if(locate(/obj/effect/mapping_helpers/group_window_placer) in each_turf)
				continue
				// skip this - that direction should be connected
			if(locate(/obj/effect/mapping_helpers/space_window_placer) in each_turf)
				continue
				// skip this - you won't want to have two directional window in the same directional spot.
				// NOTE: this is "SPACE" window placer, not "GROUP"
			if(place_onto_fulltile_window)
				var/is_fulltile
				for(var/obj/structure/window/window_on_turf in my_turf.contents)
					if(window_on_turf.fulltile)
						is_fulltile = TRUE
						break
				if(is_fulltile)
					continue
			nearby_turfs += each_turf

		for(var/turf/each_turf in nearby_turfs)
			var/obj/d_glass = new each_placer.window_type(my_turf)
			d_glass.dir = get_dir(my_turf, each_turf)

	for(var/datum/weakref/each_ref in init_group)
		var/obj/effect/mapping_helpers/group_window_placer/each_placer = each_ref.resolve()
		qdel(each_placer)
	init_group.Cut()

/obj/effect/mapping_helpers/Mapper_Comment //exists just to hold it's name and description to allow mappers to add comments to parts of their map in the editor.
	name = "Mapper Comment (Read 'Desc' variable)"
	desc = "Edit this text to your desired description."
	icon_state = "Comment"
	layer = TEXT_EFFECT_UI_LAYER

/obj/effect/mapping_helpers/Mapper_Comment/Initialize(mapload)
	return INITIALIZE_HINT_QDEL

//loads crate shelves with crates on mapload. Done via a helper because of linters
/obj/effect/mapping_helpers/crate_shelf_loader
	icon_state = "crate_putter"
	name = "crate shelf loader helper"
	desc = "Place up to three of these on a crate shelf and set their crate_type (basic grey crate by default) to load it onto the shelf."
	late = TRUE
	var/crate_type = /obj/structure/closet/crate //for changing the crate type in the map editor
	var/obj/structure/closet/crate/crate

/obj/effect/mapping_helpers/crate_shelf_loader/LateInitialize()
	. = ..()
	var/obj/structure/crate_shelf/shelf = locate(/obj/structure/crate_shelf) in loc
	if(crate_type && shelf)
		crate = new crate_type(src)
		shelf.load(crate)
		qdel(src)
		return
	CRASH("Failed to find a crate shelf at [AREACOORD(src)] or the crate_type is undefined")


