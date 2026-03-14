#define NOOSE_SOURCE "noose"

/obj/item/stack/cable_coil/building_checks(mob/builder, datum/stack_recipe/R, multiplier)
	if(R.result_type == /obj/structure/chair/noose)
		if(!(locate(/obj/structure/chair) in get_turf(builder)))
			to_chat(builder, span_warning("You have to be standing on top of a chair to make a noose!"))
			return FALSE
	return ..()

/obj/structure/chair/noose //It's a "chair".
	name = "noose"
	desc = "Well this just got a whole lot more morbid."
	icon_state = "noose"
	icon = 'icons/obj/objects.dmi'
	layer = FLY_LAYER
	flags_1 = NODECONSTRUCT_1
	pixel_y = 16
	var/mutable_appearance/overlay

/obj/structure/chair/noose/wirecutter_act(mob/living/user, obj/item/tool)
	user.visible_message(
		span_notice("[user] cuts the noose."),
		span_notice("You cut the noose."),
	)

	for(var/mob/living/buckled_mob as anything in buckled_mobs)
		if(!buckled_mob.has_gravity())
			continue
		buckled_mob.visible_message(span_danger("[buckled_mob] falls over and hits the ground!"))
		to_chat(buckled_mob, span_userdanger("You fall over and hit the ground!"))
		buckled_mob.adjustBruteLoss(10)

	new /obj/item/stack/cable_coil(drop_location(), 25)
	qdel(src)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/structure/chair/noose/Initialize(mapload)
	. = ..()
	overlay = image(icon, "noose_overlay")
	overlay.layer = FLY_LAYER
	add_overlay(overlay)

/obj/structure/chair/noose/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/chair/noose/post_buckle_mob(mob/living/M)
	. = ..()
	START_PROCESSING(SSobj, src)
	M.dir = SOUTH
	M.add_offsets(NOOSE_SOURCE, y_add = 8)

/obj/structure/chair/noose/post_unbuckle_mob(mob/living/M)
	. = ..()
	M.remove_offsets(NOOSE_SOURCE)
	if(!has_buckled_mobs())
		pixel_x = base_pixel_x
		pixel_y = base_pixel_y
		STOP_PROCESSING(SSobj, src)

/obj/structure/chair/noose/handle_layer()
	if(has_buckled_mobs())
		layer = MOB_LAYER
	else
		layer = initial(layer)

/obj/structure/chair/noose/user_unbuckle_mob(mob/living/buckled_mob, mob/user)
	if(buckled_mob != user)
		user.visible_message(span_notice("[user] begins to untie the noose over [buckled_mob]'s neck..."))
		to_chat(user, span_notice("You begin to untie the noose over [buckled_mob]'s neck..."))
		if(!do_after(user, 10 SECONDS, buckled_mob))
			return
		user.visible_message(span_notice("[user] unties the noose over [buckled_mob]'s neck!"))
		to_chat(user,span_notice("You untie the noose over [buckled_mob]'s neck!"))
		buckled_mob.Knockdown(6 SECONDS)
	else
		buckled_mob.visible_message(span_warning("[buckled_mob] struggles to untie the noose over their neck!"))
		to_chat(buckled_mob, span_notice("You struggle to untie the noose over your neck... (Stay still for 15 seconds.)"))
		if(!do_after(buckled_mob, 15 SECONDS, target = src))
			if(!QDELETED(buckled_mob) && buckled_mob.buckled)
				to_chat(buckled_mob, span_warning("You fail to untie yourself!"))
			return
		if(!buckled_mob.buckled)
			return
		buckled_mob.visible_message(span_warning("[buckled_mob] unties the noose over their neck!"))
		to_chat(buckled_mob, span_notice("You untie the noose over your neck!"))
		buckled_mob.Knockdown(6 SECONDS)

	add_fingerprint(user)
	return unbuckle_mob(buckled_mob)

/obj/structure/chair/noose/user_buckle_mob(mob/living/carbon/human/M, mob/user, check_loc = TRUE)
	if(!in_range(user, src) || user.stat != CONSCIOUS || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !iscarbon(M))
		return FALSE

	if (!M.get_bodypart(BODY_ZONE_HEAD))
		to_chat(user, span_warning("[M] has no head!"))
		return FALSE

	if(M.loc != src.loc)
		return FALSE //Can only noose someone if they're on the same tile as noose

	add_fingerprint(user)
	log_combat(user, M, "attempted to Hang", src, important = FALSE)
	M.visible_message(span_danger("[user] attempts to tie \the [src] over [M]'s neck!"))
	if(user != M)
		to_chat(user, span_notice("It will take 20 seconds and you have to stand still."))
	if(do_after(user, user == M ? 0 : 20 SECONDS, M))
		if(buckle_mob(M))
			user.visible_message(span_warning("[user] ties \the [src] over [M]'s neck!"))
			if(user == M)
				to_chat(M, span_userdanger("You tie \the [src] over your neck!"))
			else
				to_chat(M, span_userdanger("[user] ties \the [src] over your neck!"))
			playsound(user.loc, 'sound/effects/noosed.ogg', 50, 1, -1)
			log_combat(user, M, "hanged", src, important = FALSE)
			return TRUE
	user.visible_message(span_warning("[user] fails to tie \the [src] over [M]'s neck!"))
	to_chat(user, span_warning("You fail to tie \the [src] over [M]'s neck!"))
	return FALSE

/obj/structure/chair/noose/process()
	if(!has_buckled_mobs())
		STOP_PROCESSING(SSobj, src)
		return
	for(var/mob/living/buckled_mob as anything in buckled_mobs)
		if(pixel_x >= 0)
			animate(src, pixel_x = -3, time = 4.5 SECONDS, easing = ELASTIC_EASING)
			animate(buckled_mob, pixel_x = -3, time = 4.5 SECONDS, easing = ELASTIC_EASING)
		else
			animate(src, pixel_x = 3, time = 4.5 SECONDS, easing = ELASTIC_EASING)
			animate(buckled_mob, pixel_x = 3, time = 4.5 SECONDS, easing = ELASTIC_EASING)

		if(!buckled_mob.has_gravity())
			continue

		if(!buckled_mob.get_bodypart(BODY_ZONE_HEAD))
			buckled_mob.visible_message(span_danger("[buckled_mob] drops from the noose!"))
			buckled_mob.Knockdown(6 SECONDS)
			unbuckle_mob(buckled_mob)
			continue

		if(buckled_mob.stat != DEAD)
			if(!HAS_TRAIT(buckled_mob, TRAIT_NOBREATH))
				buckled_mob.adjustOxyLoss(5)
				if(prob(40))
					buckled_mob.emote("gasp")
			if(prob(20))
				var/flavor_text = pick(
					"[buckled_mob]'s legs flail for anything to stand on.",
					"[buckled_mob]'s hands are desperately clutching the noose.",
					"[buckled_mob]'s limbs sway back and forth with diminishing strength.",
				)
				buckled_mob.visible_message(span_suicide(flavor_text))

		playsound(src, 'sound/effects/noose_idle.ogg', 30, TRUE, -3)

#undef NOOSE_SOURCE
