/obj/structure/weightmachine
	name = "chest press machine"
	desc = "Just looking at this thing makes you feel tired."
	icon = 'icons/obj/fitness.dmi'
	icon_state = "stacklifter"
	base_icon_state = "stacklifter"
	can_buckle = TRUE
	buckle_lying = 0
	density = TRUE
	anchored = TRUE
	blocks_emissive = EMISSIVE_BLOCK_UNIQUE

	///How much we shift the user's pixel y when using the weight machine.
	var/pixel_shift_y = -3

	///The weight action we give to people that buckle themselves to us.
	var/datum/action/push_weights/weight_action

	///List of messages picked when using the machine.
	var/static/list/more_weight = list(
		"pushing it to the limit!",
		"going into overdrive!",
		"burning with determination!",
		"rising up to the challenge!",
		"getting strong now!",
		"getting ripped!",
	)
	///List of messages picked when finished using the machine.
	var/static/list/finished_message = list(
		"You feel stronger!",
		"You feel like you can take on the world!",
		"You feel robust!",
		"You feel indestructible!",
	)
	var/static/list/finished_silicon_message = list(
		"You feel nothing!",
		"No pain, no gain!",
		"Chassis hardness rating... Unchanged.",
		"You feel the exact same. Nothing.",
	)

/obj/structure/weightmachine/Initialize(mapload)
	. = ..()

	weight_action = new(src)
	weight_action.weightpress = src

/obj/structure/weightmachine/Destroy()
	QDEL_NULL(weight_action)
	return ..()

/obj/structure/weightmachine/buckle_mob(mob/living/buckled, force, check_loc)
	. = ..()
	weight_action.Grant(buckled)

// /obj/structure/weightmachine/post_buckle_mob(mob/living/buckled)
// 	add_overlay("[base_icon_state]-e")
// 	layer = ABOVE_MOB_LAYER

/obj/structure/weightmachine/unbuckle_mob(mob/living/buckled_mob, force, can_fall)
	. = ..()
	weight_action.Remove(buckled_mob)

// /obj/structure/weightmachine/post_unbuckle_mob(mob/living/buckled)
// 	cut_overlays()

/obj/structure/weightmachine/proc/perform_workout(mob/living/user)
	user.balloon_alert_to_viewers("[pick(more_weight)]")
	START_PROCESSING(SSobj, src)
	if(do_after(user, 8 SECONDS, src) && user.has_gravity())
		user.Stun(2 SECONDS)
		if(issilicon(user) || isipc(user)) //IPCs don't have muscle mass... i think
			user.balloon_alert(user, pick(finished_silicon_message))
		else
			user.balloon_alert(user, pick(finished_message))
		if (user.client)
			user.client.give_award(/datum/award/achievement/misc/weights, user)
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "exercise", /datum/mood_event/exercise)
		user.apply_status_effect(STATUS_EFFECT_EXERCISED)
	end_workout()

/obj/structure/weightmachine/proc/end_workout()
	playsound(src, 'sound/machines/click.ogg', 60, TRUE)
	STOP_PROCESSING(SSobj, src)
	icon_state = initial(icon_state)

/obj/structure/weightmachine/process(seconds_per_tick)
	if(!has_buckled_mobs())
		end_workout()
		return FALSE
	var/image/workout = image(icon, "[base_icon_state]-o", layer = ABOVE_MOB_LAYER)
	workout.plane = GAME_PLANE //I hate the plane cube
	workout.layer = FLY_LAYER
	flick_overlay_view(workout,0.8 SECONDS)
	flick("[base_icon_state]-u", src)
	var/mob/living/user = buckled_mobs[1]
	animate(user, pixel_y = pixel_shift_y, time = 4, SINE_EASING)
	playsound(user, 'sound/machines/creak.ogg', 60, TRUE)
	animate(pixel_y = user.base_pixel_y, time = 4, SINE_EASING)
	return TRUE

/**
 * Weight lifter subtype
 */
/obj/structure/weightmachine/weightlifter
	name = "inline bench press"
	desc = "Just looking at this thing makes you feel fatigued."
	icon = 'icons/obj/fitness.dmi'
	icon_state = "benchpress"
	base_icon_state = "benchpress"
	pixel_shift_y = 5
