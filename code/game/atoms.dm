
/**
  * The base type for nearly all physical objects in SS13

  * Lots and lots of functionality lives here, although in general we are striving to move
  * as much as possible to the components/elements system
  */
/atom
	layer = TURF_LAYER
	plane = GAME_PLANE
	appearance_flags = TILE_BOUND

	/// pass_flags that we are. If any of this matches a pass_flag on a moving thing, by default, we let them through.
	var/pass_flags_self = NONE

	///If non-null, overrides a/an/some in all cases
	var/article

	///First atom flags var
	var/flags_1 = NONE
	///Intearaction flags
	var/interaction_flags_atom = NONE

	///Reagents holder
	var/datum/reagents/reagents = null

	///This atom's HUD (med/sec, etc) images. Associative list.
	var/list/image/hud_list = null
	///HUD images that this atom can provide.
	var/list/hud_possible

	///Value used to increment ex_act() if reactionary_explosions is on
	var/explosion_block = 0

	/**
	  * used to store the different colors on an atom
	  *
	  * its inherent color, the colored paint applied on it, special color effect etc...
	  */
	var/list/atom_colours


	/// a very temporary list of overlays to remove
	var/list/remove_overlays
	/// a very temporary list of overlays to add
	var/list/add_overlays

	///vis overlays managed by SSvis_overlays to automaticaly turn them like other overlays
	var/list/managed_vis_overlays

	///overlays managed by update_overlays() to prevent removing overlays that weren't added by the same proc
	var/list/managed_overlays

	///Proximity monitor associated with this atom
	var/datum/proximity_monitor/proximity_monitor
	///Cooldown tick timer for buckle messages
	var/buckle_message_cooldown = 0
	///Last fingerprints to touch this atom
	var/fingerprintslast

	var/list/filter_data //For handling persistent filters

	///Economy cost of item
	var/custom_price
	///Economy cost of item in premium vendor
	var/custom_premium_price

	//List of datums orbiting this atom
	var/datum/component/orbiter/orbiters

	/// Will move to flags_1 when i can be arsed to (2019, has not done so)
	var/rad_flags = NONE
	/// Radiation insulation types
	var/rad_insulation = RAD_NO_INSULATION

	///The custom materials this atom is made of, used by a lot of things like furniture, walls, and floors (if I finish the functionality, that is.)
	var/list/custom_materials
	///Bitfield for how the atom handles materials.
	var/material_flags = NONE
	///Light systems, both shouldn't be active at the same time.
	var/light_system = STATIC_LIGHT
	///Boolean variable for toggleable lights. Has no effect without the proper light_system, light_range and light_power values.
	var/light_on = TRUE
	///Bitflags to determine lighting-related atom properties.
	var/light_flags = NONE

	var/flags_ricochet = NONE
	///When a projectile tries to ricochet off this atom, the projectile ricochet chance is multiplied by this
	var/ricochet_chance_mod = 1
	///When a projectile ricochets off this atom, it deals the normal damage * this modifier to this atom
	var/ricochet_damage_mod = 0.33

	/// Last name used to calculate a color for the chatmessage overlays
	var/chat_color_name
	/// Last color calculated for the the chatmessage overlays
	var/chat_color

	///Icon-smoothing behavior.
	var/smoothing_flags = NONE
	///Smoothing variable
	var/top_left_corner
	///Smoothing variable
	var/top_right_corner
	///Smoothing variable
	var/bottom_left_corner
	///Smoothing variable
	var/bottom_right_corner
	///What smoothing groups does this atom belongs to, to match canSmoothWith. If null, nobody can smooth with it.
	var/list/smoothing_groups = null
	///List of smoothing groups this atom can smooth with. If this is null and atom is smooth, it smooths only with itself.
	var/list/canSmoothWith = null
	///What directions this is currently smoothing with. IMPORTANT: This uses the smoothing direction flags as defined in icon_smoothing.dm, instead of the BYOND flags.
	var/smoothing_junction = null //This starts as null for us to know when it's first set, but after that it will hold a 8-bit mask ranging from 0 to 255.

	///Used for changing icon states for different base sprites.
	var/base_icon_state

	///The config type to use for greyscaled sprites. Both this and greyscale_colors must be assigned to work.
	var/greyscale_config
	///A string of hex format colors to be used by greyscale sprites, ex: "#0054aa#badcff"
	var/greyscale_colors

	///Mobs that are currently do_after'ing this atom, to be cleared from on Destroy()
	var/list/targeted_by

	///AI controller that controls this atom. type on init, then turned into an instance during runtime
	var/datum/ai_controller/ai_controller

	/// Lazylist of all messages currently on this atom
	var/list/chat_messages

	///LazyList of all balloon alerts currently on this atom
	var/list/balloon_alerts

/**
  * Called when an atom is created in byond (built in engine proc)
  *
  * Not a lot happens here in SS13 code, as we offload most of the work to the
  * [Intialization](atom.html#proc/Initialize) proc, mostly we run the preloader
  * if the preloader is being used and then call InitAtom of which the ultimate
  * result is that the Intialize proc is called.
  *
  * We also generate a tag here if the DF_USE_TAG flag is set on the atom
  */
/atom/New(loc, ...)
	//atom creation method that preloads variables at creation
	if(GLOB.use_preloader && (src.type == GLOB._preloader.target_path))//in case the instanciated atom is creating other atoms in New()
		world.preloader_load(src)

	if(datum_flags & DF_USE_TAG)
		GenerateTag()

	var/do_initialize = SSatoms.initialized
	if(do_initialize != INITIALIZATION_INSSATOMS)
		args[1] = do_initialize == INITIALIZATION_INNEW_MAPLOAD
		if(SSatoms.InitAtom(src, FALSE, args))
			//we were deleted
			return

/**
  * The primary method that objects are setup in SS13 with
  *
  * we don't use New as we have better control over when this is called and we can choose
  * to delay calls or hook other logic in and so forth
  *
  * During roundstart map parsing, atoms are queued for intialization in the base atom/New(),
  * After the map has loaded, then Initalize is called on all atoms one by one. NB: this
  * is also true for loading map templates as well, so they don't Initalize until all objects
  * in the map file are parsed and present in the world
  *
  * If you're creating an object at any point after SSInit has run then this proc will be
  * immediately be called from New.
  *
  * mapload: This parameter is true if the atom being loaded is either being intialized during
  * the Atom subsystem intialization, or if the atom is being loaded from the map template.
  * If the item is being created at runtime any time after the Atom subsystem is intialized then
  * it's false.
  *
  * You must always call the parent of this proc, otherwise failures will occur as the item
  * will not be seen as initalized (this can lead to all sorts of strange behaviour, like
  * the item being completely unclickable)
  *
  * You must not sleep in this proc, or any subprocs
  *
  * Any parameters from new are passed through (excluding loc), naturally if you're loading from a map
  * there are no other arguments
  *
  * Must return an [initialization hint](code/__DEFINES/subsystems.html) or a runtime will occur.
  *
  * Note: the following functions don't call the base for optimization and must copypasta handling:
  * * /turf/Initialize
  * * /turf/open/space/Initialize
  */
