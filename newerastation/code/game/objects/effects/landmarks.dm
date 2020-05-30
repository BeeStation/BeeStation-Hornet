/obj/effect/landmark/stationroom
	var/list/template_names = list()
	layer = BULLET_HOLE_LAYER

/obj/effect/landmark/stationroom/New()
	..()
	GLOB.stationroom_landmarks += src

/obj/effect/landmark/stationroom/Destroy()
	if(src in GLOB.stationroom_landmarks)
		GLOB.stationroom_landmarks -= src
	return ..()

/obj/effect/landmark/stationroom/proc/load(template_name)
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE
	if(!template_name)
		for(var/t in template_names)
			if(!SSmapping.station_room_templates[t])
				log_world("Station room spawner placed at ([T.x], [T.y], [T.z]) has invalid ruin name of \"[t]\" in its list")
				template_names -= t
		template_name = pick(template_names)
	if(!template_name)
		GLOB.stationroom_landmarks -= src
		qdel(src)
		return FALSE
	var/datum/map_template/template = SSmapping.station_room_templates[template_name]
	if(!template)
		return FALSE
	testing("Ruin \"[template_name]\" placed at ([T.x], [T.y], [T.z])")
	template.load(T, centered = FALSE)
	template.loaded++
	GLOB.stationroom_landmarks -= src
	qdel(src)
	return TRUE

//yoinked from hippie (infiltrators)
/obj/effect/landmark/start/infiltrator
	name = "infiltrator"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "snukeop_spawn"

/obj/effect/landmark/start/infiltrator/Initialize()
	..()
	GLOB.infiltrator_start += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/start/infiltrator_objective
	name = "infiltrator objective items"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "random_loot"

/obj/effect/landmark/start/infiltrator_objective/Initialize()
	..()
	GLOB.infiltrator_objective_items += loc
	return INITIALIZE_HINT_QDEL
