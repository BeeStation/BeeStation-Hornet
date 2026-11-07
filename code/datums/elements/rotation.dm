/datum/element/simple_rotation
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	/// Rotation flags for special behavior
	var/rotation_flags
	/// Optional proc to call()() after the thing is successfully rotated
	var/post_rotation_proccall

/**
 * Adds the ability to rotate an object by Alt-click or using Right-click verbs.
 *
 * args:
 * * rotation_flags (optional) Bitflags that determine behavior for rotation (defined at the top of this file)
 * * post_rotation (optional) Callback proc that is used after the object is rotated (sound effects, balloon alerts, etc.)
 **/
/datum/element/simple_rotation/Attach(datum/target, rotation_flags = NONE, post_rotation_proccall)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE

	src.rotation_flags = rotation_flags
	src.post_rotation_proccall = post_rotation_proccall

	RegisterSignal(target, COMSIG_CLICK_ALT, PROC_REF(rotate_left))
	RegisterSignal(target, COMSIG_CLICK_ALT_SECONDARY, PROC_REF(rotate_right))
	RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(examine_message))

/datum/element/simple_rotation/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, list(
		COMSIG_CLICK_ALT,
		COMSIG_CLICK_ALT_SECONDARY,
		COMSIG_ATOM_EXAMINE,
	))
	return ..()

/datum/element/simple_rotation/proc/examine_message(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	var/client_pref_found = user.client?.prefs?.read_player_preference(/datum/preference/toggle/inverted_rotation)
	if(client_pref_found)
		examine_list += span_notice("Alt + Left-click to rotate it clockwise. Alt + Right-click to rotate it counterclockwise.")
	else
		examine_list += span_notice("Alt + Right-click to rotate it clockwise. Alt + Left-click to rotate it counterclockwise.")
	if(rotation_flags & ROTATION_REQUIRE_WRENCH)
		examine_list += span_notice("This requires a wrench to be rotated.")

/datum/element/simple_rotation/proc/rotate_right(datum/source, mob/user)
	SIGNAL_HANDLER
	// This pref makes the rotation behaviour inverted. Rotate "right" would be different for each individual.
	var/client_pref_found = user.client?.prefs?.read_player_preference(/datum/preference/toggle/inverted_rotation)
	if(rotation_flags & ROTATION_DIAGONAL)
		rotate(user, source, client_pref_found ? ROTATION_COUNTERCLOCKWISE_DIAGONAL : ROTATION_CLOCKWISE_DIAGONAL)
	else
		rotate(user, source, client_pref_found ? ROTATION_COUNTERCLOCKWISE : ROTATION_CLOCKWISE)

/datum/element/simple_rotation/proc/rotate_left(datum/source, mob/user)
	SIGNAL_HANDLER
	// This pref makes the rotation behaviour inverted. Rotate "left" would be different for each individual.
	var/client_pref_found = user.client?.prefs?.read_player_preference(/datum/preference/toggle/inverted_rotation)
	if(rotation_flags & ROTATION_DIAGONAL)
		rotate(user, source, client_pref_found ? ROTATION_CLOCKWISE_DIAGONAL : ROTATION_COUNTERCLOCKWISE_DIAGONAL)
	else
		rotate(user, source, client_pref_found ? ROTATION_CLOCKWISE : ROTATION_COUNTERCLOCKWISE)

/datum/element/simple_rotation/proc/rotate(mob/user, obj/object_to_rotate, degrees)
	if(QDELETED(user))
		CRASH("[src] is being rotated [user ? "with a qdeleting" : "without a"] user")
	if(!istype(user))
		CRASH("[src] is being rotated without a user of the wrong type: [user.type]")
	if(!isnum(degrees))
		CRASH("[src] is being rotated without providing the amount of degrees needed")

	if(!can_be_rotated(user, object_to_rotate, degrees) || !can_user_rotate(user, object_to_rotate, degrees))
		return

	object_to_rotate.setDir(turn(object_to_rotate.dir, degrees))
	if(rotation_flags & ROTATION_REQUIRE_WRENCH)
		playsound(object_to_rotate, 'sound/items/ratchet.ogg', 50, TRUE)

	if(post_rotation_proccall)
		call(object_to_rotate, post_rotation_proccall)(user, degrees)

/datum/element/simple_rotation/proc/can_user_rotate(mob/user, obj/object_to_rotate, degrees)
	if(isliving(user) && user.canUseTopic(object_to_rotate, BE_CLOSE, NO_DEXTERITY, FALSE, !iscyborg(user)))
		return TRUE
	if((rotation_flags & ROTATION_GHOSTS_ALLOWED) && isobserver(user) && CONFIG_GET(flag/ghost_interaction))
		return TRUE
	return FALSE

/datum/element/simple_rotation/proc/can_be_rotated(mob/user, obj/object_to_rotate, degrees, silent = FALSE)
	if(!object_to_rotate.Adjacent(user))
		silent = TRUE

	if(rotation_flags & ROTATION_REQUIRE_WRENCH)
		if(!isliving(user))
			return FALSE
		var/obj/item/tool = user.get_active_held_item()
		if(!tool || tool.tool_behaviour != TOOL_WRENCH)
			if(!silent)
				object_to_rotate.balloon_alert(user, "need a wrench!")
			return FALSE

	if(!(rotation_flags & ROTATION_IGNORE_ANCHORED) && object_to_rotate.anchored)
		if(istype(object_to_rotate, /obj/structure/window) && !silent)
			object_to_rotate.balloon_alert(user, "need to unscrew!")
		else if(!silent)
			object_to_rotate.balloon_alert(user, "need to unwrench!")
		return FALSE

	if(rotation_flags & ROTATION_NEEDS_ROOM)
		var/target_dir = turn(object_to_rotate.dir, degrees)
		var/obj/structure/window/window_to_rotate = object_to_rotate
		var/fulltile = istype(window_to_rotate) ? window_to_rotate.fulltile : FALSE
		if(!valid_build_direction(object_to_rotate.loc, target_dir, is_fulltile = fulltile))
			if(!silent)
				object_to_rotate.balloon_alert(user, "can't rotate in that direction!")
			return FALSE

	return TRUE
