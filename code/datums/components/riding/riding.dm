/// Offsets applied for people riding something
#define RIDING_SOURCE "riding"
/// Offsets applied for something being ridden
#define BEING_RIDDEN_SOURCE "being_ridden"

/**
 * This is the riding component, which is applied to a movable atom by the [ridable element][/datum/element/ridable] when a mob is successfully buckled to said movable.
 *
 * This component lives for as long as at least one mob is buckled to the parent. Once all mobs are unbuckled, the component is deleted, until another mob is buckled in
 * and we make a new riding component, so on and so forth until the sun explodes.
 */


/datum/component/riding
	dupe_mode = COMPONENT_DUPE_UNIQUE

	var/last_move_diagonal = FALSE
	/// Tick delay between movements, lower = faster, higher = slower
	var/vehicle_move_delay = 2

	var/vehicle_move_multiplier

	/**
	 * If the driver needs a certain item in hand (or inserted, for vehicles) to drive this. For vehicles, this must be duplicated on the actual vehicle object in their
	 * [/obj/vehicle/var/key_type] variable because the vehicle objects still have a few special checks/functions of their own I'm not porting over to the riding component
	 * quite yet. Make sure if you define it on the vehicle, you define it here too.
	 */
	var/keytype
	/// allow typecache for only certain turfs, forbid to allow all but those. allow only certain turfs will take precedence.
	var/list/allowed_turf_typecache
	/// allow typecache for only certain turfs, forbid to allow all but those. allow only certain turfs will take precedence.
	var/list/forbid_turf_typecache
	/// additional traits to add to anyone riding this vehicle
	var/list/rider_traits = list(TRAIT_NO_FLOATING_ANIM)
	/// We don't need roads where we're going if this is TRUE, allow normal movement in space tiles
	var/override_allow_spacemove = FALSE

	/**
	 * Ride check flags defined for the specific riding component types, so we know if we need arms, legs, or whatever.
	 * Takes additional flags from the ridable element and the buckle proc (buckle_mob_flags) for riding cyborgs/humans in case we need to reserve arms
	 */
	var/ride_check_flags = NONE
	/// For telling someone they can't drive
	COOLDOWN_DECLARE(message_cooldown)
	/// For telling someone they can't drive
	COOLDOWN_DECLARE(vehicle_move_cooldown)
	/// Optional native-direction mask for asymmetric vehicle layering.
	var/mutable_appearance/brandish_foreground
	/// Whether this component's seat poses can be fit as a single seat.
	var/brandish_fit_offsets = TRUE

/datum/component/riding/Initialize(mob/living/riding_mob, force = FALSE, buckle_mob_flags = NONE, potion_boost = FALSE)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	riding_mob.updating_glide_size = FALSE
	ride_check_flags |= buckle_mob_flags

	//Calculate the move multiplier speed, to be proportional to mob speed
	vehicle_move_multiplier = CONFIG_GET(number/movedelay/run_delay) / 1.5
	if(potion_boost || HAS_TRAIT(parent, TRAIT_SPEED_POTIONED))
		vehicle_move_delay = round(CONFIG_GET(number/movedelay/run_delay) * 0.85, 0.01)

/datum/component/riding/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_DIR_CHANGE, PROC_REF(vehicle_turned))
	RegisterSignal(parent, COMSIG_MOVABLE_UNBUCKLE, PROC_REF(vehicle_mob_unbuckle))
	RegisterSignal(parent, COMSIG_MOVABLE_BUCKLE, PROC_REF(vehicle_mob_buckle))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(vehicle_moved))
	RegisterSignal(parent, COMSIG_MOVABLE_BUMP, PROC_REF(vehicle_bump))
	RegisterSignals(parent, GLOB.movement_type_addtrait_signals, PROC_REF(on_movement_type_trait_gain))
	RegisterSignals(parent, GLOB.movement_type_removetrait_signals, PROC_REF(on_movement_type_trait_loss))
	RegisterSignal(parent, COMSIG_SUPERMATTER_CONSUMED, PROC_REF(on_entered_supermatter))
	if(isobj(parent) && brandish_fit_offsets)
		RegisterSignal(parent, COMSIG_ATOM_UPDATED_ICON, PROC_REF(on_brandish_seat_icon_updated))
	RegisterSignal(SSdcs, COMSIG_GLOB_BRANDISH_PERSPECTIVE_CHANGED, PROC_REF(on_brandish_perspective_changed))

