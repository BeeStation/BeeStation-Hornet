GLOBAL_LIST_EMPTY(shuttle_weapons)

/obj/machinery/shuttle_weapon
	name = "Mounted Emplacement"
	desc = "A weapon system mounted onto a shuttle system."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "emitter"
	anchored = TRUE
	var/unique_id
	var/projectile_type = /obj/item/projectile/bullet/shuttle/beam/laser
	var/ammunition_type = /obj/item/ammo_box/c9mm
	var/flight_time = 10

	var/shots = 1
	var/shot_time = 2
	var/cooldown = 150

	var/fire_sound = 'sound/weapons/laser.ogg'

	var/innaccuracy = 3	//The range that things will hit

	var/turf/target_turf
	var/next_shot_world_time = 0

/obj/machinery/shuttle_weapon/Initialize()
	. = ..()
	var/static/weapon_systems = 0
	unique_id = weapon_systems++
	GLOB.shuttle_weapons["[unique_id]"] = src

/obj/machinery/shuttle_weapon/examine(mob/user)
	. = ..()
	fire(target_turf)	//Debug lol

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
	var/turf/current_target_turf = locate(target.x + rand(-innaccuracy, innaccuracy), target.y + rand(-innaccuracy, innaccuracy), target.z)
	playsound(loc, fire_sound, 75, 1)
	//Spawn the projectile to make it look like its firing from your end
	var/obj/item/projectile/P = new projectile_type(get_turf(src))
	P.fire(dir2angle(dir))
	addtimer(CALLBACK(src, .proc/spawn_incoming_fire, P, current_target_turf), flight_time)
	//Multishot cannons
	if(shots_left > 1)
		addtimer(CALLBACK(src, .proc/fire, target, shots_left - 1, TRUE), shot_time)

/obj/machinery/shuttle_weapon/proc/spawn_incoming_fire(obj/item/projectile/P, atom/target)
	if(QDELETED(P))
		return
	qdel(P)
	//Spawn the projectile to come in FTL style
	fire_projectile_towards(target, projectile_type = projectile_type)
