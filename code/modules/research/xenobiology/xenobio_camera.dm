//Xenobio camera eye
/mob/camera/ai_eye/remote/xenobio
	visible_icon = TRUE
	icon = 'icons/mob/cameramob.dmi'
	icon_state = "generic_camera"
	var/allowed_area = null

/mob/camera/ai_eye/remote/xenobio/Initialize(mapload)
	var/area/myarea = get_area(loc)
	if(!(myarea.area_flags & XENOBIOLOGY_CONSOLE_DISALLOWED))
		allowed_area = myarea.name
	. = ..()

/mob/camera/ai_eye/remote/xenobio/setLoc(destination)
	var/area/new_area = get_area(destination)
	return is_valid_area(new_area) ? ..() : FALSE

/mob/camera/ai_eye/remote/xenobio/canZMove(direction, turf/source, turf/target, pre_move = TRUE)
	var/area/new_area = get_area(target)
	return is_valid_area(new_area) ? ..() : FALSE

/// Checks if the camera eye can access this area. This is actually used by Xenobio camera mob.
/mob/camera/ai_eye/remote/proc/is_valid_area(area/new_area)
	return TRUE

/mob/camera/ai_eye/remote/xenobio/is_valid_area(area/new_area)
	return new_area && !(new_area.area_flags & XENOBIOLOGY_CONSOLE_DISALLOWED) && (new_area.name == allowed_area || (new_area.area_flags & XENOBIOLOGY_COMPATIBLE))


//Xenobio control console
/obj/machinery/computer/camera_advanced/xenobio
	name = "Slime management console"
	desc = "A computer used for remotely handling slimes."
	compatible_camera_networks = null // Will take the area's camera networks on Initialize()
	circuit = /obj/item/circuitboard/computer/xenobiology
	var/datum/action/innate/slime_place/slime_place_action
	var/datum/action/innate/slime_pick_up/slime_up_action
	var/datum/action/innate/feed_slime/feed_slime_action
	var/datum/action/innate/monkey_recycle/monkey_recycle_action
	var/datum/action/innate/slime_scan/scan_action
	var/datum/action/innate/feed_potion/potion_action
	var/datum/action/innate/hotkey_help/hotkey_help

	///The recycler connected to the camera console
	var/obj/machinery/monkey_recycler/connected_recycler
	///The slimes stored inside the console
	var/list/stored_slimes
	///The single slime potion stored inside the console
	var/obj/item/slimepotion/slime/current_potion
	///The maximum amount of slimes that fit in the machine
	var/max_slimes = 5
	///The amount of monkey cubes inside the machine
	var/monkeys = 0

	icon_screen = "slime_comp"
	icon_keyboard = "rd_key"

	light_color = LIGHT_COLOR_PINK

	reveal_camera_mob = TRUE
	camera_mob_icon_state = "xeno"

	create_camera_mob_on_computer = TRUE

/obj/machinery/computer/camera_advanced/xenobio/Initialize(mapload)
	. = ..()
	slime_place_action = new(src)
	slime_up_action = new(src)
	feed_slime_action = new(src)
	monkey_recycle_action = new(src)
	scan_action = new(src)
	potion_action = new(src)
	hotkey_help = new(src)
	stored_slimes = list()
	RegisterSignal(src, COMSIG_ATOM_CONTENTS_DEL, PROC_REF(on_contents_del))

/obj/machinery/computer/camera_advanced/xenobio/LateInitialize(mapload)
	. = ..()
	for(var/obj/machinery/monkey_recycler/recycler in GLOB.monkey_recyclers)
		if(get_area(recycler.loc) == get_area(loc))
			connected_recycler = recycler
			connected_recycler.connected += src

	var/area/myarea = get_area(src)
	compatible_camera_networks = myarea.camera_networks.Copy()

/obj/machinery/computer/camera_advanced/xenobio/Destroy()
	stored_slimes = null
	QDEL_NULL(current_potion)
	for(var/i in contents)
		var/mob/living/basic/slime/S = i
		if(istype(S))
			S.forceMove(drop_location())
	return ..()

/obj/machinery/computer/camera_advanced/xenobio/examine(user)
	. = ..()
	var/area/myarea = get_area(src)
	if(myarea.area_flags & XENOBIOLOGY_CONSOLE_DISALLOWED)
		. += span_warning("[get_area_name(myarea)] lacks xenobiological compatibility. The console will not work here!")

/obj/machinery/computer/camera_advanced/xenobio/CreateEye()
	eyeobj = new /mob/camera/ai_eye/remote/xenobio(get_turf(src))
	eyeobj.origin = src
	eyeobj.icon = camera_mob_icon
	eyeobj.icon_state = camera_mob_icon_state
	RevealCameraMob()

