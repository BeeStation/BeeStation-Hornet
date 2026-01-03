//random room spawner. takes random rooms from their appropriate map file and places them. the room will spawn with the spawner in the bottom left corner

/obj/effect/spawner/room
	name = "random room spawner"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "random_room"
	dir = NORTH
	var/room_width = 0
	var/room_height = 0
	///List of room IDs we want
	var/list/rooms = list()

/obj/effect/spawner/room/New(loc, ...)
	. = ..()
#ifndef UNIT_TESTS
	if(!isnull(SSmapping.random_room_spawners))
		SSmapping.random_room_spawners += src
#endif

/obj/effect/spawner/room/Initialize(mapload)
	. = ..()
#ifdef UNIT_TESTS
	// These are far too flakey to be including in the tests
	var/turf/main_room_turf = get_turf(src)
	for (var/x in main_room_turf.x to main_room_turf.x + room_width - 1)
		for (var/y in main_room_turf.y to main_room_turf.y + room_height - 1)
			var/turf/fix_turf = locate(x, y, main_room_turf.z)
			fix_turf.ChangeTurf(/turf/open/floor/plating, flags = CHANGETURF_IGNORE_AIR)
	return INITIALIZE_HINT_QDEL
#else
	if(!length(SSmapping.random_room_templates))
		message_admins("Room spawner created with no templates available. This shouldn't happen.")
		return INITIALIZE_HINT_QDEL
	var/list/possibletemplates = list()
	var/datum/map_template/random_room/candidate
	shuffle_inplace(SSmapping.random_room_templates)
	for(var/ID in SSmapping.random_room_templates)
		candidate = SSmapping.random_room_templates[ID]
		if((!rooms.len && candidate.spawned) || (!rooms.len && (room_height != candidate.template_height || room_width != candidate.template_width)) || (rooms.len && !(candidate.room_id in rooms)))
			candidate = null
			continue
		possibletemplates[candidate] = candidate.weight
	if(!length(possibletemplates))
		stack_trace("Failed to find a valid random room / Room Info - height: [room_height], width: [room_width], name: [name]")
	else
		var/datum/map_template/random_room/template = pick_weight(possibletemplates)
		template.stock --
		template.weight = (template.weight / 2)
		if(template.stock <= 0)
			template.spawned = TRUE
		var/datum/async_map_generator/map_place/generator = template.load(get_turf(src), centered = template.centerspawner)
		generator.on_completion(CALLBACK(src, PROC_REF(after_place)))
#endif

/obj/effect/spawner/room/proc/after_place(datum/async_map_generator/map_place/generator, turf/T, init_atmos, datum/parsed_map/parsed, finalize = TRUE, ...)
	// Scan through the room and remove any wall fixtures that were not placed correctly
	for (var/x in T.x to T.x + room_width - 1)
		for (var/y in T.y to T.y + room_height - 1)
			var/turf/current = locate(x, y, T.z)
			for (var/obj/placed_object in current)
				// Temporary hacky check to see if we contain a directional mapping helper
				// I know its a normal variable, but this is explicitly accessed through reflection
				if (!initial(placed_object._reflection_is_directional))
					continue
				// Check to see if we correctly placed ourselves on a wall
				if (!isclosedturf(get_step(placed_object, placed_object.dir)))
					SSatoms.prepare_deletion(placed_object)

/obj/effect/spawner/room/special/tenxfive_terrestrial
	name = "10x5 terrestrial room"
	room_width = 10
	room_height = 5
	icon_state = "random_room_alternative"
	rooms = list(
		"sk_rdm011_barbershop",
		"sk_rdm031_deltarobotics",
		"sk_rdm039_deltaclutter1",
		"sk_rdm040_deltabotnis",
		"sk_rdm045_deltacafeteria",
		"sk_rdm046_deltaarcade",
		"sk_rdm082_maintmedical",
		"sk_rdm091_skidrow",
		"sk_rdm100_meetingroom",
		"sk_rdm105_phage",
		"sk_rdm125_courtroom",
		"sk_rdm126_gaschamber",
		"sk_rdm127_oldaichamber",
		"sk_rdm128_radiationtherapy",
		"sk_rdm150_smallmedlobby",
		"sk_rdm151_ratburger",
		"sk_rdm152_geneticsoffice",
		"sk_rdm153_hobowithpeter",
		"sk_rdm154_butchersden",
		"sk_rdm155_punjiconveyor",
		"sk_rdm156_oldairlock_interchange",
		"sk_rdm161_kilovault")
