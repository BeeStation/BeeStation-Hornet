/obj/structure/crimesign
	name = "crime-scene holosign"
	icon = 'icons/obj/structures/crimescene.dmi'
	desc = "A laser-holo projected floor marking. This one indicates an active crimescene. You probably shouldn't interfere..."
	icon_state = "crimescene"
	anchored = TRUE
	max_integrity = 1
	armor_type = /datum/armor/structure_holosign
	layer = LOW_OBJ_LAYER

/obj/structure/crimesign/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	user.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
	user.changeNext_move(CLICK_CD_MELEE)
	take_damage(5 , BRUTE, MELEE, 1)

/obj/structure/crimesign/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(loc, 'sound/weapons/egloves.ogg', 80, 1)
		if(BURN)
			playsound(loc, 'sound/weapons/egloves.ogg', 80, 1)

// I can't tell if this is garbage or genius. This is how we did the bounding boxes when I programmed snake in java back in school.
/obj/structure/crimesign/proc/align(var/turf/source, var/size)







// TODO: CORNERS ARE WACKY, BUNDLE THEM OR SOMETHING









	// Check if we are the top
	if(y >= source.y + size)
		//We are on the top
		if(x >= source.x + size)
			//We are top right
			icon_state = "crimescene_corner"
			dir = NORTH
		if(x <= source.x - size)
			//We are top left
			icon_state = "crimescene_corner"
			dir = EAST
		// We are neither of the corners, so we are in the middle
		icon_state = "crimescene_straight"
		dir = NORTH

	// Check if we are at the bottom
	if(y <= source.y - size)
		//We are on the bottom
		if(x >= source.x + size)
			//We are bottom right
			icon_state = "crimescene_corner"
			dir = SOUTH
		if(x <= source.x - size)
			//We are bottom left
			icon_state = "crimescene_corner"
			dir = WEST
		// We are neither of the corners, so we are in the middle
		icon_state = "crimescene_straight"
		dir = SOUTH

	// We are neither, so check the sides.
	if(x >= source.x + size)
		//We are top right
		icon_state = "crimescene_straight"
		dir = EAST
	if(x <= source.x - size)
		//We are top left
		icon_state = "crimescene_straight"
		dir = WEST