/obj/machinery/computer/camera_advanced/xenobio/give_eye_control(mob/user)
	if(!eyeobj)
		return
	var/area/myarea = get_area(src)
	if(!myarea)
		return
	if(myarea.area_flags & XENOBIOLOGY_CONSOLE_DISALLOWED)
		to_chat(user, span_warning("[get_area_name(myarea)] lacks xenobiological compatibility. The console will not work here!"))
		return
	if(!eyeobj.is_valid_area(get_area(eyeobj)))
		eyeobj.abstract_move(get_turf(src))
	..()

/obj/machinery/computer/camera_advanced/xenobio/GrantActions(mob/living/user)
	..()

	if(slime_up_action)
		slime_up_action.Grant(user)
		actions += slime_up_action

	if(slime_place_action)
		slime_place_action.Grant(user)
		actions += slime_place_action

	if(feed_slime_action)
		feed_slime_action.Grant(user)
		actions += feed_slime_action

	if(monkey_recycle_action)
		monkey_recycle_action.Grant(user)
		actions += monkey_recycle_action

	if(scan_action)
		scan_action.Grant(user)
		actions += scan_action

	if(potion_action)
		potion_action.Grant(user)
		actions += potion_action

	if(hotkey_help)
		hotkey_help.Grant(user)
		actions += hotkey_help

	RegisterSignal(user, COMSIG_XENO_SLIME_CLICK_CTRL, PROC_REF(XenoSlimeClickCtrl))
	RegisterSignal(user, COMSIG_XENO_SLIME_CLICK_ALT, PROC_REF(XenoSlimeClickAlt))
	RegisterSignal(user, COMSIG_XENO_SLIME_CLICK_SHIFT, PROC_REF(XenoSlimeClickShift))
	RegisterSignal(user, COMSIG_XENO_TURF_CLICK_SHIFT, PROC_REF(XenoTurfClickShift))
	RegisterSignal(user, COMSIG_XENO_TURF_CLICK_CTRL, PROC_REF(XenoTurfClickCtrl))
	RegisterSignal(user, COMSIG_XENO_MONKEY_CLICK_CTRL, PROC_REF(XenoMonkeyClickCtrl))

/obj/machinery/computer/camera_advanced/xenobio/remove_eye_control(mob/living/user)
	UnregisterSignal(user, COMSIG_XENO_SLIME_CLICK_CTRL)
	UnregisterSignal(user, COMSIG_XENO_SLIME_CLICK_ALT)
	UnregisterSignal(user, COMSIG_XENO_SLIME_CLICK_SHIFT)
	UnregisterSignal(user, COMSIG_XENO_TURF_CLICK_SHIFT)
	UnregisterSignal(user, COMSIG_XENO_TURF_CLICK_CTRL)
	UnregisterSignal(user, COMSIG_XENO_MONKEY_CLICK_CTRL)
	..()

/obj/machinery/computer/camera_advanced/xenobio/proc/on_contents_del(datum/source, atom/deleted)
	SIGNAL_HANDLER

	if(current_potion == deleted)
		current_potion = null
	if(deleted in stored_slimes)
		stored_slimes -= deleted

/obj/machinery/computer/camera_advanced/xenobio/attackby(obj/item/O, mob/user, list/modifiers)
	if(istype(O, /obj/item/food/monkeycube))
		monkeys++
		to_chat(user, span_notice("You feed [O] to [src]. It now has [monkeys] monkey cubes stored."))
		qdel(O)
		return
	else if(istype(O, /obj/item/storage/bag))
		var/obj/item/storage/P = O
		var/loaded = FALSE
		for(var/obj/G in P.contents)
			if(istype(G, /obj/item/food/monkeycube))
				loaded = TRUE
				monkeys++
				qdel(G)
		if(loaded)
			to_chat(user, span_notice("You fill [src] with the monkey cubes stored in [O]. [src] now has [monkeys] monkey cubes stored."))
		return
	else if(istype(O, /obj/item/slimepotion/slime))
		var/replaced = FALSE
		if(user && !user.transferItemToLoc(O, src))
			return
		if(!QDELETED(current_potion))
			current_potion.forceMove(drop_location())
			replaced = TRUE
		current_potion = O
		to_chat(user, span_notice("You load [O] in the console's potion slot[replaced ? ", replacing the one that was there before" : ""]."))
		return
	..()

REGISTER_BUFFER_HANDLER(/obj/machinery/computer/camera_advanced/xenobio)

