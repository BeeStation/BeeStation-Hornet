/*
 * Handles the firing of weapons at hostile ships.
 * Basically a copy paste of sec camera console, with functionality for weapons, and instead of cameras it looks at tracked docking ports.
 * Additionally handles declaring ships rogue if they fire upon friendly ships, since its much quicker to see what camera they are on than to find what shuttle a turf is attached to.
 */

/obj/machinery/computer/weapons
	name = "weapons control console"
	desc = "a computer for controlling the weapon systems of your shuttle."
	icon_screen = "cameras"
	icon_keyboard = "security_key"
	circuit = /obj/item/circuitboard/computer/shuttle/weapons
	light_color = LIGHT_COLOR_RED

	var/list/weapon_weakrefs = list()	//A list of weakrefs to the weapon systems
	var/shuttle_id						//The shuttle we are connected to
	var/selected_ship_id = null
	var/list/concurrent_users = list()

	var/extra_range = 3

	//Weapon systems
	var/datum/weakref/selected_weapon_system = null

	// Stuff needed to render the map
	var/map_name
	var/const/default_map_size = 15
	//Contents holder to make the turfs clickable :^)
	var/atom/movable/screen/map_view/weapons_console/cam_screen
	var/atom/movable/screen/plane_master/lighting/cam_plane_master
	var/atom/movable/screen/background/cam_background

	//The coords of the top corner
	var/corner_x
	var/corner_y
	var/corner_z

/obj/machinery/computer/weapons/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	map_name = "weapon_console_[REF(src)]_map"
	// Initialize map objects
	cam_screen = new
	cam_screen.name = "screen"
	cam_screen.assigned_map = map_name
	cam_screen.del_on_map_removal = FALSE
	cam_screen.screen_loc = "[map_name]:1,1"
	cam_screen.link_to_console(src)
	cam_plane_master = new
	cam_plane_master.name = "plane_master"
	cam_plane_master.assigned_map = map_name
	cam_plane_master.del_on_map_removal = FALSE
	cam_plane_master.screen_loc = "[map_name]:CENTER"
	cam_background = new
	cam_background.assigned_map = map_name
	cam_background.del_on_map_removal = FALSE
	if(!shuttle_id)
		addtimer(CALLBACK(src, .proc/get_attached_ship), 10)

/obj/machinery/computer/weapons/Destroy()
	qdel(cam_screen)
	qdel(cam_plane_master)
	qdel(cam_background)
	return ..()

/obj/machinery/computer/weapons/ui_interact(mob/user, datum/tgui/ui = null)
	if(..())
		return
	if(!CONFIG_GET(flag/bluespace_exploration_weapons))
		//Boring!
		to_chat(user, "<span class='warning'>Nanotrasen have restricted the use of shuttle based weaponry in this sector. Sorry for the inconvinience.</span>")
		return
	var/datum/ship_datum/our_ship = SSbluespace_exploration.tracked_ships[shuttle_id]
	//Must actually be on a ship
	if(!our_ship)
		to_chat(user, "<span class='warning'>Weapon control console not linked to a shuttle.</span>")
		return
	// Update UI
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		var/user_ref = REF(user)
		var/is_living = isliving(user)
		// Ghosts shouldn't count towards concurrent users, which produces
		// an audible terminal_on click.
		if(is_living)
			concurrent_users += user_ref
		// Turn on the console
		if(length(concurrent_users) == 1 && is_living)
			playsound(src, 'sound/machines/terminal_on.ogg', 25, FALSE)
			use_power(active_power_usage)
			//Show camera static to the first viewer, since it hides potential mess ups with scaling and viewing dead ships.
			show_camera_static()
		// Register map objects
		user.client.register_map_obj(cam_screen)
		user.client.register_map_obj(cam_plane_master)
		user.client.register_map_obj(cam_background)
		// Open UI
		ui = new(user, src, "WeaponConsole")
		ui.open()