/atom/proc/Initialize(mapload, ...)
	if(flags_1 & INITIALIZED_1)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	flags_1 |= INITIALIZED_1

	if(loc)
		SEND_SIGNAL(loc, COMSIG_ATOM_CREATED, src) /// Sends a signal that the new atom `src`, has been created at `loc`

	if(greyscale_config && greyscale_colors)
		update_greyscale()

	//atom color stuff
	if(color)
		add_atom_colour(color, FIXED_COLOUR_PRIORITY)

	if (light_system == STATIC_LIGHT && light_power && light_range)
		update_light()

	if (opacity && isturf(loc))
		var/turf/T = loc
		T.has_opaque_atom = TRUE // No need to recalculate it in this case, it's guaranteed to be on afterwards anyways.

	if(custom_materials && custom_materials.len)
		var/temp_list = list()
		for(var/i in custom_materials)
			var/datum/material/material = getmaterialref(i) || i
			temp_list[material] = custom_materials[material] //Get the proper instanced version

		custom_materials = null //Null the list to prepare for applying the materials properly
		set_custom_materials(temp_list)

	ComponentInitialize()
	InitializeAIController()

	if(length(smoothing_groups))
		sortTim(smoothing_groups) //In case it's not properly ordered, let's avoid duplicate entries with the same values.
		SET_BITFLAG_LIST(smoothing_groups)
	if(length(canSmoothWith))
		sortTim(canSmoothWith)
		if(canSmoothWith[length(canSmoothWith)] > MAX_S_TURF) //If the last element is higher than the maximum turf-only value, then it must scan turf contents for smoothing targets.
			smoothing_flags |= SMOOTH_OBJ
		SET_BITFLAG_LIST(canSmoothWith)

	return INITIALIZE_HINT_NORMAL

/**
  * Late Intialization, for code that should run after all atoms have run Intialization
  *
  * To have your LateIntialize proc be called, your atoms [Initalization](atom.html#proc/Initialize)
  *  proc must return the hint
  * [INITIALIZE_HINT_LATELOAD](code/__DEFINES/subsystems.html#define/INITIALIZE_HINT_LATELOAD)
  * otherwise you will never be called.
  *
  * useful for doing things like finding other machines on GLOB.machines because you can guarantee
  * that all atoms will actually exist in the "WORLD" at this time and that all their Intialization
  * code has been run
  */
/atom/proc/LateInitialize()
	set waitfor = FALSE

/// Put your AddComponent() calls here
/atom/proc/ComponentInitialize()
	return

/**
  * Top level of the destroy chain for most atoms
  *
  * Cleans up the following:
  * * Removes alternate apperances from huds that see them
  * * qdels the reagent holder from atoms if it exists
  * * clears the orbiters list
  * * clears overlays and priority overlays
  * * clears the light object
  */
/atom/Destroy()
	if(alternate_appearances)
		for(var/current_alternate_appearance in alternate_appearances)
			var/datum/atom_hud/alternate_appearance/selected_alternate_appearance = alternate_appearances[current_alternate_appearance]
			selected_alternate_appearance.remove_from_hud(src)

	if(reagents)
		QDEL_NULL(reagents)

	orbiters = null // The component is attached to us normaly and will be deleted elsewhere

	LAZYCLEARLIST(overlays)
	LAZYNULL(managed_overlays)

	QDEL_NULL(light)
	QDEL_NULL(ai_controller)

	for(var/i in targeted_by)
		var/mob/M = i
		LAZYREMOVE(M.do_afters, src)

	targeted_by = null

	return ..()

/atom/proc/handle_ricochet(obj/item/projectile/P)
	var/turf/p_turf = get_turf(P)
	var/face_direction = get_dir(src, p_turf)
	var/face_angle = dir2angle(face_direction)
	var/incidence_s = GET_ANGLE_OF_INCIDENCE(face_angle, (P.Angle + 180))
	var/a_incidence_s = abs(incidence_s)
	if(a_incidence_s > 90 && a_incidence_s < 270)
		return FALSE
	if((P.armor_flag in list(BULLET, BOMB)) && P.ricochet_incidence_leeway)
		if((a_incidence_s < 90 && a_incidence_s < 90 - P.ricochet_incidence_leeway) || (a_incidence_s > 270 && a_incidence_s -270 > P.ricochet_incidence_leeway))
			return FALSE
	var/new_angle_s = SIMPLIFY_DEGREES(face_angle + incidence_s)
	P.setAngle(new_angle_s)
	return TRUE

///Can the mover object pass this atom, while heading for the target turf
/atom/proc/CanPass(atom/movable/mover, turf/target)
	SHOULD_CALL_PARENT(TRUE)
	SHOULD_BE_PURE(TRUE)
	if(mover.movement_type & PHASING)
		return TRUE
	. = CanAllowThrough(mover, target)
	// This is cheaper than calling the proc every time since most things dont override CanPassThrough
	if(!mover.generic_canpass)
		return mover.CanPassThrough(src, target, .)

/// Returns true or false to allow the mover to move through src
/atom/proc/CanAllowThrough(atom/movable/mover, turf/target)
	SHOULD_CALL_PARENT(TRUE)
	//SHOULD_BE_PURE(TRUE)
	if(mover.pass_flags & pass_flags_self)
		return TRUE
	if(mover.throwing && (pass_flags_self & LETPASSTHROW))
		return TRUE
	if ((mover.pass_flags & PASSTRANSPARENT) && alpha < 255 && prob(100 - (alpha/2.55)))
		return TRUE
	return !density

/**
  * Is this atom currently located on centcom
  *
  * Specifically, is it on the z level and within the centcom areas
  *
  * You can also be in a shuttleshuttle during endgame transit
  *
  * Used in gamemode to identify mobs who have escaped and for some other areas of the code
  * who don't want atoms where they shouldn't be
  */
/atom/proc/onCentCom()
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE

	if(is_reserved_level(T.z))
		for(var/A in SSshuttle.mobile)
			var/obj/docking_port/mobile/M = A
			if(M.launch_status == ENDGAME_TRANSIT)
				for(var/place in M.shuttle_areas)
					var/area/shuttle/shuttle_area = place
					if(T in shuttle_area)
						return TRUE

	if(!is_centcom_level(T.z))//if not, don't bother
		return FALSE

	//Check for centcom itself
	if(istype(T.loc, /area/centcom))
		return TRUE

	//Check for centcom shuttles
	for(var/A in SSshuttle.mobile)
		var/obj/docking_port/mobile/M = A
		if(M.launch_status == ENDGAME_LAUNCHED)
			for(var/place in M.shuttle_areas)
				var/area/shuttle/shuttle_area = place
				if(T in shuttle_area)
					return TRUE

/**
  * Is the atom in any of the centcom syndicate areas
  *
  * Either in the syndie base on centcom, or any of their shuttles
  *
  * Also used in gamemode code for win conditions
  */
/atom/proc/onSyndieBase()
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE

	if(!is_centcom_level(T.z))//if not, don't bother
		return FALSE

	if(istype(T.loc, /area/shuttle/syndicate) || istype(T.loc, /area/syndicate_mothership) || istype(T.loc, /area/shuttle/assault_pod))
		return TRUE

	return FALSE

///This atom has been hit by a hulkified mob in hulk mode (user)
/atom/proc/attack_hulk(mob/living/carbon/human/user, does_attack_animation = 0)
	SEND_SIGNAL(src, COMSIG_ATOM_HULK_ATTACK, user)
	if(does_attack_animation)
		user.changeNext_move(CLICK_CD_MELEE)
		log_combat(user, src, "punched", "hulk powers")
		user.do_attack_animation(src, ATTACK_EFFECT_SMASH)

/**
  * Ensure a list of atoms/reagents exists inside this atom
  *
  * Goes throught he list of passed in parts, if they're reagents, adds them to our reagent holder
  * creating the reagent holder if it exists.
  *
  * If the part is a moveable atom and the  previous location of the item was a mob/living,
  * it calls the inventory handler transferItemToLoc for that mob/living and transfers the part
  * to this atom
  *
  * Otherwise it simply forceMoves the atom into this atom
  */
