
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

	///Cooldown tick timer for buckle messages
	var/buckle_message_cooldown = 0
	///Last fingerprints to touch this atom
	var/fingerprintslast

	var/list/filter_data //For handling persistent filters

	/// Economy cost of item, 0 price items will not be sold and return when sent to CC trough cargo shuttle
	var/custom_price
	/// Economy cost of item in premium vendor category (Export will use this if it exists even if custom price is defined)
	var/custom_premium_price
	/// Maximum demand of the object type for exporting calculations
	var/max_demand
	/// Can be: TRADE_CONTRABAND, TRADE_NOT_SELLABLE, TRADE_DELETE_UNSOLD. Important in exporting and other things!
	var/trade_flags = NONE
	/// This is the economy price of the item. This is important for exports and imports
	var/item_price

	//List of datums orbiting this atom
	var/datum/component/orbiter/orbit_datum

	/// Radiation insulation types
	var/rad_insulation = RAD_NO_INSULATION

	///Light systems, both shouldn't be active at the same time.
	var/light_system = STATIC_LIGHT
	///Boolean variable for toggleable lights. Has no effect without the proper light_system, light_range and light_power values.
	var/light_on = TRUE
	/// How many tiles "up" this light is. 1 is typical, should only really change this if it's a floor light
	var/light_height = LIGHTING_HEIGHT
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

	///AI controller that controls this atom. type on init, then turned into an instance during runtime
	var/datum/ai_controller/ai_controller

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

	if(forensics)
		QDEL_NULL(forensics)

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
		for (var/client/client in GLOB.clients_unsafe)
			if (client.hovered_atom == src)
				client.hovered_atom = null
		hovered_user_count = 0

	return ..()

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
  * Used in objectives to identify mobs who have escaped and for some other areas of the code
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
  * Also used in objective code for win conditions
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
  * - method: How the atom is being exposed to the reagents.
  * - volume_modifier: Volume multiplier.
  * - show_message: Whether to display anything to mobs when they are exposed.
  */
/atom/proc/expose_reagents(list/reagents, datum/reagents/source, method=TOUCH, volume_modifier=1, show_message=TRUE)
	if((. = SEND_SIGNAL(src, COMSIG_ATOM_EXPOSE_REAGENTS, reagents, source, method, volume_modifier, show_message)) & COMPONENT_NO_EXPOSE_REAGENTS)
		return

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

///Return true if we're inside the passed in atom
/atom/proc/in_contents_of(container)//can take class or object instance as argument
	if(ispath(container))
		if(istype(src.loc, container))
			return TRUE
	else if(src in container)
		return TRUE
	return FALSE

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

///returns the mob's dna info as a list, to be inserted in an object's blood_DNA list
/mob/living/proc/get_blood_dna_list()
	if(get_blood_id() != /datum/reagent/blood)
		return
	return list("ANIMAL DNA" = get_blood_type("Y-"))

///Get the mobs dna list
/mob/living/carbon/get_blood_dna_list()
	if(get_blood_id() != /datum/reagent/blood)
		return
	var/list/blood_dna = list()
	if(dna)
		blood_dna[dna.unique_enzymes] = dna.blood_type
	else
		blood_dna["UNKNOWN DNA"] = get_blood_type("X")
	return blood_dna

/mob/living/carbon/alien/get_blood_dna_list()
	return list("UNKNOWN DNA" = get_blood_type("X"))

/mob/living/silicon/get_blood_dna_list()
	return list("SYNTHETIC COOLANT" = get_blood_type("Coolant"))

///to add a mob's dna info into an object's blood_dna list.
/atom/proc/transfer_mob_blood_dna(mob/living/L)
	// Returns 0 if we have that blood already
	var/new_blood_dna = L.get_blood_dna_list()
	if(!new_blood_dna)
		return FALSE
	var/old_length = GET_ATOM_BLOOD_DNA_LENGTH(src)
	add_blood_DNA(new_blood_dna)
	if(GET_ATOM_BLOOD_DNA_LENGTH(src) == old_length)
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
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_ATOM_DIR_CHANGE, dir, newdir)
	. = dir != newdir
	dir = newdir

/// Attempts to turn to the given direction. May fail if anchored/unconscious/etc.
/atom/proc/try_face(newdir)
	setDir(newdir)
	return TRUE

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
	if(SEND_SIGNAL(src, COMSIG_COMPONENT_CLEAN_ACT, clean_types))
		. = TRUE

	// Basically "if has washable coloration"
	if(length(atom_colours) >= WASHABLE_COLOUR_PRIORITY && atom_colours[WASHABLE_COLOUR_PRIORITY])
		remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
		return TRUE

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

///Connect this atom to a shuttle
/atom/proc/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override = FALSE)
	return

/// Generic logging helper
/atom/proc/log_message(message, message_type, color, log_globally = TRUE)
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

/** Update a filter's parameter to the new one. If the filter doesn't exist we won't do anything.
 *
 * Arguments:
 * * name - Filter name
 * * new_params - New parameters of the filter
 * * overwrite - TRUE means we replace the parameter list completely. FALSE means we only replace the things on new_params.
 */
/atom/proc/modify_filter(name, list/new_params, overwrite = FALSE)
	var/filter = get_filter(name)
	if(!filter)
		return
	if(overwrite)
		filter_data[name] = new_params
	else
		for(var/thing in new_params)
			filter_data[name][thing] = new_params[thing]
	update_filters()

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

///Called after the atom is 'tamed' for type-specific operations, Usually called by the tameable component but also other things.
/atom/proc/tamed(mob/living/tamer, obj/item/food)
	return

/**
  * Used to attempt to charge an object with a payment component.
  *
  * Use this if an atom needs to attempt to charge another atom.
  */
/atom/proc/attempt_charge(atom/sender, atom/target, extra_fees = 0)
	return SEND_SIGNAL(sender, COMSIG_OBJ_ATTEMPT_CHARGE, target, extra_fees)

///Setter for the "base_pixel_x" var to append behavior related to it's changing
/atom/proc/set_base_pixel_x(new_value)
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
 * micro-optimized to hell because this proc is very hot, being called several times per movement every movement.
 *
 * HEY JACKASS, LISTEN
 * IF YOU ADD SOMETHING TO THIS PROC, MAKE SURE /mob/living ACCOUNTS FOR IT
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

/atom/movable/proc/get_orbitable()
	return src
