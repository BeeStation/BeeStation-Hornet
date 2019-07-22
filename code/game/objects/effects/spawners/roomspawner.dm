/obj/effect/spawner/room
	name = "random room spawner"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "random_room"
	dir = NORTH
	var/datum/map_template/random_room/template
	var/room_width = 0
	var/room_height = 0

/obj/effect/spawner/room/proc/LateSpawn()
	template.load(get_turf(src), centered = template.centerspawner)
	qdel(src)

/obj/effect/spawner/room/Initialize()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/spawner/room/LateInitialize()
	shuffle_inplace(SSmapping.random_room_templates)
	for(var/ID in SSmapping.random_room_templates)
		template = SSmapping.random_room_templates[ID]
		if(istype(template, /datum/map_template/random_room) && room_height == template.template_height && room_width == template.template_width)
			if(!template.spawned)
				template.spawned = TRUE
				addtimer(CALLBACK(src, /obj/effect/spawner/room.proc/LateSpawn), 600)
				break
		template = null
	if(!template)
		qdel(src)