/atom/proc/CheckParts(list/parts_list)
	for(var/A in parts_list)
		if(istype(A, /datum/reagent))
			if(!reagents)
				reagents = new()
			reagents.reagent_list.Add(A)
			reagents.conditional_update()
		else if(ismovable(A))
			var/atom/movable/M = A
			if(isliving(M.loc))
				var/mob/living/L = M.loc
				L.transferItemToLoc(M, src)
			else
				M.forceMove(src)
	parts_list.Cut()

///Hook for multiz???
/atom/proc/update_multiz(prune_on_fail = FALSE)
	return FALSE

///Take air from the passed in gas mixture datum
/atom/proc/assume_air(datum/gas_mixture/giver)
	return null

/atom/proc/assume_air_moles(datum/gas_mixture/giver, moles)
	return null

/atom/proc/assume_air_ratio(datum/gas_mixture/giver, ratio)
	return null

///Remove air from this atom
/atom/proc/remove_air(amount)
	return null

/atom/proc/remove_air_ratio(ratio)
	return null

/atom/proc/transfer_air(datum/gas_mixture/taker, amount)
	return null

/atom/proc/transfer_air_ratio(datum/gas_mixture/taker, ratio)
	return null

///Return the current air environment in this atom
/atom/proc/return_air()
	if(loc)
		return loc.return_air()
	else
		return null

///Return the air if we can analyze it
/atom/proc/return_analyzable_air()
	return null

///Check if this atoms eye is still alive (probably)
/atom/proc/check_eye(mob/user)
	return

/atom/proc/Bumped(atom/movable/AM)
	set waitfor = FALSE
	SEND_SIGNAL(src, COMSIG_ATOM_BUMPED, AM)

/// Convenience proc to see if a container is open for chemistry handling
/atom/proc/is_open_container()
	return is_refillable() && is_drainable()

/// Is this atom injectable into other atoms
/atom/proc/is_injectable(mob/user, allowmobs = TRUE)
	return reagents && (reagents.flags & (INJECTABLE | REFILLABLE))

/// Can we draw from this atom with an injectable atom
/atom/proc/is_drawable(mob/user, allowmobs = TRUE)
	return reagents && (reagents.flags & (DRAWABLE | DRAINABLE))

/// Can this atoms reagents be refilled
/atom/proc/is_refillable()
	return reagents && (reagents.flags & REFILLABLE)

/// Is this atom drainable of reagents
/atom/proc/is_drainable()
	return reagents && (reagents.flags & DRAINABLE)

/// Is this atom grindable to get reagents
/atom/proc/is_grindable()
	return reagents && (reagents.flags & ABSOLUTELY_GRINDABLE)

/// Are you allowed to drop this atom
/atom/proc/AllowDrop()
	return FALSE

///Is this atom within 1 tile of another atom
/atom/proc/HasProximity(atom/movable/AM as mob|obj)
	return

/**
  * React to an EMP of the given severity
  *
  * Default behaviour is to send the COMSIG_ATOM_EMP_ACT signal
  *
  * If the signal does not return protection, and there are attached wires then we call
  * emp_pulse() on the wires
  *
  * We then return the protection value
  */
/atom/proc/emp_act(severity)
	var/protection = SEND_SIGNAL(src, COMSIG_ATOM_EMP_ACT, severity)
	if(!(protection & EMP_PROTECT_WIRES) && istype(wires))
		wires.emp_pulse()
	return protection // Pass the protection value collected here upwards

/**
 * React to a hit by a projectile object
 *
 * Default behaviour is to send the [COMSIG_ATOM_BULLET_ACT] and then call [on_hit][/obj/projectile/proc/on_hit] on the projectile
 *
 * @params
 * P - projectile
 * def_zone - zone hit
 * piercing_hit - is this hit piercing or normal?
 */
/atom/proc/bullet_act(obj/item/projectile/P, def_zone, piercing_hit = FALSE)
	SEND_SIGNAL(src, COMSIG_ATOM_BULLET_ACT, P, def_zone)
	. = P.on_hit(src, 0, def_zone, piercing_hit)

///Return true if we're inside the passed in atom
/atom/proc/in_contents_of(container)//can take class or object instance as argument
	if(ispath(container))
		if(istype(src.loc, container))
			return TRUE
	else if(src in container)
		return TRUE
	return FALSE

/**
  * Get the name of this object for examine
  *
  * You can override what is returned from this proc by registering to listen for the
  * COMSIG_ATOM_GET_EXAMINE_NAME signal
  */
/atom/proc/get_examine_name(mob/user)
	. = "\a [src]"
	var/list/override = list(gender == PLURAL ? "some" : "a", " ", "[name]")
	if(article)
		. = "[article] [src]"
		override[EXAMINE_POSITION_ARTICLE] = article
	if(SEND_SIGNAL(src, COMSIG_ATOM_GET_EXAMINE_NAME, user, override) & COMPONENT_EXNAME_CHANGED)
		. = override.Join("")

///Generate the full examine string of this atom (including icon for goonchat)
/atom/proc/get_examine_string(mob/user, thats = FALSE)
	return "[icon2html(src, user)] [thats? "That's ":""][get_examine_name(user)]"

/**
  * Called when a mob examines (shift click or verb) this atom
  *
  * Default behaviour is to get the name and icon of the object and it's reagents where
  * the TRANSPARENT flag is set on the reagents holder
  *
  * Produces a signal COMSIG_PARENT_EXAMINE
  */
/atom/proc/examine(mob/user)
	. = list("[get_examine_string(user, TRUE)].")

	if(desc)
		. += desc

	if(custom_materials)
		for(var/i in custom_materials)
			var/datum/material/M = i
			. += "<u>It is made out of [M.name]</u>."
	if(reagents)
		if(reagents.flags & TRANSPARENT)
			. += "It contains:"
			if(length(reagents.reagent_list))
				//-------- Reagent checks ---------
				if(user.can_see_reagents()) //Show each individual reagent
					for(var/datum/reagent/R in reagents.reagent_list)
						. += "[R.volume] units of [R.name]"
				else //Otherwise, just show the total volume
					var/total_volume = 0
					for(var/datum/reagent/R in reagents.reagent_list)
						total_volume += R.volume
					. += "[total_volume] units of various reagents"
				//-------- Beer goggles ---------
				if(user.can_see_boozepower())
					var/total_boozepower = 0
					var/list/taste_list = list()

					// calculates the total booze power from all 'ethanol' reagents
					for(var/datum/reagent/consumable/ethanol/B in reagents.reagent_list)
						total_boozepower += B.volume * max(B.boozepwr, 0) // minus booze power is reversed to light drinkers, but is actually 0 to normal drinkers.

					// gets taste results from all reagents
					for(var/datum/reagent/R in reagents.reagent_list)
						if(istype(R, /datum/reagent/consumable/ethanol/fruit_wine) && !(user.stat == DEAD) && !(HAS_TRAIT(src, TRAIT_BARMASTER)) ) // taste of fruit wine is mysterious, but can be known by ghosts/some special bar master trait holders
							taste_list += "<br/>   - unexplored taste of the winery (from [R.name])"
						else
							taste_list += "<br/>   - [R.taste_description] (from [R.name])"
					if(reagents.total_volume)
						. += "<span class='notice'>Booze Power: total [total_boozepower], average [round(total_boozepower/reagents.total_volume, 0.1)] ([get_boozepower_text(total_boozepower/reagents.total_volume, user)])</span>"
						. += "<span class='notice'>It would taste like: [english_list(taste_list, comma_text="", and_text="")].</span>"
				//-------------------------------
			else
				. += "Nothing."
		else if(reagents.flags & AMOUNT_VISIBLE)
			if(reagents.total_volume)
				. += "<span class='notice'>It has [reagents.total_volume] unit\s left.</span>"
			else
				. += "<span class='danger'>It's empty.</span>"

	SEND_SIGNAL(src, COMSIG_PARENT_EXAMINE, user, .)