/obj/machinery/computer/weapons/ui_data(mob/user)
	var/list/data = list()
	var/obj/docking_port/mobile/connected_port = SSshuttle.getShuttle(shuttle_id)
	data["selectedShip"] = selected_ship_id
	data["weapons"] = list()
	data["ships"] = list()
	if(!connected_port)
		log_shuttle("Weapons console linked to [shuttle_id] could not locate a connected port using SSshuttle system.")
		return data
	var/datum/ship_datum/our_ship = SSbluespace_exploration.tracked_ships[shuttle_id]
	if(!our_ship || !our_ship.combat_allowed)
		return data
	//Enemy Ships
	for(var/ship_id in SSbluespace_exploration.tracked_ships)
		var/datum/ship_datum/ship = SSbluespace_exploration.tracked_ships[ship_id]
		//Shooting ourself, 🤔
		if(ship.mobile_port_id == shuttle_id)
			continue
		//Ignore ships that are on different z-levels#
		var/obj/target_port = SSshuttle.getShuttle(ship_id)
		if(!target_port || target_port.z != connected_port.z)
			continue
		if(!ship.combat_allowed)
			continue
		var/datum/faction/their_faction = ship.ship_faction
		var/list/other_ship = list(
			id = ship_id,
			name = ship.ship_name,
			faction = ship.ship_faction,
			health = ship.integrity_remaining,
			maxHealth = ship.max_ship_integrity * SHIP_INTEGRITY_FACTOR,
			critical = ship.critical,
			//If they consider us hostile (AI works on if we consider them hostile policy, but that is confusing for players to be shot at by 'friendly' ships).
			hostile = check_faction_alignment(ship.ship_faction, our_ship.ship_faction) == FACTION_STATUS_HOSTILE || (their_faction.type in our_ship.rogue_factions),
		)
		data["ships"] += list(other_ship)
	var/list/turfs = connected_port.return_turfs()
	//Weapons
	for(var/turf/T as() in turfs)
		for(var/obj/machinery/shuttle_weapon/weapon in T)
			var/list/active_weapon = list(
				id = weapon.unique_id,
				name = weapon.name,
				cooldownLeft = max(weapon.next_shot_world_time - world.time, 0),
				cooldown = weapon.cooldown,
				inaccuracy = weapon.innaccuracy,
			)
			data["weapons"] += list(active_weapon)
	return data

/obj/machinery/computer/weapons/ui_static_data(mob/user)
	var/list/data = list()
	data["mapRef"] = map_name
	return data

/obj/machinery/computer/weapons/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("target_ship")
			var/s_id = params["id"]
			playsound(src, get_sfx("terminal_type"), 25, FALSE)
			log_shuttle("Weapons console linked to [shuttle_id] used by [usr] set camera view to ship [s_id]")

			if(!(s_id in SSbluespace_exploration.tracked_ships))
				show_camera_static()
				return TRUE

			var/obj/docking_port/mobile/target = SSshuttle.getShuttle(s_id)
			selected_ship_id = s_id

			if(!target)
				show_camera_static()
				return TRUE

			//Target.return_turfs() but with added range
			var/list/L = target.return_coords()
			var/left = min(L[1], L[3])
			var/right = max(L[1], L[3])
			var/top = max(L[2], L[4])
			var/bottom = min(L[2], L[4])
			var/turf/T0 = locate(CLAMP(left-extra_range, 1, world.maxx), CLAMP(top+extra_range, 1, world.maxy), target.z)
			var/turf/T1 = locate(CLAMP(right+extra_range, 1, world.maxx), CLAMP(bottom-extra_range, 1, world.maxy), target.z)
			var/list/visible_turfs = block(T0,T1)

			//Corner turfs for calculations when screen is clicked.
			//Idk why I have to subtract extra range but I do
			corner_x = left - extra_range
			corner_y = bottom - extra_range
			corner_z = target.z

			cam_screen.vis_contents = visible_turfs
			cam_background.icon_state = "clear"

			var/list/bbox = get_bbox_of_atoms(visible_turfs)
			var/size_x = bbox[3] - bbox[1] + 1
			var/size_y = bbox[4] - bbox[2] + 1
			cam_background.fill_rect(1, 1, size_x, size_y)
			return TRUE
		if("set_weapon_target")
			//Select the weapon system
			//This seems highly exploitable
			var/id = params["id"]
			var/found_weapon = GLOB.shuttle_weapons["[id]"]
			if(!found_weapon)
				to_chat(usr, "<span class='warning'>Failed to locate weapon system.</span>")
				return
			selected_weapon_system = WEAKREF(found_weapon)
			//Grant spell for selection (Intercepts next click)
			var/mob/living/user = usr
			if(!istype(user))
				return FALSE
			var/obj/effect/proc_holder/spell/set_weapon_target/spell = new
			user.mob_spell_list += spell
			spell.linked_console = src
			spell.add_ranged_ability(user, "", TRUE)
			to_chat(usr, "<span class='notice'>Weapon targetting enabled, select target location.</span>")
			return TRUE

