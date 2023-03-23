/obj/effect/spawner/xeno_egg_delivery
	name = "xeno egg delivery"
	icon = 'icons/mob/alien.dmi'
	icon_state = "egg_growing"
	var/announcement_time = 1200

/obj/effect/spawner/xeno_egg_delivery/Initialize(mapload)
	..()
	var/turf/T = get_turf(src)

	new /obj/structure/alien/egg(T)
	new /obj/effect/temp_visual/gravpush(T)
	playsound(T, 'sound/items/party_horn.ogg', 50, 1, -1)

	message_admins("An alien egg has been delivered to [ADMIN_VERBOSEJMP(T)].")
	log_game("An alien egg has been delivered to [AREACOORD(T)]")
	var/message = "Attention [station_name()], we have entrusted you with a research specimen in [get_area_name(T, TRUE)]. Remember to follow all safety precautions when dealing with the specimen."
	SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_addtimer), CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(print_command_report), message), announcement_time))
	return INITIALIZE_HINT_QDEL

/obj/effect/spawner/xeno_egg_delivery_troll         //We're doing big amount of trolling
	name = "\"xeno egg\" delivery"
	icon = 'icons/mob/mask.dmi'
	icon_state = "clown"
	var/announcement_time = 1000

/obj/effect/spawner/xeno_egg_delivery_troll/Initialize(mapload)
	..()
	var/turf/T = get_turf(src)
	new /obj/structure/alien/egg/troll(T)
	playsound(T, 'sound/items/bikehorn.ogg', 60, 0, 0)

	message_admins("\"A joke\" has been delivered to [ADMIN_VERBOSEJMP(T)].")
	log_game("\"A joke\" has been delivered to [AREACOORD(T)]")
	var/message = "Attention [station_name()], we have entrusted you with a research specimen in [get_area_name(T, TRUE)]. Remember to follow all safety precautions when dealing with the specimen."
	SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_addtimer), CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(print_command_report), message), announcement_time))
	return INITIALIZE_HINT_QDEL