/**
 * Updates the appearance of the icon
 *
 * Mostly delegates to update_name, update_desc, and update_icon
 *
 * Arguments:
 * - updates: A set of bitflags dictating what should be updated. Defaults to [ALL]
 */
/atom/proc/update_appearance(updates=ALL)
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_CALL_PARENT(TRUE)

	. = NONE
	updates &= ~SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_APPEARANCE, updates)
	if(updates & UPDATE_NAME)
		. |= update_name(updates)
	if(updates & UPDATE_DESC)
		. |= update_desc(updates)
	if(updates & UPDATE_ICON)
		. |= update_icon(updates)

/// Updates the name of the atom
/atom/proc/update_name(updates=ALL)
	SHOULD_CALL_PARENT(TRUE)
	return SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_NAME, updates)

/// Updates the description of the atom
/atom/proc/update_desc(updates=ALL)
	SHOULD_CALL_PARENT(TRUE)
	return SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_DESC, updates)

/// Updates the icon of the atom
/atom/proc/update_icon(updates=ALL)
	SIGNAL_HANDLER

	. = NONE
	updates &= ~SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_ICON, updates)
	if(updates & UPDATE_ICON_STATE)
		update_icon_state()
		. |= UPDATE_ICON_STATE

	if(updates & UPDATE_OVERLAYS)
		if(LAZYLEN(managed_vis_overlays))
			SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)

		var/list/new_overlays = update_overlays(updates)
		if(managed_overlays)
			cut_overlay(managed_overlays)
			managed_overlays = null
		if(length(new_overlays))
			if (length(new_overlays) == 1)
				managed_overlays = new_overlays[1]
			else
				managed_overlays = new_overlays
			add_overlay(new_overlays)
		. |= UPDATE_OVERLAYS

	. |= SEND_SIGNAL(src, COMSIG_ATOM_UPDATED_ICON, updates, .)

/// Updates the icon state of the atom
/atom/proc/update_icon_state()
	SHOULD_CALL_PARENT(TRUE)
	return SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_ICON_STATE)

/// Updates the overlays of the atom
/atom/proc/update_overlays()
	SHOULD_CALL_PARENT(TRUE)
	. = list()
	SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_OVERLAYS, .)

/// Handles updates to greyscale value updates.
/// The colors argument can be either a list or the full color string.
/// Child procs should call parent last so the update happens after all changes.
/atom/proc/set_greyscale(list/colors, new_config)
	SHOULD_CALL_PARENT(TRUE)
	if(istype(colors))
		colors = colors.Join("")
	if(!isnull(colors) && greyscale_colors != colors) // If you want to disable greyscale stuff then give a blank string
		greyscale_colors = colors

	if(!isnull(new_config) && greyscale_config != new_config)
		greyscale_config = new_config

	update_greyscale()

/// Checks if this atom uses the GAGS system and if so updates the icon
/atom/proc/update_greyscale()
	SHOULD_CALL_PARENT(TRUE)
	if(greyscale_colors && greyscale_config)
		icon = SSgreyscale.GetColoredIconByType(greyscale_config, greyscale_colors)
	if(!smoothing_flags) // This is a bitfield but we're just checking that some sort of smoothing is happening
		return
	update_atom_colour()
	QUEUE_SMOOTH(src)


/**
  * An atom we are buckled or is contained within us has tried to move
  *
  * Default behaviour is to send a warning that the user can't move while buckled as long
  * as the buckle_message_cooldown has expired (50 ticks)
  */
/atom/proc/relaymove(mob/user)
	if(buckle_message_cooldown <= world.time)
		buckle_message_cooldown = world.time + 50
		to_chat(user, "<span class='warning'>You can't move while buckled to [src]!</span>")
	return

/// Handle what happens when your contents are exploded by a bomb
/atom/proc/contents_explosion(severity, target)
	return //For handling the effects of explosions on contents that would not normally be effected

/**
  * React to being hit by an explosion
  *
  * Default behaviour is to call contents_explosion() and send the COMSIG_ATOM_EX_ACT signal
  */
/atom/proc/ex_act(severity, target)
	set waitfor = FALSE
	contents_explosion(severity, target)
	SEND_SIGNAL(src, COMSIG_ATOM_EX_ACT, severity, target)

/**
  * React to a hit by a blob objecd
  *
  * default behaviour is to send the COMSIG_ATOM_BLOB_ACT signal
  */
/atom/proc/blob_act(obj/structure/blob/B)
	if(SEND_SIGNAL(src, COMSIG_ATOM_BLOB_ACT, B) & COMPONENT_CANCEL_BLOB_ACT)
		return FALSE
	return TRUE

/atom/proc/fire_act(exposed_temperature, exposed_volume)
	SEND_SIGNAL(src, COMSIG_ATOM_FIRE_ACT, exposed_temperature, exposed_volume)
	return

/**
  * React to being hit by a thrown object
  *
  * Default behaviour is to call hitby_react() on ourselves after 2 seconds if we are dense
  * and under normal gravity.
  *
  * Im not sure why this the case, maybe to prevent lots of hitby's if the thrown object is
  * deleted shortly after hitting something (during explosions or other massive events that
  * throw lots of items around - singularity being a notable example)
  */
/atom/proc/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	SEND_SIGNAL(src, COMSIG_ATOM_HITBY, AM, skipcatch, hitpush, blocked, throwingdatum)
	if(density && !has_gravity(AM)) //thrown stuff bounces off dense stuff in no grav, unless the thrown stuff ends up inside what it hit(embedding, bola, etc...).
		addtimer(CALLBACK(src, PROC_REF(hitby_react), AM), 2)

/**
  * We have have actually hit the passed in atom
  *
  * Default behaviour is to move back from the item that hit us
  */
/atom/proc/hitby_react(atom/movable/AM)
	if(AM && isturf(AM.loc))
		step(AM, turn(AM.dir, 180))

///Handle the atom being slipped over
/atom/proc/handle_slip(mob/living/carbon/C, knockdown_amount, obj/O, lube, paralyze, force_drop)
	return

///returns the mob's dna info as a list, to be inserted in an object's blood_DNA list
/mob/living/proc/get_blood_dna_list()
	if(get_blood_id() != /datum/reagent/blood)
		return
	return list("ANIMAL DNA" = "Y-")

///Get the mobs dna list
/mob/living/carbon/get_blood_dna_list()
	if(get_blood_id() != /datum/reagent/blood)
		return
	var/list/blood_dna = list()
	if(dna)
		blood_dna[dna.unique_enzymes] = dna.blood_type
	else
		blood_dna["UNKNOWN DNA"] = "X*"
	return blood_dna

/mob/living/carbon/alien/get_blood_dna_list()
	return list("UNKNOWN DNA" = "X*")

/mob/living/silicon/get_blood_dna_list()
	return list("MOTOR OIL" = "SAE 5W-30") //just a little flavor text.

///to add a mob's dna info into an object's blood_dna list.
/atom/proc/transfer_mob_blood_dna(mob/living/L)
	// Returns 0 if we have that blood already
	var/new_blood_dna = L.get_blood_dna_list()
	if(!new_blood_dna)
		return FALSE
	var/old_length = blood_DNA_length()
	add_blood_DNA(new_blood_dna)
	if(blood_DNA_length() == old_length)
		return FALSE
	return TRUE

///to add blood from a mob onto something, and transfer their dna info
/atom/proc/add_mob_blood(mob/living/M)
	var/list/blood_dna = M.get_blood_dna_list()
	if(!blood_dna)
		return FALSE
	return add_blood_DNA(blood_dna)

///Is this atom in space
/atom/proc/isinspace()
	if(isspaceturf(get_turf(src)))
		return TRUE
	else
		return FALSE

