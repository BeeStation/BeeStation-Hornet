/obj/structure/crimesign
	name = "crime-scene holosign"
	icon = 'icons/obj/structures/crimescene.dmi'
	desc = "A laser-holo projected floor marking. This one indicates an active crimescene. You probably shouldn't interfere..."
	icon_state = "crimescene"
	anchored = TRUE
	max_integrity = 1
	armor_type = /datum/armor/structure_holosign
	layer = LOW_OBJ_LAYER
	var/user_mob //Whoever made us

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

/obj/structure/crimesign/proc/align(var/turf/source)
	switch(source.x)
