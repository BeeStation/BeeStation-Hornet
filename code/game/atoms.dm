
/**
  * The base type for nearly all physical objects in SS13

  * Lots and lots of functionality lives here, although in general we are striving to move
  * as much as possible to the components/elements system
  */
/atom
	layer = TURF_LAYER
	plane = GAME_PLANE
	appearance_flags = TILE_BOUND|LONG_GLIDE

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
	var/datum/component/orbiter/orbit_datum

	/// Will move to flags_1 when i can be arsed to (2019, has not done so)
	var/rad_flags = NONE
	/// Radiation insulation types
	var/rad_insulation = RAD_NO_INSULATION

	/// The icon state intended to be used for the acid component. Used to override the default acid overlay icon state.
	var/custom_acid_overlay = null

	///The custom materials this atom is made of, used by a lot of things like furniture, walls, and floors (if I finish the functionality, that is.)
	///The list referenced by this var can be shared by multiple objects and should not be directly modified. Instead, use [set_custom_materials][/atom/proc/set_custom_materials].
	var/list/custom_materials
	///Bitfield for how the atom handles materials.
	var/material_flags = NONE
	///Modifier that raises/lowers the effect of the amount of a material, prevents small and easy to get items from being death machines.
	var/material_modifier = 1

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

	///The config type to use for greyscaled sprites. Both this and greyscale_colors must be assigned to work.
	var/greyscale_config
	///A string of hex format colors to be used by greyscale sprites, ex: "#0054aa#badcff"
	var/greyscale_colors

	///Holds merger groups currently active on the atom. Do not access directly, use GetMergeGroup() instead.
	var/list/datum/merger/mergers

	///AI controller that controls this atom. type on init, then turned into an instance during runtime
	var/datum/ai_controller/ai_controller

	///any atom that uses integrity and can be damaged must set this to true, otherwise the integrity procs will throw an error
	var/uses_integrity = FALSE

	VAR_PROTECTED/datum/armor/armor_type = /datum/armor/none
	VAR_PRIVATE/datum/armor/armor

	VAR_PRIVATE/atom_integrity //defaults to max_integrity
	var/max_integrity = 500
	var/integrity_failure = 0 //0 if we have no special broken behavior, otherwise is a percentage of at what point the atom breaks. 0.5 being 50%
	///Damage under this value will be completely ignored
	var/damage_deflection = 0
	/// Maximum damage that can be taken in a single hit
	var/max_hit_damage = null

	var/resistance_flags = NONE // INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ON_FIRE | UNACIDABLE | ACID_PROOF

	/// the datum handler for our contents - see create_storage() for creation method
	var/datum/storage/atom_storage

	/// Lazylist of all messages currently on this atom
	var/list/chat_messages

	// Use SET_BASE_PIXEL(x, y) to set these in typepath definitions, it'll handle pixel_x and y for you
	///Default pixel x shifting for the atom's icon.
	var/base_pixel_x = 0
	///Default pixel y shifting for the atom's icon.
	var/base_pixel_y = 0
	///Used for changing icon states for different base sprites.
	var/base_icon_state

	// This veriable exists BECAUSE animating sprite (bola) has an issue to render to TGUI crafting window - it shows wrong icons.

	///LazyList of all balloon alerts currently on this atom
	var/list/balloon_alerts

	/// What is our default level of luminosity, if you want inherent luminosity
	/// withing an atom's type, set luminosity instead and we will manage it for you.
	/// Always use set_base_luminosity instead of directly modifying this
	VAR_PRIVATE/base_luminosity = 0
	/// DO NOT EDIT THIS, USE ADD_LUM_SOURCE INSTEAD
	VAR_PRIVATE/_emissive_count = 0

	/// list of clients that using this atom as their eye. SHOULD BE USED CAREFULLY
	var/list/eye_users

	/// Amount of users hovering us, if this is greater than 1 we need to clear references on destroy
	var/hovered_user_count = 0

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
	if(GLOB.use_preloader && src.type == GLOB._preloader_path)//in case the instanciated atom is creating other atoms in New()
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
	//SHOULD_NOT_SLEEP(TRUE) //TODO: We shouldn't be sleeping initialize
	SHOULD_CALL_PARENT(TRUE)

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

	// apply materials properly from the default custom_materials value
	set_custom_materials(custom_materials)

	if(uses_integrity)
		atom_integrity = max_integrity

	ComponentInitialize()
	InitializeAIController()

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
  * * Removes clients who use this, and resets their eye
  * * Removes alternate apperances from huds that see them
  * * qdels the reagent holder from atoms if it exists
  * * clears the orbiters list
  * * clears overlays and priority overlays
  * * clears the light object
  */
/atom/Destroy()
	for(var/client/each_client as anything in eye_users)
		eye_users -= each_client
		if(isnull(each_client.mob))
			stack_trace("CRITICAL: Failed to recover a client's eye as their mob.")
			continue
		each_client.mob.reset_perspective()
	eye_users = null

	if (chat_messages)
		for (var/chatmessage in chat_messages)
			qdel(chatmessage)
		chat_messages = null
	if (balloon_alerts)
		for (var/balloon_alerts in balloon_alerts)
			qdel(balloon_alerts)
		balloon_alerts = null

	if(alternate_appearances)
		for(var/current_alternate_appearance in alternate_appearances)
			var/datum/atom_hud/alternate_appearance/selected_alternate_appearance = alternate_appearances[current_alternate_appearance]
			selected_alternate_appearance.remove_from_hud(src)

	if(reagents)
		QDEL_NULL(reagents)

	if(atom_storage)
		QDEL_NULL(atom_storage)

	orbit_datum = null // The component is attached to us normaly and will be deleted elsewhere

	// Checking length(overlays) before cutting has significant speed benefits
	if (length(overlays))
		overlays.Cut()
	LAZYNULL(managed_overlays)

	if(ai_controller)
		QDEL_NULL(ai_controller)
	if(light)
		QDEL_NULL(light)

	if (hovered_user_count)
		SSscreentips.deleted_hovered_atoms ++
		for (var/client/client in GLOB.clients)
			if (client.hovered_atom == src)
				client.hovered_atom = null
		hovered_user_count = 0

	return ..()

