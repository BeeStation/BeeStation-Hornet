#define WEAPON_SIDE_LEFT -1
#define WEAPON_SIDE_RIGHT 1
#define WEAPON_SIDE_NONE 0

/obj/machinery/shuttle_weapon
	name = "Mounted Emplacement"
	desc = "A weapon system mounted onto a shuttle system. Use a wrench to rotate."
	icon = 'icons/obj/turrets.dmi'
	icon_state = "syndie_lethal"
	anchored = TRUE
	var/frame_type
	var/flight_time = 10

	var/shots = 1
	var/simultaneous_shots = 1
	var/shot_time = 2
	var/cooldown = 150

	var/fire_sound = 'sound/weapons/lasercannonfire.ogg'

	var/hit_chance = 60		//The chance that it will hit
	var/miss_chance = 30	//The chance it will miss completely instead of hit nearby (60% hit | 24% hit nearby (inaccuracy) | 16% miss)
	var/innaccuracy = 3		//The range that things will hit, if it doesn't get a perfect hit

	var/turf/target_turf
	var/next_shot_world_time = 0

	//For weapons that are side mounted (None after new sprites, but support is still here.)
	var/side = WEAPON_SIDE_LEFT
	var/fire_from_source = TRUE
	var/directional_offset = 0
	var/offset_turf_x = 0
	var/offset_turf_y = 0

	//weapon ID
	var/weapon_id

	//The weapon strength factor
	//Lower numbers indicate that its weaker, higher are stronger.
	//Shuttle strength ranges from 0 to 100, the closer this value is to the shuttle strength, the more likely it will be picked
	var/strength_rating = 0

	//The angle offset to fire projectiles from
	var/angle_offset = 0

	/// The projectile type fired if we just fire them for free
	//TODO: Make this a casing
	var/casing_type = /obj/item/projectile/bullet/shuttle/beam/laser

	/// If true, we can connect to and require an ammunition loader
	var/requires_ammunition = FALSE
	/// If we require ammunition, what calliber do we fire?
	var/fired_caliber = ""
	/// The type of the ammunition loader that we are allowed to connect to
	var/ammo_loader_type = /obj/machinery/ammo_loader
	/// The ammunition loader attached
	var/obj/machinery/ammo_loader/ammunition_loader

	/// The linkup ID for auto-linking to ammo loaders
	var/mapload_linkup_id = 0

/obj/machinery/shuttle_weapon/Initialize(mapload, ndir = 0)
	. = ..()
	weapon_id = "[LAZYLEN(SSorbits.shuttle_weapons)]"
	SSorbits.shuttle_weapons[weapon_id] = src
	set_directional_offset(ndir || dir, TRUE)
	//Check our area
	var/area/shuttle/current_area = get_area(src)
	if(istype(current_area) && current_area.mobile_port)
		var/datum/shuttle_data/shuttle_data = SSorbits.get_shuttle_data(current_area.mobile_port.id)
		shuttle_data?.register_weapon_system(src)

/obj/machinery/shuttle_weapon/Destroy()
	SSorbits.shuttle_weapons.Remove(weapon_id)
	if (ammunition_loader)
		ammunition_loader.attached_weapon = null
	. = ..()

/obj/machinery/shuttle_weapon/examine(mob/user)
	. = ..()
	. += "It could be rotated with a <b>wrench</b>!"
	. += "It seems to be <b>welded</b> in place!"

/obj/machinery/shuttle_weapon/attackby(obj/item/I, mob/living/user, params)
	if (istype(I, /obj/item/multitool))
		var/datum/component/buffer/buff = I.GetComponent(/datum/component/buffer)
		if (buff && istype(buff.referenced_machine, /obj/machinery/ammo_loader))
			var/obj/machinery/ammo_loader/weapon = buff.referenced_machine
			try_link_to(user, weapon)
			return
		I.AddComponent(/datum/component/buffer, src)
		to_chat(user, "<span class='notice'>You add [src] to the buffer of [I].</span>")
		return
	if (I.tool_behaviour == TOOL_WRENCH && I.use_tool(src, user, 0, volume=50))
		setDir(angle2dir(dir2angle(dir) + 90))
		return
	if (I.tool_behaviour == TOOL_WELDER && I.use_tool(src, user, 40, volume=50))
		if (frame_type)
			new frame_type(get_turf(user))
		qdel(src)
		user.visible_message("<span class='notice'>[user] welds [src] off of its mount.</span>")
		return
	. = ..()

