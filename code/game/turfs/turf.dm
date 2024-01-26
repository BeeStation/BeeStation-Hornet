GLOBAL_LIST_EMPTY(station_turfs)
GLOBAL_LIST_EMPTY(created_baseturf_lists)
/turf
	icon = 'icons/turf/floors.dmi'
	vis_flags = VIS_INHERIT_ID|VIS_INHERIT_PLANE // Important for interaction with and visualization of openspace.

	/// If there's a tile over a basic floor that can be ripped out
	var/overfloor_placed = FALSE
	/// How accessible underfloor pieces such as wires, pipes, etc are on this turf. Can be HIDDEN, VISIBLE, or INTERACTABLE.
	var/underfloor_accessibility = UNDERFLOOR_HIDDEN

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

	/// If this turf should initialize atmos adjacent turfs or not
	/// Optimization, not for setting outside of initialize
	var/init_air = TRUE

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

	///the holodeck can load onto this turf if TRUE
	var/holodeck_compatible = FALSE

	///Icon-smoothing variable to map a diagonal wall corner with a fixed underlay.
	var/list/fixed_underlay = null

	///Ref to texture mask overlay
	var/texture_mask_overlay

	///Can this floor be an underlay, for turf damage
	var/can_underlay = TRUE

/turf/vv_edit_var(var_name, new_value)
	var/static/list/banned_edits = list("x", "y", "z")
	if(var_name in banned_edits)
		return FALSE
	. = ..()

/turf/Initialize(mapload)
	if(flags_1 & INITIALIZED_1)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	flags_1 |= INITIALIZED_1

	if(integrity == null)
		integrity = max_integrity

	// by default, vis_contents is inherited from the turf that was here before.
	// Checking length(vis_contents) in a proc this hot has huge wins for performance.
	//if (length(vis_contents)) - this doesn't seem to help performance on Bee
	vis_contents.Cut()

	assemble_baseturfs()

	levelupdate()
	if(length(smoothing_groups))
		#ifdef UNIT_TESTS
		assert_sorted(smoothing_groups, "[type].smoothing_groups")
		#endif
		SET_BITFLAG_LIST(smoothing_groups)
	if(length(canSmoothWith))
		#ifdef UNIT_TESTS
		assert_sorted(canSmoothWith, "[type].canSmoothWith")
		#endif
		if(canSmoothWith[length(canSmoothWith)] > MAX_S_TURF) //If the last element is higher than the maximum turf-only value, then it must scan turf contents for smoothing targets.
			smoothing_flags |= SMOOTH_OBJ
		SET_BITFLAG_LIST(canSmoothWith)
	if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
		QUEUE_SMOOTH(src)

	for(var/atom/movable/content as anything in src)
		Entered(content, null)

	var/area/A = loc
	if(fullbright_type && IS_DYNAMIC_LIGHTING(A))
		if (fullbright_type == FULLBRIGHT_STARLIGHT)
			add_overlay(GLOB.starlight_overlay)
		else
			add_overlay(GLOB.fullbright_overlay)

	if(requires_activation)
		CALCULATE_ADJACENT_TURFS(src)

	if(color)
		add_atom_colour(color, FIXED_COLOUR_PRIORITY)

	if (z_flags & Z_MIMIC_BELOW)
		setup_zmimic(mapload)

	if (light_power && light_range)
		update_light()

	if (opacity)
		directional_opacity = ALL_CARDINALS

	ComponentInitialize()
	if(isopenturf(src))
		var/turf/open/O = src
		__auxtools_update_turf_temp_info(isspaceturf(get_z_base_turf()) && !O.planetary_atmos)
	else
		update_air_ref(-1)
		__auxtools_update_turf_temp_info(isspaceturf(get_z_base_turf()))

	//Handle turf texture
	var/datum/turf_texture/TT = get_turf_texture()
	if(TT)
		add_turf_texture(TT)

	return INITIALIZE_HINT_NORMAL

/turf/proc/__auxtools_update_turf_temp_info()

/turf/return_temperature()

/turf/proc/set_temperature()

/// Initializes our adjacent turfs. If you want to avoid this, do not override it, instead set init_air to FALSE
/turf/proc/Initalize_Atmos(times_fired)
	CALCULATE_ADJACENT_TURFS(src)

/turf/Destroy(force)
	. = QDEL_HINT_IWILLGC
	if(!changing_turf)
		stack_trace("Incorrect turf deletion")
	changing_turf = FALSE
	if (z_flags & Z_MIMIC_BELOW)
		cleanup_zmimic()
	if(force)
		..()
		//this will completely wipe turf state
		var/turf/B = new world.turf(src)
		for(var/A in B.contents)
			qdel(A)
		for(var/I in B.vars)
			B.vars[I] = null
		return
	QDEL_LIST(blueprint_data)
	flags_1 &= ~INITIALIZED_1
	requires_activation = FALSE
	..()

	if (length(vis_contents))
		vis_contents.Cut()

