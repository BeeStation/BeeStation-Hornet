GLOBAL_LIST_EMPTY(station_turfs)
GLOBAL_LIST_EMPTY(created_baseturf_lists)
/turf
	icon = 'icons/turf/floors.dmi'

	/// If this is TRUE, that means this floor is on top of plating so pipes and wires and stuff will appear under it... or something like that it's not entirely clear.
	var/intact = 1

	// baseturfs can be either a list or a single turf type.
	// In class definition like here it should always be a single type.
	// A list will be created in initialization that figures out the baseturf's baseturf etc.
	// In the case of a list it is sorted from bottom layer to top.
	/** baseturfs are the turfs that will appear under a turf when said turf is destroyed. For instance: when a floor is destroyed, you get plating.
	  *
	  * This shouldn't be modified directly, use the helper procs.
	  */
	var/list/baseturfs = /turf/baseturf_bottom

	/// How hot the turf is, in kelvin
	var/initial_temperature = T20C

	/// Used for fire, if a melting temperature was reached, it will be destroyed
	var/to_be_destroyed = 0
	var/max_fire_temperature_sustained = 0 //The max temperature of the fire which it was subjected to

	//If true, turf will allow users to float up and down in 0 grav.
	var/allow_z_travel = FALSE

	flags_1 = CAN_BE_DIRTY_1

	/// For the station blueprints, images of objects eg: pipes
	var/list/image/blueprint_data

	var/explosion_level = 0	//for preventing explosion dodging
	var/explosion_id = 0
	var/list/explosion_throw_details

	var/requires_activation	//add to air processing after initialize?
	var/changing_turf = FALSE

	/// Sound played when a shell casing is ejected ontop of the turf.
	var/bullet_bounce_sound = 'sound/weapons/bulletremove.ogg'
	/// Used by ammo_casing/bounce_away() to determine if the shell casing should make a sizzle sound when it's ejected over the turf. ex: If the turf is supposed to be water, set TRUE.
	var/bullet_sizzle = FALSE

	///Lumcount added by sources other than lighting datum objects, such as the overlay lighting component.
	var/dynamic_lumcount = 0

	/// Should we used the smooth tiled dirt decal or not
	var/tiled_dirt = FALSE

	vis_flags = VIS_INHERIT_ID|VIS_INHERIT_PLANE // Important for interaction with and visualization of openspace.

	///the holodeck can load onto this turf if TRUE
	var/holodeck_compatible = FALSE

	var/list/fixed_underlay = null

/turf/vv_edit_var(var_name, new_value)
	var/static/list/banned_edits = list("x", "y", "z")
	if(var_name in banned_edits)
		return FALSE
	. = ..()

/turf/Initialize(mapload)
	if(flags_1 & INITIALIZED_1)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	flags_1 |= INITIALIZED_1

	// by default, vis_contents is inherited from the turf that was here before
	vis_contents.Cut()

	assemble_baseturfs()

	levelupdate()
	if(length(smoothing_groups))
		sortTim(smoothing_groups) //In case it's not properly ordered, let's avoid duplicate entries with the same values.
		SET_BITFLAG_LIST(smoothing_groups)
	if(length(canSmoothWith))
		sortTim(canSmoothWith)
		if(canSmoothWith[length(canSmoothWith)] > MAX_S_TURF) //If the last element is higher than the maximum turf-only value, then it must scan turf contents for smoothing targets.
			smoothing_flags |= SMOOTH_OBJ
		SET_BITFLAG_LIST(canSmoothWith)
	if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
		QUEUE_SMOOTH(src)
	visibilityChanged()

	for(var/atom/movable/content as anything in src)
		Entered(content, null)

	var/area/A = loc
	if(!IS_DYNAMIC_LIGHTING(src) && IS_DYNAMIC_LIGHTING(A))
		add_overlay(/obj/effect/fullbright)

	if(requires_activation)
		CALCULATE_ADJACENT_TURFS(src)

	if(color)
		add_atom_colour(color, FIXED_COLOUR_PRIORITY)

	if (light_power && light_range)
		update_light()

	var/turf/T = SSmapping.get_turf_above(src)
	if(T)
		T.multiz_turf_new(src, DOWN)
		SEND_SIGNAL(T, COMSIG_TURF_MULTIZ_NEW, src, DOWN)
	T = SSmapping.get_turf_below(src)
	if(T)
		T.multiz_turf_new(src, UP)
		SEND_SIGNAL(T, COMSIG_TURF_MULTIZ_NEW, src, UP)

	if (opacity)
		has_opaque_atom = TRUE

	ComponentInitialize()
	if(isopenturf(src))
		var/turf/open/O = src
		__auxtools_update_turf_temp_info(isspaceturf(get_z_base_turf()) && !O.planetary_atmos)
	else
		update_air_ref(-1)
		__auxtools_update_turf_temp_info(isspaceturf(get_z_base_turf()))

	return INITIALIZE_HINT_NORMAL

