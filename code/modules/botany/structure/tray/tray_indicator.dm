/*
	Tray light
*/
/obj/effect/tray_indicator
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	appearance_flags = TILE_BOUND|LONG_GLIDE|KEEP_APART
	vis_flags = VIS_INHERIT_ID

/obj/effect/tray_indicator/Initialize(mapload, _color, _index)
	. = ..()
//Base setup
	color = _color
	icon_state = "tray_light_[_index]"
//Emmisive
	var/mutable_appearance/emissive = emissive_appearance(icon, icon_state)
	add_overlay(emissive)
//Animation
	animate(src, alpha = 127, time = 0.5 SECONDS, loop = -1)
	animate(alpha = 255, time = 0.25 SECONDS)

/*
	Tray direction
*/
/obj/effect/tray_direction
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	icon_state = "tray_direction"
	appearance_flags = TILE_BOUND|LONG_GLIDE|KEEP_APART
	vis_flags = VIS_INHERIT_ID
	alpha = 0

/*
	Screen Flash
*/
/obj/effect/hydroponics_screen
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	icon_state = "plant_scanner_on"
	appearance_flags = TILE_BOUND|LONG_GLIDE|KEEP_APART
	vis_flags = VIS_INHERIT_ID | VIS_INHERIT_LAYER | VIS_INHERIT_PLANE
	alpha = 0

/obj/effect/hydroponics_screen/Initialize(mapload, _screen_type)
	. = ..()
	icon_state = _screen_type || icon_state
	var/atom/movable/parent = loc
	if(!istype(parent))
		return
	parent.vis_contents += src

/obj/effect/hydroponics_screen/proc/flash()
	animate(src, alpha = 255, time = 0.1 SECONDS, easing = CUBIC_EASING | EASE_OUT)
	animate(alpha = 0, time = 1.3 SECONDS, easing = CUBIC_EASING | EASE_IN)
