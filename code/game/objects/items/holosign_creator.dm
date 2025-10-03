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

	/// Our currently projected holosigns
	var/list/signs
	/// Max amount of holosigns that can be projected at once
	var/max_signs = 10
	/// The time to create a holosign.
	var/creation_time = 0
	/// If we're currently placing a holosign. Used to prevent placing multiple at once.
	var/holocreator_busy = FALSE
	/// Whether or not holosigns can be created from range
	var/ranged = FALSE

	/// The created holosign type
	var/obj/structure/holosign/holosign_type = /obj/structure/holosign/wetsign
	/// List of special things we can project holofans under/through.
	var/list/projectable_through = list(
		/obj/machinery/door,
		/obj/structure/mineral_door,
	)

/obj/item/holosign_creator/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/openspace_item_click_handler)

/obj/item/holosign_creator/Destroy()
	. = ..()
	if(LAZYLEN(signs))
		for(var/obj/structure/holosign/hologram as anything in signs)
			qdel(hologram)

/obj/item/holosign_creator/handle_openspace_click(turf/target, mob/user, proximity_flag, click_parameters)
	afterattack(target, user, proximity_flag)

/obj/item/holosign_creator/examine(mob/user)
	. = ..()
	if(!signs)
		return
	. += span_notice("It is currently maintaining <b>[signs.len]/[max_signs]</b> projections.")

/obj/item/holosign_creator/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!check_allowed_items(target, not_inside = TRUE))
		return
	if(!proximity_flag && !ranged)
		return

	var/turf/target_turf = get_turf(target)
	var/obj/structure/holosign/target_holosign = locate(holosign_type) in target_turf
	if(target_holosign)
		to_chat(user, span_notice("You use [src] to deactivate [target_holosign]."))
		qdel(target_holosign)
		return

	// Can't put holograms on a tile that has dense stuff
	if(target_turf.is_blocked_turf(TRUE, ignore_atoms = projectable_through, type_list = TRUE))
		return
	if(holocreator_busy)
		balloon_alert(user, "busy making a hologram!")
		return
	if(LAZYLEN(signs) >= max_signs)
		balloon_alert(user, "max capacity!")
		return

	playsound(src, 'sound/machines/click.ogg', 20, TRUE)
	if(creation_time)
		holocreator_busy = TRUE
		if(!do_after(user, creation_time, target = target))
			holocreator_busy = FALSE
			return
		holocreator_busy = FALSE
		if(LAZYLEN(signs) >= max_signs)
			return
		// Don't try to sneak dense stuff on our tile during the wait.
		if(target_turf.is_blocked_turf(TRUE, ignore_atoms = projectable_through, type_list = TRUE))
			return

	target_holosign = create_holosign(target, user)

/obj/item/holosign_creator/attack(mob/living/carbon/human/M, mob/user)
	return

/obj/item/holosign_creator/attack_self(mob/user)
	if(LAZYLEN(signs))
		for(var/obj/structure/holosign/hologram as anything in signs)
			qdel(hologram)
		balloon_alert(user, "holograms cleared")

/obj/item/holosign_creator/proc/create_holosign(atom/target, mob/user)
	var/atom/new_holosign = new holosign_type(get_turf(target), src)
	new_holosign.add_hiddenprint(user)
	if(color)
		new_holosign.color = color
	return new_holosign

/obj/item/holosign_creator/janibarrier
	name = "custodial holobarrier projector"
	desc = "A holographic projector that creates hard light wet floor barriers."
	holosign_type = /obj/structure/holosign/barrier/wetsign
	custom_price = 200
	creation_time = 2 SECONDS
	max_signs = 12

/obj/item/holosign_creator/security
	name = "security holobarrier projector"
	desc = "A holographic projector that creates holographic security barriers."
	icon_state = "signmaker_sec"
	holosign_type = /obj/structure/holosign/barrier
	actions_types = list(/datum/action/item_action/toggle_crimesigns)
	creation_time = 3 SECONDS
	max_signs = 6
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
	creation_time = 3 SECONDS
	max_signs = 6