///Called when gravity returns after floating I think
/atom/proc/handle_fall()
	return

///Respond to the singularity eating this atom
/atom/proc/singularity_act()
	return

/**
  * Respond to the singularity pulling on us
  *
  * Default behaviour is to send COMSIG_ATOM_SING_PULL and return
  */
/atom/proc/singularity_pull(obj/anomaly/singularity/S, current_size)
	SEND_SIGNAL(src, COMSIG_ATOM_SING_PULL, S, current_size)


/**
  * Respond to acid being used on our atom
  *
  * Default behaviour is to send COMSIG_ATOM_ACID_ACT and return
  */
/atom/proc/acid_act(acidpwr, acid_volume)
	SEND_SIGNAL(src, COMSIG_ATOM_ACID_ACT, acidpwr, acid_volume)

/**
  * Respond to an emag being used on our atom
  *
  * Default behaviour is to send COMSIG_ATOM_SHOULD_EMAG,
  * if that is FALSE (due to the default being false, should_emag still occurs on /obj) then COMSIG_ATOM_ON_EMAG and return
  *
  * This typically should not be overriden, in favor of the /obj counterparts:
  * - Override on_emag(mob/user)
  * - Maintain parent calls in on_emag for good practice
  * - If the item is "undo-emaggable" (can be flipped on/off), set emag_toggleable = TRUE
  * For COMSIG_ATOM_SHOULD_EMAG, /obj uses should_emag.
  * - Parent calls do not need to be maintained.
  */
/atom/proc/use_emag(mob/user)
	if(!SEND_SIGNAL(src, COMSIG_ATOM_SHOULD_EMAG, user))
		SEND_SIGNAL(src, COMSIG_ATOM_ON_EMAG, user)

/**
  * Respond to a radioactive wave hitting this atom
  *
  * Default behaviour is to send COMSIG_ATOM_RAD_ACT and return
  */
/atom/proc/rad_act(strength)
	SEND_SIGNAL(src, COMSIG_ATOM_RAD_ACT, strength)

/**
  * Respond to narsie eating our atom
  *
  * Default behaviour is to send COMSIG_ATOM_NARSIE_ACT and return
  */
/atom/proc/narsie_act()
	SEND_SIGNAL(src, COMSIG_ATOM_NARSIE_ACT)

/**
  * Respond to ratvar eating our atom
  *
  * Default behaviour is to send COMSIG_ATOM_RATVAR_ACT and return
  */
/atom/proc/ratvar_act()
	SEND_SIGNAL(src, COMSIG_ATOM_RATVAR_ACT)

/**
  * Called when lighteater is called on this.
  */
/atom/proc/lighteater_act(obj/item/light_eater/light_eater, atom/parent)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src,COMSIG_ATOM_LIGHTEATER_ACT)
	for(var/datum/light_source/light_source in light_sources)
		if(light_source.source_atom != src)
			light_source.source_atom.lighteater_act(light_eater, src)

/**
  * Respond to the eminence clicking on our atom
  *
  * Default behaviour is to send COMSIG_ATOM_EMINENCE_ACT and return
  */
/atom/proc/eminence_act(mob/living/simple_animal/eminence/eminence)
	SEND_SIGNAL(src, COMSIG_ATOM_EMINENCE_ACT, eminence)

///Return the values you get when an RCD eats you?
/atom/proc/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	return FALSE


/**
  * Respond to an RCD acting on our item
  *
  * Default behaviour is to send COMSIG_ATOM_RCD_ACT and return FALSE
  */
/atom/proc/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	SEND_SIGNAL(src, COMSIG_ATOM_RCD_ACT, user, the_rcd, passed_mode)
	return FALSE

/**
  * Respond to our atom being teleported
  *
  * Default behaviour is to send COMSIG_ATOM_TELEPORT_ACT
  */
/atom/proc/teleport_act()
	SEND_SIGNAL(src,COMSIG_ATOM_TELEPORT_ACT)

/**
  * Respond to our atom being checked by a virus extrapolator
  *
  * Default behaviour is to send COMSIG_ATOM_EXTRAPOLATOR_ACT and return FALSE
  */
/atom/proc/extrapolator_act(mob/user, var/obj/item/extrapolator/E, scan = TRUE)
	SEND_SIGNAL(src,COMSIG_ATOM_EXTRAPOLATOR_ACT, user, E, scan)
	return FALSE
/**
  * Implement the behaviour for when a user click drags a storage object to your atom
  *
  * This behaviour is usually to mass transfer, but this is no longer a used proc as it just
  * calls the underyling /datum/component/storage dump act if a component exists
  *
  * TODO these should be purely component items that intercept the atom clicks higher in the
  * call chain
  */
/atom/proc/storage_contents_dump_act(obj/item/storage/src_object, mob/user)
	if(GetComponent(/datum/component/storage))
		return component_storage_contents_dump_act(src_object, user)
	return FALSE

/**
  * Implement the behaviour for when a user click drags another storage item to you
  *
  * In this case we get as many of the tiems from the target items compoent storage and then
  * put everything into ourselves (or our storage component)
  *
  * TODO these should be purely component items that intercept the atom clicks higher in the
  * call chain
  */
/atom/proc/component_storage_contents_dump_act(datum/component/storage/src_object, mob/user)
	var/list/things = src_object.contents()
	var/datum/progressbar/progress = new(user, things.len, src)
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	while (do_after(user, 1 SECONDS, src, NONE, FALSE, CALLBACK(STR, TYPE_PROC_REF(/datum/component/storage, handle_mass_item_insertion), things, src_object, user, progress)))
		stoplag(1)
	qdel(progress)
	to_chat(user, "<span class='notice'>You dump as much of [src_object.parent]'s contents into [STR.insert_preposition]to [src] as you can.</span>")
	STR.orient2hud(user)
	src_object.orient2hud(user)
	if(user.active_storage) //refresh the HUD to show the transfered contents
		user.active_storage.close(user)
		user.active_storage.show_to(user)
	src_object.update_icon()
	return TRUE

///Get the best place to dump the items contained in the source storage item?
/atom/proc/get_dumping_location(obj/item/storage/source,mob/user)
	return null

/**
  * This proc is called when an atom in our contents has it's Destroy() called
  *
  * Default behaviour is to simply send COMSIG_ATOM_CONTENTS_DEL
  */
/atom/proc/handle_atom_del(atom/A)
	SEND_SIGNAL(src, COMSIG_ATOM_CONTENTS_DEL, A)

/**
  * called when the turf the atom resides on is ChangeTurfed
  *
  * Default behaviour is to loop through atom contents and call their HandleTurfChange() proc
  */
/atom/proc/HandleTurfChange(turf/T)
	for(var/a in src)
		var/atom/A = a
		A.HandleTurfChange(T)

/**
  * the vision impairment to give to the mob whose perspective is set to that atom
  *
  * (e.g. an unfocused camera giving you an impaired vision when looking through it)
  */
/atom/proc/get_remote_view_fullscreens(mob/user)
	return

/**
  * the sight changes to give to the mob whose perspective is set to that atom
  *
  * (e.g. A mob with nightvision loses its nightvision while looking through a normal camera)
  */
/atom/proc/update_remote_sight(mob/living/user)
	return


/**
  * Hook for running code when a dir change occurs
  *
  * Not recommended to use, listen for the COMSIG_ATOM_DIR_CHANGE signal instead (sent by this proc)
  */
/atom/proc/setDir(newdir)
	SEND_SIGNAL(src, COMSIG_ATOM_DIR_CHANGE, dir, newdir)
	dir = newdir

/// Attempts to turn to the given direction. May fail if anchored/unconscious/etc.
/atom/proc/try_face(newdir)
	setDir(newdir)
	return TRUE