/turf/proc/__auxtools_update_turf_temp_info()

/turf/return_temperature()

/turf/proc/set_temperature()

/turf/proc/Initalize_Atmos(times_fired)
	CALCULATE_ADJACENT_TURFS(src)

/turf/Destroy(force)
	. = QDEL_HINT_IWILLGC
	if(!changing_turf)
		stack_trace("Incorrect turf deletion")
	changing_turf = FALSE
	var/turf/T = SSmapping.get_turf_above(src)
	if(T)
		T.multiz_turf_del(src, DOWN)
	T = SSmapping.get_turf_below(src)
	if(T)
		T.multiz_turf_del(src, UP)
	if(force)
		..()
		//this will completely wipe turf state
		var/turf/B = new world.turf(src)
		for(var/A in B.contents)
			qdel(A)
		for(var/I in B.vars)
			B.vars[I] = null
		return
	visibilityChanged()
	QDEL_LIST(blueprint_data)
	flags_1 &= ~INITIALIZED_1
	requires_activation = FALSE
	..()

	vis_contents.Cut()

/// WARNING WARNING
/// Turfs DO NOT lose their signals when they get replaced, REMEMBER THIS
/// It's possible because turfs are fucked, and if you have one in a list and it's replaced with another one, the list ref points to the new turf
/// We do it because moving signals over was needlessly expensive, and bloated a very commonly used bit of code
/turf/clear_signal_refs()
	return

/turf/attack_hand(mob/user)
	//Must have no gravity.
	if(get_turf(user) == src)
		if(!user.has_gravity(src) || (user.movement_type & FLYING))
			check_z_travel(user)
			return
		else if(allow_z_travel)
			to_chat(user, "<span class='warning'>You can't float up and down when there is gravity!</span>")
	. = ..()
	if(SEND_SIGNAL(user, COMSIG_MOB_ATTACK_HAND_TURF, src) & COMPONENT_NO_ATTACK_HAND)
		. = TRUE
	if(.)
		return
	user.Move_Pulled(src)

/turf/eminence_act(mob/living/simple_animal/eminence/eminence)
	if(get_turf(eminence) == src)
		check_z_travel(eminence)
		return
	return ..()

/turf/proc/check_z_travel(mob/user)
	if(get_turf(user) != src)
		return
	var/list/tool_list = list()
	var/turf/above = above()
	if(above)
		tool_list["Up"] = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = NORTH)
	var/turf/below = below()
	if(below)
		tool_list["Down"] = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = SOUTH)

	if(!length(tool_list))
		return

	var/result = show_radial_menu(user, user, tool_list, require_near = TRUE, tooltips = TRUE)
	if(get_turf(user) != src)
		return
	switch(result)
		if("Cancel")
			return
		if("Up")
			if(user.zMove(UP, TRUE))
				to_chat(user, "<span class='notice'>You move upwards.</span>")
		if("Down")
			if(user.zMove(DOWN, TRUE))
				to_chat(user, "<span class='notice'>You move down.</span>")

