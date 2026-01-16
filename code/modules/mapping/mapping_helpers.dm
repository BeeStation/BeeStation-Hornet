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
	late = TRUE
	/// If TRUE we will apply to every windoor in the loc if we can't find an airlock.
	var/apply_to_windoors = FALSE

/obj/effect/mapping_helpers/airlock/Initialize(mapload)
	. = ..()
	if(!mapload)
		log_mapping("[src] spawned outside of mapload!")
		return

	var/obj/machinery/door/airlock/airlock = locate(/obj/machinery/door/airlock) in loc
	if(!airlock)
		if(apply_to_windoors)
			var/any_found = FALSE
			for(var/obj/machinery/door/window/windoor in loc)
				payload(windoor)
				any_found = TRUE
			if(!any_found)
				log_mapping("[src] failed to find an airlock at [AREACOORD(src)], AND no windoors were found.")
			return

		log_mapping("[src] failed to find an airlock at [AREACOORD(src)]")
		return

	payload(airlock)

/obj/effect/mapping_helpers/airlock/LateInitialize()
	var/obj/machinery/door/airlock/airlock = locate(/obj/machinery/door/airlock) in loc
	if(!airlock)
		qdel(src)
		return
	if(airlock.cyclelinkeddir)
		airlock.cyclelinkairlock()
	if(airlock.closeOtherId)
		airlock.update_other_id()
	if(airlock.abandoned)
		var/outcome = rand(1,100)
		switch(outcome)
			if(1 to 9)
				var/turf/here = get_turf(src)
				for(var/turf/closed/T in range(2, src))
					here.PlaceOnTop(T.type)
					qdel(airlock)
					qdel(src)
					return
				here.PlaceOnTop(/turf/closed/wall)
				qdel(airlock)
				qdel(src)
				return
			if(9 to 11)
				airlock.lights = FALSE
				// These do not use airlock.bolt() because we want to pretend it was always locked. That means no sound effects.
				airlock.locked = TRUE
			if(12 to 15)
				airlock.locked = TRUE
			if(16 to 23)
				airlock.welded = TRUE
			if(24 to 30)
				airlock.panel_open = TRUE
	if(airlock.cut_ai_wire)
		airlock.wires.cut(WIRE_AI)
	if(airlock.autoname)
		airlock.name = get_area_name(src, TRUE)
	airlock.update_appearance()
	qdel(src)

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
	else if(!cycle_id)
		log_mapping("[src] at [AREACOORD(src)] doesn't have a cycle_id to assign to [airlock]!")
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
	name = "airlock unrestricted side helper"
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

/obj/effect/mapping_helpers/airlock/welded
	name = "airlock welded helper"
	icon_state = "airlock_welded"

/obj/effect/mapping_helpers/airlock/welded/payload(obj/machinery/door/airlock/airlock)
	if(airlock.welded)
		log_mapping("[src] at [AREACOORD(src)] tried to make [airlock] welded but it's already welded closed!")
	airlock.welded = TRUE

/obj/effect/mapping_helpers/airlock/cutaiwire
	name = "airlock cut ai wire helper"
	icon_state = "airlock_cutaiwire"

/obj/effect/mapping_helpers/airlock/cutaiwire/payload(obj/machinery/door/airlock/airlock)
	if(airlock.cut_ai_wire)
		log_mapping("[src] at [AREACOORD(src)] tried to cut the ai wire on [airlock] but it's already cut!")
	else
		airlock.cut_ai_wire = TRUE

/obj/effect/mapping_helpers/airlock/autoname
	name = "airlock autoname helper"
	icon_state = "airlock_autoname"

/obj/effect/mapping_helpers/airlock/autoname/payload(obj/machinery/door/airlock/airlock)
	if(airlock.autoname)
		log_mapping("[src] at [AREACOORD(src)] tried to autoname the [airlock] but it's already autonamed!")
	else
		airlock.autoname = TRUE

/obj/effect/mapping_helpers/airlock/note_placer
	name = "Airlock Note Placer"
	icon_state = "airlocknoteplacer"

	/// Custom note name
	var/note_name
	/// For writing out custom notes without creating an extra paper subtype
	var/note_info
	/// Premade notes, for example: /obj/item/paper/guides/antag/nuke_instructions
	var/obj/item/paper/note_path