DEFINE_BUFFER_HANDLER(/obj/machinery/computer/camera_advanced/xenobio)
	if (istype(buffer,/obj/machinery/monkey_recycler) && connected_recycler != buffer)
		to_chat(user, span_notice("You link [src] with [buffer] in [buffer_parent] buffer."))
		connected_recycler = buffer
		connected_recycler.connected += src
		return COMPONENT_BUFFER_RECEIVED
	return NONE

/*
Boilerplate check for a valid area to perform a camera action in.
Checks if the AI eye is on a valid turf and then checks if the target turf is xenobiology compatible
Due to keyboard shortcuts, the second one is not necessarily the remote eye's location.
*/
/obj/machinery/computer/camera_advanced/xenobio/proc/validate_area(mob/living/user, mob/camera/ai_eye/remote/xenobio/remote_eye, turf/open/target_turf)
	if(!GLOB.cameranet.checkTurfVis(remote_eye.loc))
		to_chat(user, span_warning("Target is not near a camera. Cannot proceed."))
		return FALSE

	var/area/turfarea = get_area(target_turf)
	if(turfarea.name != remote_eye.allowed_area && !(turfarea.area_flags & XENOBIOLOGY_COMPATIBLE))
		to_chat(user, span_warning("Invalid area. Cannot proceed."))
		return FALSE

	return TRUE

///Places every slime in storage on target turf
/obj/machinery/computer/camera_advanced/xenobio/proc/slime_place(turf/open/target_turf)
	for(var/mob/living/basic/slime/stored_slime in stored_slimes)
		stored_slime.forceMove(target_turf)
		stored_slime.visible_message(span_notice("[stored_slime] warps in!"))
		stored_slimes -= stored_slime
		stored_slime.remove_status_effect(/datum/status_effect/grouped/stasis, XENOBIO_CONSOLE_TRAIT)
		stored_slime.handle_slime_stasis()

///Places every slime not controlled by a player into the internal storage, respecting its limits
///Returns TRUE to signal it hitting the limit, in case its being called from a loop and we want it to stop
/obj/machinery/computer/camera_advanced/xenobio/proc/slime_pickup(mob/living/user, mob/living/basic/slime/target_slime)
	if(target_slime in stored_slimes)
		// It's possible for this proc to be called on a slime that's already being picked up,
		// so we need to check whether we already have to avoid duplicate entries.
		return FALSE
	if(stored_slimes.len >= max_slimes)
		to_chat(user, span_warning("Slime storage is full."))
		return TRUE
	if(target_slime.ckey)
		to_chat(user, span_warning("The slime wiggled free!"))
		return FALSE
	if(target_slime.buckled)
		target_slime.stop_feeding(silent = TRUE)
	target_slime.visible_message(span_notice("[target_slime] vanishes in a flash of light!"))
	target_slime.forceMove(src)
	stored_slimes += target_slime
	target_slime.apply_status_effect(/datum/status_effect/grouped/stasis, XENOBIO_CONSOLE_TRAIT)

	return FALSE

///Places one monkey, if possible
/obj/machinery/computer/camera_advanced/xenobio/proc/feed_slime(mob/living/user, turf/open/target_turf)
	if(monkeys < 1)
		to_chat(user, span_warning("[src] needs to have at least 1 monkey stored. Currently has [monkeys] monkeys stored."))
		return

	var/mob/living/carbon/monkey/food = new /mob/living/carbon/monkey(target_turf, TRUE, user)
	if (QDELETED(food))
		return

	food.apply_status_effect(/datum/status_effect/slime_food, user)
	monkeys--
	monkeys = round(monkeys, 0.1) //Prevents rounding errors
	to_chat(user, span_notice("[src] now has [monkeys] monkeys stored."))

///Recycles the target monkey
/obj/machinery/computer/camera_advanced/xenobio/proc/monkey_recycle(mob/living/user, mob/living/target_mob)
	if(!ismonkey(target_mob))
		return
	if(!target_mob.stat)
		return

	target_mob.visible_message(span_notice("[target_mob] vanishes as [target_mob.p_theyre()] reclaimed for recycling!"))
	connected_recycler.use_power(500)
	monkeys += connected_recycler.cube_production
	monkeys = round(monkeys, 0.1) //Prevents rounding errors
	qdel(target_mob)
	to_chat(user, span_notice("[src] now has [monkeys] monkeys stored."))

/datum/action/innate/slime_place
	name = "Place Slimes"
	button_icon = 'icons/hud/actions/actions_silicon.dmi'
	button_icon_state = "slime_down"