/datum/component/riding/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_UPDATED_ICON)
	UnregisterSignal(SSdcs, COMSIG_GLOB_BRANDISH_PERSPECTIVE_CHANGED)
	clear_brandish_foreground()
	return ..()

/datum/component/riding/proc/on_brandish_perspective_changed()
	SIGNAL_HANDLER
	var/atom/movable/seat = parent
	update_parent_layer_and_offsets(seat.dir)

/// This proc is called when a rider unbuckles, whether they chose to or not. If there's no more riders, this will be the riding component's death knell.
/datum/component/riding/proc/vehicle_mob_unbuckle(datum/source, mob/living/rider, force = FALSE)
	SIGNAL_HANDLER

	restore_rider_layer_and_offsets(rider)
	handle_unbuckle(rider)

	var/atom/movable/movable_parent = parent
	if(movable_parent.has_buckled_mobs())
		update_parent_layer_and_offsets(movable_parent.dir, animate = TRUE)
	else
		restore_parent_layer_and_offsets()
		qdel(src)

/datum/component/riding/proc/handle_unbuckle(mob/living/rider)
	unequip_buckle_inhands(rider)
	rider.updating_glide_size = TRUE
	for (var/trait in GLOB.movement_type_trait_to_flag)
		if (HAS_TRAIT(parent, trait))
			REMOVE_TRAIT(rider, trait, REF(src))
	rider.remove_traits(rider_traits, REF(src))

/// This proc is called when a rider buckles, allowing for offsets to be set properly
/datum/component/riding/proc/vehicle_mob_buckle(datum/source, mob/living/rider, force = FALSE)
	SIGNAL_HANDLER

	var/atom/movable/movable_parent = parent
	update_parent_layer_and_offsets(movable_parent.dir, animate = TRUE)
	handle_buckle(rider)

/datum/component/riding/proc/handle_buckle(mob/living/rider)
	if(rider.pulling == parent)
		rider.stop_pulling()

	for (var/trait in GLOB.movement_type_trait_to_flag)
		if (HAS_TRAIT(parent, trait))
			ADD_TRAIT(rider, trait, REF(src))
	rider.add_traits(rider_traits, REF(src))

/// This is called after the ridden atom is successfully moved and is used to handle icon stuff
/datum/component/riding/proc/vehicle_moved(datum/source, oldloc, dir, forced)
	SIGNAL_HANDLER

	var/atom/movable/movable_parent = parent
	if(isnull(dir) || uses_brandish_riding_offsets())
		dir = movable_parent.dir
	refresh_riding_placement(dir)

/datum/component/riding/proc/refresh_riding_placement(dir)
	var/atom/movable/movable_parent = parent
	for(var/mob/buckled_mob as anything in movable_parent.buckled_mobs)
		ride_check(buckled_mob)
	if(QDELETED(src))
		return // runtimed with piggy's without this, look into this more
	update_parent_layer_and_offsets(dir)

/// Turning is like moving
/datum/component/riding/proc/vehicle_turned(datum/source, _old_dir, new_dir)
	SIGNAL_HANDLER

	if(uses_brandish_riding_offsets())
		refresh_riding_placement(new_dir)
	else
		vehicle_moved(source, new_dir)

/// Check to see if we have all of the necessary bodyparts and not-falling-over statuses we need to stay onboard
/datum/component/riding/proc/ride_check(mob/living/rider)
	return

