/obj/machinery/shuttle_weapon
	name = "Mounted Emplacement"
	desc = "A weapon system mounted onto a shuttle system."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "emitter"
	anchored = TRUE
	var/projectile_type = /obj/item/projectile/bullet/shuttle/beam/laser
	var/ammunition_type = /obj/item/ammo_box/c9mm
	var/flight_time = 10

	var/shots = 1
	var/shot_time = 2
	var/cooldown = 150

	var/fire_sound = 'sound/weapons/laser.ogg'

	var/innaccuracy = 3	//The range that things will hit

/obj/machinery/shuttle_weapon/examine(mob/user)
	. = ..()
	fire(user)	//Debug lol

/obj/machinery/shuttle_weapon/proc/check_ammo(ammount = 0)
	return TRUE

/obj/machinery/shuttle_weapon/proc/consume_ammo(amount = 0)
	if(!check_ammo())
		return FALSE
	return TRUE

/obj/machinery/shuttle_weapon/proc/fire(atom/target, shots_left = shots)
	if(!consume_ammo())
		return
	var/turf/target_turf = locate(target.x + rand(-innaccuracy, innaccuracy), target.y + rand(-innaccuracy, innaccuracy), target.z)
	playsound(loc, fire_sound, 75, 1)
	//Spawn the projectile to make it look like its firing from your end
	var/obj/item/projectile/P = new projectile_type(get_turf(src))
	P.fire(dir2angle(dir))
	addtimer(CALLBACK(src, .proc/spawn_incoming_fire, P, target_turf), flight_time)
	//Multishot cannons
	if(shots_left > 0)
		addtimer(CALLBACK(src, .proc/fire, target, shots_left - 1), shot_time)

/obj/machinery/shuttle_weapon/proc/spawn_incoming_fire(obj/item/projectile/P, atom/target)
	if(QDELETED(P))
		return
	qdel(P)
	//Spawn the projectile to come in FTL style
	fire_projectile_towards(target, projectile_type = projectile_type)