/obj/effect/mapping_helpers/airlock/note_placer/payload(obj/machinery/door/airlock/airlock)
	if(note_path && !ispath(note_path, /obj/item/paper)) //don't put non-paper in the paper slot thank you
		log_mapping("[src] at [x],[y] had an improper note_path path, could not place paper note.")
		return

	if(note_path)
		var/obj/item/paper/paper = new note_path(src)
		airlock.note = paper
		paper.forceMove(airlock)
		airlock.update_appearance()
		return

	if(note_info)
		var/obj/item/paper/paper = new /obj/item/paper(src)
		if(note_name)
			paper.name = note_name
		paper.add_raw_text(sanitize(note_info))
		paper.update_appearance()
		airlock.note = paper
		paper.forceMove(airlock)
		airlock.update_appearance()
		return

	log_mapping("[src] at [x],[y] had no note_path or note_info, cannot place paper note.")

//air alarm helpers
/obj/effect/mapping_helpers/airalarm
	desc = "You shouldn't see this. Report it please."
	layer = ABOVE_OBJ_LAYER
	late = TRUE

/obj/effect/mapping_helpers/airalarm/Initialize(mapload)
	. = ..()
	if(!mapload)
		log_mapping("[src] spawned outside of mapload!")
		return INITIALIZE_HINT_QDEL

	var/obj/machinery/airalarm/target = locate(/obj/machinery/airalarm) in loc
	if(isnull(target))
		var/area/target_area = get_area(target)
		log_mapping("[src] failed to find an air alarm at [AREACOORD(src)] ([target_area.type]).")
	else
		payload(target)

	return INITIALIZE_HINT_LATELOAD

/obj/effect/mapping_helpers/airalarm/LateInitialize()
	var/obj/machinery/airalarm/target = locate(/obj/machinery/airalarm) in loc

	if(isnull(target))
		qdel(src)
		return
	if(target.unlocked)
		target.unlock()

	if(target.tlv_cold_room)
		target.set_tlv_cold_room()
	if(target.tlv_kitchen)
		target.set_tlv_kitchen()
	if(target.tlv_no_checks)
		target.set_tlv_no_checks()
	if(target.tlv_no_checks + target.tlv_cold_room + target.tlv_kitchen > 1)
		CRASH("Tried to apply incompatible air alarm threshold helpers!")

	if(target.syndicate_access)
		target.give_syndicate_access()
	if(target.away_general_access)
		target.give_away_general_access()
	if(target.engine_access)
		target.give_engine_access()
	if(target.mixingchamber_access)
		target.give_mixingchamber_access()
	if(target.all_access)
		target.give_all_access()
	if(target.syndicate_access + target.away_general_access + target.engine_access + target.mixingchamber_access + target.all_access > 1)
		CRASH("Tried to combine incompatible air alarm access helpers!")

	target.update_icon()
	qdel(src)

/obj/effect/mapping_helpers/airalarm/proc/payload(obj/machinery/airalarm/target)
	return

/obj/effect/mapping_helpers/airalarm/unlocked
	name = "airalarm unlocked interface helper"
	icon_state = "airalarm_unlocked_interface_helper"

/obj/effect/mapping_helpers/airalarm/unlocked/payload(obj/machinery/airalarm/target)
	if(target.unlocked)
		var/area/area = get_area(target)
		log_mapping("[src] at [AREACOORD(src)] [(area.type)] tried to unlock the [target] but it's already unlocked!")
	target.unlocked = TRUE

/obj/effect/mapping_helpers/airalarm/syndicate_access
	name = "airalarm syndicate access helper"
	icon_state = "airalarm_syndicate_access_helper"

/obj/effect/mapping_helpers/airalarm/syndicate_access/payload(obj/machinery/airalarm/target)
	if(target.syndicate_access)
		var/area/area = get_area(target)
		log_mapping("[src] at [AREACOORD(src)] [(area.type)] tried to adjust [target]'s access to syndicate but it's already changed!")
	target.syndicate_access = TRUE

/obj/effect/mapping_helpers/airalarm/away_general_access
	name = "airalarm away access helper"
	icon_state = "airalarm_away_general_access_helper"