/turf/proc/travel_z(mob/user, turf/target, dir)
	var/mob/living/L = user
	if(istype(L) && L.incorporeal_move) // Allow most jaunting
		user.client?.Process_Incorpmove(dir)
		return
	var/atom/movable/AM
	if(user.pulling)
		AM = user.pulling
		AM.forceMove(target)
	if(user.pulledby) // We moved our way out of the pull
		user.pulledby.stop_pulling()
	if(user.has_buckled_mobs())
		for(var/M in user.buckled_mobs)
			var/mob/living/buckled_mob = M
			var/old_dir = buckled_mob.dir
			if(!buckled_mob.Move(target, dir))
				user.doMove(buckled_mob.loc) //forceMove breaks buckles, use doMove
				user.last_move = buckled_mob.last_move
				// Otherwise they will always face north
				buckled_mob.setDir(old_dir)
				user.setDir(old_dir)
				return FALSE
	else
		user.forceMove(target)
	if(istype(AM) && user.Adjacent(AM))
		user.start_pulling(AM)

/turf/proc/multiz_turf_del(turf/T, dir)

/turf/proc/multiz_turf_new(turf/T, dir)

/// Returns TRUE if the turf cannot be moved onto
/proc/is_blocked_turf(turf/T, exclude_mobs)
	if(T.density)
		return 1
	for(var/i in T)
		var/atom/A = i
		if(A.density && (!exclude_mobs || !ismob(A)))
			return 1
	return 0

/proc/is_anchored_dense_turf(turf/T) //like the older version of the above, fails only if also anchored
	if(T.density)
		return 1
	for(var/i in T)
		var/atom/movable/A = i
		if(A.density && A.anchored)
			return 1
	return 0


//zPassIn doesn't necessarily pass an atom!
//direction is direction of travel of air
/turf/proc/zPassIn(atom/movable/A, direction, turf/source, falling = FALSE)
	return FALSE

//direction is direction of travel of air
/turf/proc/zPassOut(atom/movable/A, direction, turf/destination, falling = FALSE)
	return FALSE

//direction is direction of travel of air
/turf/proc/zAirIn(direction, turf/source)
	return FALSE

//direction is direction of travel of air
/turf/proc/zAirOut(direction, turf/source)
	return FALSE

/turf/proc/attempt_z_impact(atom/movable/A, levels = 1, turf/prev_turf)
	var/flags = NONE
	for(var/i in contents)
		var/atom/thing = i
		flags |= thing.intercept_zImpact(A, levels)
		if(flags & FALL_STOP_INTERCEPTING)
			break
	if(prev_turf && !(flags & FALL_NO_MESSAGE))
		prev_turf.visible_message("<span class='danger'>[A] falls through [prev_turf]!</span>")
	if(flags & FALL_INTERCEPTED)
		return FALSE
	if(zFall(A, levels + 1, from_zfall = TRUE))
		return FALSE
	do_z_impact(A, levels)
	return TRUE

/turf/proc/do_z_impact(atom/movable/A, levels)
	// You can "crash into" openspace above zero gravity, but it looks weird to say that
	if(!isopenspace(src))
		A.visible_message("<span class='danger'>[A] crashes into [src]!</span>")
	A.onZImpact(src, levels)

/// If an atom is allowed to zfall through this turf
/turf/proc/can_zFall(atom/movable/A, turf/target)
	return zPassOut(A, DOWN, target, falling = TRUE) && target.zPassIn(A, DOWN, src, falling = TRUE)

/// Determines if an atom should start zfalling or continue zfalling
/turf/proc/can_start_zFall(atom/movable/A, turf/target, force = FALSE, from_zfall = FALSE)
	if(!from_zfall && A.zfalling) // We don't want to trigger another zfall
		return FALSE
	if(!target || (!isobj(A) && !ismob(A)))
		return FALSE
	if(!force && (!can_zFall(A, target) || !A.can_zFall(src, target, DOWN)))
		return FALSE
	return TRUE