/// A quick and easy way to create a storage datum for an atom
/atom/proc/create_storage(
	max_slots,
	max_specific_storage,
	max_total_storage,
	numerical_stacking = FALSE,
	allow_quick_gather = FALSE,
	allow_quick_empty = FALSE,
	collection_mode = COLLECT_ONE,
	attack_hand_interact = TRUE,
	list/canhold,
	list/canthold,
	storage_type = /datum/storage,
)

	if(atom_storage)
		QDEL_NULL(atom_storage)

	atom_storage = new storage_type(src, max_slots, max_specific_storage, max_total_storage, numerical_stacking, allow_quick_gather, collection_mode, attack_hand_interact)

	if(canhold || canthold)
		atom_storage.set_holdable(canhold, canthold)

	return atom_storage

/// A quick and easy way to /clone/ a storage datum for an atom (does not copy over contents, only the datum details)
/atom/proc/clone_storage(datum/storage/cloning)
	if(atom_storage)
		QDEL_NULL(atom_storage)

	atom_storage = new cloning.type(src, cloning.max_slots, cloning.max_specific_storage, cloning.max_total_storage, cloning.numerical_stacking, cloning.allow_quick_gather, cloning.collection_mode, cloning.attack_hand_interact)

	if(cloning.can_hold || cloning.cant_hold)
		atom_storage.set_holdable(cloning.can_hold, cloning.cant_hold)

	return atom_storage

/atom/proc/handle_ricochet(obj/projectile/P)
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
	P.set_angle(new_angle_s)
	return TRUE

/// Whether the mover object can avoid being blocked by this atom, while arriving from (or leaving through) the border_dir.
/atom/proc/CanPass(atom/movable/mover, border_dir)
	SHOULD_CALL_PARENT(TRUE)
	SHOULD_BE_PURE(TRUE)
	if(mover.movement_type & PHASING)
		return TRUE
	. = CanAllowThrough(mover, border_dir)
	// This is cheaper than calling the proc every time since most things dont override CanPassThrough
	if(!mover.generic_canpass)
		return mover.CanPassThrough(src, REVERSE_DIR(border_dir), .)

/// Returns true or false to allow the mover to move through src
/atom/proc/CanAllowThrough(atom/movable/mover, border_dir)
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

	//Check for centcom itself
	if(istype(T.loc, /area/centcom))
		return TRUE

	return onCentComShuttle()

/**
 * Is this atom currently on a centcom roundend escape shuttle?
 */
/atom/proc/onCentComShuttle()
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE

	var/area/shuttle/loc_area = get_area(T)
	if(isnull(loc_area))
		return FALSE

	for(var/A in SSshuttle.mobile)
		var/obj/docking_port/mobile/M = A
		if(M.launch_status == ENDGAME_LAUNCHED)
			if(loc_area in M.shuttle_areas)
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
/atom/proc/CheckParts(list/parts_list, datum/crafting_recipe/R)
	SEND_SIGNAL(src, COMSIG_ATOM_CHECKPARTS, parts_list, R)
	if(!parts_list)
		return

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
			SEND_SIGNAL(M, COMSIG_ATOM_USED_IN_CRAFT, src)
	parts_list.Cut()

///Take air from the passed in gas mixture datum
/atom/proc/assume_air(datum/gas_mixture/giver)
	return null

///Remove air from this atom
/atom/proc/remove_air(amount)
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

/** Handles exposing this atom to a list of reagents.
  *
  * Sends COMSIG_ATOM_EXPOSE_REAGENTS
  * Calls expose_atom() for every reagent in the reagent list.
  *
  * Arguments:
  * - [reagents][/list]: The list of reagents the atom is being exposed to.
  * - [source][/datum/reagents]: The reagent holder the reagents are being sourced from.
  * - methods: How the atom is being exposed to the reagents. Bitflags.
  * - volume_modifier: Volume multiplier.
  * - show_message: Whether to display anything to mobs when they are exposed.
  */
