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
	var/mutable_appearance/overlay
	var/weight_type = /obj/item/barbell/stacklifting

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
	overlay = mutable_appearance(icon, "[base_icon_state]-s")
	src.add_overlay(overlay)
	weight_action = new(src)
	weight_action.weightpress = src

/obj/structure/weightmachine/Destroy()
	new /obj/item/stack/sheet/iron(loc, 2)
	new /obj/item/stack/rods(loc, 6)
	new weight_type(loc)
	unbuckle_all_mobs()
	QDEL_NULL(weight_action)
	qdel(overlay)
	return ..()

/obj/structure/weightmachine/wrench_act(mob/living/user, obj/item/I)
	if (default_unfasten_wrench(user, I, 50) == 2 && anchored)
		setDir(SOUTH)
	unbuckle_all_mobs()
	return TRUE

/obj/structure/weightmachine/screwdriver_act(mob/living/user, obj/item/I)
	to_chat(user, span_notice("You begin to take apart [src]..."))
	if(I.use_tool(src, user, 40, volume=50))
		to_chat(user, span_notice("You deconstruct [src]."))
		qdel(src)
	return TRUE

/obj/structure/weightmachine/buckle_mob(mob/living/buckled, force, check_loc, needs_anchored = TRUE)
	. = ..()

/obj/structure/weightmachine/post_buckle_mob(mob/living/buckled)
	weight_action.Grant(buckled)
	buckled.add_overlay(overlay)
	src.cut_overlay(overlay)

/obj/structure/weightmachine/unbuckle_mob(mob/living/buckled_mob, force, can_fall)
	. = ..()
	src.add_overlay(overlay)
	buckled_mob.cut_overlay(overlay)
	weight_action.Remove(buckled_mob)

/obj/structure/weightmachine/proc/perform_workout(mob/living/user)
	user.balloon_alert_to_viewers("[pick(more_weight)]")
	START_PROCESSING(SSobj, src)
	if(do_after(user, 8 SECONDS, src) && user.has_gravity())
		user.Stun(0.5 SECONDS)
		if(issilicon(user) || isipc(user)) //IPCs don't have muscle mass... i think
			user.balloon_alert(user, pick(finished_silicon_message))
		else
			user.balloon_alert(user, pick(finished_message))
		if (user.client)
			user.client.give_award(/datum/award/achievement/misc/weights, user)
		if(ishuman(user))
			SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "exercise", /datum/mood_event/exercise)
			user.apply_status_effect(/datum/status_effect/exercised, 40)
	end_workout()

/obj/structure/weightmachine/proc/end_workout()
	playsound(src, 'sound/machines/click.ogg', 60, TRUE)
	STOP_PROCESSING(SSobj, src)
	icon_state = initial(icon_state)

/obj/structure/weightmachine/process(delta_time)
	if(!has_buckled_mobs())
		end_workout()
		return FALSE
	var/mob/living/user = buckled_mobs[1]
	flick("[base_icon_state]-u", src)
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
	weight_type = /obj/item/barbell

/obj/item/barbell
	name = "barbell"
	desc = "A long bar with some huge weights on the ends. Very impressive."
	icon = 'icons/obj/fitness.dmi'
	icon_state = "barbell"
	lefthand_file = 'icons/mob/inhands/equipment/weightlifting.dmi'
	righthand_file = 'icons/mob/inhands/equipment/weightlifting.dmi'
	flags_1 = CONDUCT_1
	force = 16
	throwforce = 16
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY
	attack_weight = 2
	w_class = WEIGHT_CLASS_HUGE
	item_flags = SLOWS_WHILE_IN_HAND
	custom_materials = list(/datum/material/iron=10000)
	throw_speed = 1
	throw_range = 2
	slowdown = 2

/obj/item/barbell/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands=TRUE, block_power_unwielded=block_power, block_power_wielded=block_power)

/obj/item/barbell/stacklifting
	name = "chest press handle"
	desc = "A handle that attaches to some heavy weights. Looks complicated."
	icon_state = "chestpress"