#define GET_X_OFFSET(offsets) (length(offsets) >= 1 ? offsets[1] : 0)
#define GET_Y_OFFSET(offsets) (length(offsets) >= 2 ? offsets[2] : 0)
#define GET_LAYER(offsets, default) (length(offsets) >= 3 ? offsets[3] : default)

/datum/component/riding/proc/update_parent_layer_and_offsets(dir, animate = FALSE)
	var/atom/movable/seat = parent
	if(!seat.has_buckled_mobs())
		return

	var/passindex = 0
	for(var/mob/living/buckled_mob as anything in seat.buckled_mobs)
		passindex++
		update_rider_layer_and_offsets(dir, passindex, buckled_mob)

	var/list/directional_offsets = get_parent_offsets_and_layers()
	var/list/offsets = directional_offsets?["[dir]"]
	// Non-living parent tables contain legacy absolute sprite offsets. Remove
	// the canvas origin already moved to screen axes before splitting height.
	var/origin_x = isliving(seat) ? 0 : seat.brandish_origin_screen_x
	var/origin_y = isliving(seat) ? 0 : seat.brandish_origin_screen_y
	var/list/placement = get_riding_placement(directional_offsets, dir, uses_brandish_riding_offsets(), origin_x, origin_y)
	var/layer = GET_LAYER(offsets, seat.layer)

	if(isliving(seat))
		var/mob/living/living_seat = seat
		living_seat.add_offsets(BEING_RIDDEN_SOURCE, x_add = placement[1], y_add = placement[2], w_add = placement[3], z_add = placement[4], animate = animate)
	else
		seat.pixel_x = placement[1] + seat.base_pixel_x
		seat.pixel_y = placement[2] + seat.base_pixel_y
		seat.pixel_w = seat.get_screen_base_pixel_w() + placement[3]
		seat.pixel_z = seat.get_screen_base_pixel_z() + placement[4]
	if(update_brandish_foreground(length(offsets) >= 3))
		layer = OBJ_LAYER
	seat.layer = layer

/datum/component/riding/proc/update_rider_layer_and_offsets(dir, passindex, mob/living/rider, animate = FALSE)
	if(rider.dir != dir)
		rider.setDir(dir)

	var/list/directional_offsets = get_rider_offsets_and_layers(passindex, rider)
	var/list/diroffsets = directional_offsets?["[dir]"]
	var/list/placement = get_riding_placement(directional_offsets, dir, uses_brandish_riding_offsets())
	var/layer = GET_LAYER(diroffsets, rider.layer)

	// if they are intended to be buckled, offset their existing offset
	var/atom/movable/seat = parent
	if(seat.buckle_lying && rider.body_position == LYING_DOWN)
		placement[4] -= PIXEL_Y_OFFSET_LYING

	rider.add_offsets(RIDING_SOURCE, x_add = placement[1], y_add = placement[2], w_add = placement[3], z_add = placement[4], animate = animate)
	rider.layer = layer

/// Multi-tile seats and upright canvases with multiple seats keep their legacy placement.
/datum/component/riding/proc/uses_brandish_riding_offsets()
	var/atom/movable/seat = parent
	return GLOB.brandish_perspective_enabled && brandish_fit_offsets && seat.bound_width <= ICON_SIZE_X && seat.bound_height <= ICON_SIZE_Y