/atom/proc/expose_reagents(list/reagents, datum/reagents/source, methods=TOUCH, volume_modifier=1, show_message=TRUE)
	. = SEND_SIGNAL(src, COMSIG_ATOM_EXPOSE_REAGENTS, reagents, source, methods, volume_modifier, show_message)
	if(. & COMPONENT_NO_EXPOSE_REAGENTS)
		return

	SEND_SIGNAL(source, COMSIG_REAGENTS_EXPOSE_ATOM, src, reagents, methods, volume_modifier, show_message)
	for(var/reagent in reagents)
		var/datum/reagent/R = reagent
		. |= R.expose_atom(src, reagents[R])

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
/atom/proc/bullet_act(obj/projectile/P, def_zone, piercing_hit = FALSE)
	var/bullet_signal = SEND_SIGNAL(src, COMSIG_ATOM_BULLET_ACT, P, def_zone)
	if(bullet_signal & COMSIG_ATOM_BULLET_ACT_FORCE_PIERCE)
		return BULLET_ACT_FORCE_PIERCE
	else if(bullet_signal & COMSIG_ATOM_BULLET_ACT_BLOCK)
		return BULLET_ACT_BLOCK
	else if(bullet_signal & COMSIG_ATOM_BULLET_ACT_HIT)
		return BULLET_ACT_HIT
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
	var/examine_string = get_examine_string(user, thats = TRUE)
	if(examine_string)
		. = list("[examine_string].")
	else
		. = list()

	if(desc)
		. += desc

	if(z && user.z != z) // Z-mimic
		var/diff = abs(user.z - z)
		. += span_boldnotice("[p_theyre(TRUE)] [diff] level\s below you.")

	var/list/tags_list = examine_tags(user)
	if (length(tags_list))
		var/tag_string = list()
		for (var/atom_tag in tags_list)
			tag_string += (isnull(tags_list[atom_tag]) ? atom_tag : span_tooltip(tags_list[atom_tag], atom_tag))
		// Weird bit but ensures that if the final element has its own "and" we don't add another one
		tag_string = english_list(tag_string, and_text = (findtext(tag_string[length(tag_string)], " and ")) ? ", " : " and ")
		var/post_descriptor = examine_post_descriptor(user)
		. += "[p_They()] [p_are()] a [tag_string] [examine_descriptor(user)][length(post_descriptor) ? " [jointext(post_descriptor, " ")]" : ""]."

	if(reagents)
		var/user_sees_reagents = user.can_see_reagents()
		var/reagent_sigreturn = SEND_SIGNAL(src, COMSIG_PARENT_REAGENT_EXAMINE, user, ., user_sees_reagents)
		if(!(reagent_sigreturn & STOP_GENERIC_REAGENT_EXAMINE))
			if(reagents.flags & TRANSPARENT)
				if(reagents.total_volume > 0)
					. += "It contains <b>[round(reagents.total_volume, 0.01)]</b> units of various reagents[user_sees_reagents ? ":" : "."]"
					if(user_sees_reagents) //Show each individual reagent
						for(var/datum/reagent/current_reagent as anything in reagents.reagent_list)
							. += "&bull; [round(current_reagent.volume, 0.01)] units of [current_reagent.name]"

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
							. += span_notice("Booze Power: total [total_boozepower], average [round(total_boozepower/reagents.total_volume, 0.1)] ([get_boozepower_text(total_boozepower/reagents.total_volume, user)])")
							. += span_notice("It would taste like: [english_list(taste_list, comma_text="", and_text="")].")
					//-------------------------------
				else
					. += "It contains:<br>Nothing."
			else if(reagents.flags & AMOUNT_VISIBLE)
				if(reagents.total_volume)
					. += span_notice("It has [reagents.total_volume] unit\s left.")
				else
					. += span_danger("It's empty.")

	if(HAS_TRAIT(user, TRAIT_PSYCHIC_SENSE))
		var/list/souls = return_souls()
		if(!length(souls))
			return
		to_chat(user, span_notice("You sense a presence here..."))
		//Count of souls
		var/list/present_souls = list()
		for(var/soul in souls)
			present_souls[soul] += 1
		//Display the total soul count
		for(var/soul in present_souls)
			if(!present_souls[soul] || !GLOB.soul_glimmer_colors[soul])
				continue
			to_chat(user, "\t[span_notice("<span class='[GLOB.soul_glimmer_cfc_list[soul]]'>[soul]")], [present_souls[soul] > 1 ? "[present_souls[soul]] times" : "once"].</span>")

	SEND_SIGNAL(src, COMSIG_PARENT_EXAMINE, user, .)

/*
 * A list of "tags" displayed after atom's description in examine.
 * This should return an assoc list of tags -> tooltips for them. If item if null, then no tooltip is assigned.
 * For example:
 * list("small" = "This is a small size class item.", "fireproof" = "This item is impervious to fire.")
 * will result in
 * This is a small, fireproof item.
 * where "item" is pulled from examine_descriptor() proc
 */
/atom/proc/examine_tags(mob/user)
	. = list()
	SEND_SIGNAL(src, COMSIG_ATOM_EXAMINE_TAGS, user, .)

/// What this atom should be called in examine tags
/atom/proc/examine_descriptor(mob/user)
	return "object"

/// Returns a list of strings to be displayed after the descriptor
/atom/proc/examine_post_descriptor(mob/user)
	. = list()
	if(!custom_materials)
		return
	var/mats_list = list()
	for(var/custom_material in custom_materials)
		var/datum/material/current_material = SSmaterials.GetMaterialRef(custom_material)
		mats_list += span_tooltip("It is made out of [current_material.name].", current_material.name)
	. += "made of [english_list(mats_list)]"

/**
 * Called when a mob examines (shift click or verb) this atom twice (or more) within EXAMINE_MORE_WINDOW (default 1 second)
 *
 * This is where you can put extra information on something that may be superfluous or not important in critical gameplay
 * moments, while allowing people to manually double-examine to take a closer look
 *
 * Produces a signal [COMSIG_PARENT_EXAMINE_MORE]
 */
/atom/proc/examine_more(mob/user)
	SHOULD_CALL_PARENT(TRUE)
	RETURN_TYPE(/list)

	. = list()
	SEND_SIGNAL(src, COMSIG_PARENT_EXAMINE_MORE, user, .)

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

	if (ismovable(src))
		UPDATE_OO_IF_PRESENT

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
	// SHOULD_CALL_PARENT(TRUE) this should eventually be set when all update_icons() are updated. As of current this makes zmimic sometimes not catch updates
	SIGNAL_HANDLER

	. = NONE
	updates &= ~SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_ICON, updates)
	if(updates & UPDATE_ICON_STATE)
		update_icon_state()
		. |= UPDATE_ICON_STATE

	if(updates & UPDATE_OVERLAYS)
		if(LAZYLEN(managed_vis_overlays))
			SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)

		// Clear the luminosity sources for our managed overlays
		REMOVE_LUM_SOURCE(src, LUM_SOURCE_MANAGED_OVERLAY)
		// Update the overlays where any luminous things get added again
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
	if (ismovable(src)) // need to update here as well since update_appearance() is not always called
		UPDATE_OO_IF_PRESENT