/obj/effect/mapping_helpers/airalarm/away_general_access/payload(obj/machinery/airalarm/target)
	if(target.away_general_access)
		var/area/area = get_area(target)
		log_mapping("[src] at [AREACOORD(src)] [(area.type)] tried to adjust [target]'s access to away_general but it's already changed!")
	target.away_general_access = TRUE

/obj/effect/mapping_helpers/airalarm/engine_access
	name = "airalarm engine access helper"
	icon_state = "airalarm_engine_access_helper"

/obj/effect/mapping_helpers/airalarm/engine_access/payload(obj/machinery/airalarm/target)
	if(target.engine_access)
		var/area/area = get_area(target)
		log_mapping("[src] at [AREACOORD(src)] [(area.type)] tried to adjust [target]'s access to engine_access but it's already changed!")
	target.engine_access = TRUE

/obj/effect/mapping_helpers/airalarm/mixingchamber_access
	name = "airalarm mixingchamber access helper"
	icon_state = "airalarm_mixingchamber_access_helper"

/obj/effect/mapping_helpers/airalarm/mixingchamber_access/payload(obj/machinery/airalarm/target)
	if(target.mixingchamber_access)
		var/area/area = get_area(target)
		log_mapping("[src] at [AREACOORD(src)] [(area.type)] tried to adjust [target]'s access to mixingchamber_access but it's already changed!")
	target.mixingchamber_access = TRUE

/obj/effect/mapping_helpers/airalarm/all_access
	name = "airalarm all access helper"
	icon_state = "airalarm_all_access_helper"

/obj/effect/mapping_helpers/airalarm/all_access/payload(obj/machinery/airalarm/target)
	if(target.all_access)
		var/area/area = get_area(target)
		log_mapping("[src] at [AREACOORD(src)] [(area.type)] tried to adjust [target]'s access to all_access but it's already changed!")
	target.all_access = TRUE

/obj/effect/mapping_helpers/airalarm/tlv_cold_room
	name = "airalarm cold room tlv helper"
	icon_state = "airalarm_tlv_cold_room_helper"

/obj/effect/mapping_helpers/airalarm/tlv_cold_room/payload(obj/machinery/airalarm/target)
	if(target.tlv_cold_room)
		var/area/area = get_area(target)
		log_mapping("[src] at [AREACOORD(src)] [(area.type)] tried to adjust [target]'s tlv to cold_room but it's already changed!")
	target.tlv_cold_room = TRUE

/obj/effect/mapping_helpers/airalarm/tlv_kitchen
	name = "airalarm kitchen tlv helper"
	icon_state = "airalarm_tlv_kitchen_helper"

/obj/effect/mapping_helpers/airalarm/tlv_kitchen/payload(obj/machinery/airalarm/target)
	if(target.tlv_kitchen)
		var/area/area = get_area(target)
		log_mapping("[src] at [AREACOORD(src)] [(area.type)] tried to adjust [target]'s tlv to kitchen but it's already changed!")
	target.tlv_kitchen = TRUE

/obj/effect/mapping_helpers/airalarm/tlv_no_checks
	name = "airalarm no checks tlv helper"
	icon_state = "airalarm_tlv_no_checks_helper"

/obj/effect/mapping_helpers/airalarm/tlv_no_checks/payload(obj/machinery/airalarm/target)
	if(target.tlv_no_checks)
		var/area/area = get_area(target)
		log_mapping("[src] at [AREACOORD(src)] [(area.type)] tried to adjust [target]'s tlv to no_checks but it's already changed!")
	target.tlv_no_checks = TRUE

/obj/effect/mapping_helpers/airalarm/link
	name = "airalarm link helper"
	icon_state = "airalarm_link_helper"
	late = TRUE
	var/chamber_id = ""
	var/allow_link_change = FALSE

/obj/effect/mapping_helpers/airalarm/link/Initialize(mapload)
	. = ..()
	if(!mapload)
		log_mapping("[src] spawned outside of mapload!")
		return INITIALIZE_HINT_QDEL

/obj/effect/mapping_helpers/airalarm/link/LateInitialize(mapload)
	var/obj/machinery/airalarm/alarm = locate(/obj/machinery/airalarm) in loc
	if(!isnull(alarm))
		alarm.air_sensor_chamber_id = chamber_id
		alarm.allow_link_change = allow_link_change
		alarm.setup_chamber_link()
	else
		log_mapping("[src] failed to find air alarm at [AREACOORD(src)].")
	qdel(src)

