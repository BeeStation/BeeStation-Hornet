/obj/effect/tray_indicator
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	vis_flags = 0
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