/// Updates the icon state of the atom
/atom/proc/update_icon_state()
	SHOULD_CALL_PARENT(TRUE)
	return SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_ICON_STATE)

/// Updates the overlays of the atom
/atom/proc/update_overlays()
	SHOULD_CALL_PARENT(TRUE)
	. = list()
	SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_OVERLAYS, .)

/atom/proc/update_inhand_icon(mob/target = loc)
	SHOULD_CALL_PARENT(TRUE)
	if(!istype(target))
		return

	target.update_inv_hands()

	//SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_INHAND_ICON, target)

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
/atom/proc/relaymove(mob/living/user, direction)
	if(buckle_message_cooldown <= world.time)
		buckle_message_cooldown = world.time + 50
		to_chat(user, span_warning("You can't move while buckled to [src]!"))
	return

/**
 * A special case of relaymove() in which the person relaying the move may be "driving" this atom
 *
 * This is a special case for vehicles and ridden animals where the relayed movement may be handled
 * by the riding component attached to this atom. Returns TRUE as long as there's nothing blocking
 * the movement, or FALSE if the signal gets a reply that specifically blocks the movement
 */
/atom/proc/relaydrive(mob/living/user, direction)
	return !(SEND_SIGNAL(src, COMSIG_RIDDEN_DRIVER_MOVE, user, direction) & COMPONENT_DRIVER_BLOCK_MOVE)

/// Handle what happens when your contents are exploded by a bomb
/atom/proc/contents_explosion(severity, target)
	return //For handling the effects of explosions on contents that would not normally be effected

/**
 * React to being hit by an explosion
 *
 * Should be called through the [EX_ACT] wrapper macro.
 * The wrapper takes care of the [COMSIG_ATOM_EX_ACT] signal.
 * as well as calling [/atom/proc/contents_explosion].
 */
/atom/proc/ex_act(severity, target)
	set waitfor = FALSE

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
	return FALSE

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

///Used for making a sound when a mob involuntarily falls into the ground.
/atom/proc/handle_fall(mob/faller)
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
	return FALSE

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
/atom/proc/use_emag(mob/user, obj/item/card/emag/hacker)
	if(!SEND_SIGNAL(src, COMSIG_ATOM_SHOULD_EMAG, user))
		SEND_SIGNAL(src, COMSIG_ATOM_ON_EMAG, user, hacker)

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
 * Intercept our atom being teleported if we need to
 *
 * return COMPONENT_BLOCK_TELEPORT to explicity block teleportation
 */
/atom/proc/intercept_teleport(channel, turf/origin, turf/destination)
	. = SEND_SIGNAL(src, COMSIG_ATOM_INTERCEPT_TELEPORT, channel, origin, destination)

	if(. == COMPONENT_BLOCK_TELEPORT)
		return

	// Recursively check contents by default. This can be overriden if we want different behavior.
	for(var/atom/thing in contents)
		// For the purposes of intercepting teleports, mobs on the turf don't count.
		// We're already doing logic for intercepting teleports on the teleatom-level
		if(isturf(src) && ismob(thing))
			continue
		var/result = thing.intercept_teleport(channel, origin, destination)
		if(result == COMPONENT_BLOCK_TELEPORT)
			return result

/**
  * Respond to our atom being checked by a virus extrapolator.
  *
  * Default behaviour is to send COMSIG_ATOM_EXTRAPOLATOR_ACT and return an empty list (which may be populated by the signal)
  *
  * Returns a list of viruses in the atom.
  * Include EXTRAPOLATOR_SPECIAL_HANDLED in the list if the extrapolation act has been handled by this proc or a signal, and should not be handled by the extrapolator itself.
  */
/atom/proc/extrapolator_act(mob/living/user, obj/item/extrapolator/extrapolator, dry_run = FALSE)
	. = list(EXTRAPOLATOR_RESULT_DISEASES = list())
	SEND_SIGNAL(src, COMSIG_ATOM_EXTRAPOLATOR_ACT, user, extrapolator, dry_run, .)

/**
 * If someone's trying to dump items onto our atom, where should they be dumped to?
 *
 * Return a loc to place objects, or null to stop dumping.
 */
/atom/proc/get_dumping_location()
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
	. = dir != newdir
	dir = newdir

/// Attempts to turn to the given direction. May fail if anchored/unconscious/etc.
/atom/proc/try_face(newdir)
	setDir(newdir)
	return TRUE

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
		return
	if(colour_priority > atom_colours.len)
		return
	if(coloration && atom_colours[colour_priority] != coloration)
		return //if we don't have the expected color (for a specific priority) to remove, do nothing
	atom_colours[colour_priority] = null
	update_atom_colour()


///Resets the atom's color to null, and then sets it to the highest priority colour available
/atom/proc/update_atom_colour()
	color = null
	if(!atom_colours)
		return
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
  * Wash this atom
  *
  * This will clean it off any temporary stuff like blood. Override this in your item to add custom cleaning behavior.
  * Returns true if any washing was necessary and thus performed
  * Arguments:
  * * clean_types: any of the CLEAN_ constants
  */