/obj/effect/mapping_helpers/airalarm/surgery
	name = "airalarm surgery helper"
	icon_state = "airalarm_surgery_helper"

/obj/effect/mapping_helpers/airalarm/surgery/LateInitialize()
	var/obj/machinery/airalarm/target = locate() in loc
	for(var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber as anything in target?.my_area?.air_scrubbers)
		scrubber.filter_types |= /datum/gas/nitrous_oxide
		scrubber.set_widenet(TRUE)
	return ..()

//apc helpers
/obj/effect/mapping_helpers/apc
	desc = "You shouldn't see this. Report it please."
	late = TRUE

/obj/effect/mapping_helpers/apc/Initialize(mapload)
	. = ..()
	if(!mapload)
		log_mapping("[src] spawned outside of mapload!")
		return INITIALIZE_HINT_QDEL

	var/obj/machinery/power/apc/target = locate(/obj/machinery/power/apc) in loc
	if(isnull(target))
		var/area/target_area = get_area(src)
		log_mapping("[src] failed to find an apc at [AREACOORD(src)] ([target_area.type]).")
	else
		payload(target)

	return INITIALIZE_HINT_LATELOAD

/obj/effect/mapping_helpers/apc/LateInitialize()
	var/obj/machinery/power/apc/target = locate(/obj/machinery/power/apc) in loc

	if(isnull(target))
		qdel(src)
		return
	if(target.cut_ai_wire)
		target.wires.cut(WIRE_AI)
	if(target.unlocked)
		target.unlock()
	if(target.syndicate_access)
		target.give_syndicate_access()
	if(target.away_general_access)
		target.give_away_general_access()
	if(target.no_charge)
		target.set_no_charge()
	if(target.full_charge)
		target.set_full_charge()
	if(target.syndicate_access && target.away_general_access)
		CRASH("Tried to combine non-combinable syndicate_access and away_general_access APC helpers!")
	if(target.no_charge && target.full_charge)
		CRASH("Tried to combine non-combinable no_charge and full_charge APC helpers!")
	target.update_appearance()
	qdel(src)

/obj/effect/mapping_helpers/apc/proc/payload(obj/machinery/power/apc/target)
	return

/obj/effect/mapping_helpers/apc/cut_ai_wire
	name = "apc AI wire mended helper"
	icon_state = "apc_cut_AIwire_helper"

/obj/effect/mapping_helpers/apc/cut_ai_wire/payload(obj/machinery/power/apc/target)
	if(target.cut_ai_wire)
		var/area/apc_area = get_area(target)
		log_mapping("[src] at [AREACOORD(src)] [(apc_area.type)] tried to mend the AI wire on the [target] but it's already cut!")
	target.cut_ai_wire = TRUE

/obj/effect/mapping_helpers/apc/syndicate_access
	name = "apc syndicate access helper"
	icon_state = "apc_syndicate_access_helper"

/obj/effect/mapping_helpers/apc/syndicate_access/payload(obj/machinery/power/apc/target)
	if(target.syndicate_access)
		var/area/apc_area = get_area(target)
		log_mapping("[src] at [AREACOORD(src)] [(apc_area.type)] tried to adjust [target]'s access to syndicate but it's already changed!")
	target.syndicate_access = TRUE

/obj/effect/mapping_helpers/apc/away_general_access
	name = "apc away access helper"
	icon_state = "apc_away_general_access_helper"

/obj/effect/mapping_helpers/apc/away_general_access/payload(obj/machinery/power/apc/target)
	if(target.away_general_access)
		var/area/apc_area = get_area(target)
		log_mapping("[src] at [AREACOORD(src)] [(apc_area.type)] tried to adjust [target]'s access to away_general but it's already changed!")
	target.away_general_access = TRUE

/obj/effect/mapping_helpers/apc/unlocked
	name = "apc unlocked interface helper"
	icon_state = "apc_unlocked_interface_helper"

/obj/effect/mapping_helpers/apc/unlocked/payload(obj/machinery/power/apc/target)
	if(target.unlocked)
		var/area/apc_area = get_area(target)
		log_mapping("[src] at [AREACOORD(src)] [(apc_area.type)] tried to unlock the [target] but it's already unlocked!")
	target.unlocked = TRUE

