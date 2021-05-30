
/obj/effect/abstract/open_area_marker
	name = "open area marker"
	icon = 'icons/obj/device.dmi'
	icon_state = "pinonfar"

/obj/effect/abstract/open_area_marker/Initialize()
	return INITIALIZE_HINT_QDEL

/obj/effect/abstract/doorway_marker
	name = "doorway marker"
	icon = 'icons/obj/device.dmi'
	icon_state = "pinonmedium"

/obj/effect/abstract/doorway_marker/Initialize()
	return INITIALIZE_HINT_QDEL