///Handle melee attack by a mech
/atom/proc/mech_melee_attack(obj/mecha/M)
	return

/**
  * Called when the atom log's in or out
  *
  * Default behaviour is to call on_log on the location this atom is in
  */
/atom/proc/on_log(login)
	if(loc)
		loc.on_log(login)


/*
	Atom Colour Priority System
	A System that gives finer control over which atom colour to colour the atom with.
	The "highest priority" one is always displayed as opposed to the default of
	"whichever was set last is displayed"
*/


///Adds an instance of colour_type to the atom's atom_colours list
/atom/proc/add_atom_colour(coloration, colour_priority)
	if(!atom_colours || !atom_colours.len)
		atom_colours = list()
		atom_colours.len = COLOUR_PRIORITY_AMOUNT //four priority levels currently.
	if(!coloration)
		return
	if(colour_priority > atom_colours.len)
		return
	atom_colours[colour_priority] = coloration
	update_atom_colour()


///Removes an instance of colour_type from the atom's atom_colours list
/atom/proc/remove_atom_colour(colour_priority, coloration)
	if(!atom_colours)
		atom_colours = list()
		atom_colours.len = COLOUR_PRIORITY_AMOUNT //four priority levels currently.
	if(colour_priority > atom_colours.len)
		return
	if(coloration && atom_colours[colour_priority] != coloration)
		return //if we don't have the expected color (for a specific priority) to remove, do nothing
	atom_colours[colour_priority] = null
	update_atom_colour()


///Resets the atom's color to null, and then sets it to the highest priority colour available
/atom/proc/update_atom_colour()
	if(!atom_colours)
		atom_colours = list()
		atom_colours.len = COLOUR_PRIORITY_AMOUNT //four priority levels currently.
	color = null
	for(var/C in atom_colours)
		if(islist(C))
			var/list/L = C
			if(L.len)
				color = L
				return
		else if(C)
			color = C
			return

/**
  * call back when a var is edited on this atom
  *
  * Can be used to implement special handling of vars
  *
  * At the atom level, if you edit a var named "color" it will add the atom colour with
  * admin level priority to the atom colours list
  *
  * Also, if GLOB.Debug2 is FALSE, it sets the ADMIN_SPAWNED_1 flag on flags_1, which signifies
  * the object has been admin edited
  */
/atom/vv_edit_var(var_name, var_value)
	if(!GLOB.Debug2)
		flags_1 |= ADMIN_SPAWNED_1
	. = ..()
	switch(var_name)
		if(NAMEOF(src, color))
			add_atom_colour(color, ADMIN_COLOUR_PRIORITY)

/**
  * Return the markup to for the dropdown list for the VV panel for this atom
  *
  * Override in subtypes to add custom VV handling in the VV panel
  */
/atom/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "---------")
	if(!ismovable(src))
		var/turf/curturf = get_turf(src)
		if(curturf)
			. += "<option value='?_src_=holder;[HrefToken()];adminplayerobservecoodjump=1;X=[curturf.x];Y=[curturf.y];Z=[curturf.z]'>Jump To</option>"
	VV_DROPDOWN_OPTION(VV_HK_MODIFY_TRANSFORM, "Modify Transform")
	VV_DROPDOWN_OPTION(VV_HK_ADD_REAGENT, "Add Reagent")
	VV_DROPDOWN_OPTION(VV_HK_TRIGGER_EMP, "EMP Pulse")
	VV_DROPDOWN_OPTION(VV_HK_TRIGGER_EXPLOSION, "Explosion")
	VV_DROPDOWN_OPTION(VV_HK_EDIT_FILTERS, "Edit Filters")
	VV_DROPDOWN_OPTION(VV_HK_ADD_AI, "Add AI controller")
	if(greyscale_colors)
		VV_DROPDOWN_OPTION(VV_HK_MODIFY_GREYSCALE, "Modify greyscale colors")

/atom/vv_do_topic(list/href_list)
	. = ..()
	if(href_list[VV_HK_ADD_REAGENT] && check_rights(R_VAREDIT))
		if(!reagents)
			var/amount = input(usr, "Specify the reagent size of [src]", "Set Reagent Size", 50) as num
			if(amount)
				create_reagents(amount)

		if(reagents)
			var/chosen_id
			switch(alert(usr, "Choose a method.", "Add Reagents", "Search", "Choose from a list", "I'm feeling lucky"))
				if("Search")
					var/valid_id
					while(!valid_id)
						chosen_id = input(usr, "Enter the ID of the reagent you want to add.", "Search reagents") as null|text
						if(isnull(chosen_id)) //Get me out of here!
							break
						if (!ispath(text2path(chosen_id)))
							chosen_id = pick_closest_path(chosen_id, make_types_fancy(subtypesof(/datum/reagent)))
							if (ispath(chosen_id))
								valid_id = TRUE
						else
							valid_id = TRUE
						if(!valid_id)
							to_chat(usr, "<span class='warning'>A reagent with that ID doesn't exist!</span>")

				if("Choose from a list")
					chosen_id = input(usr, "Choose a reagent to add.", "Choose a reagent.") as null|anything in subtypesof(/datum/reagent)

				if("I'm feeling lucky")
					chosen_id = pick(subtypesof(/datum/reagent))

			if(chosen_id)
				var/amount = input(usr, "Choose the amount to add.", "Choose the amount.", reagents.maximum_volume) as num

				if(amount)
					reagents.add_reagent(chosen_id, amount)
					log_admin("[key_name(usr)] has added [amount] units of [chosen_id] to [src]")
					message_admins("<span class='notice'>[key_name(usr)] has added [amount] units of [chosen_id] to [src]</span>")

	if(href_list[VV_HK_TRIGGER_EXPLOSION] && check_rights(R_FUN))
		usr.client.cmd_admin_explosion(src)

	if(href_list[VV_HK_TRIGGER_EMP] && check_rights(R_FUN))
		usr.client.cmd_admin_emp(src)

	if(href_list[VV_HK_MODIFY_TRANSFORM] && check_rights(R_VAREDIT))
		var/result = input(usr, "Choose the transformation to apply","Transform Mod") as null|anything in list("Scale","Translate","Rotate")
		var/matrix/M = transform
		switch(result)
			if("Scale")
				var/x = input(usr, "Choose x mod","Transform Mod") as null|num
				var/y = input(usr, "Choose y mod","Transform Mod") as null|num
				if(!isnull(x) && !isnull(y))
					transform = M.Scale(x,y)
			if("Translate")
				var/x = input(usr, "Choose x mod","Transform Mod") as null|num
				var/y = input(usr, "Choose y mod","Transform Mod") as null|num
				if(!isnull(x) && !isnull(y))
					transform = M.Translate(x,y)
			if("Rotate")
				var/angle = input(usr, "Choose angle to rotate","Transform Mod") as null|num
				if(!isnull(angle))
					transform = M.Turn(angle)

	if(href_list[VV_HK_AUTO_RENAME] && check_rights(R_ADMIN))
		var/newname = input(usr, "What do you want to rename this to?", "Automatic Rename") as null|text
		if(newname)
			vv_auto_rename(newname)

	if(href_list[VV_HK_MODIFY_TRAITS] && check_rights(R_VAREDIT))
		usr.client.holder.modify_traits(src)

	if(href_list[VV_HK_ADD_AI] && check_rights(R_VAREDIT))
		var/result = input(usr, "Choose the AI controller to apply to this atom WARNING: Not all AI works on all atoms.", "AI controller") as null|anything in subtypesof(/datum/ai_controller)
		if(!result)
			return
		ai_controller = new result(src)

	if(href_list[VV_HK_EDIT_FILTERS] && check_rights(R_VAREDIT))
		var/client/C = usr.client
		C?.open_filter_editor(src)

