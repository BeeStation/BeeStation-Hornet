/obj/structure/crimesign
	name = "crime-scene holosign"
	icon = 'icons/obj/structures/crimescene.dmi'
	desc = "A laser-holo projected floor marking. This one indicates an active crimescene. You probably shouldn't interfere..."
	icon_state = "crimescene"
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	armor_type = /datum/armor/structure_holosign
	layer = LOW_OBJ_LAYER
	plane = FLOOR_PLANE
	light_color = "#ff2466"
	light_range = 1.5
	light_power = 0.25

/obj/structure/crimesign/Initialize(mapload)
	. = ..()
	alpha = 100
	add_filter("bloom" , 1 , list(type="bloom", size=0.5, offset = 0.1, alpha = 200))

// I can't tell if this is garbage or genius.
/obj/structure/crimesign/proc/align(var/turf/source, var/size)
	// Check if we are the top
	if(y >= source.y + size)
		//We are on the top
		if(x >= source.x + size)
			//We are top right
			icon_state = "crimescene_corner"
			dir = NORTH
			return
		if(x <= source.x - size)
			//We are top left
			icon_state = "crimescene_corner"
			dir = EAST
			return
		// We are neither of the corners, so we are in the middle
		icon_state = "crimescene_straight"
		dir = NORTH
		return

	// Check if we are at the bottom
	if(y <= source.y - size)
		//We are on the bottom
		if(x >= source.x + size)
			//We are bottom right
			icon_state = "crimescene_corner"
			dir = SOUTH
			return
		if(x <= source.x - size)
			//We are bottom left
			icon_state = "crimescene_corner"
			dir = WEST
			return
		// We are neither of the corners, so we are in the middle
		icon_state = "crimescene_straight"
		dir = SOUTH
		return

	// We are neither, so check the sides.
	if(x >= source.x + size)
		//We are top right
		icon_state = "crimescene_straight"
		dir = EAST
		return
	if(x <= source.x - size)
		//We are top left
		icon_state = "crimescene_straight"
		dir = WEST
		return
	update_overlays()
