GLOBAL_LIST_EMPTY_TYPED(ongoing_tutorials, /datum/tutorial)

/datum/tutorial
	/// What the tutorial is called, is player facing
	var/name = "Base"
	/// Internal ID of the tutorial
	var/tutorial_id = "base"
	/// A short 1-2 sentence description of the tutorial
	var/desc = ""
	/// What the tutorial's icon in the UI should look like
	var/icon_state = ""
	/// What category the tutorial should be under
	var/category = TUTORIAL_CATEGORY_BASE
	/// Ref to the bottom_left_corner
	var/turf/bottom_left_corner
	/// Ref to the turf reservation for this tutorial
	var/datum/turf_reservation/reservation
	/// Ref to the player who is doing the tutorial
	var/mob/tutorial_mob
	/// If the tutorial will be ending soon
	var/tutorial_ending = FALSE
	/// A dict of type:atom ref for some important junk that should be trackable
	var/list/tracking_atoms = list()
	/// What map template should be used for the tutorial
	var/datum/map_template/tutorial/tutorial_template = /datum/map_template/tutorial/s12x12
	/// What is the parent path of this, to exclude from the tutorial menu
	var/parent_path = /datum/tutorial
	/// A dictionary of "bind_name" : "keybind_button". The inverse of `key_bindings` on a client's prefs
	var/list/player_bind_dict = list()

/datum/tutorial/Destroy(force, ...)
	GLOB.ongoing_tutorials -= src
	qdel(reservation)

	tutorial_mob = null // We don't delete it because the turf reservation will do that for us

	QDEL_LIST_ASSOC_VAL(tracking_atoms)

	return ..()

/datum/tutorial/proc/init_tutorial(mob/starting_mob)
	SHOULD_CALL_PARENT(TRUE)

	if(!starting_mob?.client)
		return FALSE

	ADD_TRAIT(starting_mob, TRAIT_IN_TUTORIAL, TRAIT_SOURCE_TUTORIAL)
	tutorial_mob = starting_mob
	reservation = SSmapping.RequestBlockReservation(initial(tutorial_template.width), initial(tutorial_template.height))
	if(!reservation)
		return FALSE

	var/turf/bottom_left_corner_reservation = locate(reservation.bottom_left_coords[1], reservation.bottom_left_coords[2], reservation.bottom_left_coords[3])
	var/datum/map_template/tutorial/template = new tutorial_template
	var/datum/async_map_generator/template_placer = template.load(bottom_left_corner_reservation, FALSE, TRUE)
	template_placer.on_completion(CALLBACK(src, PROC_REF(start_tutorial), tutorial_mob))

/datum/tutorial/proc/start_tutorial(mob/starting_mob)
	var/obj/test_landmark = locate(/obj/effect/landmark/tutorial_bottom_left) in GLOB.landmarks_list
	bottom_left_corner = get_turf(test_landmark)
	qdel(test_landmark)
	if(!verify_template_loaded())
		abort_tutorial()
		return FALSE

	generate_binds()

	GLOB.ongoing_tutorials |= src
	var/area/tutorial_area = get_area(bottom_left_corner)
	init_map()
	if(!tutorial_mob)
		end_tutorial()

	return TRUE

/// The proc used to end and clean up the tutorial
/datum/tutorial/proc/end_tutorial(completed = FALSE)
	SHOULD_CALL_PARENT(TRUE)

	if(tutorial_mob)
		var/mob/dead/new_player/NP = new()
		if(!tutorial_mob.mind)
			tutorial_mob.mind_initialize()
		
		tutorial_mob.mind.transfer_to(NP)
	if(!QDELETED(src))
		qdel(src)

/datum/tutorial/proc/verify_template_loaded()
	// We subtract 1 from x and y because the bottom left corner doesn't start at the walls.
	var/turf/true_bottom_left_corner = locate(
		reservation.bottom_left_coords[1],
		reservation.bottom_left_coords[2],
		reservation.bottom_left_coords[3],
	)
	// We subtract 1 from x and y here because the bottom left corner counts as the first tile
	var/turf/top_right_corner = locate(
		true_bottom_left_corner.x + initial(tutorial_template.width) - 1,
		true_bottom_left_corner.y + initial(tutorial_template.height) - 1,
		true_bottom_left_corner.z
	)
	for(var/turf/tile as anything in block(true_bottom_left_corner, top_right_corner))
		// For some reason I'm unsure of, the template will not always fully load, leaving some tiles to be space tiles. So, we check all tiles in the (small) tutorial area
		// and tell start_tutorial to abort if there's any space tiles.
		if(istype(tile, /turf/open/space))
			return FALSE

	return TRUE

/// Something went very, very wrong during load so let's abort
/datum/tutorial/proc/abort_tutorial()
	to_chat(tutorial_mob, "<span class='boldwarning'>Something went wrong during tutorial load, please try again!</span>")
	end_tutorial(FALSE)

