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

	var/shuttle_id						//The shuttle we are connected to
	var/selected_ship_id = null
	var/list/concurrent_users = list()	//List of users in this console. Shouldn't cause hard deletes as UIs are closed upon mob deletion which calls ui_close.

	var/extra_range = 3

	//Weapon systems
	var/datum/weakref/selected_weapon_system = null

	// Stuff needed to render the map
	var/map_name
	var/const/default_map_size = 15
	//Contents holder to make the turfs clickable :^)
	var/atom/movable/screen/map_view/weapons_console/cam_screen
	/// All the plane masters that need to be applied.
	var/list/cam_plane_masters
	var/atom/movable/screen/plane_master/o_light_visual/visual_plane_master
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
	cam_plane_masters = list()
	for(var/plane in subtypesof(/atom/movable/screen/plane_master) - /atom/movable/screen/plane_master/blackness)
		var/atom/movable/screen/plane_master/instance = new plane()
		if(instance.blend_mode_override)
			instance.blend_mode = instance.blend_mode_override
		instance.assigned_map = map_name
		instance.del_on_map_removal = FALSE
		instance.screen_loc = "[map_name]:CENTER"
		cam_plane_masters += instance
	visual_plane_master = new
	visual_plane_master.name = "plane_master"
	visual_plane_master.assigned_map = map_name
	visual_plane_master.del_on_map_removal = FALSE
	visual_plane_master.screen_loc = "[map_name]:CENTER"
	cam_background = new
	cam_background.assigned_map = map_name
	cam_background.del_on_map_removal = FALSE
	//If we spawn on a ship after the ship is registered, find what ship we are on.
	//If the ship isn't registered yet, upon completion, it will find us.
	get_attached_ship()

/obj/machinery/computer/weapons/Destroy()
	QDEL_NULL(cam_screen)
	QDEL_LIST(cam_plane_masters)
	QDEL_NULL(visual_plane_master)
	QDEL_NULL(cam_background)
	concurrent_users = null
	selected_weapon_system = null
	return ..()

/obj/machinery/computer/weapons/attackby(obj/item/I, mob/living/user, params)
	if (istype(I, /obj/item/shuttle_creator))
		var/obj/item/shuttle_creator/creator = I
		if (creator.linkedShuttleId)
			shuttle_id = creator.linkedShuttleId
			to_chat(user, "<span class='notice'>You link [src] to the shuttle.</span>")
		else
			to_chat(user, "<span class='warning'>[I] is not attached to a shuttle.</span>")
		return
	. = ..()


/obj/machinery/computer/weapons/ui_interact(mob/user, datum/tgui/ui = null)
	if(..())
		return
	if(!user.client)
		return
	if(CONFIG_GET(flag/disable_shuttle_weapons))
		//Boring!
		to_chat(user, "<span class='warning'>Nanotrasen have restricted the use of shuttle based weaponry in this sector.</span>")
		return
	var/datum/shuttle_data/our_ship = SSorbits.get_shuttle_data(shuttle_id)
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
		for(var/plane in cam_plane_masters)
			user.client.register_map_obj(plane)
		user.client.register_map_obj(visual_plane_master)
		user.client.register_map_obj(cam_background)
		// Open UI
		ui = new(user, src, "WeaponConsole")
		ui.set_autoupdate(TRUE)
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
	//Not attached to any shuttle
	var/datum/shuttle_data/our_ship = SSorbits.get_shuttle_data(shuttle_id)
	var/datum/orbital_object/shuttle/our_shuttle_object = SSorbits.assoc_shuttles[shuttle_id]
	if (!our_ship)
		return data
	//Weapons
	for(var/obj/machinery/shuttle_weapon/weapon in our_ship.shuttle_weapons)
		var/list/active_weapon = list(
			id = weapon.weapon_id,
			name = weapon.name,
			cooldownLeft = max(weapon.next_shot_world_time - world.time, 0),
			cooldown = weapon.cooldown,
			inaccuracy = weapon.innaccuracy,
			disabled = weapon.is_disabled(),
		)
		data["weapons"] += list(active_weapon)
	data["in_flight"] = FALSE
	// We are not currently in flight
	if (!our_shuttle_object)
		return data
	//Send this data over
	data["in_flight"] = TRUE
	//Enemy Ships
	for(var/ship_id in SSorbits.assoc_shuttles)
		var/datum/shuttle_data/ship = SSorbits.get_shuttle_data(ship_id)
		var/datum/orbital_object/shuttle/shuttle_object = SSorbits.assoc_shuttles[ship_id]
		//Don't allow us to shoot ourselfs
		if(!ship || !shuttle_object || ship.port_id == shuttle_id)
			continue
		//Ignore ships that are too far away
		var/obj/target_port = SSshuttle.getShuttle(ship_id)
		if(!target_port || our_shuttle_object.position.DistanceTo(shuttle_object.position) > our_ship.detection_range)
			continue
		// Cannot see stealth ships
		if (ship.stealth)
			continue
		var/list/other_ship = list(
			id = ship_id,
			name = shuttle_object.get_name(),
			health = ship.integrity_remaining,
			maxHealth = ship.max_ship_integrity * ship.critical_proportion,
			critical = ship.reactor_critical,
			aggro_state = our_ship.faction.check_faction_alignment(ship.faction),
		)
		data["ships"] += list(other_ship)
	return data

