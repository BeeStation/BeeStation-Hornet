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
	var/projectile_type = /obj/item/projectile/bullet/shuttle/beam/laser
	var/flight_time = 10

	var/shots = 1
	var/simultaneous_shots = 1
	var/shot_time = 2
	var/cooldown = 150

	var/fire_sound = 'sound/weapons/lasercannonfire.ogg'

	var/hit_chance = 60		//The chance that it will hit
	var/miss_chance = 40	//The chance it will miss completely instead of hit nearby (60% hit | 24% hit nearby (inaccuracy) | 16% miss)
	var/innaccuracy = 1		//The range that things will hit, if it doesn't get a perfect hit

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
	. = ..()

/obj/machinery/shuttle_weapon/examine(mob/user)
	. = ..()
	. += "It could be rotated with a <b>wrench</b>!"
	. += "It seems to be <b>welded</b> in place!"

/obj/machinery/shuttle_weapon/attackby(obj/item/I, mob/living/user, params)
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

/obj/machinery/shuttle_weapon/proc/fire(atom/target, shots_left = shots, forced = FALSE)
	if(!target)
		if(!target_turf)
			return
		target = target_turf
	if(world.time < next_shot_world_time && !forced)
		return FALSE
	if(!forced)
		next_shot_world_time = world.time + cooldown
	var/turf/current_target_turf = get_turf(target)
	var/missed = FALSE
	if(!prob(hit_chance))
		current_target_turf = locate(target.x + rand(-innaccuracy, innaccuracy), target.y + rand(-innaccuracy, innaccuracy), target.z)
		if(prob(miss_chance))
			missed = TRUE
	playsound(loc, fire_sound, 75, 1)
	for(var/i in 1 to simultaneous_shots)
		//Spawn the projectile to make it look like its firing from your end
		var/obj/item/projectile/bullet/shuttle/P = new projectile_type(get_offset_target_turf(get_turf(src), offset_turf_x, offset_turf_y))
		//Outgoing shots shouldn't hit our own ship because its easier
		P.force_miss = TRUE
		P.fire((dir2angle(dir) + angle_offset) % 360)
		addtimer(CALLBACK(src, .proc/spawn_incoming_fire, P, current_target_turf, missed), flight_time)
	//Multishot cannons
	if(shots_left > 1)
		addtimer(CALLBACK(src, .proc/fire, target, shots_left - 1, TRUE), shot_time)

/obj/machinery/shuttle_weapon/proc/spawn_incoming_fire(obj/item/projectile/P, atom/target, missed = FALSE)
	if(QDELETED(P))
		return
	qdel(P)
	//Spawn the projectile to come in FTL style
	fire_projectile_towards(target, projectile_type = projectile_type, missed = missed)