/obj/effect/mapping_helpers/apc/no_charge
	name = "apc no charge helper"
	icon_state = "apc_no_charge_helper"

/obj/effect/mapping_helpers/apc/no_charge/payload(obj/machinery/power/apc/target)
	if(target.no_charge)
		var/area/apc_area = get_area(target)
		log_mapping("[src] at [AREACOORD(src)] [(apc_area.type)] tried to set [target]'s charge to 0 but it's already at 0!")
	target.no_charge = TRUE

/obj/effect/mapping_helpers/apc/full_charge
	name = "apc full charge helper"
	icon_state = "apc_full_charge_helper"

/obj/effect/mapping_helpers/apc/full_charge/payload(obj/machinery/power/apc/target)
	if(target.full_charge)
		var/area/apc_area = get_area(target)
		log_mapping("[src] at [AREACOORD(src)] [(apc_area.type)] tried to set [target]'s charge to 100 but it's already at 100!")
	target.full_charge = TRUE


//needs to do its thing before spawn_rivers() is called
INITIALIZE_IMMEDIATE(/obj/effect/mapping_helpers/no_lava)

/obj/effect/mapping_helpers/no_lava
	icon_state = "no_lava"

/obj/effect/mapping_helpers/no_lava/Initialize(mapload)
	. = ..()
	var/turf/T = get_turf(src)
	T.flags_1 |= NO_LAVA_GEN_1

CREATION_TEST_IGNORE_SELF(/obj/effect/mapping_helpers/atom_injector)

///Helpers used for injecting stuff into atoms on the map.
/obj/effect/mapping_helpers/atom_injector
	name = "Atom Injector"
	icon_state = "injector"
	late = TRUE
	///Will inject into all fitting the criteria if false, otherwise first found.
	var/first_match_only = TRUE
	///Will inject into atoms of this type.
	var/target_type
	///Will inject into atoms with this name.
	var/target_name

//Late init so everything is likely ready and loaded (no warranty)
/obj/effect/mapping_helpers/atom_injector/LateInitialize()
	if(!check_validity())
		return
	var/turf/target_turf = get_turf(src)
	var/matches_found = 0
	for(var/atom/atom_on_turf as anything in target_turf.GetAllContents())
		if(atom_on_turf == src)
			continue
		if(target_name && atom_on_turf.name != target_name)
			continue
		if(target_type && !istype(atom_on_turf, target_type))
			continue
		inject(atom_on_turf)
		matches_found++
		if(first_match_only)
			qdel(src)
			return
	if(!matches_found)
		stack_trace(generate_stack_trace())
	qdel(src)

///Checks if whatever we are trying to inject with is valid
/obj/effect/mapping_helpers/atom_injector/proc/check_validity()
	return TRUE

///Injects our stuff into the atom
/obj/effect/mapping_helpers/atom_injector/proc/inject(atom/target)
	return

///Generates text for our stack trace
/obj/effect/mapping_helpers/atom_injector/proc/generate_stack_trace()
	. = "[name] found no targets at ([x], [y], [z]). First Match Only: [first_match_only ? "true" : "false"] target type: [target_type] | target name: [target_name]"

/obj/effect/mapping_helpers/atom_injector/obj_flag
	name = "Obj Flag Injector"
	icon_state = "objflag_helper"
	var/inject_flags = NONE

/obj/effect/mapping_helpers/atom_injector/obj_flag/inject(atom/target)
	if(!isobj(target))
		return
	var/obj/obj_target = target
	obj_target.obj_flags |= inject_flags

///This helper applies components to things on the map directly.
/obj/effect/mapping_helpers/atom_injector/component_injector
	name = "Component Injector"
	icon_state = "component"
	///Typepath of the component.
	var/component_type
	///Arguments for the component.
	var/list/component_args = list()

/obj/effect/mapping_helpers/atom_injector/component_injector/check_validity()
	if(!ispath(component_type, /datum/component))
		CRASH("Wrong component type in [type] - [component_type] is not a component")
	return TRUE

/obj/effect/mapping_helpers/atom_injector/component_injector/inject(atom/target)
	var/arguments = list(component_type)
	arguments += component_args
	target._AddComponent(arguments)

