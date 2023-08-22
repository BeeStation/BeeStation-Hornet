/datum/orbital_object/z_linked/beacon
	name = "Unidentified Signal"
	mass = 0
	radius = 30
	can_dock_anywhere = TRUE
	render_mode = RENDER_MODE_BEACON
	//The attached event
	var/datum/ruin_event/ruin_event

/datum/orbital_object/z_linked/beacon/New()
	. = ..()
	var/datum/orbital_map/linked_map = SSorbits.orbital_maps[orbital_map_index]
	ruin_event = SSorbits.get_event()
	if(ruin_event?.warning_message)
		name = "[initial(name)] #[rand(1, 9)][linked_map.object_count][rand(1, 9)] ([ruin_event.warning_message])"
	else
		name = "[initial(name)] #[rand(1, 9)][linked_map.object_count][rand(1, 9)]"
	//Link the ruin event to ourselves
	ruin_event?.linked_z = src

/datum/orbital_object/z_linked/beacon/post_map_setup()
	//Orbit around the systems sun
	var/datum/orbital_map/linked_map = SSorbits.orbital_maps[orbital_map_index]
	set_orbitting_around_body(linked_map.center, 4000 + 250 * linked_z_level[1].z_value)

/datum/orbital_object/z_linked/beacon/weak
	name = "Weak Signal"

//====================
// Asteroids
//====================

/datum/orbital_object/z_linked/beacon/ruin/asteroid
	name = "Asteroid"
	render_mode = RENDER_MODE_DEFAULT
	var/static/list/rare_minerals = list(
		/obj/item/stack/ore/uranium = 5, /obj/item/stack/ore/diamond = 1, /obj/item/stack/ore/gold = 10,
		/obj/item/stack/ore/silver = 12, /obj/item/stack/ore/plasma = 20, /obj/item/stack/ore/titanium = 11,
		/turf/closed/mineral/gibtonite = 6, /obj/item/stack/ore/bluespace_crystal = 1
	)
	var/static/list/common_minerals = list(
		/obj/item/stack/ore/uranium = 2, /obj/item/stack/ore/gold = 3,
		/obj/item/stack/ore/silver = 8, /obj/item/stack/ore/plasma = 15, /obj/item/stack/ore/iron = 40,
		/turf/closed/mineral/gibtonite = 4,
		/obj/item/stack/ore/copper = 15
	)
	/// Minerals that we contain, associating to their weight of spawning
	var/list/minerals = list()
	var/rare_material_point = 0

/datum/orbital_object/z_linked/beacon/ruin/asteroid/New()
	. = ..()
	radius = rand(30, 70)
	SSorbits.asteroids ++
	// Generate spawned minerals
	minerals[/datum] = rand(100, 300)
	// Generate some rich materials
	for (var/i in 1 to rand(0, 3))
		var/selected_type = pick_weight(common_minerals)
		minerals[selected_type] = max(rand(50, 150), minerals[selected_type])
	// Generate other materials
	for (var/i in 1 to rand(2, 4))
		var/selected_type = pick_weight(common_minerals)
		minerals[selected_type] = max(rand(5, 30), minerals[selected_type])
	// Generate rare materials
	for (var/i in 1 to rand(0, 2))
		var/selected_type = pick_weight(rare_minerals)
		minerals[selected_type] = max(rand(5, 30), minerals[selected_type])
	// Convert into 0 to 1 ranges
	var/maximum = 0
	for (var/material_type in minerals)
		maximum += minerals[material_type]
	var/current = 0
	for (var/material_type in minerals)
		var/stored_current = minerals[material_type]
		minerals[material_type] = current / maximum
		current += stored_current
	rare_material_point = rand(40, 70)/100

/datum/orbital_object/z_linked/beacon/ruin/asteroid/Destroy(force, ...)
	. = ..()
	SSorbits.asteroids --

/datum/orbital_object/z_linked/beacon/ruin/asteroid/assign_z_level()
	var/datum/space_level/assigned_space_level = SSzclear.get_free_z_level()
	linked_z_level = list(assigned_space_level)
	SSorbits.assoc_z_levels["[assigned_space_level.z_value]"] = src
	var/list/sizes = generate_asteroids(world.maxx / 2, world.maxy / 2, assigned_space_level.z_value, 4, 7, rand(-0.4, -0.6), rand(20, 40), list(/turf/closed/mineral = 0, /turf/closed/mineral/tough = rare_material_point * 0.3, /turf/closed/mineral/hard = rare_material_point * 0.6, /turf/closed/mineral/dense = rare_material_point), minerals)
	contained_zones += new /datum/orbital_zone(name, sizes[1], sizes[3], sizes[4], sizes[2], assigned_space_level.z_value)