/// Fit R(camera) * (x, y) + (w, z) to the four screen-relative artwork poses.
/datum/component/riding/proc/get_riding_placement(list/directional_offsets, dir, fit = FALSE, origin_x = 0, origin_y = 0)
	var/list/north_view = directional_offsets?["[dir]"]
	if(fit && (dir in GLOB.cardinals))
		var/list/east_view = directional_offsets?["[turn(dir, 90)]"]
		var/list/south_view = directional_offsets?["[turn(dir, 180)]"]
		var/list/west_view = directional_offsets?["[turn(dir, -90)]"]
		if(length(north_view) >= 2 && length(east_view) >= 2 && length(south_view) >= 2 && length(west_view) >= 2)
			var/static/list/fitted_cache = list()
			var/cache_key = "[north_view[1]],[north_view[2]]|[east_view[1]],[east_view[2]]|[south_view[1]],[south_view[2]]|[west_view[1]],[west_view[2]]|[origin_x],[origin_y]"
			var/list/cached = fitted_cache[cache_key]
			if(cached)
				return cached.Copy()
			// Mean of the four poses is screen-fixed. The mean after applying
			// each inverse camera rotation gives the world offset because
			// the four rotated copies of the fixed term sum to zero.
			var/world_x = (north_view[1] + east_view[2] - south_view[1] - west_view[2]) / 4
			var/world_y = (north_view[2] - east_view[1] - south_view[2] + west_view[1]) / 4
			var/screen_x = (north_view[1] + east_view[1] + south_view[1] + west_view[1]) / 4 - origin_x
			var/screen_y = (north_view[2] + east_view[2] + south_view[2] + west_view[2]) / 4 - origin_y
			var/list/fitted = list(round(world_x, 1), round(world_y, 1), round(screen_x, 1), round(screen_y, 1))
			if((fitted[1] - world_x == 0.5 || fitted[2] - world_y == 0.5) && (fitted[3] != screen_x || fitted[4] != screen_y))
				var/list/poses = list(north_view, east_view, south_view, west_view)
				resolve_riding_rounding_ties(fitted, poses, world_x, world_y, screen_x, screen_y, origin_x, origin_y)
			fitted_cache[cache_key] = fitted
			return fitted.Copy()
	var/height = get_uniform_offset_height(directional_offsets, origin_y)
	return list(GET_X_OFFSET(north_view) - origin_x, GET_Y_OFFSET(north_view) - origin_y - height, 0, height)

/// Half-pixel world ties have two equally good least-squares solutions.
/// Keep the screen rounding fixed across headings and prefer the world pair
/// that adds the least error to the worst-affected view.
/datum/component/riding/proc/resolve_riding_rounding_ties(list/fitted, list/poses, world_x, world_y, screen_x, screen_y, origin_x, origin_y)
	var/list/x_candidates = list(fitted[1])
	var/list/y_candidates = list(fitted[2])
	if(fitted[1] - world_x == 0.5)
		x_candidates += fitted[1] - 1
	if(fitted[2] - world_y == 0.5)
		y_candidates += fitted[2] - 1
	var/static/list/view_headings = list(NORTH, EAST, SOUTH, WEST)
	var/best_increase = INFINITY
	for(var/x in x_candidates)
		for(var/y in y_candidates)
			var/max_increase = 0
			for(var/index in 1 to length(view_headings))
				var/heading = view_headings[index]
				var/list/pose = poses[index]
				var/list/continuous = camera_world_to_screen(world_x, world_y, heading)
				var/list/rounded = camera_world_to_screen(x, y, heading)
				var/dx = continuous[1] + screen_x + origin_x - pose[1]
				var/dy = continuous[2] + screen_y + origin_y - pose[2]
				var/rounded_dx = rounded[1] + fitted[3] + origin_x - pose[1]
				var/rounded_dy = rounded[2] + fitted[4] + origin_y - pose[2]
				max_increase = max(max_increase, sqrt(rounded_dx ** 2 + rounded_dy ** 2) - sqrt(dx ** 2 + dy ** 2))
			if(max_increase < best_increase)
				best_increase = max_increase
				fitted[1] = x
				fitted[2] = y

/datum/component/riding/proc/on_brandish_seat_icon_updated(atom/movable/seat)
	SIGNAL_HANDLER
	if(!seat.has_buckled_mobs() || (!brandish_foreground && !uses_brandish_riding_offsets()))
		return
	var/had_mask = !!brandish_foreground
	var/list/directional_offsets = get_parent_offsets_and_layers()
	var/list/offsets = directional_offsets?["[seat.dir]"]
	if(update_brandish_foreground(length(offsets) >= 3))
		seat.layer = OBJ_LAYER
	else if(had_mask)
		seat.layer = GET_LAYER(offsets, initial(seat.layer))