/atom/proc/wash(clean_types)
	SHOULD_CALL_PARENT(TRUE)

	. = FALSE
	if(SEND_SIGNAL(src, COMSIG_COMPONENT_CLEAN_ACT, clean_types) & COMPONENT_CLEANED)
		. = TRUE

	// Basically "if has washable coloration"
	if(length(atom_colours) >= WASHABLE_COLOUR_PRIORITY && atom_colours[WASHABLE_COLOUR_PRIORITY])
		remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
		return TRUE

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
	switch(var_name)
		if(NAMEOF(src, base_pixel_x))
			set_base_pixel_x(var_value)
			. = TRUE
		if(NAMEOF(src, base_pixel_y))
			set_base_pixel_y(var_value)
			. = TRUE
		if (NAMEOF(src, _emissive_count))
			return FALSE

	if(!isnull(.))
		datum_flags |= DF_VAR_EDITED
		return

	if(!GLOB.Debug2)
		flags_1 |= ADMIN_SPAWNED_1

	. = ..()

	// Check for appearance updates
	var/static/list/appearance_updaters = list("layer", "plane", "alpha", "icon", "icon_state", "name", "desc", "blocks_emissive", "appearance_flags")
	if (var_name in appearance_updaters)
		update_appearance()

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
			. += "<option value='byond://?_src_=holder;[HrefToken()];adminplayerobservecoodjump=1;X=[curturf.x];Y=[curturf.y];Z=[curturf.z]'>Jump To</option>"
	VV_DROPDOWN_OPTION(VV_HK_MODIFY_TRANSFORM, "Modify Transform")
	VV_DROPDOWN_OPTION(VV_HK_ADD_REAGENT, "Add Reagent")
	VV_DROPDOWN_OPTION(VV_HK_TRIGGER_EMP, "EMP Pulse")
	VV_DROPDOWN_OPTION(VV_HK_TRIGGER_EXPLOSION, "Explosion")
	VV_DROPDOWN_OPTION(VV_HK_RADIATE, "Radiate")
	VV_DROPDOWN_OPTION(VV_HK_EDIT_FILTERS, "Edit Filters")
	VV_DROPDOWN_OPTION(VV_HK_EDIT_COLOR_MATRIX, "Edit Color as Matrix")
	VV_DROPDOWN_OPTION(VV_HK_ADD_AI, "Add AI controller")
	VV_DROPDOWN_OPTION(VV_HK_ARMOR_MOD, "Modify Armor")
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
							to_chat(usr, span_warning("A reagent with that ID doesn't exist!"))

				if("Choose from a list")
					chosen_id = input(usr, "Choose a reagent to add.", "Choose a reagent.") as null|anything in subtypesof(/datum/reagent)

				if("I'm feeling lucky")
					chosen_id = pick(subtypesof(/datum/reagent))

			if(chosen_id)
				var/amount = input(usr, "Choose the amount to add.", "Choose the amount.", reagents.maximum_volume) as num

				if(amount)
					reagents.add_reagent(chosen_id, amount)
					log_admin("[key_name(usr)] has added [amount] units of [chosen_id] to [src]")
					message_admins(span_notice("[key_name(usr)] has added [amount] units of [chosen_id] to [src]"))

	if(href_list[VV_HK_TRIGGER_EXPLOSION] && check_rights(R_FUN))
		usr.client.cmd_admin_explosion(src)

	if(href_list[VV_HK_TRIGGER_EMP] && check_rights(R_FUN))
		usr.client.cmd_admin_emp(src)

	if(href_list[VV_HK_RADIATE] && check_rights(R_FUN))
		var/strength = input(usr, "Choose the radiation strength.", "Choose the strength.") as num|null
		if(!isnull(strength))
			AddComponent(/datum/component/radioactive, strength, src)

	if(href_list[VV_HK_ARMOR_MOD])
		var/list/pickerlist = list()
		var/list/armorlist = get_armor().get_rating_list()

		for (var/i in armorlist)
			pickerlist += list(list("value" = armorlist[i], "name" = i))

		var/list/result = presentpicker(usr, "Modify armor", "Modify armor: [src]", Button1="Save", Button2 = "Cancel", Timeout=FALSE, inputtype = "text", values = pickerlist)
		var/list/armor_all = ARMOR_LIST_ALL

		if (islist(result))
			if (result["button"] != 2) // If the user pressed the cancel button
				// text2num conveniently returns a null on invalid values
				var/list/converted = list()
				for(var/armor_key in armor_all)
					converted[armor_key] = text2num(result["values"][armor_key])
				set_armor(get_armor().generate_new_with_specific(converted))
				var/message = "[key_name(usr)] modified the armor on [src] ([type]) to: "
				for(var/armor_key in armor_all)
					message += "[armor_key]=[get_armor_rating(armor_key)],"
				message = copytext(message, 1, -1)
				log_admin(span_notice("[message]"))
				message_admins(span_notice("[message]"))

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

	if(href_list[VV_HK_EDIT_COLOR_MATRIX] && check_rights(R_VAREDIT))
		var/client/C = usr.client
		C?.open_color_matrix_editor(src)