/obj/item/holosign_creator/atmos
	name = "\improper ATMOS holofan projector"
	desc = "A holographic projector that creates holographic barriers that prevent changes in atmosphere conditions."
	icon_state = "signmaker_atmos"
	holosign_type = /obj/structure/holosign/barrier/atmos
	creation_time = 0
	max_signs = 3
	projectable_through = list(
		/obj/machinery/door,
		/obj/structure/mineral_door,
		/obj/structure/window,
		/obj/structure/grille,
	)

	/// Clearview holograms don't catch clicks and are more transparent
	var/clearview = FALSE
	/// Timer for auto-turning off clearview
	var/clearview_timer

/obj/item/holosign_creator/atmos/add_context_self(datum/screentip_context/context, mob/user)
	context.add_right_click_action("[clearview ? "Disable" : "Temporarily activate"] clearview")

/obj/item/holosign_creator/atmos/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	var/obj/machinery/door/firedoor/firelock = locate() in get_turf(target)
	firelock?.open()

/obj/item/holosign_creator/atmos/create_holosign(atom/target, mob/user)
	var/obj/structure/holosign/barrier/atmos/new_holosign = new holosign_type(get_turf(target), src)
	new_holosign.add_hiddenprint(user)
	if(color)
		new_holosign.color = color
	if(clearview)
		new_holosign.clearview_transparency()
	return new_holosign

/obj/item/holosign_creator/atmos/attack_self_secondary(mob/user, modifiers)
	if(clearview)
		reset_hologram_transparency()
		balloon_alert(user, "clearview disabled.")
		return
	if(LAZYLEN(signs))
		for(var/obj/structure/holosign/barrier/atmos/hologram as anything in signs)
			hologram.clearview_transparency()
		clearview = TRUE
		balloon_alert(user, "clearview enabled.")
		clearview_timer = addtimer(CALLBACK(src, PROC_REF(reset_hologram_transparency)), 40 SECONDS, TIMER_STOPPABLE)
	return ..()

/obj/item/holosign_creator/atmos/proc/reset_hologram_transparency()
	if(LAZYLEN(signs))
		for(var/obj/structure/holosign/barrier/atmos/hologram as anything in signs)
			hologram.reset_transparency()
		clearview = FALSE
		deltimer(clearview_timer)

/obj/item/holosign_creator/medical
	name = "\improper PENLITE barrier projector"
	desc = "A holographic projector that creates PENLITE holobarriers. Useful during quarantines since they halt those with malicious diseases."
	icon_state = "signmaker_med"
	holosign_type = /obj/structure/holosign/barrier/medical
	creation_time = 3 SECONDS
	max_signs = 3

/obj/item/holosign_creator/cyborg
	name = "energy barrier projector"
	desc = "A holographic projector that creates fragile energy fields."
	creation_time = 1.5 SECONDS
	max_signs = 9
	holosign_type = /obj/structure/holosign/barrier/cyborg

	/// Currently projecting shocked barriers?
	var/shock = FALSE

/obj/item/holosign_creator/cyborg/attack_self(mob/user)
	if(iscyborg(user))
		var/mob/living/silicon/robot/borg = user

		if(shock)
			to_chat(user, span_notice("You clear all active holograms, and reset your projector to normal."))
			holosign_type = /obj/structure/holosign/barrier/cyborg
			creation_time = 1.5 SECONDS
			for(var/obj/structure/holosign/hologram as anything in signs)
				qdel(hologram)
			shock = FALSE
			return
		if(borg.emagged && !shock)
			to_chat(user, span_warning("You clear all active holograms, and overload your energy projector!"))
			holosign_type = /obj/structure/holosign/barrier/cyborg/hacked
			creation_time = 3 SECONDS
			for(var/obj/structure/holosign/hologram as anything in signs)
				qdel(hologram)
			shock = TRUE
			return

	if(LAZYLEN(signs))
		for(var/obj/structure/holosign/hologram as anything in signs)
			qdel(hologram)
		balloon_alert(user, "holograms cleared")