/datum/orbital_object/z_linked/beacon/ruin/asteroid/post_map_setup()
	//Orbit around the systems central gravitional body
	//Pack closely together to make an asteriod belt.
	var/datum/orbital_map/linked_map = SSorbits.orbital_maps[orbital_map_index]
	set_orbitting_around_body(linked_map.center, 1200 + 20 * rand(-10, 10))

/datum/orbital_object/z_linked/beacon/ruin/asteroid/get_scan_data()
	var/data = list()
	data["Mineral Scan"] = list()
	var/index = 0
	for (var/turf/closed/mineral/mineral_path as() in minerals)
		var/atom/mineral_type = mineral_path
		index ++
		if (mineral_path == /turf/closed/mineral || !mineral_path || mineral_path == /datum)
			continue
		if (ispath(mineral_type, /turf/closed/mineral))
			mineral_type = initial(mineral_path.mineralType)
		if (!mineral_type)
			continue
		var/spawn_point = minerals[mineral_path]
		var/proportion = index == length(minerals) ? (1 - spawn_point) : (minerals[minerals[index + 1]] - spawn_point)
		data["Mineral Scan"] += "[initial(mineral_type.name)] - [round(proportion * 100)]%"
	return data

//====================
// Regular Ruin Z-levels
//====================

/datum/orbital_object/z_linked/beacon/ruin/spaceruin
	name = "Unknown Signal"

/datum/orbital_object/z_linked/beacon/ruin/spaceruin/New()
	. = ..()
	SSorbits.ruin_levels ++

/datum/orbital_object/z_linked/beacon/ruin/spaceruin/Destroy(force, ...)
	. = ..()
	SSorbits.ruin_levels --

/datum/orbital_object/z_linked/beacon/ruin/spaceruin/assign_z_level()
	var/datum/space_level/assigned_space_level = SSzclear.get_free_z_level()
	linked_z_level = list(assigned_space_level)
	SSorbits.assoc_z_levels["[assigned_space_level.z_value]"] = src
	seedRuins(list(assigned_space_level.z_value), CONFIG_GET(number/space_budget), /area/space, SSmapping.space_ruins_templates)

/datum/orbital_object/z_linked/beacon/ruin/spaceruin/post_map_setup()
	//Orbit around the systems sun
	var/datum/orbital_map/linked_map = SSorbits.orbital_maps[orbital_map_index]
	set_orbitting_around_body(linked_map.center, 4000 + 250 * rand(4, 20))

//====================
// Random-Ruin z-levels
//====================
/datum/orbital_object/z_linked/beacon/ruin
	//The linked objective to the ruin, for generating extra stuff if required.
	var/datum/orbital_objective/linked_objective

/datum/orbital_object/z_linked/beacon/ruin/Destroy()
	//Remove linked objective.
	if(linked_objective)
		linked_objective.linked_beacon = null
		linked_objective = null
	. = ..()

/datum/orbital_object/z_linked/beacon/ruin/proc/assign_z_level()
	var/datum/space_level/assigned_space_level = SSzclear.get_free_z_level()
	linked_z_level = list(assigned_space_level)
	SSorbits.assoc_z_levels["[assigned_space_level.z_value]"] = src
	generate_space_ruin(world.maxx / 2, world.maxy / 2, assigned_space_level.z_value, 100, 100, linked_objective, null, ruin_event)

/datum/orbital_object/z_linked/beacon/ruin/post_map_setup()
	//Orbit around the systems sun
	var/datum/orbital_map/linked_map = SSorbits.orbital_maps[orbital_map_index]
	set_orbitting_around_body(linked_map.center, 4000 + 250 * rand(4, 20))

//====================
//Stranded shuttles
//====================
/datum/orbital_object/z_linked/beacon/ruin/stranded_shuttle
	name = "Distress Beacon"
	static_object = TRUE

/datum/orbital_object/z_linked/beacon/ruin/stranded_shuttle/assign_z_level()
	var/datum/space_level/assigned_space_level = SSzclear.get_free_z_level()
	linked_z_level = list(assigned_space_level)
	SSorbits.assoc_z_levels["[assigned_space_level.z_value]"] = src
	generate_asteroids(world.maxx / 2, world.maxy / 2, assigned_space_level.z_value, 40, 120, -0.4, 40)

/datum/orbital_object/z_linked/beacon/ruin/stranded_shuttle/post_map_setup()
	return

//====================
//Interdiction
//====================
/datum/orbital_object/z_linked/beacon/ruin/interdiction
	name = "Distress Beacon"
	static_object = TRUE

/datum/orbital_object/z_linked/beacon/ruin/interdiction/assign_z_level()
	var/datum/space_level/assigned_space_level = SSzclear.get_free_z_level()
	linked_z_level = list(assigned_space_level)
	SSorbits.assoc_z_levels["[assigned_space_level.z_value]"] = src

/datum/orbital_object/z_linked/beacon/ruin/interdiction/post_map_setup()
	return