/atom/vv_get_header()
	. = ..()
	var/refid = REF(src)
	. += "[VV_HREF_TARGETREF(refid, VV_HK_AUTO_RENAME, "<b id='name'>[src]</b>")]"
	. += "<br><font size='1'><a href='byond://?_src_=vars;[HrefToken()];rotatedatum=[refid];rotatedir=left'><<</a> <a href='byond://?_src_=vars;[HrefToken()];datumedit=[refid];varnameedit=dir' id='dir'>[dir2text(dir) || dir]</a> <a href='byond://?_src_=vars;[HrefToken()];rotatedatum=[refid];rotatedir=right'>>></a></font>"

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
/atom/proc/tool_act(mob/living/user, obj/item/tool, tool_type, is_right_clicking)
	var/act_result
	var/signal_result

	var/is_left_clicking = !is_right_clicking

	if(is_left_clicking) // Left click first for sensibility
		var/list/processing_recipes = list() //List of recipes that can be mutated by sending the signal
		signal_result = SEND_SIGNAL(src, COMSIG_ATOM_TOOL_ACT(tool_type), user, tool, processing_recipes)
		if(signal_result & COMPONENT_BLOCK_TOOL_ATTACK) // The COMSIG_ATOM_TOOL_ACT signal is blocking the act
			return TOOL_ACT_SIGNAL_BLOCKING
		if(processing_recipes.len)
			process_recipes(user, tool, processing_recipes)
		if(QDELETED(tool))
			return TRUE
	else
		signal_result = SEND_SIGNAL(src, COMSIG_ATOM_SECONDARY_TOOL_ACT(tool_type), user, tool)
		if(signal_result & COMPONENT_BLOCK_TOOL_ATTACK) // The COMSIG_ATOM_TOOL_ACT signal is blocking the act
			return TOOL_ACT_SIGNAL_BLOCKING

	switch(tool_type)
		if(TOOL_CROWBAR)
			act_result = is_left_clicking ? crowbar_act(user, tool) : crowbar_act_secondary(user, tool)
		if(TOOL_MULTITOOL)
			act_result = is_left_clicking ? multitool_act(user, tool) : multitool_act_secondary(user, tool)
		if(TOOL_SCREWDRIVER)
			act_result = is_left_clicking ? screwdriver_act(user, tool) : screwdriver_act_secondary(user, tool)
		if(TOOL_WRENCH)
			act_result = is_left_clicking ? wrench_act(user, tool) : wrench_act_secondary(user, tool)
		if(TOOL_WIRECUTTER)
			act_result = is_left_clicking ? wirecutter_act(user, tool) : wirecutter_act_secondary(user, tool)
		if(TOOL_WELDER)
			act_result = is_left_clicking ? welder_act(user, tool) : welder_act_secondary(user, tool)
		if(TOOL_ANALYZER)
			act_result = is_left_clicking ? analyzer_act(user, tool) : analyzer_act_secondary(user, tool)
	if(!act_result)
		return

	// A tooltype_act has completed successfully
	if(is_left_clicking)
		investigate_log("[key_name(user)] used [tool] on [src] at [AREACOORD(src)]", INVESTIGATE_TOOLS)
		SEND_SIGNAL(tool,  COMSIG_TOOL_ATOM_ACTED_PRIMARY(tool_type), src)
	else
		investigate_log("[key_name(user)] used [tool] on [src] (right click) at [AREACOORD(src)]", INVESTIGATE_TOOLS)
		SEND_SIGNAL(tool,  COMSIG_TOOL_ATOM_ACTED_SECONDARY(tool_type), src)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/atom/proc/process_recipes(mob/living/user, obj/item/I, list/processing_recipes)
	//Only one recipe? use the first
	if(processing_recipes.len == 1)
		StartProcessingAtom(user, I, processing_recipes[1])
		return
	//Otherwise, select one with a radial
	ShowProcessingGui(user, I, processing_recipes)

///Creates the radial and processes the selected option
/atom/proc/ShowProcessingGui(mob/living/user, obj/item/I, list/possible_options)
	var/list/choices_to_options = list() //Dict of object name | dict of object processing settings
	var/list/choices = list()

	for(var/i in possible_options)
		var/list/current_option = i
		var/atom/current_option_type = current_option[TOOL_PROCESSING_RESULT]
		choices_to_options[initial(current_option_type.name)] = current_option
		var/image/option_image = image(icon = initial(current_option_type.icon), icon_state = initial(current_option_type.icon_state))
		choices += list("[initial(current_option_type.name)]" = option_image)

	var/pick = show_radial_menu(user, src, choices, radius = 36, require_near = TRUE)

	StartProcessingAtom(user, I, choices_to_options[pick])


/atom/proc/StartProcessingAtom(mob/living/user, obj/item/process_item, list/chosen_option)
	var/processing_time = chosen_option[TOOL_PROCESSING_TIME]
	to_chat(user, span_notice("You start working on [src]"))
	if(process_item.use_tool(src, user, processing_time, volume=50))
		var/atom/atom_to_create = chosen_option[TOOL_PROCESSING_RESULT]
		var/list/atom/created_atoms = list()
		var/amount_to_create = chosen_option[TOOL_PROCESSING_AMOUNT]
		for(var/i = 1 to amount_to_create)
			var/atom/created_atom = new atom_to_create(drop_location())
			created_atom.pixel_x = pixel_x
			created_atom.pixel_y = pixel_y
			if(i > 1)
				created_atom.pixel_x += rand(-8,8)
				created_atom.pixel_y += rand(-8,8)
			created_atom.OnCreatedFromProcessing(user, process_item, chosen_option, src)
			to_chat(user, span_notice("You manage to create [chosen_option[TOOL_PROCESSING_AMOUNT]] [initial(atom_to_create.gender) == PLURAL ? "[initial(atom_to_create.name)]" : "[initial(atom_to_create.name)][plural_s(initial(atom_to_create.name))]"] from [src]."))
			created_atoms.Add(created_atom)
		SEND_SIGNAL(src, COMSIG_ATOM_PROCESSED, user, process_item, created_atoms)
		UsedforProcessing(user, process_item, chosen_option)
		return

/atom/proc/UsedforProcessing(mob/living/user, obj/item/used_item, list/chosen_option)
	qdel(src)
	return

/atom/proc/OnCreatedFromProcessing(mob/living/user, obj/item/I, list/chosen_option, atom/original_atom)
	if(user.mind)
		ADD_TRAIT(src, TRAIT_FOOD_CHEF_MADE, REF(user.mind))
	return

//! Tool-specific behavior procs.
///

