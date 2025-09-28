/obj/item/holosign_creator
	name = "holographic sign projector"
	desc = "A handy-dandy holographic projector that displays a janitorial sign."
	icon = 'icons/obj/device.dmi'
	icon_state = "signmaker"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	force = 0
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	item_flags = NOBLUDGEON
	var/sign_name = "sign"
	var/list/signs = list()
	var/max_signs = 10
	var/creation_time = 0 //time to create a holosign in deciseconds.
	var/holosign_type = /obj/structure/holosign/wetsign
	var/holocreator_busy = FALSE //to prevent placing multiple holo barriers at once
	var/ranged = FALSE

/obj/item/holosign_creator/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/openspace_item_click_handler)

/obj/item/holosign_creator/handle_openspace_click(turf/target, mob/user, proximity_flag, click_parameters)
	afterattack(target, user, proximity_flag)

/obj/item/holosign_creator/afterattack(atom/target, mob/user, flag)
	. = ..()
	if(flag || ranged)
		if(!check_allowed_items(target, 1))
			return
		var/turf/T = get_turf(target)
		var/obj/structure/holosign/H = locate(holosign_type) in T
		if(H)
			to_chat(user, span_notice("You use [src] to deactivate [H]."))
			qdel(H)
		else
			if(!T.is_blocked_turf(TRUE)) //can't put holograms on a tile that has dense stuff
				if(holocreator_busy)
					to_chat(user, span_notice("[src] is busy creating a hologram."))
					return
				if(length(signs) < max_signs)
					playsound(src.loc, 'sound/machines/click.ogg', 20, 1)
					if(creation_time)
						holocreator_busy = TRUE
						if(!do_after(user, creation_time, target = target))
							holocreator_busy = FALSE
							return
						holocreator_busy = FALSE
						if(length(signs) >= max_signs)
							return
						if(T.is_blocked_turf(TRUE)) //don't try to sneak dense stuff on our tile during the wait.
							return
					H = new holosign_type(get_turf(target), src)
					if(length(signs) == max_signs)
						to_chat(user, span_notice("You create \a [H] with [src]. It cannot project any more [sign_name]\s!"))
					else
						to_chat(user, span_notice("You create \a [H] with [src]. It can project [max_signs - length(signs)] more [sign_name]\s."))
				else
					to_chat(user, span_notice("[src] is projecting at max capacity!"))

/obj/item/holosign_creator/attack(mob/living/carbon/human/M, mob/user)
	return

/obj/item/holosign_creator/attack_self(mob/user)
	if(length(signs))
		var/signs_amount = length(signs)
		for(var/H in signs)
			qdel(H)
		to_chat(user, span_notice("You clear [signs_amount] active [sign_name]\s."))

/obj/item/holosign_creator/examine(mob/user)
	. = ..()
	. += "It has a maximum capacity of [max_signs] [sign_name]\s"
	if(!length(signs))
		. += "It is currently not projecting any [sign_name]\s."
		return
	if(length(signs) < max_signs)
		. += "It is currently projecting [length(signs)] [sign_name]\s."
		return
	if(length(signs) == max_signs)
		. += "It is currently projecting at maximum capacity!"

/obj/item/holosign_creator/janibarrier
	name = "custodial holobarrier projector"
	desc = "A holographic projector that creates hard light wet floor barriers."
	holosign_type = /obj/structure/holosign/barrier/wetsign
	sign_name = "holobarrier"
	custom_price = 200
	creation_time = 20
	max_signs = 12

/obj/item/holosign_creator/security
	name = "security holobarrier projector"
	desc = "A holographic projector that creates holographic security barriers."
	icon_state = "signmaker_sec"
	holosign_type = /obj/structure/holosign/barrier
	actions_types = list(/datum/action/item_action/toggle_crimesigns)
	sign_name = "holobarrier"
	creation_time = 30
	max_signs = 6
	custom_price = 50
	var/active_crimesign = FALSE
	var/list/active_barriers = list()
	var/crimesign_range = 4 //in tiles
	var/cooldown_length = 5 MINUTES
	var/obj/item/radio/radio
	COOLDOWN_DECLARE(crimesign_projector_cooldown)

/obj/item/holosign_creator/security/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_UI_ACTION_CLICK, PROC_REF(on_action_click))

	radio = new/obj/item/radio(src)
	radio.set_listening(FALSE)
	radio.set_frequency(FREQ_SECURITY)

/obj/item/holosign_creator/security/Destroy()
	UnregisterSignal(src, COMSIG_ITEM_UI_ACTION_CLICK)
	QDEL_NULL(radio)
	delete_barriers(FALSE)
	. = ..()

