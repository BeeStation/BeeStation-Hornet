#define WEAPON_SIDE_LEFT -1
#define WEAPON_SIDE_RIGHT 1
#define WEAPON_SIDE_NONE 0

GLOBAL_LIST_EMPTY(shuttle_weapons)

/obj/machinery/shuttle_weapon
	name = "Mounted Emplacement"
	desc = "A weapon system mounted onto a shuttle system."
	icon = 'icons/obj/shuttle_weapons.dmi'
	icon_state = "cannon_left"
	anchored = TRUE
	var/unique_id
	var/projectile_type = /obj/item/projectile/bullet/shuttle/beam/laser
	var/ammunition_type = /obj/item/ammo_box/c9mm
	var/flight_time = 10

	var/shots = 1
	var/shot_time = 2
	var/cooldown = 150

	var/fire_sound = 'sound/weapons/lasercannonfire.ogg'

	var/hit_chance = 60		//The chance that it will hit
	var/miss_chance = 40	//The chance it will miss completely instead of hit nearby (60% hit | 24% hit nearby (inaccuracy) | 16% miss)
	var/innaccuracy = 1		//The range that things will hit, if it doesn't get a perfect hit

	var/turf/target_turf
	var/next_shot_world_time = 0

	var/side = WEAPON_SIDE_LEFT
	var/directional_offset = 32
	var/offset_turf_x = 0
	var/offset_turf_y = 0

/obj/machinery/shuttle_weapon/Initialize()
	. = ..()
	var/static/weapon_systems = 0
	unique_id = weapon_systems++
	GLOB.shuttle_weapons["[unique_id]"] = src
	set_directional_offset(dir, TRUE)

/obj/machinery/shuttle_weapon/setDir(newdir)
	. = ..()
	//Shuttle rotations handle the pixel_x changes, and this shouldn't be rotatable, unless rotated from a shuttle
	set_directional_offset(newdir, FALSE)

/obj/machinery/shuttle_weapon/obj_break(damage_flag)
	qdel(src)

/obj/machinery/shuttle_weapon/proc/set_directional_offset(newdir, update_pixel = FALSE)
	var/offset_value = directional_offset * side
	offset_turf_x = 0
	offset_turf_y = 0
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

/obj/machinery/shuttle_weapon/proc/check_ammo(ammount = 0)
	return TRUE

/obj/machinery/shuttle_weapon/proc/consume_ammo(amount = 0)
	if(!check_ammo())
		return FALSE
	return TRUE

/obj/machinery/shuttle_weapon/proc/fire(atom/target, shots_left = shots, forced = FALSE)
	if(!target)
		if(!target_turf)
			return
		target = target_turf
	if(world.time < next_shot_world_time && !forced)
		return FALSE
	if(!consume_ammo())
		return
	if(!forced)
		next_shot_world_time = world.time + cooldown
	var/turf/current_target_turf = get_turf(target)
	var/missed = FALSE
	if(!prob(hit_chance))
		current_target_turf = locate(target.x + rand(-innaccuracy, innaccuracy), target.y + rand(-innaccuracy, innaccuracy), target.z)
		if(prob(miss_chance))
			missed = TRUE
	playsound(loc, fire_sound, 75, 1)
	//Spawn the projectile to make it look like its firing from your end
	var/obj/item/projectile/P = new projectile_type(get_offset_target_turf(get_turf(src), offset_turf_x, offset_turf_y))
	P.fire(dir2angle(dir))
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