/atom/vv_get_header()
	. = ..()
	var/refid = REF(src)
	. += "[VV_HREF_TARGETREF(refid, VV_HK_AUTO_RENAME, "<b id='name'>[src]</b>")]"
	. += "<br><font size='1'><a href='?_src_=vars;[HrefToken()];rotatedatum=[refid];rotatedir=left'><<</a> <a href='?_src_=vars;[HrefToken()];datumedit=[refid];varnameedit=dir' id='dir'>[dir2text(dir) || dir]</a> <a href='?_src_=vars;[HrefToken()];rotatedatum=[refid];rotatedir=right'>>></a></font>"

///Where atoms should drop if taken from this atom
/atom/proc/drop_location()
	var/atom/L = loc
	if(!L)
		return null
	return L.AllowDrop() ? L : L.drop_location()

/atom/proc/vv_auto_rename(newname)
	name = newname

/**
 * An atom has entered this atom's contents
 *
 * Default behaviour is to send the [COMSIG_ATOM_ENTERED]
 */
/atom/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SEND_SIGNAL(src, COMSIG_ATOM_ENTERED, arrived, old_loc, old_locs)

/**
 * An atom is attempting to exit this atom's contents
 *
 * Default behaviour is to send the [COMSIG_ATOM_EXIT]
 */
/atom/Exit(atom/movable/leaving, direction)
	// Don't call `..()` here, otherwise `Uncross()` gets called.
	// See the doc comment on `Uncross()` to learn why this is bad.

	if(SEND_SIGNAL(src, COMSIG_ATOM_EXIT, leaving, direction) & COMPONENT_ATOM_BLOCK_EXIT)
		return FALSE

	return TRUE

/**
 * An atom has exited this atom's contents
 *
 * Default behaviour is to send the [COMSIG_ATOM_EXITED]
 */
/atom/Exited(atom/movable/gone, direction)
	SEND_SIGNAL(src, COMSIG_ATOM_EXITED, gone, direction)

///Return atom temperature
/atom/proc/return_temperature()
	return

/**
  *Tool behavior procedure. Redirects to tool-specific procs by default.
  *
  * You can override it to catch all tool interactions, for use in complex deconstruction procs.
  *
  * Must return  parent proc ..() in the end if overridden
  */
/atom/proc/tool_act(mob/living/user, obj/item/I, tool_type)
	var/signal_result
	signal_result = SEND_SIGNAL(src, COMSIG_ATOM_TOOL_ACT(tool_type), user, I)
	if(signal_result & COMPONENT_BLOCK_TOOL_ATTACK) // The COMSIG_ATOM_TOOL_ACT signal is blocking the act
		return TOOL_ACT_SIGNAL_BLOCKING
	switch(tool_type)
		if(TOOL_CROWBAR)
			return crowbar_act(user, I)
		if(TOOL_MULTITOOL)
			return multitool_act(user, I)
		if(TOOL_SCREWDRIVER)
			return screwdriver_act(user, I)
		if(TOOL_WRENCH)
			return wrench_act(user, I)
		if(TOOL_WIRECUTTER)
			return wirecutter_act(user, I)
		if(TOOL_WELDER)
			return welder_act(user, I)
		if(TOOL_ANALYZER)
			return analyzer_act(user, I)

//! Tool-specific behavior procs. To be overridden in subtypes.
///

///Crowbar act
/atom/proc/crowbar_act(mob/living/user, obj/item/I)
	return

///Multitool act
/atom/proc/multitool_act(mob/living/user, obj/item/I)
	return

///Check if the multitool has an item in it's data buffer
/atom/proc/multitool_check_buffer(user, obj/item/I, silent = FALSE)
	if(!istype(I, /obj/item/multitool))
		if(user && !silent)
			to_chat(user, "<span class='warning'>[I] has no data buffer!</span>")
		return FALSE
	return TRUE

///Screwdriver act
/atom/proc/screwdriver_act(mob/living/user, obj/item/I)
	return

///Wrench act
/atom/proc/wrench_act(mob/living/user, obj/item/I)
	return

///Wirecutter act
/atom/proc/wirecutter_act(mob/living/user, obj/item/I)
	return

///Welder act
/atom/proc/welder_act(mob/living/user, obj/item/I)
	return

///Analyzer act
/atom/proc/analyzer_act(mob/living/user, obj/item/I)
	return

///Generate a tag for this atom
/atom/proc/GenerateTag()
	return

///Connect this atom to a shuttle
/atom/proc/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override=FALSE)
	return

/// Generic logging helper
/atom/proc/log_message(message, message_type, color=null, log_globally=TRUE)
	if(!log_globally)
		return

	var/log_text = "[key_name(src)] [message] [loc_name(src)]"
	switch(message_type)
		if(LOG_ATTACK)
			log_attack(log_text)
		if(LOG_SAY)
			log_say(log_text)
		if(LOG_WHISPER)
			log_whisper(log_text)
		if(LOG_EMOTE)
			log_emote(log_text)
		if(LOG_DSAY)
			log_dsay(log_text)
		if(LOG_PDA)
			log_pda(log_text)
		if(LOG_CHAT)
			log_chat(log_text)
		if(LOG_COMMENT)
			log_comment(log_text)
		if(LOG_TELECOMMS)
			log_telecomms(log_text)
		if(LOG_OOC)
			log_ooc(log_text)
		if(LOG_ADMIN)
			log_admin(log_text)
		if(LOG_ADMIN_PRIVATE)
			log_admin_private(log_text)
		if(LOG_ASAY)
			log_adminsay(log_text)
		if(LOG_OWNERSHIP)
			log_game(log_text)
		if(LOG_GAME)
			log_game(log_text)
		if(LOG_MECHA)
			log_mecha(log_text)
		if(LOG_RADIO_EMOTE)
			log_radio_emote(log_text)
		if(LOG_SPEECH_INDICATORS)
			log_speech_indicators(log_text)
		else
			stack_trace("Invalid individual logging type: [message_type]. Defaulting to [LOG_GAME] (LOG_GAME).")
			log_game(log_text)

/// Helper for logging chat messages or other logs with arbitrary inputs (e.g. announcements)
/atom/proc/log_talk(message, message_type, tag=null, log_globally=TRUE, forced_by=null, custom_say_emote = null)
	var/prefix = tag ? "([tag]) " : ""
	var/suffix = forced_by ? " FORCED by [forced_by]" : ""
	log_message("[prefix][custom_say_emote ? "*[custom_say_emote]*, " : ""]\"[message]\"[suffix]", message_type, log_globally=log_globally)

/// Helper for logging of messages with only one sender and receiver
/proc/log_directed_talk(atom/source, atom/target, message, message_type, tag)
	if(!tag)
		stack_trace("Unspecified tag for private message")
		tag = "UNKNOWN"

	source.log_talk(message, message_type, tag="[tag] to [key_name(target)]")
	if(source != target)
		target.log_talk(message, message_type, tag="[tag] from [key_name(source)]", log_globally=FALSE)

/**
  * Log for crafting items
  *
  * 1 argument is for the user making the item
  * 2 argument is for the item being created
  * 3 argument is for if admins should be notified if a non-antag crafts this
 */
/proc/log_crafting(mob/blacksmith, atom/object, dangerous = FALSE)
	var/message = "has crafted [object]"
	blacksmith.log_message(message, LOG_GAME)
	if(!dangerous)
		return
	if(isnull(locate(/datum/antagonist) in blacksmith.mind?.antag_datums))
		message_admins("[ADMIN_LOOKUPFLW(blacksmith)] has crafted [object] as a non-antagonist.")