/// Signal proc for [COMSIG_ITEM_UI_ACTION_CLICK] that toggles crimesign on and off if our action button is clicked.
/obj/item/holosign_creator/security/proc/on_action_click(obj/item/source, mob/user, datum/action)
	SIGNAL_HANDLER

	if(!active_crimesign)
		if(COOLDOWN_FINISHED(src, crimesign_projector_cooldown))
			spawn_barriers(user)
		else
			say("Error. Function on cooldown.")
	else
		delete_barriers(FALSE)

	return COMPONENT_ACTION_HANDLED

/obj/item/holosign_creator/security/proc/spawn_barriers(mob/user)
	// Create a square that is 7 tiles radius(A), then one that is 6 in radius(B).
	var/list/regionA = RANGE_TURFS(crimesign_range, user.loc)
	var/list/regionB = RANGE_TURFS(crimesign_range - 1, user.loc)

	// Remove all tiles of B from A to get the bounds.
	var/list/regionC = regionA - regionB

	// Go over each open turf in our bounds list, check for blacklisted objects, then spawn a barrier.
	for(var/turf/open/floor/turf_candidate in regionC)
		if(!turf_candidate.is_blocked_turf(TRUE))
			var/obj/effect/crimesign/barrier = new /obj/effect/crimesign(turf_candidate, get_turf(src), crimesign_range)
			active_barriers += barrier

	playsound(user, 'sound/effects/crimesignalarm.ogg', 10, 0, 4)

	radio.talk_into(src, "Attention: A secure area was declared by [user].")
	say("BYSTANDERS ARE TO VACATE THE AREA.")
	active_crimesign = TRUE
	COOLDOWN_START(src, crimesign_projector_cooldown, cooldown_length)
	addtimer(CALLBACK(src, PROC_REF(delete_barriers), TRUE), cooldown_length / 1.2)
	return

/obj/item/holosign_creator/security/proc/delete_barriers(fizzled)

	if(!active_crimesign)
		return

	for(var/anything as anything in active_barriers)
		active_barriers -= anything
		qdel(anything)

	if(fizzled)
		say("Error. Charge depleted.")
	active_crimesign = FALSE
	return

/obj/item/holosign_creator/engineering
	name = "engineering holobarrier projector"
	desc = "A holographic projector that creates holographic engineering barriers."
	icon_state = "signmaker_engi"
	holosign_type = /obj/structure/holosign/barrier/engineering
	sign_name = "holobarrier"
	creation_time = 30
	max_signs = 6

/obj/item/holosign_creator/atmos
	name = "\improper ATMOS holofan projector"
	desc = "A holographic projector that creates holographic barriers that prevent changes in atmosphere conditions."
	icon_state = "signmaker_atmos"
	holosign_type = /obj/structure/holosign/barrier/atmos
	sign_name = "holofan"
	creation_time = 0
	max_signs = 3

/obj/item/holosign_creator/medical
	name = "\improper PENLITE barrier projector"
	desc = "A holographic projector that creates PENLITE holobarriers. Useful during quarantines since they halt those with malicious diseases."
	icon_state = "signmaker_med"
	holosign_type = /obj/structure/holosign/barrier/medical
	sign_name = "holobarrier"
	creation_time = 30
	max_signs = 3

/obj/item/holosign_creator/cyborg
	name = "energy barrier projector"
	desc = "A holographic projector that creates fragile energy fields."
	creation_time = 15
	max_signs = 9
	holosign_type = /obj/structure/holosign/barrier/cyborg
	sign_name = "barrier"
	var/shock = 0

/obj/item/holosign_creator/cyborg/attack_self(mob/user)
	if(iscyborg(user))
		var/mob/living/silicon/robot/R = user

		if(shock)
			to_chat(user, span_notice("You clear all active energy fields, and reset your projector to normal."))
			holosign_type = /obj/structure/holosign/barrier/cyborg
			creation_time = 5
			if(length(signs))
				for(var/H in signs)
					qdel(H)
			shock = 0
			return
		else if(R.emagged&&!shock)
			to_chat(user, span_warning("You clear all active energy fields, and overload your energy projector!"))
			holosign_type = /obj/structure/holosign/barrier/cyborg/hacked
			creation_time = 30
			if(length(signs))
				for(var/H in signs)
					qdel(H)
			shock = 1
			return
		else
			if(length(signs))
				var/signs_amount = length(signs)
				for(var/H in signs)
					qdel(H)
				to_chat(user, span_notice("You clear [signs_amount] active energy field\s."))
	if(length(signs))
		var/signs_amount = length(signs)
		for(var/H in signs)
			qdel(H)
		to_chat(user, span_notice("You clear [signs_amount] active energy field\s."))
