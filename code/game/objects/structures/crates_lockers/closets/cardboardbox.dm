#define SNAKE_SPAM_TICKS 600 //how long between cardboard box openings that trigger the '!'
/obj/structure/closet/cardboard
	name = "large cardboard box"
	desc = "Just a box..."
	icon_state = "cardboard"
	mob_storage_capacity = 1
	resistance_flags = FLAMMABLE
	max_integrity = 70
	integrity_failure = 0
	can_weld_shut = FALSE
	cutting_tool = TOOL_WIRECUTTER
	open_sound = "rustle"
	material_drop = /obj/item/stack/sheet/cardboard
	delivery_icon = "deliverybox"
	anchorable = FALSE
	door_anim_time = 0 // no animation
	open_sound = 'sound/machines/cardboard_box.ogg'
	close_sound = 'sound/machines/cardboard_box.ogg'
	open_sound_volume = 35
	close_sound_volume = 35
	var/move_speed_multiplier = 1
	var/move_delay = FALSE
	var/egged = 0

/obj/structure/closet/cardboard/relaymove(mob/living/user, direction)
	if(opened || move_delay || user.incapacitated || !isturf(loc) || !has_gravity(loc))
		return
	move_delay = TRUE
	var/oldloc = loc
	step(src, direction)
	if(oldloc != loc)
		addtimer(CALLBACK(src, PROC_REF(ResetMoveDelay)), CONFIG_GET(number/movedelay/walk_delay) * move_speed_multiplier)
	else
		move_delay = FALSE

/obj/structure/closet/cardboard/proc/ResetMoveDelay()
	move_delay = FALSE

/obj/structure/closet/cardboard/open(mob/living/user, force = FALSE, special_effects)
	if(opened || !can_open())
		return 0
	var/list/alerted = null
	if(egged < world.time)
		var/mob/living/Snake = null
		for(var/mob/living/L in src.contents)
			Snake = L
			break
		if(Snake)
			alerted = viewers(7,src)
	..()
	if(LAZYLEN(alerted))
		egged = world.time + SNAKE_SPAM_TICKS
		for(var/mob/living/L in alerted)
			if(!L.stat)
				if(!INCAPACITATED_IGNORING(L, INCAPABLE_RESTRAINTS))
					L.face_atom(src)
				L.do_alert_animation()
		playsound(loc, 'sound/machines/chime.ogg', 50, FALSE, -5)

/// Does the MGS ! animation
/atom/proc/do_alert_animation()
	var/mutable_appearance/alert = mutable_appearance('icons/obj/storage/closet.dmi', "cardboard_special")
	alert.plane = ABOVE_LIGHTING_PLANE
	var/atom/movable/flick_visual/exclamation = flick_overlay_view(alert, 1 SECONDS)
	exclamation.alpha = 0
	animate(exclamation, pixel_z = 32, alpha = 255, time = 0.5 SECONDS, easing = ELASTIC_EASING)


/obj/structure/closet/cardboard/metal
	name = "large metal box"
	desc = "THE COWARDS! THE FOOLS!"
	icon_state = "metalbox"
	max_integrity = 500
	mob_storage_capacity = 5
	resistance_flags = NONE
	move_speed_multiplier = 2
	cutting_tool = TOOL_WELDER
	open_sound = 'sound/machines/crate_open.ogg'
	close_sound = 'sound/machines/crate_close.ogg'
	open_sound_volume = 35
	close_sound_volume = 50
	material_drop = /obj/item/stack/sheet/plasteel
#undef SNAKE_SPAM_TICKS