/// Only authored masks can replace a direction-specific layer. Vehicles with
/// existing native covers (e.g. wheelchair and speedbike) keep those overlays.
/datum/component/riding/proc/update_brandish_foreground(has_layer_override)
	var/atom/movable/seat = parent
	if(has_layer_override && isobj(seat) && uses_brandish_riding_offsets())
		var/mutable_appearance/foreground = GLOB.brandish_assets.foreground_for(seat.icon, seat.icon_state, ABOVE_MOB_LAYER)
		if(foreground && icon_exists(foreground.icon, foreground.icon_state))
			if(brandish_foreground?.icon != foreground.icon || brandish_foreground?.icon_state != foreground.icon_state)
				clear_brandish_foreground()
				brandish_foreground = foreground
			if(!(brandish_foreground.appearance in seat.overlays))
				seat.add_overlay(brandish_foreground)
			return TRUE
	clear_brandish_foreground()
	return FALSE

/datum/component/riding/proc/clear_brandish_foreground()
	if(!brandish_foreground)
		return
	var/atom/movable/seat = parent
	seat.cut_overlay(brandish_foreground)
	brandish_foreground = null

#undef GET_X_OFFSET
#undef GET_Y_OFFSET
#undef GET_LAYER

/// Preserve the legacy uniform-height rule when using the standard perspective.
/datum/component/riding/proc/get_uniform_offset_height(list/directional_offsets, origin = 0)
	var/height
	for(var/facing in GLOB.cardinals)
		var/list/offset = directional_offsets?["[facing]"]
		if(length(offset) < 2 || !isnum(offset[2]))
			return 0
		if(isnull(height))
			height = offset[2]
		else if(height != offset[2])
			return 0
	return (height || 0) - origin

/**
 * Determines where riders get offset while riding
 *
 * * pass_index: The index of the rider in the list of buckled mobs
 * * mob/offsetter: The mob that is being offset
 */
/datum/component/riding/proc/get_rider_offsets_and_layers(pass_index, mob/offsetter) as /list // list(dir = x, y, layer)
	RETURN_TYPE(/list)
	return list(
		TEXT_NORTH = list(0, 0),
		TEXT_SOUTH = list(0, 0),
		TEXT_EAST =  list(0, 0),
		TEXT_WEST =  list(0, 0),
	)

/**
 * Determines where the parent gets offset while riders are riding
 */
/datum/component/riding/proc/get_parent_offsets_and_layers() as /list // list(dir = x, y, layer)
	RETURN_TYPE(/list)
	return list(
		TEXT_NORTH = list(0, 0, OBJ_LAYER),
		TEXT_SOUTH = list(0, 0, ABOVE_MOB_LAYER),
		TEXT_EAST =  list(0, 0, ABOVE_MOB_LAYER),
		TEXT_WEST =  list(0, 0, ABOVE_MOB_LAYER),
	)

/**
 * This proc is used to see if we have the appropriate key to drive this atom, if such a key is needed. Returns FALSE if we don't have what we need to drive.
 *
 * Still needs to be neatened up and spruced up with proper OOP, as a result of vehicles having their own key handling from other ridable atoms
 */
/datum/component/riding/proc/keycheck(mob/user)
	if(!keytype)
		return TRUE

	if(isvehicle(parent))
		var/obj/vehicle/vehicle_parent = parent
		return istype(vehicle_parent.inserted_key, keytype)

	return user.is_holding_item_of_type(keytype)

//BUCKLE HOOKS
/datum/component/riding/proc/restore_rider_layer_and_offsets(mob/living/buckled_mob)
	buckled_mob.remove_offsets(RIDING_SOURCE)
	buckled_mob.layer = initial(buckled_mob.layer)
	buckled_mob.client?.view_size.resetToDefault()