/// WARNING WARNING
/// Turfs DO NOT lose their signals when they get replaced, REMEMBER THIS
/// It's possible because turfs are fucked, and if you have one in a list and it's replaced with another one, the list ref points to the new turf
/// We do it because moving signals over was needlessly expensive, and bloated a very commonly used bit of code
/turf/clear_signal_refs()
	return

/turf/attack_hand(mob/user)
	// Show a zmove radial when clicked
	if(get_turf(user) == src)
		if(!user.has_gravity(src) || (user.movement_type & FLYING))
			show_zmove_radial(user)
			return
		else if(allow_z_travel)
			to_chat(user, "<span class='warning'>You can't float up and down when there is gravity!</span>")
	. = ..()
	if(SEND_SIGNAL(user, COMSIG_MOB_ATTACK_HAND_TURF, src) & COMPONENT_NO_ATTACK_HAND)
		. = TRUE
	if(.)
		return
	if(user.Move_Pulled(src))
		user.changeNext_move(CLICK_CD_RAPID)
	else
		user.changeNext_move(CLICK_CD_MELEE)

/turf/eminence_act(mob/living/simple_animal/eminence/eminence)
	if(get_turf(eminence) == src)
		show_zmove_radial(eminence)
		return
	return ..()

/**
 * Check whether the specified turf is blocked by something dense inside it with respect to a specific atom.
 *
 * Returns truthy value TURF_BLOCKED_TURF_DENSE if the turf is blocked because the turf itself is dense.
 * Returns truthy value TURF_BLOCKED_CONTENT_DENSE if one of the turf's contents is dense and would block
 * a source atom's movement.
 * Returns falsey value TURF_NOT_BLOCKED if the turf is not blocked.
 *
 * Arguments:
 * * exclude_mobs - If TRUE, ignores dense mobs on the turf.
 * * source_atom - If this is not null, will check whether any contents on the turf can block this atom specifically. Also ignores itself on the turf.
 * * ignore_atoms - Check will ignore any atoms in this list. Useful to prevent an atom from blocking itself on the turf.
 */
/turf/proc/is_blocked_turf(exclude_mobs = FALSE, source_atom = null, list/ignore_atoms)
	if(density)
		return TRUE

	for(var/atom/movable/movable_content as anything in contents)
		// We don't want to block ourselves or consider any ignored atoms.
		if((movable_content == source_atom) || (movable_content in ignore_atoms))
			continue
		// If the thing is dense AND we're including mobs or the thing isn't a mob AND if there's a source atom and
		// it cannot pass through the thing on the turf,  we consider the turf blocked.
		if(movable_content.density && (!exclude_mobs || !ismob(movable_content)))
			if(source_atom && movable_content.CanPass(source_atom, get_dir(src, source_atom)))
				continue
			return TRUE
	return FALSE

/proc/is_anchored_dense_turf(turf/T) //like the older version of the above, fails only if also anchored
	if(T.density)
		return 1
	for(var/i in T)
		var/atom/movable/A = i
		if(A.density && A.anchored)
			return 1
	return 0

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

//There's a lot of QDELETED() calls here if someone can figure out how to optimize this but not runtime when something gets deleted by a Bump/CanPass/Cross call, lemme know or go ahead and fix this mess - kevinz000
/turf/Enter(atom/movable/mover)
	// Do not call ..()
	// Byond's default turf/Enter() doesn't have the behaviour we want with Bump()
	// By default byond will call Bump() on the first dense object in contents
	// Here's hoping it doesn't stay like this for years before we finish conversion to step_
	var/atom/firstbump
	var/canPassSelf = CanPass(mover, get_dir(src, mover))
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

// A proc in case it needs to be recreated or badmins want to change the baseturfs
/turf/proc/assemble_baseturfs(turf/fake_baseturf_type)
	var/turf/current_target
	if(fake_baseturf_type)
		if(length(fake_baseturf_type)) // We were given a list, just apply it and move on
			baseturfs = baseturfs_string_list(fake_baseturf_type, src)
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
			baseturfs = baseturfs_string_list(premade_baseturfs.Copy(), src)
		else
			baseturfs = baseturfs_string_list(premade_baseturfs, src)
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

	baseturfs = baseturfs_string_list(new_baseturfs, src)
	GLOB.created_baseturf_lists[new_baseturfs[new_baseturfs.len]] = new_baseturfs.Copy()
	return new_baseturfs