/datum/tutorial/proc/add_highlight(atom/target, color = "#d19a02")
	target.add_filter("tutorial_highlight", 2, list("type" = "outline", "color" = color, "size" = 1))

/datum/tutorial/proc/remove_highlight(atom/target)
	target.remove_filter("tutorial_highlight")

/datum/tutorial/proc/add_to_tracking_atoms(atom/reference)
	tracking_atoms[reference.type] = reference

/datum/tutorial/proc/remove_from_tracking_atoms(atom/reference)
	tracking_atoms -= reference.type

/// Broadcast a message to the player's screen
/datum/tutorial/proc/message_to_player(message)
	playsound(tutorial_mob.client, 'sound/effects/radio1.ogg', tutorial_mob.loc, 25, FALSE)
	tutorial_mob.balloon_alert(tutorial_mob, message)
	to_chat(tutorial_mob, "<span class='notice'>[message]</span>")


/// Initialize the tutorial mob.
/datum/tutorial/proc/init_mob()
	tutorial_mob.AddComponent(/datum/component/tutorial_status)
//	give_action(tutorial_mob, /datum/action/tutorial_end, null, null, src)
	ADD_TRAIT(tutorial_mob, TRAIT_IN_TUTORIAL, TRAIT_SOURCE_TUTORIAL)

/// Ends the tutorial after a certain amount of time.
/datum/tutorial/proc/tutorial_end_in(time = 5 SECONDS, completed = TRUE)
	tutorial_ending = TRUE
	addtimer(CALLBACK(src, PROC_REF(end_tutorial), completed), time)

/// Initialize any objects that need to be in the tutorial area from the beginning.
/datum/tutorial/proc/init_map()
	return

/// Returns a turf offset by offset_x (left-to-right) and offset_y (up-to-down)
/datum/tutorial/proc/loc_from_corner(offset_x = 0, offset_y = 0)
	RETURN_TYPE(/turf)
	return locate(bottom_left_corner.x + offset_x, bottom_left_corner.y + offset_y, bottom_left_corner.z)

/// Handle the player ghosting out
/datum/tutorial/proc/on_ghost(datum/source, mob/dead/observer/ghost)
	SIGNAL_HANDLER
	var/mob/dead/new_player/NP = new()
	if(!ghost.mind)
		ghost.mind_initialize()

	ghost.mind.transfer_to(NP)

	end_tutorial(FALSE)

/// A wrapper for signals to call end_tutorial()
/datum/tutorial/proc/signal_end_tutorial(datum/source)
	SIGNAL_HANDLER

	end_tutorial(FALSE)

/// Called whenever the tutorial_mob logs out
/datum/tutorial/proc/on_logout(datum/source)
	SIGNAL_HANDLER
	end_tutorial(FALSE)

/// Generate a dictionary of button : action for use of referencing what keys to press
/datum/tutorial/proc/generate_binds()
	if(!tutorial_mob.client?.prefs)
		return

	for(var/bind in tutorial_mob.client.prefs.key_bindings)
		var/action = tutorial_mob.client.prefs.key_bindings[bind]
		// We presume the first action under a certain binding is the one we want.
		if(action[1] in player_bind_dict)
			player_bind_dict[bind] += action[1]
		else
			player_bind_dict[bind] = list(action[1])

/// Getter for player_bind_dict. Provide an action name like "North" or "quick_equip"
/datum/tutorial/proc/retrieve_bind(action_name)
	if(!action_name)
		return

	if(!(action_name in player_bind_dict))
		return "Undefined"

	return player_bind_dict[action_name][1]

/datum/action/tutorial_end
	name = "Stop Tutorial"
//	icon_state = "nose"
	/// Weakref to the tutorial this is related to
	var/datum/weakref/tutorial

/datum/action/tutorial_end/New(Target, override_icon_state, datum/tutorial/selected_tutorial)
	. = ..()
	tutorial = WEAKREF(selected_tutorial)

///datum/action/tutorial_end/action_activate()
//	if(!tutorial)
//		return
//
//	var/datum/tutorial/selected_tutorial = tutorial.resolve()
//	if(selected_tutorial.tutorial_ending)
//		return
//
//	selected_tutorial.end_tutorial()
//
/datum/map_template/tutorial
	name = "Tutorial Zone (12x12)"
	mappath = "_maps/tutorial/tutorial_12x12.dmm"
	width = 12
	height = 12

/datum/map_template/tutorial/s12x12

/datum/map_template/tutorial/s12x12

/datum/map_template/tutorial/s8x9
	name = "Tutorial Zone (8x9)"
	mappath = "maps/tutorial/tutorial_8x9.dmm"
	width = 8
	height = 9

/datum/map_template/tutorial/s8x9/no_baselight
	name = "Tutorial Zone (8x9) (No Baselight)"
	mappath = "maps/tutorial/tutorial_8x9_nb.dmm"

/datum/map_template/tutorial/s7x7
	name = "Tutorial Zone (7x7)"
	mappath = "maps/tutorial/tutorial_7x7.dmm"
	width = 7
	height = 7