/obj/effect/mapping_helpers/atom_injector/component_injector/generate_stack_trace()
	. = ..()
	. += " | component type: [component_type] | component arguments: [list2params(component_args)]"

///This helper applies elements to things on the map directly.
/obj/effect/mapping_helpers/atom_injector/element_injector
	name = "Element Injector"
	icon_state = "element"
	///Typepath of the element.
	var/element_type
	///Arguments for the element.
	var/list/element_args = list()

/obj/effect/mapping_helpers/atom_injector/element_injector/check_validity()
	if(!ispath(element_type, /datum/element))
		CRASH("Wrong element type in [type] - [element_type] is not a element")
	return TRUE

/obj/effect/mapping_helpers/atom_injector/element_injector/inject(atom/target)
	var/arguments = list(element_type)
	arguments += element_args
	target._AddElement(arguments)

/obj/effect/mapping_helpers/atom_injector/element_injector/generate_stack_trace()
	. = ..()
	. += " | element type: [element_type] | element arguments: [list2params(element_args)]"

///This helper applies traits to things on the map directly.
/obj/effect/mapping_helpers/atom_injector/trait_injector
	name = "Trait Injector"
	icon_state = "trait"
	///Name of the trait, in the lower-case text (NOT the upper-case define) form.
	var/trait_name

/obj/effect/mapping_helpers/atom_injector/trait_injector/check_validity()
	if(!istext(trait_name))
		CRASH("Wrong trait in [type] - [trait_name] is not a trait")
	if(!GLOB.trait_name_map)
		GLOB.trait_name_map = generate_trait_name_map()
	if(!GLOB.trait_name_map.Find(trait_name))
		stack_trace("Possibly wrong trait in [type] - [trait_name] is not a trait in the global trait list")
	return TRUE

/obj/effect/mapping_helpers/atom_injector/trait_injector/inject(atom/target)
	ADD_TRAIT(target, trait_name, MAPPING_HELPER_TRAIT)

/obj/effect/mapping_helpers/atom_injector/trait_injector/generate_stack_trace()
	. = ..()
	. += " | trait name: [trait_name]"

///Fetches an external dmi and applies to the target object
/obj/effect/mapping_helpers/atom_injector/custom_icon
	name = "Custom Icon Injector"
	icon_state = "icon"
	///This is the var tha will be set with the fetched icon. In case you want to set some secondary icon sheets like inhands and such.
	var/target_variable = "icon"
	///This should return raw dmi in response to http get request. For example: "https://github.com/tgstation/SS13-sprites/raw/master/mob/medu.dmi?raw=true"
	var/icon_url
	///The icon file we fetched from the http get request.
	var/icon_file

/obj/effect/mapping_helpers/atom_injector/custom_icon/check_validity()
	var/static/icon_cache = list()
	var/static/query_in_progress = FALSE //We're using a single tmp file so keep it linear.
	if(query_in_progress)
		UNTIL(!query_in_progress)
	if(icon_cache[icon_url])
		icon_file = icon_cache[icon_url]
		return TRUE
	log_asset("Custom Icon Helper fetching dmi from: [icon_url]")
	var/datum/http_request/request = new()
	var/file_name = "tmp/custom_map_icon.dmi"
	request.prepare(RUSTG_HTTP_METHOD_GET, icon_url, "", "", file_name)
	query_in_progress = TRUE
	request.begin_async()
	UNTIL(request.is_complete())
	var/datum/http_response/response = request.into_response()
	if(response.errored || response.status_code != 200)
		query_in_progress = FALSE
		CRASH("Failed to fetch mapped custom icon from url [icon_url], code: [response.status_code], error: [response.error]")
	var/icon/new_icon = new(file_name)
	icon_cache[icon_url] = new_icon
	query_in_progress = FALSE
	icon_file = new_icon
	return TRUE

/obj/effect/mapping_helpers/atom_injector/custom_icon/inject(atom/target)
	if(IsAdminAdvancedProcCall())
		return
	target.vars[target_variable] = icon_file

/obj/effect/mapping_helpers/atom_injector/custom_icon/generate_stack_trace()
	. = ..()
	. += " | target variable: [target_variable] | icon url: [icon_url]"