/turf/proc/levelupdate()
	for(var/obj/O in src)
		if(O.flags_1 & INITIALIZED_1)
			SEND_SIGNAL(O, COMSIG_OBJ_HIDE, underfloor_accessibility < UNDERFLOOR_VISIBLE)

// override for space turfs, since they should never hide anything
/turf/open/space/levelupdate()
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

/turf/proc/can_have_cabling()
	return TRUE

/turf/proc/can_lay_cable()
	return can_have_cabling() && underfloor_accessibility >= UNDERFLOOR_INTERACTABLE

/turf/proc/visibilityChanged()
	GLOB.cameranet.updateVisibility(src)

/turf/proc/is_shielded()
	return

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

/// When someone falls over onto this turf (Knockdown() or similar), not related to zfalls
/turf/handle_fall(mob/faller)
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

/turf/proc/add_vomit_floor(mob/living/M, toxvomit = NONE, purge = TRUE)

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
	else if (toxvomit == VOMIT_NANITE)
		V.name = "metallic slurry"
		V.desc = "A puddle of metallic slurry that looks vaguely like very fine sand. It almost seems like it's moving..."
		V.icon_state = "vomitnanite_[pick(1,4)]"
	if (purge && iscarbon(M))
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

/turf/proc/generate_fake_pierced_realities(centered = TRUE, max_amount = 2)
	if(max_amount <= 0)
		return
	var/to_spawn = pick(1, max_amount)
	var/spawned = 0
	var/location_sanity = 0
	while(spawned < to_spawn && location_sanity < 100)
		var/precision = pick(5, 15 * max_amount)
		var/turf/chosen_location = pick(get_safe_random_station_turfs())
		if(centered)
			chosen_location = get_teleport_turf(src, precision) //Using the random teleportation logic here to find a destination turf
		// We don't want them close to each other - at least 1 tile of seperation
		var/list/nearby_things = range(1, chosen_location)
		var/obj/effect/heretic_influence/what_if_i_have_one = locate() in nearby_things
		var/obj/effect/visible_heretic_influence/what_if_i_had_one_but_its_used = locate() in nearby_things
		if(what_if_i_have_one || what_if_i_had_one_but_its_used || isspaceturf(chosen_location))
			location_sanity++
			continue
		addtimer(CALLBACK(src, PROC_REF(create_new_fake_reality), chosen_location), rand(0, 500))
		spawned++

/turf/proc/create_new_fake_reality(turf/F)
	new /obj/effect/visible_heretic_influence(F)

/// Checks if the turf was blessed with holy water OR the area its in is Chapel
/turf/proc/is_holy()
	if(locate(/obj/effect/blessing) in src)
		return TRUE
	if(istype(loc, /area/chapel))
		return TRUE
	return FALSE

/turf/proc/make_traction(add_visual = TRUE)
	if(add_visual)
		//Add overlay
		var/mutable_appearance/MA = mutable_appearance(icon, "no_slip")
		MA.blend_mode = BLEND_OVERLAY
		add_overlay(MA)

///Add our relevant floor texture, if we can / need
/turf/proc/add_turf_texture(list/textures, force)
	if(!length(textures) || length(contents) && (locate(/obj/effect/decal/cleanable/dirt) in contents || locate(/obj/effect/decal/cleanable/dirt) in vis_contents))
		if(!force) //readability
			return
	var/datum/turf_texture/turf_texture
	for(var/datum/turf_texture/TF as() in textures)
		var/area/A = loc
		if(TF in A?.get_turf_textures())
			turf_texture = turf_texture ? initial(TF.priority) > initial(turf_texture.priority) ? TF : turf_texture : TF
	if(turf_texture)
		vis_contents += load_turf_texture(turf_texture)

/turf/proc/clean_turf_texture()
	for(var/atom/movable/turf_texture/TF in vis_contents)
		if(initial(TF.parent_texture?.cleanable))
			vis_contents -= TF

/// returns a list of all mobs inside of a turf.
/// likely detects mobs hiding in a closet.
/turf/proc/get_all_mobs()
	. = list()
	for(var/each in contents)
		if(ismob(each))
			. += each
		else if(isstructure(each))
			var/obj/O = each
			for(var/mob/M in O.contents)
				. += M


/turf/proc/get_turf_texture()
	return

/**
  * Called when this turf is being washed. Washing a turf will also wash any mopable floor decals
  */
/turf/wash(clean_types)
	. = ..()

	for(var/am in src)
		if(am == src)
			continue
		var/atom/movable/movable_content = am
		if(!ismopable(movable_content))
			continue
		movable_content.wash(clean_types)