/obj/machinery/shuttle_weapon/setDir(newdir)
	. = ..()
	//Shuttle rotations handle the pixel_x changes, and this shouldn't be rotatable, unless rotated from a shuttle
	set_directional_offset(newdir, FALSE)

/obj/machinery/shuttle_weapon/proc/set_directional_offset(newdir, update_pixel = FALSE)
	var/offset_value = directional_offset * side
	offset_turf_x = 0
	offset_turf_y = 0
	if(fire_from_source)
		return
	switch(newdir)
		if(1)
			if(update_pixel)
				pixel_x = offset_value
			offset_turf_x = side
		if(2)
			if(update_pixel)
				pixel_x = -offset_value
			offset_turf_x = -side
		if(4)
			if(update_pixel)
				pixel_y = -offset_value
			offset_turf_y = -side
		if(8)
			if(update_pixel)
				pixel_y = offset_value
			offset_turf_y = side

/obj/machinery/shuttle_weapon/proc/fire(shuttleId, atom/target, shots_left = shots, forced = FALSE)
	if(!target)
		if(!target_turf)
			return
		target = target_turf
	if(world.time < next_shot_world_time && !forced)
		return FALSE
	// Check power
	if (!powered())
		return
	// Check ammunition
	// Fire the shot
	var/turf/current_target_turf = get_turf(target)
	var/missed = FALSE
	if(!prob(hit_chance))
		current_target_turf = locate(target.x + rand(-innaccuracy, innaccuracy), target.y + rand(-innaccuracy, innaccuracy), target.z)
		if(prob(miss_chance))
			missed = TRUE
	playsound(loc, fire_sound, 75, 1)
	if(!forced)
		next_shot_world_time = world.time + cooldown
	for(var/i in 1 to simultaneous_shots)
		//Spawn the projectile to make it look like its firing from your end
		var/obj/item/ammo_casing/fired_casing = get_fired_casing()
		if (!fired_casing)
			return
		fired_casing.forceMove(loc)
		var/obj/item/projectile/bullet/shuttle/P = fired_casing.BB
		fired_casing.BB = null
		if (P)
			//Outgoing shots shouldn't hit our own ship because its easier
			P.is_outgoing = TRUE
			P.fired_from_shuttle = shuttleId
			P.fire((dir2angle(dir) + angle_offset) % 360)
			addtimer(CALLBACK(src, PROC_REF(spawn_incoming_fire), P, current_target_turf, missed), flight_time)
		// This is very janky, but I don't have time to rework projectile casings
		if (istype(fired_casing, /obj/item/ammo_casing/caseless))
			qdel(fired_casing)
			continue
		// Just lob the spent casing
		fired_casing.forceMove(loc)
		fired_casing.bounce_away(TRUE)
	//Multishot cannons
	if(shots_left > 1)
		addtimer(CALLBACK(src, PROC_REF(fire), shuttleId, target, shots_left - 1, TRUE), shot_time)

/obj/machinery/shuttle_weapon/proc/spawn_incoming_fire(obj/item/projectile/bullet/shuttle/P, atom/target, missed = FALSE)
	if(QDELETED(P))
		return
	//Spawn the projectile to come in FTL style
	P.is_outgoing = FALSE
	fire_projectile_towards(target, projectile = P, missed = missed)

/obj/machinery/shuttle_weapon/proc/get_fired_casing()
	RETURN_TYPE(/obj/item/ammo_casing)
	// Instantiate a projectile
	if (!requires_ammunition)
		return new casing_type(loc)
	// Try to fetch a bullet from the ammo loader
	if (!ammunition_loader)
		return null
	return ammunition_loader.take_bullet(fired_caliber)

/obj/machinery/shuttle_weapon/proc/has_ammo()
	if (!requires_ammunition)
		return TRUE
	if (!ammunition_loader)
		return FALSE
	if (!ammunition_loader.has_ammo(fired_caliber))
		return FALSE
	return TRUE

/obj/machinery/shuttle_weapon/proc/try_link_to(mob/user, obj/machinery/ammo_loader/loader)
	if (loader.type != ammo_loader_type)
		var/obj/machinery/ammo_loader/loader_type = ammo_loader_type
		if (user)
			to_chat(user, "<span class='notice'>You cannot connect [src] to [loader], it can only connect to [initial(loader_type.name)].</span>")
		return
	loader.attached_weapon = src
	ammunition_loader = loader
	if (user)
		to_chat(user, "<span class='notice'>You connect [src] to [loader]!</span>")

/obj/machinery/shuttle_weapon/proc/is_disabled()
	if (!is_operational)
		return TRUE
	if (!powered())
		return TRUE
	if (!has_ammo())
		return TRUE
	return FALSE