/datum/action/innate/slime_place/on_activate()
	if(!master || !isliving(owner))
		return
	var/mob/living/owner_mob = owner
	var/mob/camera/ai_eye/remote/xenobio/remote_eye = owner_mob.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/xeno_console = master

	if(!xeno_console.validate_area(owner, remote_eye, remote_eye.loc))
		return

	xeno_console.slime_place(remote_eye.loc)

/datum/action/innate/slime_pick_up
	name = "Pick up Slime"
	button_icon = 'icons/hud/actions/actions_silicon.dmi'
	button_icon_state = "slime_up"

/datum/action/innate/slime_pick_up/on_activate()
	if(!master || !isliving(owner))
		return
	var/mob/living/owner_mob = owner
	var/mob/camera/ai_eye/remote/xenobio/remote_eye = owner_mob.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/xeno_console = master

	if(!xeno_console.validate_area(owner, remote_eye, remote_eye.loc))
		return

	for(var/mob/living/basic/slime/target_slime in remote_eye.loc)
		if(xeno_console.slime_pickup(owner_mob, target_slime)) ///Returns true if we hit our slime pickup limit
			break


/datum/action/innate/feed_slime
	name = "Feed Slimes"
	button_icon = 'icons/hud/actions/actions_silicon.dmi'
	button_icon_state = "monkey_down"

/datum/action/innate/feed_slime/on_activate()
	if(!master || !isliving(owner))
		return
	var/mob/living/living_owner = owner
	var/mob/camera/ai_eye/remote/xenobio/remote_eye = living_owner.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/xeno_console = master

	if(!xeno_console.validate_area(owner, remote_eye, remote_eye.loc))
		return

	xeno_console.feed_slime(living_owner, remote_eye.loc)


/datum/action/innate/monkey_recycle
	name = "Recycle Monkeys"
	button_icon = 'icons/hud/actions/actions_silicon.dmi'
	button_icon_state = "monkey_up"

/datum/action/innate/monkey_recycle/on_activate()
	if(!master || !isliving(owner))
		return
	var/mob/living/owner_mob = owner
	var/mob/camera/ai_eye/remote/xenobio/remote_eye = owner_mob.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/xeno_console = master
	var/obj/machinery/monkey_recycler/recycler = xeno_console.connected_recycler

	if(!xeno_console.validate_area(owner, remote_eye, remote_eye.loc))
		return

	if(!recycler)
		to_chat(owner, span_notice("There is no connected monkey recycler. Use a multitool to link one."))
		return
	for(var/mob/living/carbon/monkey/target_mob in remote_eye.loc)
		xeno_console.monkey_recycle(owner, target_mob)

/datum/action/innate/slime_scan
	name = "Scan Slime"
	button_icon = 'icons/hud/actions/actions_silicon.dmi'
	button_icon_state = "slime_scan"

/datum/action/innate/slime_scan/on_activate()
	if(!master || !isliving(owner))
		return
	var/mob/living/owner_mob = owner
	var/mob/camera/ai_eye/remote/xenobio/remote_eye = owner_mob.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/xeno_console = master

	if(!xeno_console.validate_area(owner, remote_eye, remote_eye.loc))
		return

	for(var/mob/living/basic/slime/scanned_slime in remote_eye.loc)
		slime_scan(scanned_slime, owner_mob)

/datum/action/innate/feed_potion
	name = "Apply Potion"
	button_icon = 'icons/hud/actions/actions_silicon.dmi'
	button_icon_state = "slime_potion"

/datum/action/innate/feed_potion/on_activate()
	if(!master || !isliving(owner))
		return

	var/mob/living/owner_mob = owner
	var/mob/camera/ai_eye/remote/xenobio/remote_eye = owner_mob.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/xeno_console = master

	if(!xeno_console.validate_area(owner, remote_eye, remote_eye.loc))
		return

	if(QDELETED(xeno_console.current_potion))
		to_chat(owner, span_warning("No potion loaded."))
		return

	for(var/mob/living/basic/slime/potioned_slime in remote_eye.loc)
		xeno_console.current_potion.interact_with_atom(potioned_slime, owner_mob)
		break

/datum/action/innate/hotkey_help
	name = "Hotkey Help"
	button_icon = 'icons/hud/actions/actions_silicon.dmi'
	button_icon_state = "hotkey_help"

/datum/action/innate/hotkey_help/on_activate()
	if(!master || !isliving(owner))
		return

	var/render_list = list()
	render_list += "<b>Click shortcuts:</b>"
	render_list += "&bull; Shift-click a slime to pick it up, or the floor to drop all held slimes."
	render_list += "&bull; Ctrl-click a slime to scan it."
	render_list += "&bull; Alt-click a slime to feed it a potion."
	render_list += "&bull; Ctrl-click or a dead monkey to recycle it, or the floor to place a new monkey."

	to_chat(owner, examine_block(jointext(render_list, "\n")))