/// Called on an object when a tool with crowbar capabilities is used to left click an object
/atom/proc/crowbar_act(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with crowbar capabilities is used to right click an object
/atom/proc/crowbar_act_secondary(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with multitool capabilities is used to left click an object
/atom/proc/multitool_act(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with multitool capabilities is used to right click an object
/atom/proc/multitool_act_secondary(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with screwdriver capabilities is used to left click an object
/atom/proc/screwdriver_act(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with screwdriver capabilities is used to right click an object
/atom/proc/screwdriver_act_secondary(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with wrench capabilities is used to left click an object
/atom/proc/wrench_act(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with wrench capabilities is used to right click an object
/atom/proc/wrench_act_secondary(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with wirecutter capabilities is used to left click an object
/atom/proc/wirecutter_act(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with wirecutter capabilities is used to right click an object
/atom/proc/wirecutter_act_secondary(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with welder capabilities is used to left click an object
/atom/proc/welder_act(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with welder capabilities is used to right click an object
/atom/proc/welder_act_secondary(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with analyzer capabilities is used to left click an object
/atom/proc/analyzer_act(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with analyzer capabilities is used to right click an object
/atom/proc/analyzer_act_secondary(mob/living/user, obj/item/tool)
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
		if(LOG_ECON)
			log_econ(log_text)
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
/proc/log_crafting(mob/blacksmith, object, result, dangerous = FALSE)
	var/message = "has crafted [object]"
	blacksmith.log_message(message, LOG_GAME)
	if(!dangerous)
		return
	if(isnull(locate(/datum/antagonist) in blacksmith.mind?.antag_datums))
		if(istext(result))
			message_admins("[ADMIN_LOOKUPFLW(blacksmith)] has attempted to craft [object] as a non-antagonist, but failed: [result]")
		else
			message_admins("[ADMIN_LOOKUPFLW(blacksmith)] has crafted [object] as a non-antagonist.")
/**
  * Log a combat message in the attack log
  *
  * 1 argument is the actor performing the action
  * 2 argument is the target of the action
  * 3 is a verb describing the action (e.g. punched, throwed, kicked, etc.)
  * 4 is a tool with which the action was made (usually an item)
  * 5 is any additional text, which will be appended to the rest of the log line
  * 6 if an attack isn't important, then it won't be considered for the blackbox combat log outcomes
  */
/proc/log_combat(atom/user, atom/target, what_done, object=null, addition=null, important = TRUE)
	if(isweakref(user))
		var/datum/weakref/A_ref = user
		user = A_ref.resolve()
	var/ssource = key_name(user)
	var/starget = key_name(target)
	var/datum/tool_atom = object

	var/mob/living/living_target = target
	var/hp = istype(living_target) ? " (NEWHP: [living_target.health]) " : ""
	var/stam
	if(iscarbon(living_target))
		var/mob/living/carbon/C = living_target
		stam = "(STAM: [C.getStaminaLoss()]) "

	var/sobject = ""
	if(object)
		sobject = " with [object][(istype(tool_atom) ? " ([tool_atom.type])" : "")]"
	var/saddition = ""
	if(addition)
		saddition = " [addition]"

	var/postfix = "[sobject][saddition][hp][stam]"

	var/message = "has [what_done] [starget][postfix]"
	user.log_message(message, LOG_ATTACK, color="red")

	if (important && isliving(user) && isliving(target))
		var/mob/living/living_user = user
		SScombat_logging.log_combat(living_user, living_target, istype(tool_atom) ? tool_atom.type : object)

	if(user != target)
		var/reverse_message = "has been [what_done] by [ssource][postfix]"
		target.log_message(reverse_message, LOG_ATTACK, color="orange", log_globally=FALSE)

/**
  * Log for buying items from the uplink
  *
  * [buyer]: is for the user that bought the item
  * [object]: is for the item that was purchased
  * [type]: is for the uplink type (traitor/contractor)
  * [is_bonus]: is given TRUE when an item is given for free
 */
/proc/log_uplink_purchase(mob/buyer, atom/object, type = "\improper uplink", is_bonus = FALSE)
	var/message = "has [!is_bonus ? "bought" : "received a bonus item"] [object] from \a [type]"
	buyer.log_message(message, LOG_GAME)
	if(isnull(locate(/datum/antagonist) in buyer.mind?.antag_datums))
		message_admins("[ADMIN_LOOKUPFLW(buyer)] has [!is_bonus ? "bought" : "received a bonus item"] [object] from \a [type] as a non-antagonist.")

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

/obj/item/update_filters()
	. = ..()
	update_action_buttons()

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

///Sets the custom materials for an item.
/atom/proc/set_custom_materials(var/list/materials, multiplier = 1)

	if(custom_materials) //Only runs if custom materials existed at first. Should usually be the case but check anyways
		for(var/i in custom_materials)
			var/datum/material/custom_material = SSmaterials.GetMaterialRef(i)
			custom_material.on_removed(src, custom_materials[i], material_flags) //Remove the current materials

	if(!length(materials))
		custom_materials = null
		return

	if(material_flags & MATERIAL_EFFECTS)
		for(var/x in materials)
			var/datum/material/custom_material = SSmaterials.GetMaterialRef(x)
			custom_material.on_applied(src, materials[x] * multiplier * material_modifier, material_flags)

	custom_materials = SSmaterials.FindOrCreateMaterialCombo(materials, multiplier)

/**Returns the material composition of the atom.
  *
  * Used when recycling items, specifically to turn alloys back into their component mats.
  *
  * Exists because I'd need to add a way to un-alloy alloys or otherwise deal
  * with people converting the entire stations material supply into alloys.
  *
  * Arguments:
  * - flags: A set of flags determining how exactly the materials are broken down.
  */
/atom/proc/get_material_composition(breakdown_flags=NONE)
	. = list()
	var/list/cached_materials = custom_materials
	for(var/mat in cached_materials)
		var/datum/material/material = SSmaterials.GetMaterialRef(mat)
		var/list/material_comp = material.return_composition(cached_materials[material], breakdown_flags)
		for(var/comp_mat in material_comp)
			.[comp_mat] += material_comp[comp_mat]

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
	SEND_SIGNAL(src, COMSIG_ATOM_DENSITY_CHANGED)

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
  * Used to attempt to charge an object with a payment component.
  *
  * Use this if an atom needs to attempt to charge another atom.
  */
/atom/proc/attempt_charge(var/atom/sender, var/atom/target, var/extra_fees = 0)
	return SEND_SIGNAL(sender, COMSIG_OBJ_ATTEMPT_CHARGE, target, extra_fees)

/**
* Instantiates the AI controller of this atom. Override this if you want to assign variables first.
*
* This will work fine without manually passing arguments.
+*/
/atom/proc/InitializeAIController()
	if(ai_controller)
		ai_controller = new ai_controller(src)

///Setter for the "base_pixel_x" var to append behavior related to it's changing
/atom/proc/set_base_pixel_x(var/new_value)
	if(base_pixel_x == new_value)
		return
	. = base_pixel_x
	base_pixel_x = new_value

	pixel_x = pixel_x + base_pixel_x - .

///Setter for the "base_pixel_y" var to append behavior related to it's changing
/atom/proc/set_base_pixel_y(new_value)
	if(base_pixel_y == new_value)
		return
	. = base_pixel_y
	base_pixel_y = new_value

	pixel_y = pixel_y + base_pixel_y - .

/**
 * Returns true if this atom has gravity for the passed in turf
 *
 * Sends signals [COMSIG_ATOM_HAS_GRAVITY] and [COMSIG_TURF_HAS_GRAVITY], both can force gravity with
 * the forced gravity var.
 *
 * HEY JACKASS, LISTEN
 * IF YOU ADD SOMETHING TO THIS PROC, MAKE SURE /mob/living ACCOUNTS FOR IT
 *
 * Living mobs treat gravity in an event based manner. We've decomposed this proc into different checks
 * for them to use. If you add more to it, make sure you do that, or things will behave strangely
 *
 * Gravity situations:
 * * No gravity if you're not in a turf
 * * No gravity if this atom is in is a space turf
 * * No gravity if the area has NO_GRAVITY flag (space, ordnance bomb site, nearstation, solars)
 * * Gravity if the area it's in always has gravity
 * * Gravity if there's a gravity generator on the z level
 * * Gravity if the Z level has an SSMappingTrait for ZTRAIT_GRAVITY
 * * otherwise no gravity
 */
/atom/proc/has_gravity(turf/gravity_turf)
	if(!isturf(gravity_turf))
		gravity_turf = get_turf(src)

		if(!gravity_turf)//no gravity in nullspace
			return FALSE

	var/list/forced_gravity = list()
	SEND_SIGNAL(src, COMSIG_ATOM_HAS_GRAVITY, gravity_turf, forced_gravity)
	SEND_SIGNAL(gravity_turf, COMSIG_TURF_HAS_GRAVITY, src, forced_gravity)
	if(length(forced_gravity))
		var/positive_grav = max(forced_gravity)
		var/negative_grav = min(min(forced_gravity), 0) //negative grav needs to be below or equal to 0

		//our gravity is sum of the most massive positive and negative numbers returned by the signal
		//so that adding two forced_gravity elements with an effect size of 1 each doesnt add to 2 gravity
		//but negative force gravity effects can cancel out positive ones

		return (positive_grav + negative_grav)

	var/area/turf_area = gravity_turf.loc

	return (!gravity_turf.force_no_gravity && !(turf_area.area_flags & NO_GRAVITY)) && (SSmapping.gravity_by_z_level[gravity_turf.z] || turf_area.default_gravity)

/*
* Called when something made out of plasma is exposed to high temperatures.
* Intended for use only with plasma that is ignited outside of some form of containment
* Contained plasma ignitions (such as power cells or light fixtures) should explode with proper force
*/
/atom/proc/plasma_ignition(strength, mob/user, reagent_reaction)
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/environment = T.return_air()
	if(GET_MOLES(/datum/gas/oxygen, environment) >= PLASMA_MINIMUM_OXYGEN_NEEDED) //Flashpoint ignition can only occur with at least this much oxygen present
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
		T.visible_message("<b>[span_userdanger("[src] ignites in a brilliant flash!")]</b>")
		if(reagent_reaction) // Don't qdel(src). It's a reaction inside of something (or someone) important.
			return TRUE
		else if(isturf(src))
			var/turf/srcTurf = src
			srcTurf.ScrapeAway() //Can't just qdel turfs
		else
			qdel(src)
		return TRUE
	return FALSE

//Used to exclude this atom from the psychic highlight plane
/atom/proc/generate_psychic_mask()
	var/mutable_appearance/MA = mutable_appearance()
	MA.appearance = appearance
	MA.plane = ANTI_PSYCHIC_PLANE
	add_overlay(MA)

/atom/proc/update_luminosity()
	if (isnull(base_luminosity))
		base_luminosity = initial(luminosity)

	if (_emissive_count)
		luminosity = max(1, base_luminosity)
	else
		luminosity = base_luminosity

/atom/movable/update_luminosity()
	if (isnull(base_luminosity))
		base_luminosity = initial(luminosity)

	if (UNLINT(_emissive_count))
		UNLINT(luminosity = max(max(base_luminosity, affecting_dynamic_lumi), 1))
	else
		UNLINT(luminosity = max(base_luminosity, affecting_dynamic_lumi))

#define set_base_luminosity(target, new_value)\
if (UNLINT(target.base_luminosity != new_value)) {\
	UNLINT(target.base_luminosity = new_value);\
	target.update_luminosity();\
}

/atom/movable/proc/get_orbitable()
	return src

/// Gets a merger datum representing the connected blob of objects in the allowed_types argument
/atom/proc/GetMergeGroup(id, list/allowed_types)
	RETURN_TYPE(/datum/merger)
	var/datum/merger/candidate
	if(mergers)
		candidate = mergers[id]
	if(!candidate)
		new /datum/merger(id, allowed_types, src)
		candidate = mergers[id]
	return candidate