/// A non-waiting proc that calls zFall()
/turf/proc/try_start_zFall(atom/movable/A, levels = 1, force = FALSE, old_loc = null)
	set waitfor = FALSE
	zFall(A, levels, force, old_loc, FALSE)

/// Checks if we can start a zfall and then performs the zfall
/turf/proc/zFall(atom/movable/A, levels = 1, force = FALSE, old_loc = null, from_zfall = FALSE)
	var/turf/target = get_step_multiz(src, DOWN)
	if(!can_start_zFall(A, target, force, from_zfall))
		return FALSE
	if(from_zfall) // if this is a >1 level fall
		sleep(2) // add some time
		var/turf/new_turf = get_turf(A) // make sure we didn't move onto a solid turf, if we did this will perform a zimpact via the caller
		target = get_step_multiz(new_turf, DOWN)
		if(!new_turf.can_start_zFall(A, target, force, from_zfall))
			new_turf.do_z_impact(A, levels - 1)
			return TRUE // skip parent zimpact - do a zimpact on new turf, the turf below us is solid
		else if(new_turf != src) // our fall continues... no need to check can_start_zFall again, because we just checked it
			new_turf.zFall_Move(A, levels, old_loc, target)
			return TRUE // don't do an impact from the parent caller. essentially terminating the old fall with no actions
	return zFall_Move(A, levels, old_loc, target)

/// Actually performs the zfall movement, regardless of if you can fall or not
/turf/proc/zFall_Move(atom/movable/A, levels = 1, old_loc = null, turf/target)
	A.zfalling = TRUE
	if(A.pulling && old_loc) // Moves whatever we're pulling to where we were before so we're still adjacent
		A.pulling.moving_from_pull = A
		A.pulling.Move(old_loc)
		A.pulling.moving_from_pull = null
	if(A.pulledby) // Prevents dragging stuff while on another z-level
		A.pulledby.stop_pulling()
	if(!A.Move(target))
		A.doMove(target)
	// Returns false if we continue falling - which calls zfall again
	// which calls attempt_z_impact (which returns true) if it impacts
	// basically, check if we should hit the ground, otherwise call zFall again.
	. = target.attempt_z_impact(A, levels, src)
	A.zfalling = FALSE

/turf/proc/handleRCL(obj/item/rcl/C, mob/user)
	if(C.loaded)
		for(var/obj/structure/cable/LC in src)
			if(!LC.d1 || !LC.d2)
				LC.handlecable(C, user)
				return
		C.loaded.place_turf(src, user)
		if(C.wiring_gui_menu)
			C.wiringGuiUpdate(user)
		C.is_empty(user)