/obj/machinery/computer/weapons/ui_static_data(mob/user)
	var/list/data = list()
	data["mapRef"] = map_name
	return data

/obj/machinery/computer/weapons/process()
	. = ..()
	//Check target range
	if(selected_ship_id)
		var/datum/orbital_object/shuttle/our_shuttle_object = SSorbits.assoc_shuttles[shuttle_id]
		var/datum/orbital_object/shuttle/shuttle_object = SSorbits.assoc_shuttles[selected_ship_id]
		var/datum/shuttle_data/our_ship = SSorbits.get_shuttle_data(shuttle_id)
		if(!our_ship || !shuttle_object || !our_shuttle_object || our_shuttle_object.position.DistanceTo(shuttle_object.position) > our_ship.detection_range)
			show_camera_static()
			selected_ship_id = null

/obj/machinery/computer/weapons/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("target_ship")
			var/s_id = params["id"]
			playsound(src, get_sfx("terminal_type"), 25, FALSE)
			log_shuttle("Weapons console linked to [shuttle_id] used by [usr] set camera view to ship [s_id]")

			//Invalid ship ID selected
			if(!(s_id in SSorbits.assoc_shuttle_data))
				show_camera_static()
				return TRUE

			var/obj/docking_port/mobile/target = SSshuttle.getShuttle(s_id)
			var/obj/docking_port/mobile/connected_port = SSshuttle.getShuttle(shuttle_id)

			if(!target || !connected_port)
				show_camera_static()
				return TRUE

			//Prevent from HREF exploitation by only allowing viewing of ships that should be in view
			var/datum/orbital_object/shuttle/our_shuttle_object = SSorbits.assoc_shuttles[shuttle_id]
			var/datum/orbital_object/shuttle/shuttle_object = SSorbits.assoc_shuttles[s_id]
			var/datum/shuttle_data/our_ship = SSorbits.get_shuttle_data(shuttle_id)
			if(!our_ship || !shuttle_object || !our_shuttle_object || !our_shuttle_object.position.DistanceTo(shuttle_object.position) > our_ship.detection_range)
				show_camera_static()
				return TRUE

			selected_ship_id = s_id

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

			cam_background.fill_rect(1, 1, \
								clamp(right+extra_range, 1, world.maxx) - clamp(left-extra_range, 1, world.maxx) + 1, \
								clamp(top+extra_range, 1, world.maxy) - clamp(bottom-extra_range, 1, world.maxy) + 1)
			return TRUE
		if("set_weapon_target")
			var/datum/shuttle_data/ship_data = SSorbits.get_shuttle_data(shuttle_id)
			if (ship_data.stealth)
				to_chat(usr, "<span class='warning'>Your ship's cloaking field is jamming the weapons!</span>")
				return
			//Select the weapon system
			//This seems highly exploitable
			var/id = params["id"]
			var/found_weapon = SSorbits.shuttle_weapons["[id]"]
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
	//Update the UI
	ui_update()

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
	user.client?.clear_map(map_name)
	// Turn off the console
	if(length(concurrent_users) == 0 && is_living)
		playsound(src, 'sound/machines/terminal_off.ogg', 25, FALSE)
		use_power(0)

/obj/machinery/computer/weapons/proc/on_target_location(turf/T)
	//Find our weapon
	var/obj/machinery/shuttle_weapon/weapon = selected_weapon_system.resolve()
	if(!weapon)
		log_shuttle("[usr] attempted to target a location, but somehow managed to not have the weapon system targetted.")
		CRASH("[usr] attempted to target a location, but somehow managed to not have the weapon system targetted.")
	//Check if the turf is on the enemy ships turf (Prevents you from firing the console at nearby turfs, or using a weapons console and security camera console to fire at the station)
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(selected_ship_id)
	if(!M)
		log_shuttle("Attempted to fire at [selected_ship_id] although it doesn't exist as a shuttle (likely destroyed).")
		return
	if(!(T in M.return_turfs()))
		return
	// Log that we just attempted an attack
	var/datum/shuttle_data/data = SSorbits.get_shuttle_data(M.id)
	var/datum/shuttle_data/our_data = SSorbits.get_shuttle_data(shuttle_id)
	data.faction.on_attacked_by(our_data.faction)
	weapon.target_turf = T
	//Fire
	INVOKE_ASYNC(weapon, TYPE_PROC_REF(/obj/machinery/shuttle_weapon, fire), shuttle_id)
	to_chat(usr, "<span class='notice'>Weapon target selected successfully.</span>")

/obj/machinery/computer/weapons/proc/get_attached_ship()
	var/area/shuttle/shuttle_area = get_area(src)
	if(!istype(shuttle_area))
		return
	shuttle_id = shuttle_area.mobile_port?.id

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
