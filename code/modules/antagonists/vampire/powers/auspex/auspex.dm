/// Multiplier so the view can pan all the way to the edge of the (widened) screen without the cursor needing to leave the game window.
#define AUSPEX_POINTER_OFFSET_MULT 1.1
/// Maximum pixels the camera may travel per process tick, preventing the view from whipping instantly to the cursor.
#define AUSPEX_PAN_SPEED 64

/datum/discipline/auspex
	name = "Auspex"
	discipline_explanation = "Auspex is a Discipline that grants vampires supernatural senses, letting them peer far further and see things best left unseen.\n\
		The malkavians especially have a bond with it, being seers at heart."
	icon_state = "auspex"

	// Lists of abilities granted per level
	level_1 = list(/datum/action/vampire/auspex)
	level_2 = list(/datum/action/vampire/auspex/two)
	level_3 = list(/datum/action/vampire/auspex/three)
	level_4 = list(/datum/action/vampire/auspex/four)

/datum/discipline/auspex/level_up(datum/antagonist/vampire/clan_owner)
	. = ..()
	var/mob/living/ownermob = clan_owner.owner.current
	if(level >= 4)
		to_chat(ownermob, span_cultbold("You have reached level 3 in Auspex, sharpening your senses to such a degree that you can now hear through walls."), type = MESSAGE_TYPE_INFO)
		if(!HAS_TRAIT(ownermob, TRAIT_XRAY_HEARING))
			ADD_TRAIT(ownermob, TRAIT_XRAY_HEARING, "Auspex")

/datum/discipline/auspex/apply_discipline_quirks(datum/antagonist/vampire/clan_owner)
	var/mob/living/ownermob = clan_owner.owner.current
	if(!HAS_TRAIT(ownermob, TRAIT_GOOD_HEARING))
		to_chat(ownermob, span_cultbold("You have reached level 1 in Auspex. You are now able to clearly hear whispering of others."), type = MESSAGE_TYPE_INFO)
		ADD_TRAIT(ownermob, TRAIT_GOOD_HEARING, "Auspex")

/datum/discipline/auspex/malkavian
	level_5 = list(/datum/action/vampire/auspex/four, /datum/action/vampire/astral_projection)

/**
 *	# Auspex
 */
/datum/action/vampire/auspex
	name = "Auspex"
	desc = "Sense the vitae of any creature directly, and use your keen senses to widen your perception."
	button_icon_state = "power_auspex"
	power_explanation = "- Level 1: When Activated, you will see further. \n\
					- Level 2: When Activated, you will see further, and hear faint whispers as clearly as normal speech.\n\
					- Level 3: When Activated, You get meson vision, with even more range. \n\
					- Level 4: When Activated, you will see much, much further, and be able to sense anything in sight, seeing through walls and barriers as if they were glass, and hearing speech through them too."
	power_flags = BP_AM_TOGGLE | BP_AM_STATIC_COOLDOWN
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	vitaecost = 20
	constant_vitaecost = 0.25
	cooldown_time = 1 SECONDS

	// These can be changed
	var/add_meson = FALSE
	var/add_xray = FALSE
	var/pan_tiles = 10

	// These cannot
	var/looking = FALSE
	var/mob/listeningTo
	/// Fullscreen mouse-tracker that drives the cursor panning while we're looking.
	var/atom/movable/screen/fullscreen/cursor_catcher/auspex/scope_tracker

/datum/action/vampire/auspex/two
	name = "Auspex"
	vitaecost = 20
	constant_vitaecost = 0.5
	pan_tiles = 20

/datum/action/vampire/auspex/three
	name = "Auspex"
	vitaecost = 20
	constant_vitaecost = 0.75
	pan_tiles = 30
	add_meson = TRUE

/datum/action/vampire/auspex/four
	name = "Auspex"
	vitaecost = 20
	constant_vitaecost = 1
	pan_tiles = 50
	add_xray = TRUE

/datum/action/vampire/auspex/activate_power()
	. = ..()
	if(!looking)
		lookie()

/datum/action/vampire/auspex/deactivate_power()
	if(looking)
		unlooky()
	return ..()// This does cooldown stuff and we have to do it after because processing stuff i think maybe iunno it doesn't work without this

/datum/action/vampire/auspex/proc/lookie()
	SIGNAL_HANDLER

	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(deactivate_power))
	listeningTo = owner
	looking = TRUE

	if(owner?.client)
		// Panning
		scope_tracker = owner.overlay_fullscreen("auspex", /atom/movable/screen/fullscreen/cursor_catcher/auspex, 0)
		scope_tracker.assign_to_mob(owner, pan_tiles)
		START_PROCESSING(SSfastprocess, src)

	if(add_meson && !HAS_TRAIT(owner, TRAIT_MESON_VISION))
		ADD_TRAIT(owner, TRAIT_MESON_VISION, "Auspex")
		owner.update_sight()

	if(add_xray && !HAS_TRAIT(owner, TRAIT_XRAY_VISION))
		ADD_TRAIT(owner, TRAIT_XRAY_VISION, "Auspex")
		owner.update_sight()

