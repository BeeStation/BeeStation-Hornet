/obj/item/floor_buffer
	name = "floor buffer"
	desc = "A shiny station is a... a shiny station."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "buffer"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	force = 8
	throwforce = 10
	block_upgrade_walk = 1
	throw_speed = 3
	throw_range = 7
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("polished", "bashed", "bludgeoned", "whacked")
	resistance_flags = FLAMMABLE
	///How fast we polish floors
	var/buffer_speed = 1
	///How long it takes to polish a floor
	var/buffer_time = 1 SECONDS

/obj/item/floor_buffer/super
	name = "super floor buffer"
	buffer_speed = 5

/obj/item/floor_buffer/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	var/turf/T = get_turf(A)
	//Check for dirt / cleanable shit on the tile - the tile needs to be clean to buffer
	for(var/obj/effect/O in A)
		if(is_cleanable(O))
			to_chat(user, "<span class='danger'>[T] is too dirty!</span>")
			return
	//Make the floor shiny & handle wet floor shit
	var/time = buffer_time / buffer_speed
	if(do_after(user, time, T))
		var/datum/component/wet_floor/W = T.GetComponent(/datum/component/wet_floor)
		qdel(W)
		T.make_shiny(SHINE_REFLECTIVE)
		to_chat(user, "<span class='notice'>You polish [T].</span>")