/obj/machinery/computer/weapons/afterShuttleMove(turf/oldT, list/movement_force, shuttle_dir, shuttle_preferred_direction, move_dir, rotation)
	. = ..()
	//Show camera static after jumping away so we don't get to see the ship being deleted by the SS
	show_camera_static()

/obj/machinery/computer/weapons/proc/show_camera_static()
	cam_screen.vis_contents.Cut()
	cam_background.icon_state = "scanline2"
	cam_background.fill_rect(1, 1, default_map_size, default_map_size)

/obj/machinery/computer/weapons/ui_close(mob/user)
	var/user_ref = REF(user)
	var/is_living = isliving(user)
	// Living creature or not, we remove you anyway.
	concurrent_users -= user_ref
	// Unregister map objects
	user.client.clear_map(map_name)
	// Turn off the console
	if(length(concurrent_users) == 0 && is_living)
		playsound(src, 'sound/machines/terminal_off.ogg', 25, FALSE)
		use_power(0)
	//Remove spell from user if they have it.
	user.RemoveSpell(/obj/effect/proc_holder/spell/set_weapon_target)

/obj/machinery/computer/weapons/proc/on_target_location(turf/T)
	//Find our weapon
	var/obj/machinery/shuttle_weapon/weapon = selected_weapon_system.resolve()
	if(!weapon)
		log_shuttle("[usr] attempted to target a location, but somehow managed to not have the weapon system targetted.")
		log_runtime("[usr] attempted to target a location, but somehow managed to not have the weapon system targetted.")
		return
	CHECK_TICK
	//Check if the turf is on the enemy ships turf (Prevents you from firing the console at nearby turfs, or using a weapons console and security camera console to fire at the station)
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(selected_ship_id)
	CHECK_TICK
	if(!M)
		log_shuttle("Attempted to fire at [selected_ship_id] although it doesn't exist as a shuttle (likely destroyed).")
		return
	if(!(T in M.return_turfs()))
		return
	weapon.target_turf = T
	CHECK_TICK
	//Fire
	INVOKE_ASYNC(weapon, /obj/machinery/shuttle_weapon.proc/fire)
	to_chat(usr, "<span class='notice'>Weapon target selected successfully.</span>")
	CHECK_TICK
	//Handle declaring ships rogue
	var/datum/ship_datum/our_ship = SSbluespace_exploration.tracked_ships[shuttle_id]
	var/datum/ship_datum/their_ship = SSbluespace_exploration.tracked_ships[selected_ship_id]
	if(our_ship && their_ship)
		SSbluespace_exploration.after_ship_attacked(our_ship, their_ship)
	else
		log_shuttle("after_ship_attacked unable to call: [our_ship ? "our ship was valid" : "our ship was null"] ([shuttle_id]) and/but [their_ship ? "their ship was valid" : "their ship was null"] ([selected_ship_id])")

/obj/machinery/computer/weapons/proc/get_attached_ship()
	var/turf/our_turf = get_turf(src)
	for(var/shuttle_dock_id in SSbluespace_exploration.tracked_ships)
		var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttle_dock_id)
		if(!M)
			continue
		if(M.z != z)
			continue
		if(our_turf in M.return_turfs())
			shuttle_id = M.id
			break

// ========================
// Custom Map Popups
// Added Functionality:
//  - Click interception.
// Provides the functionality for clicking on turfs, clicking on objects is handled by the spell.
// ========================

/atom/movable/screen/map_view/weapons_console
	var/datum/weakref/linked_console

/atom/movable/screen/map_view/weapons_console/proc/link_to_console(console)
	linked_console = WEAKREF(console)

/atom/movable/screen/map_view/weapons_console/Click(location, control, params)
	. = ..()
	//What we have (X and Y in a range of the screen size (pixel width))
	//What we want (X and Y in the range of the screens view (turf width))

	//Get the console
	var/obj/machinery/computer/weapons/weapons_console = linked_console?.resolve()
	if(!weapons_console)
		return

	//Check if we have a weapon
	if(!weapons_console.selected_weapon_system)
		return

	//Get the x and y offset
	var/x_click = text2num(params2list(params)["icon-x"]) / world.icon_size
	var/y_click = text2num(params2list(params)["icon-y"]) / world.icon_size

	//Find it
	weapons_console.on_target_location(locate(weapons_console.corner_x + x_click, weapons_console.corner_y + y_click, weapons_console.corner_z))