/datum/component/riding/proc/restore_parent_layer_and_offsets()
	var/atom/movable/seat = parent
	clear_brandish_foreground()
	if(isliving(seat))
		var/mob/living/living_seat = seat
		living_seat.remove_offsets(BEING_RIDDEN_SOURCE)
	else
		seat.pixel_x = seat.base_pixel_x
		seat.pixel_y = seat.base_pixel_y
		seat.pixel_w = seat.get_screen_base_pixel_w()
		seat.pixel_z = seat.get_screen_base_pixel_z()
	seat.layer = initial(seat.layer)

//MOVEMENT
/datum/component/riding/proc/turf_check(turf/next, turf/current)
	if(allowed_turf_typecache && !allowed_turf_typecache[next.type])
		return allowed_turf_typecache[current.type]
	else if(forbid_turf_typecache && forbid_turf_typecache[next.type])
		return !forbid_turf_typecache[current.type]
	return TRUE

/// Every time the driver tries to move, this is called to see if they can actually drive and move the vehicle (via relaymove)
/datum/component/riding/proc/driver_move(atom/movable/movable_parent, mob/living/user, direction)
	SIGNAL_HANDLER
	SHOULD_CALL_PARENT(TRUE)
	movable_parent.set_glide_size(DELAY_TO_GLIDE_SIZE(vehicle_move_delay))

/// So we can check all occupants when we bump a door to see if anyone has access
/datum/component/riding/proc/vehicle_bump(atom/movable/movable_parent, obj/machinery/door/possible_bumped_door)
	SIGNAL_HANDLER
	if(!istype(possible_bumped_door))
		return
	for(var/occupant in movable_parent.buckled_mobs)
		INVOKE_ASYNC(possible_bumped_door, TYPE_PROC_REF(/obj/machinery/door, bumpopen), occupant)

/datum/component/riding/proc/Unbuckle(atom/movable/M)
	addtimer(CALLBACK(parent, TYPE_PROC_REF(/atom/movable, unbuckle_mob), M), 0, TIMER_UNIQUE)

/datum/component/riding/proc/Process_Spacemove(direction, continuous_move)
	var/atom/movable/AM = parent
	return override_allow_spacemove || AM.has_gravity()

/// currently replicated from ridable because we need this behavior here too, see if we can deal with that
/datum/component/riding/proc/unequip_buckle_inhands(mob/living/carbon/user)
	var/atom/movable/AM = parent
	for(var/obj/item/riding_offhand/O in user.contents)
		if(O.parent != AM)
			CRASH("RIDING OFFHAND ON WRONG MOB")
		if(O.selfdeleting)
			continue
		else
			qdel(O)
	return TRUE

/// Called when our vehicle gains a movement trait, so we can apply it to the riders
/datum/component/riding/proc/on_movement_type_trait_gain(atom/movable/source, trait)
	SIGNAL_HANDLER
	var/atom/movable/movable_parent = parent
	for (var/mob/rider in movable_parent.buckled_mobs)
		ADD_TRAIT(rider, trait, REF(src))

/// Called when our vehicle loses a movement trait, so we can remove it from the riders
/datum/component/riding/proc/on_movement_type_trait_loss(atom/movable/source, trait)
	SIGNAL_HANDLER
	var/atom/movable/movable_parent = parent
	for (var/mob/rider in movable_parent.buckled_mobs)
		REMOVE_TRAIT(rider, trait, REF(src))

/// When we touch a crystal, kill everything inside us
/datum/component/riding/proc/on_entered_supermatter(atom/movable/ridden, atom/movable/supermatter)
	SIGNAL_HANDLER
	for (var/mob/passenger as anything in ridden.buckled_mobs)
		passenger.Bump(supermatter)

#undef RIDING_SOURCE
#undef BEING_RIDDEN_SOURCE
