/area/ocean
	name = "Ocean"
	icon_state = "space"
	requires_power = TRUE
	always_unpowered = TRUE
	power_light = FALSE
	power_equip = FALSE
	has_gravity = STANDARD_GRAVITY
	power_environ = FALSE
	area_flags = VALID_TERRITORY | UNIQUE_AREA | FLORA_ALLOWED
	outdoors = TRUE
	ambience_index = AMBIENCE_SPACE
	flags_1 = CAN_BE_DIRTY_1
	sound_environment = SOUND_AREA_SPACE
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED

/area/ruin/ocean
	has_gravity = TRUE

/area/ruin/ocean/listening_outpost
	area_flags = UNIQUE_AREA

/area/ruin/ocean/bunker
	area_flags = UNIQUE_AREA

/area/ruin/ocean/bioweapon_research
	area_flags = UNIQUE_AREA

/area/ruin/ocean/mining_site
	area_flags = UNIQUE_AREA

/turf/open/openspace/ocean
	name = "ocean"
	planetary_atmos = TRUE
	baseturfs = /turf/open/openspace/ocean
	var/replacement_turf = /turf/open/floor/plating/ocean

/turf/open/openspace/ocean/Initialize()
	. = ..()
	ChangeTurf(replacement_turf, null, CHANGETURF_IGNORE_AIR)

/turf/open/floor/plating/ocean
	gender = PLURAL
	name = "ocean sand"
	baseturfs = /turf/open/floor/plating/ocean
	icon = 'icons/turf/floors/seafloor.dmi'
	icon_state = "seafloor"
	base_icon_state = "seafloor"
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	planetary_atmos = TRUE
	var/obj/effect/abstract/ocean_overlay/static_overlay
	var/list/ocean_reagents = list(/datum/reagent/water = 100)
	var/ocean_temp = T20C - 150

/turf/open/floor/plating/ocean/Initialize()
	. = ..()

/turf/open/floor/plating/ocean/Destroy()
	. = ..()
/obj/effect/abstract/ocean_overlay
	icon = 'icons/effects/liquid.dmi'
	icon_state = "ocean"
	base_icon_state = "ocean"
	plane = BLACKNESS_PLANE //Same as weather, etc.
	layer = ABOVE_MOB_LAYER
	vis_flags = NONE
	mouse_opacity = FALSE

/obj/effect/abstract/ocean_overlay/Initialize(mapload, list/ocean_contents)
	. = ..()
	color = mix_color_from_reagents(ocean_contents)

/turf/open/floor/plating/ocean/proc/movable_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	var/turf/T = source
	if(isobserver(AM))
		return //ghosts, camera eyes, etc. don't make water splashy splashy
	if(prob(30))
		var/sound_to_play = pick(list(
			'sound/effects/water_wade1.ogg',
			'sound/effects/water_wade2.ogg',
			'sound/effects/water_wade3.ogg',
			'sound/effects/water_wade4.ogg'
			))
		playsound(T, sound_to_play, 50, 0)

	SEND_SIGNAL(AM, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WEAK)

//Subtypes for abyss station
/area/ocean/deep
	name = "Deep ocean"
	icon_state = "dark"
	dynamic_lighting = DYNAMIC_LIGHTING_ENABLED

/area/ocean/deep/cavern
	name = "Deep ocean cavern"
	icon_state = "purple"
	ambience_index = AMBIENCE_RUINS
	sound_environment = SOUND_AREA_TUNNEL_ENCLOSED
	area_flags = UNIQUE_AREA | FLORA_ALLOWED | CAVES_ALLOWED | MOB_SPAWN_ALLOWED
	map_generator = /datum/map_generator/cave_generator/ocean
	lighting_overlay_opacity = 0

/turf/open/floor/plating/ocean/abyss
	gender = PLURAL
	name = "ocean floor"
	baseturfs = /turf/open/floor/plating/ocean/abyss
	initial_temperature = T20C
	ocean_reagents = list(/datum/reagent/expired_blood = 100)
	///Warp effect holder for displacement filter
	var/atom/movable/warp_effect/ocean/warp

//Natural ocean lighting
/obj/effect/water_projection
	icon = 'icons/effects/ocean.dmi'
	icon_state = "water"
	base_icon_state = "water"
	plane = LIGHTING_PLANE
	appearance_flags = PIXEL_SCALE
	mouse_opacity = FALSE

/obj/effect/water_projection/Initialize(mapload)
	. = ..()
	//Ripple - use wave, not ripple
	add_filter("water_ripple", 1, wave_filter(x = 1, y = 0, size = 1, offset = 1))
	animate(get_filter("water_ripple"), offset = 50, time = 20 SECONDS, loop = -1)
	animate(offset = 1, time = 20 SECONDS, loop = -1)
	//Bloom
	filters += filter(type = "bloom", threshold = rgb(1, 1, 1), size = 5)