/obj/effect/spawner/room/special/tenxten_terrestrial
	name = "10x10 terrestrial room"
	room_width = 10
	room_height = 10
	icon_state = "random_room_alternative"
	rooms = list(
		"sk_rdm033_deltalibrary",
		"sk_rdm060_snakefighter",
		"sk_rdm062_roosterdome",
		"sk_rdm070_pubbybar",
		"sk_rdm083_bigtheatre",
		"sk_rdm098_graffitiroom",
		"sk_rdm102_podrepairbay",
		"sk_rdm106_sanitarium",
		"sk_rdm129_beach",
		"sk_rdm130_benoegg",
		"sk_rdm131_confinementroom",
		"sk_rdm132_conveyorroom",
		"sk_rdm133_oldoffice",
		"sk_rdm134_snowforest",
		"sk_rdm141_6sectorsdown",
		"sk_rdm142_olddiner",
		"sk_rdm143_gamercave",
		"sk_rdm144_smallmagician",
		"sk_rdm145_ladytesla_altar",
		"sk_rdm146_blastdoor_interchange",
		"sk_rdm147_advbotany",
		"sk_rdm148_botany_apiary",
		"sk_rdm157_chess",
		"sk_rdm159_kilosnakepit",
		"sk_rdm167_library_ritual",
		"sk_rdm176_spacewindowroom")
/obj/effect/spawner/room/fivexfour
	name = "5x4 room spawner"
	room_width = 5
	room_height = 4

/obj/effect/spawner/room/fivexthree
	name = "5x3 room spawner"
	room_width = 5
	room_height = 3

/obj/effect/spawner/room/threexfive
	name = "3x5 room spawner"
	room_width = 3
	room_height = 5

/obj/effect/spawner/room/tenxten
	name = "10x10 room spawner"
	room_width = 10
	room_height = 10

/obj/effect/spawner/room/tenxfive
	name = "10x5 room spawner"
	room_width = 10
	room_height = 5

/obj/effect/spawner/room/threexthree
	name = "3x3 room spawner"
	room_width = 3
	room_height = 3

/obj/effect/spawner/room/fland
	name = "Special Room (5x10)"
	icon_state = "random_room_alternative"
	room_width = 5
	room_height = 10

/obj/effect/spawner/surface/echo
	name = "seasonal surface spawner"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "random_room_alternative"
	dir = NORTH

/obj/effect/spawner/surface/echo/Initialize(mapload)
	var/season = get_current_season()
	var/list/echo_season = list(
		"SUMMER" = "summer_surface",
		"WINTER" = "winter_surface",
		"SPRING" = "spring_surface",
		"AUTUMN" = "autumn_surface"
	)

	if (!(season in echo_season))
		message_admins("Echo surface spawner error: Unknown season '[season]'")
		return INITIALIZE_HINT_QDEL

	var/target_room_id = echo_season[season]
	var/datum/map_template/random_room/template = null

	for (var/datum/map_template/random_room/T in SSmapping.echo_surface_templates)
		if (T.room_id == target_room_id)
			template = T
			break

	if (!template)
		message_admins("Echo spawner: No surface map found for '[season]' ([target_room_id])")
		return INITIALIZE_HINT_QDEL

	message_admins("Echo spawner: Loading [template.name]. This may take a moment.")

	var/datum/async_map_generator/map_place/generator = template.load(get_turf(src), centered = template.centerspawner)
	generator.on_completion(CALLBACK(src, PROC_REF(after_place)))

	return INITIALIZE_HINT_QDEL

/obj/effect/spawner/surface/echo/proc/after_place(datum/async_map_generator/map_place/generator, turf/T, init_atmos, datum/parsed_map/parsed, finalize = TRUE, ...)
	message_admins("Echo spawner: Surface placement complete.")


/proc/get_current_season()
	var/month = text2num(time2text(world.timeofday, "MM"))

	if (month in list(DECEMBER, JANUARY, FEBRUARY))
		return "WINTER"
	//if (month in list(MARCH, APRIL, MAY))
	//	return "SPRING"
	//if (month in list(SEPTEMBER, OCTOBER, NOVEMBER))
	//	return "AUTUMN"
	return "SUMMER" //"SUMMER" by default
