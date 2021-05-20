/obj/item/stack/cable_coil/building_checks(datum/stack_recipe/R, multiplier)
	if(R.result_type == /obj/structure/chair/noose)
		if(!(locate(/obj/structure/chair) in get_turf(usr)))
			to_chat(usr, "<span class='warning'>You have to be standing on top of a chair to make a noose!</span>")
			return FALSE
	return ..()

/obj/structure/chair/noose //It's a "chair".
	name = "noose"
	desc = "Well this just got a whole lot more morbid."
	icon_state = "noose"
	icon = 'icons/obj/objects.dmi'
	layer = FLY_LAYER
	flags_1 = NODECONSTRUCT_1
	var/mutable_appearance/overlay

/obj/structure/chair/noose/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_WIRECUTTER)
		user.visible_message("[user] cuts the noose.", "<span class='notice'>You cut the noose.</span>")
		if(has_buckled_mobs())
			for(var/m in buckled_mobs)
				var/mob/living/buckled_mob = m
				if(buckled_mob.has_gravity())
					buckled_mob.visible_message("<span class='danger'>[buckled_mob] falls over and hits the ground!</span>")
					to_chat(buckled_mob, "<span class='userdanger'>You fall over and hit the ground!</span>")
					buckled_mob.adjustBruteLoss(10)
		var/obj/item/stack/cable_coil/C = new(get_turf(src))
		C.amount = 25
		qdel(src)
		return
	..()

/obj/structure/chair/noose/Initialize()
	. = ..()
	pixel_y += 16 //Noose looks like it's "hanging" in the air
	overlay = image(icon, "noose_overlay")
	overlay.layer = FLY_LAYER
	add_overlay(overlay, priority = 0)

/obj/structure/chair/noose/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/chair/noose/post_buckle_mob(mob/living/M)
	if(has_buckled_mobs())
		src.layer = MOB_LAYER
		START_PROCESSING(SSobj, src)
		M.dir = SOUTH
		animate(M, pixel_y = initial(pixel_y) + 8, time = 8, easing = LINEAR_EASING)
	else
		layer = initial(layer)
		STOP_PROCESSING(SSobj, src)
		M.pixel_x = initial(M.pixel_x)
		pixel_x = initial(pixel_x)
		M.pixel_y = M.get_standard_pixel_y_offset(M.lying)

/obj/structure/chair/noose/user_unbuckle_mob(mob/living/M,mob/living/user)
	if(has_buckled_mobs())
		if(M != user)
			user.visible_message("<span class='notice'>[user] begins to untie the noose over [M]'s neck...</span>")
			to_chat(user, "<span class='notice'>You begin to untie the noose over [M]'s neck...</span>")
			if(!do_mob(user, M, 100))
				return
			user.visible_message("<span class='notice'>[user] unties the noose over [M]'s neck!</span>")
			to_chat(user,"<span class='notice'>You untie the noose over [M]'s neck!</span>")
			M.Knockdown(60)
		else
			M.visible_message("<span class='warning'>[M] struggles to untie the noose over their neck!</span>")
			to_chat(M,"<span class='notice'>You struggle to untie the noose over your neck... (Stay still for 15 seconds.)</span>")
			if(!do_after(M, 150, target = src))
				if(M && M.buckled)
					to_chat(M, "<span class='warning'>You fail to untie yourself!</span>")
				return
			if(!M.buckled)
				return
			M.visible_message("<span class='warning'>[M] unties the noose over their neck!</span>")
			to_chat(M,"<span class='notice'>You untie the noose over your neck!</span>")
			M.Knockdown(60)
		unbuckle_all_mobs(force=1)
		M.pixel_z = initial(M.pixel_z)
		pixel_z = initial(pixel_z)
		M.pixel_x = initial(M.pixel_x)
		pixel_x = initial(pixel_x)
		add_fingerprint(user)

/obj/structure/chair/noose/user_buckle_mob(mob/living/carbon/human/M, mob/user)
	if(!in_range(user, src) || user.stat || user.restrained() || !iscarbon(M))
		return FALSE

	if (!M.get_bodypart("head"))
		to_chat(user, "<span class='warning'>[M] has no head!</span>")
		return FALSE

	if(M.loc != src.loc)
		return FALSE //Can only noose someone if they're on the same tile as noose

	add_fingerprint(user)
	log_combat(user, M, "Attempted to Hang", src)
	M.visible_message("<span class='danger'>[user] attempts to tie \the [src] over [M]'s neck!</span>")
	if(user != M)
		to_chat(user, "<span class='notice'>It will take 20 seconds and you have to stand still.</span>")
	if(do_mob(user, M, user == M ? 0:200))
		if(buckle_mob(M))
			user.visible_message("<span class='warning'>[user] ties \the [src] over [M]'s neck!</span>")
			if(user == M)
				to_chat(M, "<span class='userdanger'>You tie \the [src] over your neck!</span>")
			else
				to_chat(M, "<span class='userdanger'>[user] ties \the [src] over your neck!</span>")
			playsound(user.loc, 'sound/effects/noosed.ogg', 50, 1, -1)
			log_combat(user, M, "hanged", src)
			return TRUE
	user.visible_message("<span class='warning'>[user] fails to tie \the [src] over [M]'s neck!</span>")
	to_chat(user, "<span class='warning'>You fail to tie \the [src] over [M]'s neck!</span>")
	return FALSE


/obj/structure/chair/noose/process()
	if(!has_buckled_mobs())
		STOP_PROCESSING(SSobj, src)
		return
	for(var/m in buckled_mobs)
		var/mob/living/buckled_mob = m
		if(pixel_x >= 0)
			animate(src, pixel_x = -3, time = 45, easing = ELASTIC_EASING)
			animate(m, pixel_x = -3, time = 45, easing = ELASTIC_EASING)
		else
			animate(src, pixel_x = 3, time = 45, easing = ELASTIC_EASING)
			animate(m, pixel_x = 3, time = 45, easing = ELASTIC_EASING)
		if(buckled_mob.has_gravity())
			if(buckled_mob.get_bodypart("head"))
				if(buckled_mob.stat != DEAD)
					if(!HAS_TRAIT(buckled_mob, TRAIT_NOBREATH))
						buckled_mob.adjustOxyLoss(5)
						if(prob(40))
							buckled_mob.emote("gasp")
					if(prob(20))
						var/flavor_text = list("<span class='suicide'>[buckled_mob]'s legs flail for anything to stand on.</span>",\
												"<span class='suicide'>[buckled_mob]'s hands are desperately clutching the noose.</span>",\
												"<span class='suicide'>[buckled_mob]'s limbs sway back and forth with diminishing strength.</span>")
						buckled_mob.visible_message(pick(flavor_text))
				playsound(buckled_mob.loc, 'sound/effects/noose_idle.ogg', 30, 1, -3)
			else
				buckled_mob.visible_message("<span class='danger'>[buckled_mob] drops from the noose!</span>")
				buckled_mob.Knockdown(60)
				buckled_mob.pixel_z = initial(buckled_mob.pixel_z)
				pixel_z = initial(pixel_z)
				buckled_mob.pixel_x = initial(buckled_mob.pixel_x)
				pixel_x = initial(pixel_x)
				unbuckle_all_mobs(force=1)