//
// Alternate clicks for slime, monkey and open turf if using a xenobio console

/mob/living/basic/slime/CtrlClick(mob/user)
	SEND_SIGNAL(user, COMSIG_XENO_SLIME_CLICK_CTRL, src)
	..()

/mob/living/basic/slime/AltClick(mob/user)
	SEND_SIGNAL(user, COMSIG_XENO_SLIME_CLICK_ALT, src)
	..()

/mob/living/basic/slime/ShiftClick(mob/user)
	SEND_SIGNAL(user, COMSIG_XENO_SLIME_CLICK_SHIFT, src)
	..()

/turf/open/ShiftClick(mob/user)
	SEND_SIGNAL(user, COMSIG_XENO_TURF_CLICK_SHIFT, src)
	..()

/turf/open/CtrlClick(mob/user)
	SEND_SIGNAL(user, COMSIG_XENO_TURF_CLICK_CTRL, src)
	..()

/mob/living/carbon/monkey/CtrlClick(mob/user)
	SEND_SIGNAL(user, COMSIG_XENO_MONKEY_CLICK_CTRL, src)
	..()

/// Scans the target slime
/obj/machinery/computer/camera_advanced/xenobio/proc/XenoSlimeClickCtrl(mob/living/user, mob/living/basic/slime/target_slime)
	SIGNAL_HANDLER

	var/mob/camera/ai_eye/remote/xenobio/remote_eye = user.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/xeno_console = remote_eye.origin

	if(!xeno_console.validate_area(user, remote_eye, target_slime.loc))
		return

	slime_scan(target_slime, user)

///Feeds a stored potion to a slime
/obj/machinery/computer/camera_advanced/xenobio/proc/XenoSlimeClickAlt(mob/living/user, mob/living/basic/slime/target_slime)
	SIGNAL_HANDLER

	var/mob/camera/ai_eye/remote/xenobio/remote_eye = user.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/xeno_console = remote_eye.origin

	if(!xeno_console.validate_area(user, remote_eye, target_slime.loc))
		return

	if(QDELETED(xeno_console.current_potion))
		to_chat(user, span_warning("No potion loaded."))
		return

	INVOKE_ASYNC(xeno_console.current_potion, TYPE_PROC_REF(/obj/item/slimepotion/slime, interact_with_atom), target_slime, user)

///Picks up a slime, and places them in the internal storage
/obj/machinery/computer/camera_advanced/xenobio/proc/XenoSlimeClickShift(mob/living/user, mob/living/basic/slime/target_slime)
	SIGNAL_HANDLER

	var/mob/camera/ai_eye/remote/xenobio/remote_eye = user.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/xeno_console = remote_eye.origin

	if(!xeno_console.validate_area(user, remote_eye, target_slime.loc))
		return

	xeno_console.slime_pickup(user, target_slime)

///Places all slimes from the internal storage
/obj/machinery/computer/camera_advanced/xenobio/proc/XenoTurfClickShift(mob/living/user, turf/open/target_turf)
	SIGNAL_HANDLER

	var/mob/living/user_mob = user
	var/mob/camera/ai_eye/remote/xenobio/remote_eye = user_mob.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/xeno_console = remote_eye.origin

	if(!xeno_console.validate_area(user, remote_eye, target_turf))
		return

	slime_place(target_turf)

///Places a monkey from the internal storage
/obj/machinery/computer/camera_advanced/xenobio/proc/XenoTurfClickCtrl(mob/living/user, turf/open/target_turf)
	SIGNAL_HANDLER

	var/mob/camera/ai_eye/remote/xenobio/remote_eye = user.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/xeno_console = remote_eye.origin

	if(!xeno_console.validate_area(user, remote_eye, target_turf))
		return

	xeno_console.feed_slime(user, target_turf)


///Picks up a dead monkey for recycling
/obj/machinery/computer/camera_advanced/xenobio/proc/XenoMonkeyClickCtrl(mob/living/user, mob/living/carbon/monkey/target_mob)
	SIGNAL_HANDLER
	if(!ismonkey(target_mob))
		return

	var/mob/camera/ai_eye/remote/xenobio/remote_eye = user.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/xeno_console = remote_eye.origin

	if(!xeno_console.validate_area(user, remote_eye, target_mob.loc))
		return

	if(!xeno_console.connected_recycler)
		to_chat(user, span_warning("There is no connected monkey recycler. Use a multitool to link one."))
		return

	xeno_console.monkey_recycle(user, target_mob)