///Fetches an external sound and applies to the target object
/obj/effect/mapping_helpers/atom_injector/custom_sound
	name = "Custom Sound Injector"
	icon_state = "sound"
	///This is the var that will be set with the fetched sound.
	var/target_variable = "hitsound"
	///This should return raw sound in response to http get request. For example: "https://github.com/tgstation/tgstation/blob/master/sound/misc/bang.ogg?raw=true"
	var/sound_url
	///The sound file we fetched from the http get request.
	var/sound_file

/obj/effect/mapping_helpers/atom_injector/custom_sound/check_validity()
	var/static/sound_cache = list()
	var/static/query_in_progress = FALSE //We're using a single tmp file so keep it linear.
	if(query_in_progress)
		UNTIL(!query_in_progress)
	if(sound_cache[sound_url])
		sound_file = sound_cache[sound_url]
		return TRUE
	log_asset("Custom Sound Helper fetching sound from: [sound_url]")
	var/datum/http_request/request = new()
	var/file_name = "tmp/custom_map_sound.ogg"
	request.prepare(RUSTG_HTTP_METHOD_GET, sound_url, "", "", file_name)
	query_in_progress = TRUE
	request.begin_async()
	UNTIL(request.is_complete())
	var/datum/http_response/response = request.into_response()
	if(response.errored || response.status_code != 200)
		query_in_progress = FALSE
		CRASH("Failed to fetch mapped custom sound from url [sound_url], code: [response.status_code], error: [response.error]")
	var/sound/new_sound = new(file_name)
	sound_cache[sound_url] = new_sound
	query_in_progress = FALSE
	sound_file = new_sound
	return TRUE

/obj/effect/mapping_helpers/atom_injector/custom_sound/inject(atom/target)
	if(IsAdminAdvancedProcCall())
		return
	target.vars[target_variable] = sound_file

/obj/effect/mapping_helpers/atom_injector/custom_sound/generate_stack_trace()
	. = ..()
	. += " | target variable: [target_variable] | sound url: [sound_url]"

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
	for (var/obj/item/organ/organ in corpse.organs) //randomly remove organs from each body, set those we keep to be in stasis
		if (prob(40))
			qdel(organ)
		else
			organ.organ_flags |= ORGAN_FROZEN
	container.update_icon()

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
	var/obj/machinery/portable_atmospherics/port_atmos = locate(/obj/machinery/portable_atmospherics) in loc
	var/obj/machinery/atmospherics/components/unary/portables_connector/connector = locate(/obj/machinery/atmospherics/components/unary/portables_connector) in loc
	if(port_atmos && connector)
		port_atmos.connect(connector)
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
	/// there are a few stuff that "can_atmos_pass()" is not reliable
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

		if(!each_turf.can_atmos_pass(my_turf))
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
		if(!each_turf.can_atmos_pass(my_turf) || isspaceturf(each_turf) || isopenspace(each_turf))
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


//it must be done before decomposition component is added.
INITIALIZE_IMMEDIATE(/obj/effect/mapping_helpers/foodpreserver)

/obj/effect/mapping_helpers/foodpreserver
	name = "food preserving helper"
	icon_state = "preserved"

/obj/effect/mapping_helpers/foodpreserver/Initialize(mapload)
	. = ..()
	var/turf/T = get_turf(src)
	for(var/obj/item/food/preservee in T.contents)
		preservee.preserved_food = TRUE
	for(var/obj/structure/closet/closet in T.contents)
		for(var/obj/item/food/preservee in closet.contents)
			preservee.preserved_food = TRUE

/obj/effect/mapping_helpers/broken_floor
	name = "broken floor"
	icon = 'icons/turf/damaged.dmi'
	icon_state = "damaged1"
	layer = ABOVE_NORMAL_TURF_LAYER
	late = TRUE

/obj/effect/mapping_helpers/broken_floor/LateInitialize()
	var/turf/open/floor/floor = get_turf(src)
	floor.break_tile()
	qdel(src)

/obj/effect/mapping_helpers/burnt_floor
	name = "burnt floor"
	icon = 'icons/turf/damaged.dmi'
	icon_state = "floorscorched1"
	layer = ABOVE_NORMAL_TURF_LAYER
	late = TRUE

/obj/effect/mapping_helpers/burnt_floor/LateInitialize()
	var/turf/open/floor/floor = get_turf(src)
	floor.burn_tile()
	qdel(src)