/// Pans the view toward the cursor each tick while the power is active.
/datum/action/vampire/auspex/process(seconds_per_tick)
	// No lookie? so stop
	if(!looking)
		return ..()

	var/client/user_client = owner?.client
	if(isnull(user_client) || isnull(scope_tracker))
		// Lost our client, time to panic and shut it all down safely
		deactivate_power()
		return

	scope_tracker.calculate_params()

	// Animate magic
	animate(user_client, SSfastprocess.wait, pixel_x = scope_tracker.given_x, pixel_y = scope_tracker.given_y)

/datum/action/vampire/auspex/proc/unlooky()
	SIGNAL_HANDLER

	STOP_PROCESSING(SSfastprocess, src)

	if(listeningTo)
		UnregisterSignal(listeningTo, COMSIG_MOVABLE_MOVED)
		listeningTo = null

	looking = FALSE

	if(owner)
		owner.clear_fullscreen("auspex")

		if(owner.client)
			var/client/our_client = owner.client
			animate(our_client, 1 SECONDS, pixel_x = 0, pixel_y = 0)

	scope_tracker = null

	if(HAS_TRAIT_FROM(owner, TRAIT_MESON_VISION, "Auspex"))
		REMOVE_TRAIT(owner, TRAIT_MESON_VISION, "Auspex")

	if(HAS_TRAIT_FROM(owner, TRAIT_XRAY_VISION, "Auspex"))
		REMOVE_TRAIT(owner, TRAIT_XRAY_VISION, "Auspex")

	owner.update_sight()

/datum/action/vampire/auspex/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	scope_tracker = null
	listeningTo = null
	return ..()

/atom/movable/screen/fullscreen/cursor_catcher/auspex
	/// How many tiles the view may pan from centre toward the cursor.
	var/pan_tiles = 2
	/// Current smoothed camera offset, updated each tick by at most AUSPEX_PAN_SPEED pixels.
	var/tracked_x = 0
	var/tracked_y = 0

/atom/movable/screen/fullscreen/cursor_catcher/auspex/assign_to_mob(mob/new_owner, pan_tiles)
	src.pan_tiles = pan_tiles
	return ..()

/atom/movable/screen/fullscreen/cursor_catcher/auspex/Click(location, control, params)
	if(usr == owner)
		calculate_params()
	return ..()

/// Black magic
/atom/movable/screen/fullscreen/cursor_catcher/auspex/calculate_params()
	var/list/modifiers = params2list(mouse_params)
	var/center_x = view_list[1] * ICON_SIZE_X / 2
	var/center_y = view_list[2] * ICON_SIZE_Y / 2
	var/icon_x = text2num(LAZYACCESS(modifiers, VIS_X))

	if(isnull(icon_x))
		icon_x = text2num(LAZYACCESS(modifiers, ICON_X))
		if(isnull(icon_x))
			icon_x = center_x

	var/icon_y = text2num(LAZYACCESS(modifiers, VIS_Y))
	if(isnull(icon_y))
		icon_y = text2num(LAZYACCESS(modifiers, ICON_Y))
		if(isnull(icon_y))
			icon_y = center_y

	var/x_cap = pan_tiles * ICON_SIZE_X
	var/y_cap = pan_tiles * ICON_SIZE_Y
	var/uncapped_x = round((icon_x - center_x) / center_x * x_cap * AUSPEX_POINTER_OFFSET_MULT)
	var/uncapped_y = round((icon_y - center_y) / center_y * y_cap * AUSPEX_POINTER_OFFSET_MULT)

	var/target_x = clamp(uncapped_x, -x_cap, x_cap)
	var/target_y = clamp(uncapped_y, -y_cap, y_cap)

	// Step toward the target by at most AUSPEX_PAN_SPEED pixels per tick to avoid whipping the camera.
	tracked_x = clamp(target_x, tracked_x - AUSPEX_PAN_SPEED, tracked_x + AUSPEX_PAN_SPEED)
	tracked_y = clamp(target_y, tracked_y - AUSPEX_PAN_SPEED, tracked_y + AUSPEX_PAN_SPEED)

	given_x = tracked_x
	given_y = tracked_y
	given_turf = locate(owner.x + round(given_x / ICON_SIZE_X, 1), owner.y + round(given_y / ICON_SIZE_Y, 1), owner.z)

#undef AUSPEX_PAN_SPEED
#undef AUSPEX_POINTER_OFFSET_MULT