/**
  * Log a combat message in the attack log
  *
  * 1 argument is the actor performing the action
  * 2 argument is the target of the action
  * 3 is a verb describing the action (e.g. punched, throwed, kicked, etc.)
  * 4 is a tool with which the action was made (usually an item)
  * 5 is any additional text, which will be appended to the rest of the log line
  */
/proc/log_combat(atom/user, atom/target, what_done, atom/object=null, addition=null)
	var/ssource = key_name(user)
	var/starget = key_name(target)

	var/mob/living/living_target = target
	var/hp = istype(living_target) ? " (NEWHP: [living_target.health]) " : ""

	var/sobject = ""
	if(object)
		sobject = " with [object]"
	var/saddition = ""
	if(addition)
		saddition = " [addition]"

	var/postfix = "[sobject][saddition][hp]"

	var/message = "has [what_done] [starget][postfix]"
	user.log_message(message, LOG_ATTACK, color="red")

	if(user != target)
		var/reverse_message = "has been [what_done] by [ssource][postfix]"
		target.log_message(reverse_message, LOG_ATTACK, color="orange", log_globally=FALSE)

/**
  * Log for buying items from the uplink
  *
  * 1 argument is for the user that bought the item
  * 2 argument is for the item that was purchased
  * 3 argument is for the uplink type (traitor/contractor)
 */
/proc/log_uplink_purchase(mob/buyer, atom/object, type = "\improper uplink")
	var/message = "has bought [object] from \a [type]"
	buyer.log_message(message, LOG_GAME)
	if(isnull(locate(/datum/antagonist) in buyer.mind?.antag_datums))
		message_admins("[ADMIN_LOOKUPFLW(buyer)] has bought [object] from \a [type] as a non-antagonist.")

/atom/proc/add_filter(name,priority,list/params)
	LAZYINITLIST(filter_data)
	var/list/p = params.Copy()
	p["priority"] = priority
	filter_data[name] = p
	update_filters()

/atom/proc/update_filters()
	filters = null
	filter_data = sortTim(filter_data, GLOBAL_PROC_REF(cmp_filter_data_priority), TRUE)
	for(var/f in filter_data)
		var/list/data = filter_data[f]
		var/list/arguments = data.Copy()
		arguments -= "priority"
		filters += filter(arglist(arguments))
	UNSETEMPTY(filter_data)

/atom/proc/transition_filter(name, time, list/new_params, easing, loop)
	var/filter = get_filter(name)
	if(!filter)
		return

	var/list/old_filter_data = filter_data[name]

	var/list/params = old_filter_data.Copy()
	for(var/thing in new_params)
		params[thing] = new_params[thing]

	animate(filter, new_params, time = time, easing = easing, loop = loop)
	for(var/param in params)
		filter_data[name][param] = params[param]

/atom/proc/change_filter_priority(name, new_priority)
	if(!filter_data || !filter_data[name])
		return

	filter_data[name]["priority"] = new_priority
	update_filters()

/atom/proc/get_filter(name)
	if(filter_data && filter_data[name])
		return filters[filter_data.Find(name)]

/atom/proc/remove_filter(name_or_names)
	if(!filter_data)
		return

	var/list/names = islist(name_or_names) ? name_or_names : list(name_or_names)

	for(var/name in names)
		if(filter_data[name])
			filter_data -= name
	update_filters()

/atom/proc/clear_filters()
	filter_data = null
	filters = null

/atom/proc/intercept_zImpact(atom/movable/AM, levels = 1)
	. |= SEND_SIGNAL(src, COMSIG_ATOM_INTERCEPT_Z_FALL, AM, levels)

///Sets the custom materials for an item.
/atom/proc/set_custom_materials(var/list/materials, multiplier = 1)
	if(custom_materials) //Only runs if custom materials existed at first. Should usually be the case but check anyways
		for(var/i in custom_materials)
			var/datum/material/custom_material = i
			custom_material.on_removed(src, material_flags) //Remove the current materials

	if(!length(materials))
		return

	custom_materials = list() //Reset the list

	for(var/x in materials)
		var/datum/material/custom_material = x

		custom_material.on_applied(src, materials[custom_material] * multiplier, material_flags)
		custom_materials[custom_material] += materials[custom_material] * multiplier

/// Returns the indice in filters of the given filter name.
/// If it is not found, returns null.
/atom/proc/get_filter_index(name)
	return filter_data?.Find(name)

///Setter for the `density` variable to append behavior related to its changing.
/atom/proc/set_density(new_value)
	SHOULD_CALL_PARENT(TRUE)
	if(density == new_value)
		return
	. = density
	density = new_value

/**
  * Causes effects when the atom gets hit by a rust effect from heretics
  *
  * Override this if you want custom behaviour in whatever gets hit by the rust
  */
/atom/proc/rust_heretic_act()
	return

/**
  * Used to set something as 'open' if it's being used as a supplypod
  *
  * Override this if you want an atom to be usable as a supplypod.
  */
/atom/proc/setOpened()
	return

/**
  * Used to set something as 'closed' if it's being used as a supplypod
  *
  * Override this if you want an atom to be usable as a supplypod.
  */
/atom/proc/setClosed()
	return

/**
* Instantiates the AI controller of this atom. Override this if you want to assign variables first.
*
* This will work fine without manually passing arguments.
+*/
/atom/proc/InitializeAIController()
	if(ai_controller)
		ai_controller = new ai_controller(src)

/*
* Called when something made out of plasma is exposed to high temperatures.
* Intended for use only with plasma that is ignited outside of some form of containment
* Contained plasma ignitions (such as power cells or light fixtures) should explode with proper force
*/
/atom/proc/plasma_ignition(strength, mob/user, reagent_reaction)
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/environment = T.return_air()
	if(environment.get_moles(GAS_O2) >= PLASMA_MINIMUM_OXYGEN_NEEDED) //Flashpoint ignition can only occur with at least this much oxygen present
		//no reason to alert admins or create an explosion if there's not enough power to actually make an explosion
		if(strength > 1)
			if(user)
				message_admins("[src] ignited by [ADMIN_LOOKUPFLW(user)] in [ADMIN_VERBOSEJMP(T)]")
				log_game("[src] ignited by [key_name(user)] in [AREACOORD(T)]")
			else
				//if we can't get a direct source for ignition, we'll take the last person who touched what is blowing up
				var/mob/toucher = get_mob_by_ckey(fingerprintslast)
				if(toucher)
					message_admins("[src] ignited in [ADMIN_VERBOSEJMP(T)], last touched by [ADMIN_LOOKUPFLW(toucher)]")
					log_game("[src] ignited in [AREACOORD(T)], last touched by [key_name(toucher)]")
				else
					//Nobody directly touched the source of ignition or what ignited. Probably caused by burning atmos.
					message_admins("[src] ignited by unidentified causes in [ADMIN_VERBOSEJMP(T)]")
					log_game("[src] ignited by unidentified causes in [AREACOORD(T)]")
			explosion(T, 0, 0, light_impact_range = strength/4, flash_range = strength/2, flame_range = strength, silent = TRUE)
		else
			new /obj/effect/hotspot(T)
		//Regardless of power, whatever is burning will go up in a brilliant flash with at least a fizzle
		playsound(T,'sound/magic/fireball.ogg', max(strength*20, 20), 1)
		T.visible_message("<b><span class='userdanger'>[src] ignites in a brilliant flash!</span></b>")
		if(reagent_reaction) // Don't qdel(src). It's a reaction inside of something (or someone) important.
			return TRUE
		else if(isturf(src))
			var/turf/srcTurf = src
			srcTurf.ScrapeAway() //Can't just qdel turfs
		else
			qdel(src)
		return TRUE
	return FALSE

