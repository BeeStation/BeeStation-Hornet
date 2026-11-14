//map and direction signs

/obj/structure/sign/directions/Initialize(mapload)
	. = ..()
	// Whole-tile offsets locate the wall. Sub-tile offsets stack labels on
	// that wall and must stay aligned with their upright lettering.
	var/wall_x = FLOOR((pixel_x + ICON_SIZE_X / 2) / ICON_SIZE_X, 1) * ICON_SIZE_X
	var/wall_y = FLOOR((pixel_y + ICON_SIZE_Y / 2) / ICON_SIZE_Y, 1) * ICON_SIZE_Y
	brandish_screen_origin(pixel_x - wall_x, pixel_y - wall_y)

/obj/structure/sign/map
	brandish_icon_mode = "surface"
	name = "station map"
	desc = "A framed picture of the station."
	max_integrity = 500

/obj/structure/sign/map/left
	icon_state = "map-left"

/obj/structure/sign/map/right
	icon_state = "map-right"
	
/obj/structure/sign/map/echo
	desc = "A framed picture of a floor on Echo Station."
	icon_state = "map-echo"

/obj/structure/sign/directions/science
	name = "science department"
	desc = "A direction sign, pointing out which way the Science department is."
	icon_state = "direction_sci"

/obj/structure/sign/directions/engineering
	name = "engineering department"
	desc = "A direction sign, pointing out which way the Engineering department is."
	icon_state = "direction_eng"

/obj/structure/sign/directions/security
	name = "security department"
	desc = "A direction sign, pointing out which way the Security department is."
	icon_state = "direction_sec"

/obj/structure/sign/directions/medical
	name = "medical bay"
	desc = "A direction sign, pointing out which way the Medical Bay is."
	icon_state = "direction_med"

/obj/structure/sign/directions/evac
	name = "escape arm"
	desc = "A direction sign, pointing out which way the escape shuttle dock is."
	icon_state = "direction_evac"

/obj/structure/sign/directions/supply
	name = "cargo bay"
	desc = "A direction sign, pointing out which way the Cargo Bay is."
	icon_state = "direction_supply"

/obj/structure/sign/directions/command
	name = "command department"
	desc = "A direction sign, pointing out which way the Command department is."
	icon_state = "direction_bridge"
	
	
	
	
