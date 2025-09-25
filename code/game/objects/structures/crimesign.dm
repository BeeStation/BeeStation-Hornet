/obj/structure/crimesign
	name = "security holosign"
	icon = 'icons/effects/crimesign.dmi'
	desc = "A laser-holo projected floor marking. This one indicates an active security situation. You probably shouldn't interfere..."
	icon_state = "crimesign"
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	armor_type = /datum/armor/structure_holosign
	layer = LOW_OBJ_LAYER
	plane = FLOOR_PLANE
	light_color = "#ff2466"
	light_range = 1
	light_power = 0.25

/obj/structure/crimesign/Initialize(mapload)
	. = ..()
	alpha = 100
	add_filter("bloom" , 1 , list(type="bloom", size=0.5, offset = 0.1, alpha = 200))
	update_overlays()

/obj/structure/crimesign/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[icon_state]-emissive", layer, alpha)
	ADD_LUM_SOURCE(src, LUM_SOURCE_MANAGED_OVERLAY)

// I can't tell if this is garbage or genius.
/obj/structure/crimesign/proc/align(var/turf/source, var/size)
	// Check if we are the top
	if(y >= source.y + size)
		//We are on the top
		if(x >= source.x + size)
			//We are top right
			icon_state = "crimesign_corner"
			dir = NORTH
			update_appearance(UPDATE_ICON)
			return
		if(x <= source.x - size)
			//We are top left
			icon_state = "crimesign_corner"
			dir = EAST
			update_appearance(UPDATE_ICON)
			return
		// We are neither of the corners, so we are in the middle
		icon_state = "crimesign_straight"
		dir = NORTH
		update_appearance(UPDATE_ICON)
		return

	// Check if we are at the bottom
	if(y <= source.y - size)
		//We are on the bottom
		if(x >= source.x + size)
			//We are bottom right
			icon_state = "crimesign_corner"
			dir = SOUTH
			update_appearance(UPDATE_ICON)
			return
		if(x <= source.x - size)
			//We are bottom left
			icon_state = "crimesign_corner"
			dir = WEST
			update_appearance(UPDATE_ICON)
			return
		// We are neither of the corners, so we are in the middle
		icon_state = "crimesign_straight"
		dir = SOUTH
		update_appearance(UPDATE_ICON)
		return

	// We are neither, so check the sides.
	if(x >= source.x + size)
		//We are top right
		icon_state = "crimesign_straight"
		dir = EAST
		update_appearance(UPDATE_ICON)
		return
	if(x <= source.x - size)
		//We are top left
		icon_state = "crimesign_straight"
		dir = WEST
		update_appearance(UPDATE_ICON)
		return