/turf/attackby(obj/item/C, mob/user, params)
	if(..())
		return TRUE
	if(can_lay_cable() && istype(C, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/coil = C
		for(var/obj/structure/cable/LC in src)
			if(!LC.d1 || !LC.d2)
				LC.attackby(C,user)
				return
		coil.place_turf(src, user)
		return TRUE

	else if(istype(C, /obj/item/rcl))
		handleRCL(C, user)

	return FALSE

//There's a lot of QDELETED() calls here if someone can figure out how to optimize this but not runtime when something gets deleted by a Bump/CanPass/Cross call, lemme know or go ahead and fix this mess - kevinz000
/turf/Enter(atom/movable/mover)
	// Do not call ..()
	// Byond's default turf/Enter() doesn't have the behaviour we want with Bump()
	// By default byond will call Bump() on the first dense object in contents
	// Here's hoping it doesn't stay like this for years before we finish conversion to step_
	var/atom/firstbump
	var/canPassSelf = CanPass(mover, src)
	if(canPassSelf || (mover.movement_type & PHASING))
		for(var/i in contents)
			if(QDELETED(mover))
				return FALSE		//We were deleted, do not attempt to proceed with movement.
			if(i == mover || i == mover.loc) // Multi tile objects and moving out of other objects
				continue
			var/atom/movable/thing = i
			if(!thing.Cross(mover))
				if(QDELETED(mover))		//Mover deleted from Cross/CanPass, do not proceed.
					return FALSE
				if((mover.movement_type & PHASING))
					mover.Bump(thing)
					continue
				else
					if(!firstbump || ((thing.layer > firstbump.layer || thing.flags_1 & ON_BORDER_1) && !(firstbump.flags_1 & ON_BORDER_1)))
						firstbump = thing
	if(QDELETED(mover))					//Mover deleted from Cross/CanPass/Bump, do not proceed.
		return FALSE
	if(!canPassSelf)	//Even if mover is unstoppable they need to bump us.
		firstbump = src
	if(firstbump)
		mover.Bump(firstbump)
		return (mover.movement_type & PHASING)
	return TRUE

/turf/Entered(atom/movable/arrived, direction)
	..()
	// If an opaque movable atom moves around we need to potentially update visibility.
	if (arrived.opacity)
		has_opaque_atom = TRUE // Make sure to do this before reconsider_lights(), incase we're on instant updates. Guaranteed to be on in this case.
		reconsider_lights()

/turf/open/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	..()
	//melting
	if(isobj(arrived) && air && air.return_temperature() > T0C)
		var/obj/O = arrived
		if(O.obj_flags & FROZEN)
			O.make_unfrozen()
	if(!arrived.zfalling)
		zFall(arrived, old_loc = old_loc)


/turf/open/openspace/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	..()
	// Did not move in parent call
	if(get_turf(arrived) == src)
		SSzfall.add_openspace_inhabitant(arrived)

/turf/open/openspace/Exited(atom/movable/exiting, atom/newloc)
	..()
	SSzfall.remove_openspace_inhabitant(exiting)

// A proc in case it needs to be recreated or badmins want to change the baseturfs
/turf/proc/assemble_baseturfs(turf/fake_baseturf_type)
	var/turf/current_target
	if(fake_baseturf_type)
		if(length(fake_baseturf_type)) // We were given a list, just apply it and move on
			baseturfs = fake_baseturf_type
			return
		current_target = fake_baseturf_type
	else
		if(length(baseturfs))
			return // No replacement baseturf has been given and the current baseturfs value is already a list/assembled
		if(!baseturfs)
			current_target = initial(baseturfs) || type // This should never happen but just in case...
			stack_trace("baseturfs var was null for [type]. Failsafe activated and it has been given a new baseturfs value of [current_target].")
		else
			current_target = baseturfs

	// If we've made the output before we don't need to regenerate it
	if(GLOB.created_baseturf_lists[current_target])
		var/list/premade_baseturfs = GLOB.created_baseturf_lists[current_target]
		if(length(premade_baseturfs))
			baseturfs = premade_baseturfs.Copy()
		else
			baseturfs = premade_baseturfs
		return baseturfs

	var/turf/next_target = initial(current_target.baseturfs)
	//Most things only have 1 baseturf so this loop won't run in most cases
	if(current_target == next_target)
		baseturfs = current_target
		GLOB.created_baseturf_lists[current_target] = current_target
		return current_target
	var/list/new_baseturfs = list(current_target)
	for(var/i=0;current_target != next_target;i++)
		if(i > 100)
			// A baseturfs list over 100 members long is silly
			// Because of how this is all structured it will only runtime/message once per type
			stack_trace("A turf <[type]> created a baseturfs list over 100 members long. This is most likely an infinite loop.")
			message_admins("A turf <[type]> created a baseturfs list over 100 members long. This is most likely an infinite loop.")
			break
		new_baseturfs.Insert(1, next_target)
		current_target = next_target
		next_target = initial(current_target.baseturfs)

	baseturfs = new_baseturfs
	GLOB.created_baseturf_lists[new_baseturfs[new_baseturfs.len]] = new_baseturfs.Copy()
	return new_baseturfs

/turf/proc/levelupdate()
	for(var/obj/O in src)
		if(O.flags_1 & INITIALIZED_1)
			SEND_SIGNAL(O, COMSIG_OBJ_HIDE, intact)

// override for space turfs, since they should never hide anything
/turf/open/space/levelupdate()
	for(var/obj/O in src)
		return

// Removes all signs of lattice on the pos of the turf -Donkieyo
/turf/proc/RemoveLattice()
	var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
	if(L && (L.flags_1 & INITIALIZED_1))
		qdel(L)

/turf/proc/Bless()
	new /obj/effect/blessing(src)

/turf/storage_contents_dump_act(datum/component/storage/src_object, mob/user)
	. = ..()
	if(.)
		return
	if(length(src_object.contents()))
		balloon_alert(usr, "You dump out the contents.")
		if(!do_after(usr,20,target=src_object.parent))
			return FALSE

	var/list/things = src_object.contents()
	var/datum/progressbar/progress = new(user, things.len, src)
	while (do_after(usr, 10, src, progress = FALSE, extra_checks = CALLBACK(src_object, TYPE_PROC_REF(/datum/component/storage, mass_remove_from_storage), src, things, progress)))
		stoplag(1)
	qdel(progress)

	return TRUE

//////////////////////////////
//Distance procs
//////////////////////////////

//Distance associates with all directions movement
/turf/proc/Distance(var/turf/T)
	return get_dist(src,T)

//  This Distance proc assumes that only cardinal movement is
//  possible. It results in more efficient (CPU-wise) pathing
//  for bots and anything else that only moves in cardinal dirs.
/turf/proc/Distance_cardinal(turf/T)
	if(!src || !T)
		return FALSE
	return abs(x - T.x) + abs(y - T.y)

////////////////////////////////////////////////////

/turf/singularity_act()
	if(intact)
		for(var/obj/O in contents) //this is for deleting things like wires contained in the turf
			if(O.invisibility == INVISIBILITY_MAXIMUM)
				O.singularity_act()
	ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
	return(2)

/turf/proc/can_have_cabling()
	return TRUE

/turf/proc/can_lay_cable()
	return can_have_cabling() & !intact

/turf/proc/visibilityChanged()
	GLOB.cameranet.updateVisibility(src)

/turf/proc/burn_tile()
	return

/turf/proc/is_shielded()
	return

/turf/contents_explosion(severity, target)

	for(var/thing in contents)
		var/atom/atom_thing = thing
		if(!QDELETED(atom_thing))
			if(ismovable(atom_thing))
				var/atom/movable/movable_thing = atom_thing
				if(!movable_thing.ex_check(explosion_id))
					continue
				switch(severity)
					if(EXPLODE_DEVASTATE)
						SSexplosions.high_mov_atom += movable_thing
					if(EXPLODE_HEAVY)
						SSexplosions.med_mov_atom += movable_thing
					if(EXPLODE_LIGHT)
						SSexplosions.low_mov_atom += movable_thing

/turf/narsie_act(force, ignore_mobs, probability = 20)
	. = (prob(probability) || force)
	for(var/I in src)
		var/atom/A = I
		if(ignore_mobs && ismob(A))
			continue
		if(ismob(A) || .)
			A.narsie_act()

/turf/ratvar_act(force, ignore_mobs, probability = 40)
	. = (prob(probability) || force)
	for(var/I in src)
		var/atom/A = I
		if(ignore_mobs && ismob(A))
			continue
		if(ismob(A) || .)
			A.ratvar_act()

/turf/proc/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = icon
	underlay_appearance.icon_state = icon_state
	underlay_appearance.dir = adjacency_dir
	return TRUE

/turf/proc/add_blueprints(atom/movable/AM)
	var/image/I = new
	I.appearance = AM.appearance
	I.appearance_flags = RESET_COLOR|RESET_ALPHA|RESET_TRANSFORM
	I.loc = src
	I.setDir(AM.dir)
	I.alpha = 128

	LAZYADD(blueprint_data, I)


/turf/proc/add_blueprints_preround(atom/movable/AM)
	if(!SSicon_smooth.initialized)
		add_blueprints(AM)

/turf/proc/is_transition_turf()
	return

/turf/acid_act(acidpwr, acid_volume)
	. = 1
	var/acid_type = /obj/effect/acid
	if(acidpwr >= 200) //alien acid power
		acid_type = /obj/effect/acid/alien
	var/has_acid_effect = FALSE
	for(var/obj/O in src)
		if(istype(O, acid_type))
			var/obj/effect/acid/A = O
			A.acid_level = min(acid_volume * acidpwr, 12000)//capping acid level to limit power of the acid
			has_acid_effect = 1
			continue
		O.acid_act(acidpwr, acid_volume)
	if(!has_acid_effect)
		new acid_type(src, acidpwr, acid_volume)

/turf/proc/acid_melt()
	return

/turf/rust_heretic_act()
	if(HAS_TRAIT(src, TRAIT_RUSTY))
		return

	AddElement(/datum/element/rust)

/turf/handle_fall(mob/faller, forced)
	if(!forced)
		return
	if(has_gravity(src))
		playsound(src, "bodyfall", 50, 1)

/turf/proc/photograph(limit=20)
	var/image/I = new()
	I.add_overlay(src)
	for(var/V in contents)
		var/atom/A = V
		if(A.invisibility)
			continue
		I.add_overlay(A)
		if(limit)
			limit--
		else
			return I
	return I

/turf/AllowDrop()
	return TRUE

/turf/proc/add_vomit_floor(mob/living/M, toxvomit = NONE)

	var/obj/effect/decal/cleanable/vomit/V = new /obj/effect/decal/cleanable/vomit(src, M.get_static_viruses())

	//if the vomit combined, apply toxicity and reagents to the old vomit
	if (QDELETED(V))
		V = locate() in src
	if(!V)
		return
	// Make toxins and blazaam vomit look different
	if(toxvomit == VOMIT_PURPLE)
		V.icon_state = "vomitpurp_[pick(1,4)]"
	else if (toxvomit == VOMIT_TOXIC)
		V.icon_state = "vomittox_[pick(1,4)]"
	if (iscarbon(M))
		var/mob/living/carbon/C = M
		if(C.reagents)
			clear_reagents_to_vomit_pool(C,V)

/proc/clear_reagents_to_vomit_pool(mob/living/carbon/M, obj/effect/decal/cleanable/vomit/V)
	M.reagents.trans_to(V, M.reagents.total_volume / 10, transfered_by = M)
	for(var/datum/reagent/R in M.reagents.reagent_list)                //clears the stomach of anything that might be digested as food
		if(istype(R, /datum/reagent/consumable))
			var/datum/reagent/consumable/nutri_check = R
			if(nutri_check.nutriment_factor >0)
				M.reagents.remove_reagent(R.type, min(R.volume, 10))

//Whatever happens after high temperature fire dies out or thermite reaction works.
//Should return new turf
/turf/proc/Melt()
	return ScrapeAway(flags = CHANGETURF_INHERIT_AIR)

/turf/proc/check_gravity()
	return TRUE

/**
 * Returns adjacent turfs to this turf that are reachable, in all cardinal directions
 *
 * Arguments:
 * * caller: The movable, if one exists, being used for mobility checks to see what tiles it can reach
 * * ID: An ID card that decides if we can gain access to doors that would otherwise block a turf
 * * simulated_only: Do we only worry about turfs with simulated atmos, most notably things that aren't space?
*/
/turf/proc/reachableAdjacentTurfs(caller, ID, simulated_only)
	var/static/space_type_cache = typecacheof(/turf/open/space)
	. = list()

	for(var/iter_dir in GLOB.cardinals)
		var/turf/turf_to_check = get_step(src,iter_dir)
		if(!turf_to_check || (simulated_only && space_type_cache[turf_to_check.type]))
			continue
		if(turf_to_check.density || LinkBlockedWithAccess(turf_to_check, caller, ID))
			continue
		. += turf_to_check
