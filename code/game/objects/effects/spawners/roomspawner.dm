/obj/effect/spawner/room
	name = "room spawner"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "random_room"
	var/datum/map_template/random_room/template

/obj/effect/spawner/room/proc/LateSpawn()
	template.load(get_turf(src), centered = template.centerspawner)
	qdel(src)

/obj/effect/spawner/room/fivebyfour
	name = "random 5x4 maint room spawner"
	dir = NORTH

/obj/effect/spawner/room/fivebyfour/Initialize()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/spawner/room/fivebyfour/LateInitialize()
	shuffle_inplace(SSmapping.random_room_templates)
	for(var/ID in SSmapping.random_room_templates)
		template = SSmapping.random_room_templates[ID]
		if(istype(template, /datum/map_template/random_room/fivebyfour))
			if(!template.spawned)
				template.spawned = TRUE
				addtimer(CALLBACK(src, /obj/effect/spawner/room.proc/LateSpawn), 600)
				break
		template = null
	if(!template)
		qdel(src)
