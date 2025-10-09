/**
  * Delete a mob
  *
  * Removes mob from the following global lists
  * * GLOB.mob_list
  * * GLOB.dead_mob_list
  * * GLOB.alive_mob_list
  * * GLOB.all_clockwork_mobs
  * * GLOB.mob_directory
  *
  * Unsets the focus var
  *
  * Clears alerts for this mob
  *
  * Resets all the observers perspectives to the tile this mob is on
  *
  * qdels any client colours in place on this mob
  *
  * Clears any refs to the mob inside its current location
  *
  * Ghostizes the client attached to this mob
  *
  * If our mind still exists, clear its current var to prevent harddels
  *
  * Parent call
  */
/mob/Destroy()//This makes sure that mobs with clients/keys are not just deleted from the game.
	remove_from_mob_list()
	remove_from_dead_mob_list()
	remove_from_alive_mob_list()
	remove_from_mob_suicide_list()
	remove_from_disconnected_mob_list()

	focus = null
	if(length(progressbars))
		stack_trace("[src] destroyed with elements in its progressbars list")
		progressbars = null
	for (var/alert in alerts)
		clear_alert(alert, TRUE)
	if(observers?.len)
		for(var/mob/dead/observe as anything in observers)
			observe.reset_perspective(null)
	qdel(hud_used)
	for(var/cc in client_colours)
		qdel(cc)
	client_colours = null
	ghostize()
	if(mind?.current == src) //Let's just be safe yeah? This will occasionally be cleared, but not always. Can't do it with ghostize without changing behavior
		mind.set_current(null)
	return ..()

/mob/New()
	// This needs to happen IMMEDIATELY. I'm sorry :(
	GenerateTag()
	return ..()

/**
  * Intialize a mob
  *
  * Sends global signal COMSIG_GLOB_MOB_CREATED
  *
  * Adds to global lists
  * * GLOB.mob_list
  * * GLOB.mob_directory (by tag)
  * * GLOB.dead_mob_list - if mob is dead
  * * GLOB.alive_mob_list - if the mob is alive
  *
  * Other stuff:
  * * Sets the mob focus to itself
  * * Generates huds
  * * If there are any global alternate apperances apply them to this mob
  * * set a random nutrition level
  * * Intialize the movespeed of the mob
  */
/mob/Initialize(mapload)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_MOB_CREATED, src)
	mob_properties = list()
	add_to_mob_list()
	if(stat == DEAD)
		add_to_dead_mob_list()
	else
		add_to_alive_mob_list()
	set_focus(src)
	prepare_huds()
	for(var/v in GLOB.active_alternate_appearances)
		if(!v)
			continue
		var/datum/atom_hud/alternate_appearance/AA = v
		AA.onNewMob(src)

	set_nutrition(rand(NUTRITION_LEVEL_START_MIN, NUTRITION_LEVEL_START_MAX))
	. = ..()
	update_config_movespeed()
	initialize_actionspeed()
	update_movespeed(TRUE)
	//Give verbs to stat
	add_verb(verbs, TRUE)
	become_hearing_sensitive()

/**
  * Generate the tag for this mob
  *
  * This is simply "mob_"+ a global incrementing counter that goes up for every mob
  */
/mob/GenerateTag()
	tag = "mob_[next_mob_id++]"

/**
  * Prepare the huds for this atom
  *
  * Goes through hud_possible list and adds the images to the hud_list variable (if not already
  * cached)
  */
/atom/proc/prepare_huds()
	hud_list = list()
	for(var/hud in hud_possible)
		var/hint = hud_possible[hud]
		switch(hint)
			if(HUD_LIST_LIST)
				hud_list[hud] = list()
			else
				var/image/I = image('icons/mob/hud.dmi', src, "")
				I.appearance_flags = RESET_COLOR|RESET_TRANSFORM
				I.plane = DATA_HUD_PLANE
				hud_list[hud] = I

/**
  * Some kind of debug verb that gives atmosphere environment details
  */
/mob/proc/Cell()
	set category = "Admin"
	set hidden = 1

	if(!loc)
		return 0

	var/datum/gas_mixture/environment = loc.return_air()

	var/t =	span_notice("Coordinates: [x],[y] \n")
	t +=	span_danger("Temperature: [environment.return_temperature()] \n")
	for(var/id in environment.gases)
		if(environment.gases[id][MOLES])
			t+=span_notice("[GLOB.meta_gas_info[id][META_GAS_NAME]]: [environment.gases[id][MOLES]] \n")

	to_chat(usr, t)

/**
  * Return the desc of this mob for a photo
  */
/mob/proc/get_photo_description(obj/item/camera/camera)
	return "You can also see a ... thing?"

/**
  * Show a message to this mob (visual or audible)
  */
/mob/proc/show_message(msg, type, alt_msg, alt_type, avoid_highlighting = FALSE, dist)//Message, type of message (1 or 2), alternative message, alt message type (1 or 2)

	if(!client)
		return FALSE

	msg = copytext_char(msg, 1, MAX_MESSAGE_LEN)

	// Return TRUE if we sent the original msg, otherwise return FALSE
	. = TRUE
	if(type)
		if(type & MSG_VISUAL && (is_blind() && dist > BLIND_TEXT_DIST))//Vision related
			if(!alt_msg)
				return FALSE
			else
				msg = alt_msg
				type = alt_type
				. = FALSE

		if(type & MSG_AUDIBLE && !can_hear())//Hearing related
			if(!alt_msg)
				return FALSE
			else
				msg = alt_msg
				type = alt_type
				. = FALSE
				if(type & MSG_VISUAL && is_blind())
					return FALSE
	// voice muffling
	if(stat == UNCONSCIOUS || stat == HARD_CRIT)
		if(type & MSG_AUDIBLE) //audio
			to_chat(src, "<I>... You can almost hear something ...</I>")
		return
	to_chat(src, msg, avoid_highlighting = avoid_highlighting)
	return .


/atom/proc/visible_message(message, self_message, blind_message, vision_distance = DEFAULT_MESSAGE_RANGE, list/ignored_mobs, list/visible_message_flags, allow_inside_usr = FALSE, separation = " ")
	var/turf/T = get_turf(src)
	if(!T)
		return

	if(!islist(ignored_mobs))
		ignored_mobs = list(ignored_mobs)

	var/list/hearers = hearers(vision_distance, T) //caches the hearers and then removes ignored mobs.
	hearers -= ignored_mobs

	if(self_message)
		hearers -= src

	var/raw_msg = message
	var/is_emote = FALSE
	if(LAZYFIND(visible_message_flags, CHATMESSAGE_EMOTE))
		message = span_emote("<b>[src]</b>[separation][message]")
		is_emote = TRUE

	var/list/show_to = list()

	for(var/mob/M as() in hearers)
		if(!M.client)
			continue

		var/msg = message
		if(M.see_invisible < invisibility)//if src is invisible to M
			msg = blind_message
		else if(T != loc && T != src) //if src is inside something and not a turf.
			if(!allow_inside_usr || loc != usr)
				msg = blind_message
		else if(T.lighting_object && T.lighting_object.invisibility <= M.see_invisible && T.is_softly_lit() && !in_range(T,M)) //if it is too dark.
			msg = blind_message
		if(!msg)
			continue

		if(is_emote && M.should_show_chat_message(src, null, TRUE))
			if(M.is_blind() && get_dist(M, src) > BLIND_TEXT_DIST)
				continue
			show_to += M

		M.show_message(msg, MSG_VISUAL, blind_message, MSG_AUDIBLE, avoid_highlighting = M == src)

	//Create the chat message
	if(length(show_to))
		create_chat_message(src, null, show_to, raw_msg, null, visible_message_flags)

/mob/visible_message(message, self_message, blind_message, vision_distance = DEFAULT_MESSAGE_RANGE, list/ignored_mobs, list/visible_message_flags, allow_inside_usr = FALSE, separation = " ")
	. = ..()
	if(!self_message)
		return
	var/raw_self_message = self_message
	var/self_runechat = FALSE
	if(LAZYFIND(visible_message_flags, CHATMESSAGE_EMOTE))
		self_message = span_emote("<b>[src]</b> [self_message]") // May make more sense as "You do x"

	if(LAZYFIND(visible_message_flags, ALWAYS_SHOW_SELF_MESSAGE))
		to_chat(src, self_message)
		self_runechat = TRUE

	else
		self_runechat = show_message(self_message, MSG_VISUAL, blind_message, MSG_AUDIBLE)

	if(self_runechat && (LAZYFIND(visible_message_flags, CHATMESSAGE_EMOTE)) && runechat_prefs_check(src, visible_message_flags))
		create_chat_message(src, null, list(src), raw_message = raw_self_message, message_mods = visible_message_flags)

/**
  * Show a message to all mobs in earshot of this atom
  *
  * Use for objects performing audible actions
  *
  * vars:
  * * message is the message output to anyone who can hear.
  * * self_message (optional) is what the src mob hears.
  * * deaf_message (optional) is what deaf people will see.
  * * hearing_distance (optional) is the range, how many tiles away the message can be heard.
  */
/atom/proc/audible_message(message, deaf_message, hearing_distance = DEFAULT_MESSAGE_RANGE, self_message, list/audible_message_flags, separation = " ")
	var/list/hearers = get_hearers_in_view(hearing_distance, src, SEE_INVISIBLE_MAXIMUM)
	if(self_message)
		hearers -= src

	var/raw_msg = message
	var/is_emote = FALSE
	if(LAZYFIND(audible_message_flags, CHATMESSAGE_EMOTE))
		is_emote = TRUE
		message = span_emote("<b>[src]</b>[separation][message]")

	var/list/show_to = list()
	for(var/mob/M in hearers)
		if(is_emote && M.should_show_chat_message(src, null, TRUE, is_heard = TRUE))
			show_to += M
		M.show_message(message, MSG_AUDIBLE, deaf_message, MSG_VISUAL)

	if(length(show_to))
		create_chat_message(src, null, show_to, raw_message = raw_msg, spans = list("italics"), message_mods = audible_message_flags)

/**
  * Show a message to all mobs in earshot of this one
  *
  * This would be for audible actions by the src mob
  *
  * vars:
  * * message is the message output to anyone who can hear.
  * * self_message (optional) is what the src mob hears.
  * * deaf_message (optional) is what deaf people will see.
  * * hearing_distance (optional) is the range, how many tiles away the message can be heard.
  */
/mob/audible_message(message, deaf_message, hearing_distance = DEFAULT_MESSAGE_RANGE, self_message, list/audible_message_flags, separation = " ")
	. = ..()
	if(!self_message)
		return

	var/raw_self_message = self_message
	var/self_runechat = FALSE
	if(LAZYFIND(audible_message_flags, CHATMESSAGE_EMOTE))
		self_message = span_emote("<b>[src]</b> [self_message]")
	if(LAZYFIND(audible_message_flags, ALWAYS_SHOW_SELF_MESSAGE))
		to_chat(src, self_message)
		self_runechat = TRUE
	else
		self_runechat = show_message(self_message, MSG_AUDIBLE, deaf_message, MSG_VISUAL)

	if(self_runechat && (LAZYFIND(audible_message_flags, CHATMESSAGE_EMOTE)) && runechat_prefs_check(src, audible_message_flags))
		create_chat_message(src, null, list(src), raw_message = raw_self_message, message_mods = audible_message_flags)

///Returns the client runechat visible messages preference according to the message type.
/atom/proc/runechat_prefs_check(mob/target, list/visible_message_flags)
	if(!target.client?.prefs.read_player_preference(/datum/preference/toggle/enable_runechat))
		return FALSE
	if (!target.client?.prefs.read_player_preference(/datum/preference/toggle/enable_runechat_non_mobs))
		return FALSE
	if((LAZYFIND(visible_message_flags, CHATMESSAGE_EMOTE)) && !target.client.prefs.read_player_preference(/datum/preference/toggle/see_rc_emotes))
		return FALSE
	return TRUE

/mob/runechat_prefs_check(mob/target, list/visible_message_flags)
	if(!target.client?.prefs.read_player_preference(/datum/preference/toggle/enable_runechat))
		return FALSE
	if((LAZYFIND(visible_message_flags, CHATMESSAGE_EMOTE)) && !target.client.prefs.read_player_preference(/datum/preference/toggle/see_rc_emotes))
		return FALSE
	return TRUE

///Get the item on the mob in the storage slot identified by the id passed in
/mob/proc/get_item_by_slot(slot_id)
	return null

/// Gets what slot the item on the mob is held in.
/// Returns null if the item isn't in any slots on our mob.
/// Does not check if the passed item is null, which may result in unexpected outcoms.
/mob/proc/get_slot_by_item(obj/item/looking_for)
	if(looking_for in held_items)
		return ITEM_SLOT_HANDS
	return null

///Is the mob incapacitated
/mob/proc/incapacitated(flags)
	return

/**
  * This proc is called whenever someone clicks an inventory ui slot.
  *
  * Mostly tries to put the item into the slot if possible, or call attack hand
  * on the item in the slot if the users active hand is empty
  */
/mob/proc/attack_ui(slot, params)
	if(world.time <= usr.next_move)
		return FALSE
	if(HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return FALSE
	var/obj/item/W = get_active_held_item()
	if(istype(W))
		//IF HELD TRY APPLY TO SLOT
		if(equip_to_slot_if_possible(W, slot,0,0,0))
			W.apply_outline()
			return TRUE
	//IF NO ITEM IS HELD, APPLY TO SLOT
	if(!W)
		// Activate the item
		var/obj/item/I = get_item_by_slot(slot)
		if(istype(I))
			var/list/modifiers = params2list(params)
			I.attack_hand(src, modifiers)

	return FALSE

/**
  * Try to equip an item to a slot on the mob
  *
  * This is a SAFE proc. Use this instead of equip_to_slot()!
  *
  * set qdel_on_fail to have it delete W if it fails to equip
  *
  * set disable_warning to disable the 'you are unable to equip that' warning.
  *
  * unset redraw_mob to prevent the mob icons from being redrawn at the end.
  */
/mob/proc/equip_to_slot_if_possible(obj/item/W, slot, qdel_on_fail = FALSE, disable_warning = FALSE, redraw_mob = TRUE, bypass_equip_delay_self = FALSE, initial = FALSE)
	if(!istype(W))
		return FALSE
	if(!W.mob_can_equip(src, null, slot, disable_warning, bypass_equip_delay_self))
		if(qdel_on_fail)
			qdel(W)
		else if(!disable_warning)
			to_chat(src, span_warning("You are unable to equip that!"))
		return FALSE
	equip_to_slot(W, slot, initial, redraw_mob) //This proc should not ever fail.
	return TRUE

/**
  * Actually equips an item to a slot (UNSAFE)
  *
  * This is an UNSAFE proc. It merely handles the actual job of equipping. All the checks on
  * whether you can or can't equip need to be done before! Use mob_can_equip() for that task.
  *
  *In most cases you will want to use equip_to_slot_if_possible()
  */
/mob/proc/equip_to_slot(obj/item/W, slot)
	return

/**
  * Equip an item to the slot or delete
  *
  * This is just a commonly used configuration for the equip_to_slot_if_possible() proc, used to
  * equip people when the round starts and when events happen and such.
  *
  * Also bypasses equip delay checks, since the mob isn't actually putting it on.
  */
/mob/proc/equip_to_slot_or_del(obj/item/W, slot, initial = FALSE)
	return equip_to_slot_if_possible(W, slot, TRUE, TRUE, FALSE, TRUE, initial)

/**
  * Auto equip the passed in item the appropriate slot based on equipment priority
  *
  * puts the item "W" into an appropriate slot in a human's inventory
  *
  * returns 0 if it cannot, 1 if successful
  */
/mob/proc/equip_to_appropriate_slot(obj/item/W, qdel_on_fail = FALSE)
	if(!istype(W))
		return FALSE
	var/slot_priority = W.slot_equipment_priority

	if(!slot_priority)
		slot_priority = list( \
			ITEM_SLOT_BACK, ITEM_SLOT_ID,\
			ITEM_SLOT_ICLOTHING, ITEM_SLOT_OCLOTHING,\
			ITEM_SLOT_MASK, ITEM_SLOT_HEAD, ITEM_SLOT_NECK,\
			ITEM_SLOT_FEET, ITEM_SLOT_GLOVES,\
			ITEM_SLOT_EARS, ITEM_SLOT_EYES,\
			ITEM_SLOT_BELT, ITEM_SLOT_SUITSTORE,\
			ITEM_SLOT_LPOCKET, ITEM_SLOT_RPOCKET,\
			ITEM_SLOT_DEX_STORAGE\
		)

	for(var/slot in slot_priority)
		if(equip_to_slot_if_possible(W, slot, FALSE, TRUE, TRUE, FALSE, FALSE)) //qdel_on_fail = FALSE; disable_warning = TRUE; redraw_mob = TRUE;
			return TRUE

	if(qdel_on_fail)
		qdel(W)
	return FALSE

// Convinience proc.  Collects crap that fails to equip either onto the mob's back, or drops it.
// Used in job equipping so shit doesn't pile up at the start loc.
/mob/living/carbon/human/proc/equip_or_collect(obj/item/W, slot)
	if(W.mob_can_equip(src, null, slot, TRUE, TRUE))
		//Mob can equip.  Equip it.
		equip_to_slot_or_del(W, slot)
	else
		//Mob can't equip it.  Put it in a bag B.
		// Do I have a backpack?
		var/obj/item/storage/B
		if(istype(back,/obj/item/storage))
			//Mob is wearing backpack
			B = back
		else
			//not wearing backpack.  Check if player holding box
			if(!is_holding_item_of_type(/obj/item/storage/box)) //If not holding box, give box
				B = new /obj/item/storage/box(null) // Null in case of failed equip.
				if(!put_in_hands(B))
					return // box could not be placed in players hands.  I don't know what to do here...
			//Now, B represents a container we can insert W into.
			if(B.atom_storage.can_insert(W))
				B.atom_storage.attempt_insert(W)
			return B

/**
 * Reset the attached clients perspective (viewpoint)
 *
 * reset_perspective(null) set eye to common default : mob on turf, loc otherwise
 * reset_perspective(thing) set the eye to the thing (if it's equal to current default reset to mob perspective)
 */
/mob/proc/reset_perspective(atom/new_eye)
	SHOULD_CALL_PARENT(TRUE)
	/*
	*In the future, this signal may need to be moved to the end of the proc, after the eye has been given a chance to fully updated.
	*No issues atm, but if one occurs, try that solution first
	*/
	SEND_SIGNAL(src, COMSIG_MOB_RESET_PERSPECTIVE)
	if(!client)
		return

	if(new_eye)
		if(ismovable(new_eye))
			//Set the new eye unless it's us
			if(new_eye != src)
				client.perspective = EYE_PERSPECTIVE
				client.set_eye(new_eye)
			else
				client.set_eye(client.mob)
				client.perspective = MOB_PERSPECTIVE

		else if(isturf(new_eye))
			//Set to the turf unless it's our current turf
			if(new_eye != loc)
				client.perspective = EYE_PERSPECTIVE
				client.set_eye(new_eye)
			else
				client.set_eye(client.mob)
				client.perspective = MOB_PERSPECTIVE
		else
			return TRUE //no setting eye to stupid things like areas or whatever
	else
		//Reset to common defaults: mob if on turf, otherwise current loc
		if(isturf(loc))
			client.set_eye(client.mob)
			client.perspective = MOB_PERSPECTIVE
		else
			client.perspective = EYE_PERSPECTIVE
			client.set_eye(loc)
	return TRUE

/**
  * Examine a mob
  *
  * mob verbs are faster than object verbs. See
  * [this byond forum post](https://secure.byond.com/forum/?post=1326139&page=2#comment8198716)
  * for why this isn't atom/verb/examine()
  */
/mob/verb/examinate(atom/examinify as mob|obj|turf in view()) //It used to be oview(12), but I can't really say why
	set name = "Examine"
	set category = "IC"

	if(isturf(examinify) && !(sight & SEE_TURFS) && !(examinify in view(client ? client.view : world.view, src)))
		// shift-click catcher may issue examinate() calls for out-of-sight turfs
		return

	if(is_blind(src) && !blind_examine_check(examinify))
		return

	face_atom(examinify)
	var/list/result
	if(client)
		LAZYINITLIST(client.recent_examines)
		var/ref_to_atom = ref(examinify)
		var/examine_time = client.recent_examines[ref_to_atom]
		if(examine_time && (world.time - examine_time < EXAMINE_MORE_WINDOW))
			result = examinify.examine_more(src)
			if(!length(result))
				result += span_notice("<i>You examine [examinify] closer, but find nothing of interest...</i>")
		else
			result = examinify.examine(src)
			SEND_SIGNAL(src, COMSIG_MOB_EXAMINING, examinify, result)
			client.recent_examines[ref_to_atom] = world.time // set to when we last normal examine'd them
			addtimer(CALLBACK(src, PROC_REF(clear_from_recent_examines), ref_to_atom), RECENT_EXAMINE_MAX_WINDOW)
	else
		result = examinify.examine(src) // if a tree is examined but no client is there to see it, did the tree ever really exist?

	if(result.len)
		for(var/i in 1 to (length(result) - 1))
			result[i] += "\n"

	to_chat(src, examine_block("<span class='infoplain'>[result.Join()]</span>"))
	SEND_SIGNAL(src, COMSIG_MOB_EXAMINATE, examinify)

/mob/proc/blind_examine_check(atom/examined_thing)
	return TRUE

/mob/living/blind_examine_check(atom/examined_thing)
	//need to be next to something and awake
	if(!Adjacent(examined_thing) || incapacitated())
		to_chat(src, span_warning("Something is there, but you can't see it!"))
		return FALSE

	var/active_item = get_active_held_item()
	if(active_item && active_item != examined_thing)
		to_chat(src, span_warning("Your hands are too full to examine this!"))
		return FALSE

	//you can only initiate exaimines if you have a hand, it's not disabled, and only as many examines as you have hands
	/// our active hand, to check if it's disabled/detatched
	var/obj/item/bodypart/active_hand = has_active_hand()? get_active_hand() : null
	if(!active_hand || active_hand.bodypart_disabled || do_after_count() >= usable_hands)
		to_chat(src, span_warning("You don't have a free hand to examine this!"))
		return FALSE

	//you can only queue up one examine on something at a time
	if(DOING_INTERACTION_WITH_TARGET(src, examined_thing))
		return FALSE

	to_chat(src, span_notice("You start feeling around for something..."))
	visible_message(span_notice(" [name] begins feeling around for \the [examined_thing.name]..."))

	/// how long it takes for the blind person to find the thing they're examining
	var/examine_delay_length = rand(1 SECONDS, 2 SECONDS)
	if(client?.recent_examines && client?.recent_examines[ref(examined_thing)]) //easier to find things we just touched
		examine_delay_length = 0.33 SECONDS
	else if(isobj(examined_thing))
		examine_delay_length *= 1.5
	else if(ismob(examined_thing) && examined_thing != src)
		examine_delay_length *= 2

	if(examine_delay_length > 0 && !do_after(src, examine_delay_length, target = examined_thing))
		to_chat(src, span_notice("You can't get a good feel for what is there."))
		return FALSE

	//now we touch the thing we're examining
	/// our current intent, so we can go back to it after touching
	var/previous_combat_mode = combat_mode
	set_combat_mode(FALSE)
	examined_thing.attack_hand(src)
	set_combat_mode(previous_combat_mode)
	return TRUE

/mob/proc/clear_from_recent_examines(ref_to_clear)
	SIGNAL_HANDLER
	if(!client)
		return
	LAZYREMOVE(client.recent_examines, ref_to_clear)

/**
  * Called by using Activate Held Object with an empty hand/limb
  *
  * Does nothing by default. The intended use is to allow limbs to call their
  * own attack_self procs. It is up to the individual mob to override this
  * parent and actually use it.
  */
/mob/proc/limb_attack_self()
	return

///Can this mob resist (default FALSE)
/mob/proc/can_resist()
	return FALSE		//overridden in living.dm

///Spin this mob around it's central axis
/mob/proc/spin(spintime, speed)
	set waitfor = 0
	var/D = dir
	if((spintime < 1)||(speed < 1)||!spintime||!speed)
		return
	while(spintime >= speed)
		sleep(speed)
		switch(D)
			if(NORTH)
				D = EAST
			if(SOUTH)
				D = WEST
			if(EAST)
				D = SOUTH
			if(WEST)
				D = NORTH
		setDir(D)
		spintime -= speed

///Update the pulling hud icon
/mob/proc/update_pull_hud_icon()
	hud_used?.pull_icon?.update_icon()

///Update the resting hud icon
/mob/proc/update_rest_hud_icon()
	hud_used?.rest_icon?.update_icon()

/**
  * Verb to activate the object in your held hand
  *
  * Calls attack self on the item and updates the inventory hud for hands
  */
/mob/verb/mode()
	set name = "Activate Held Object"
	set category = "Object"
	set src = usr

	if(isnewplayer(src))
		return

	if(ismecha(loc))
		return

	if(incapacitated())
		return

	var/obj/item/I = get_active_held_item()
	if(I)
		I.attack_self(src)
		update_held_items()
		return

	limb_attack_self()


/**
  * Get the notes of this mob
  *
  * This actually gets the mind datums notes
  */
/mob/verb/memory()
	set name = "Notes"
	set category = "IC"
	set desc = "View your character's notes memory."
	if(mind)
		mind.show_memory(src)
	else
		to_chat(src, "You don't have a mind datum for some reason, so you can't look at your notes, if you had any.")

/**
  * Add a note to the mind datum
  */
/mob/verb/add_memory(msg as message)
	set name = "Add Note"
	set category = "IC"
	if(mind)
		if (world.time < memory_throttle_time)
			return
		memory_throttle_time = world.time + 5 SECONDS
		msg = copytext_char(msg, 1, MAX_MESSAGE_LEN)
		msg = sanitize(msg)

		mind.store_memory(msg)
	else
		to_chat(src, "You don't have a mind datum for some reason, so you can't add a note to it.")

/**
  * Allows you to respawn, abandoning your current mob
  *
  * This sends you back to the lobby creating a new dead mob
  *
  * Only works if flag/norespawn is allowed in config
  */
/mob/verb/abandon_mob()
	set name = "Respawn"
	set category = "OOC"
	if(isnewplayer(src))
		return
	var/alert_yes

	if (CONFIG_GET(flag/norespawn))
		if(!check_rights_for(client, R_ADMIN))
			to_chat(usr, span_boldnotice("Respawning is disabled."))
			return
		alert_yes = alert(src, "Do you want to use your admin privilege to respawn? (Respawning is currently disabled)", "Options", "Yes", "No")
		if(alert_yes != "Yes")
			return

	if ((stat != DEAD || !( SSticker )))
		to_chat(usr, span_boldnotice("You must be dead to use this!"))
		return

	log_game("[key_name(usr)] used abandon mob.")

	to_chat(usr, span_boldnotice("Please roleplay correctly!"))

	if(!client)
		log_game("[key_name(usr)] AM failed due to disconnect.")
		return
	client.screen.Cut()
	client.screen += client.void
	if(!client)
		log_game("[key_name(usr)] AM failed due to disconnect.")
		return

	var/mob/dead/new_player/M = new /mob/dead/new_player()
	if(!client)
		log_game("[key_name(usr)] AM failed due to disconnect.")
		qdel(M)
		return
	if(alert_yes)
		log_admin("[key_name(usr)] has used admin privilege to respawn themselves back to the Lobby.")
		message_admins("[key_name(usr)] has used admin privilege to respawn themselves back to the Lobby.")

	M.key = key
//	M.Login()	//wat
	return


/**
  * Sometimes helps if the user is stuck in another perspective or camera
  */
/mob/verb/cancel_camera()
	set name = "Cancel Camera View"
	set category = "OOC"
	reset_perspective(null)
	unset_machine()

//suppress the .click/dblclick macros so people can't use them to identify the location of items or aimbot
/mob/verb/DisClick(argu = null as anything, sec = "" as text, number1 = 0 as num  , number2 = 0 as num)
	set name = ".click"
	set hidden = TRUE
	set category = null
	return

/mob/verb/DisDblClick(argu = null as anything, sec = "" as text, number1 = 0 as num  , number2 = 0 as num)
	set name = ".dblclick"
	set hidden = TRUE
	set category = null
	return

/**
  * Controls if a mouse drop succeeds (return null if it doesnt)
  */
/mob/MouseDrop(mob/M)
	. = ..()
	if(M != usr)
		return
	if(usr == src)
		return
	if(!Adjacent(usr))
		return
	if(isAI(M))
		return

///Is the mob muzzled (default false)
/mob/proc/is_muzzled()
	return FALSE

/datum/action/proc/get_stat_label()
	var/label = ""
	var/time_left = max(next_use_time - world.time, 0)
	if (cooldown_time)
		if(istype(src, /datum/action/spell))
			var/datum/action/spell/spell = src
			label = "Spell Level: [spell.spell_level]/[spell.spell_max_level], Spell Cooldown: [(spell.cooldown_time/10)] Seconds, Can be cast in [(time_left/10)]"
		else
			label = "Action Cooldown: [(cooldown_time/10)] Seconds,  Can be cast in [(time_left/10)]"
	else
		label = "Activate"
	return label

/datum/action/proc/update_stat_status(list/stat)
	return null

#define MOB_FACE_DIRECTION_DELAY 1

// facing verbs
/**
  * Returns true if a mob can turn to face things
  *
  * Conditions:
  * * client.last_turn > world.time
  * * not dead or unconscious
  * * not anchored
  * * no transform not set
  * * we are not restrained
  */
/mob/proc/canface()
	if(world.time < client.last_turn)
		return FALSE
	if(stat >= UNCONSCIOUS)
		return FALSE
	if(anchored)
		return FALSE
	if(notransform)
		return FALSE
	if(HAS_TRAIT(src, TRAIT_RESTRAINED))
		return FALSE
	return TRUE

///Checks mobility move as well as parent checks
/mob/living/canface()
	if(!(mobility_flags & MOBILITY_MOVE))
		return FALSE
	return ..()

/mob/dead/observer/canface()
	return TRUE

/mob/try_face(newdir)
	if(!canface())
		return FALSE
	. = ..()
	if(.)
		client.last_turn = world.time + MOB_FACE_DIRECTION_DELAY

/mob/proc/swap_hand()
	var/obj/item/held_item = get_active_held_item()
	if(SEND_SIGNAL(src, COMSIG_MOB_SWAP_HANDS, held_item) & COMPONENT_BLOCK_SWAP)
		to_chat(src, span_warning("Your other hand is too busy holding [held_item]."))
		return FALSE
	return TRUE

/mob/proc/activate_hand(selhand)
	return

/mob/proc/assess_threat(judgment_criteria, lasercolor = "", datum/callback/weaponcheck=null) //For sec bot threat assessment
	return 0

///Get the ghost of this mob (from the mind)
/mob/proc/get_ghost(even_if_they_cant_reenter, ghosts_with_clients)
	if(mind)
		return mind.get_ghost(even_if_they_cant_reenter, ghosts_with_clients)

///Force get the ghost from the mind
/mob/proc/grab_ghost(force)
	if(mind)
		return mind.grab_ghost(force = force)

///Notify a ghost that it's body is being cloned
/mob/proc/notify_ghost_cloning(message = "Someone is trying to revive you. Re-enter your corpse if you want to be revived!", sound = 'sound/effects/genetics.ogg', atom/source = null, flashwindow)
	var/mob/dead/observer/ghost = get_ghost()
	if(ghost)
		ghost.notify_cloning(message, sound, source, flashwindow)
		return ghost

/**
 * Checks to see if the mob can block magic
 *
 * args:
 * * casted_magic_flags (optional) A bitfield with the types of magic resistance being checked (see flags at: /datum/component/anti_magic)
 * * charge_cost (optional) The cost of charge to block a spell that will be subtracted from the protection used
**/
/mob/proc/can_block_magic(casted_magic_flags = MAGIC_RESISTANCE, charge_cost = 1)
	if(casted_magic_flags == NONE) // magic with the NONE flag is immune to blocking
		return FALSE

	// A list of all things which are providing anti-magic to us
	var/list/antimagic_sources = list()
	var/is_magic_blocked = FALSE

	if(SEND_SIGNAL(src, COMSIG_MOB_RECEIVE_MAGIC, casted_magic_flags, charge_cost, antimagic_sources) & COMPONENT_MAGIC_BLOCKED)
		is_magic_blocked = TRUE
	if(HAS_TRAIT(src, TRAIT_ANTIMAGIC))
		is_magic_blocked = TRUE
	if((casted_magic_flags & MAGIC_RESISTANCE_HOLY) && HAS_TRAIT(src, TRAIT_HOLY))
		is_magic_blocked = TRUE

	if(is_magic_blocked && charge_cost > 0 && !HAS_TRAIT(src, TRAIT_RECENTLY_BLOCKED_MAGIC))
		on_block_magic_effects(casted_magic_flags, antimagic_sources)

	return is_magic_blocked

/// Called whenever a magic effect with a charge cost is blocked and we haven't recently blocked magic.
/mob/proc/on_block_magic_effects(magic_flags, list/antimagic_sources)
	return

/mob/proc/antimagic_trait_handler()
	REMOVE_TRAIT(src, TRAIT_RECENTLY_BLOCKED_MAGIC, MAGIC_TRAIT)

/mob/living/on_block_magic_effects(magic_flags, list/antimagic_sources)
	ADD_TRAIT(src, TRAIT_RECENTLY_BLOCKED_MAGIC, MAGIC_TRAIT)
	addtimer(CALLBACK(src, PROC_REF(antimagic_trait_handler)), 6 SECONDS)
	var/mutable_appearance/antimagic_effect
	var/antimagic_color
	var/atom/antimagic_source = length(antimagic_sources) ? pick(antimagic_sources) : src

	if(magic_flags & MAGIC_RESISTANCE)
		visible_message(
			"<span class='warning'>[src] pulses red as [ismob(antimagic_source) ? p_they() : antimagic_source] absorbs magic energy!</span>",
			"<span class='userdanger'>An intense magical aura pulses around [ismob(antimagic_source) ? "you" : antimagic_source] as it dissipates into the air!</span>",
		)
		antimagic_effect = mutable_appearance('icons/effects/effects.dmi', "shield-red", MOB_SHIELD_LAYER)
		antimagic_color = LIGHT_COLOR_BLOOD_MAGIC
		playsound(src, 'sound/magic/magic_block.ogg', 50, TRUE)

	else if(magic_flags & MAGIC_RESISTANCE_HOLY)
		visible_message(
			("<span class='warning'>[src] starts to glow as [ismob(antimagic_source) ? p_they() : antimagic_source] emits a halo of light!</span>"),
			("<span class='userdanger'>A feeling of warmth washes over [ismob(antimagic_source) ? "you" : antimagic_source] as rays of light surround your body and protect you!</span>"),
		)
		antimagic_effect = mutable_appearance('icons/mob/effects/genetics.dmi', "servitude", -MUTATIONS_LAYER)
		antimagic_color = LIGHT_COLOR_HOLY_MAGIC
		playsound(src, 'sound/magic/magic_block_holy.ogg', 50, TRUE)

	else if(magic_flags & MAGIC_RESISTANCE_MIND)
		visible_message(
			("<span class='warning'>[src] forehead shines as [ismob(antimagic_source) ? p_they() : antimagic_source] repulses magic from their mind!</span>"),
			("<span class='userdanger'>A feeling of cold splashes on [ismob(antimagic_source) ? "you" : antimagic_source] as your forehead reflects magic usering your mind!</span>"),
		)
		antimagic_effect = mutable_appearance('icons/mob/effects/genetics.dmi', "telekinesishead", MOB_SHIELD_LAYER)
		antimagic_color = LIGHT_COLOR_DARK_BLUE
		playsound(src, 'sound/magic/magic_block_mind.ogg', 50, TRUE)

	mob_light(range = 2, color = antimagic_color, duration = 5 SECONDS)
	add_overlay(antimagic_effect)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, cut_overlay), antimagic_effect), 5 SECONDS)

/**
 * Checks to see if the mob can cast normal magic spells.
 *
 * args:
 * * magic_flags (optional) A bitfield with the type of magic being cast (see flags at: /datum/component/anti_magic)
**/
/mob/proc/can_cast_magic(magic_flags = MAGIC_RESISTANCE)
	if(magic_flags == NONE) // magic with the NONE flag can always be cast
		return TRUE

	var/restrict_magic_flags = SEND_SIGNAL(src, COMSIG_MOB_RESTRICT_MAGIC, magic_flags)
	return restrict_magic_flags == NONE

///Return any anti artifact atom on this mob
/mob/proc/anti_artifact_check(self = FALSE, slot)
	var/list/protection_sources = list()
	if(SEND_SIGNAL(src, COMSIG_MOB_RECEIVE_ARTIFACT, src, self, protection_sources, slot) & COMPONENT_BLOCK_ARTIFACT)
		if(protection_sources.len)
			return pick(protection_sources)
		else
			return src

/**
 * Buckle a living mob to this mob. Also turns you to face the other mob
 *
 * You can buckle on mobs if you're next to them since most are dense
 */
/mob/buckle_mob(mob/living/M, force = FALSE, check_loc = TRUE, buckle_mob_flags= NONE)
	if(M.buckled && !force)
		return FALSE
	var/turf/T = get_turf(src)
	if(M.loc != T)
		var/old_density = density //old and doesnt use set_density()
		density = FALSE
		var/can_step = step_towards(M, T)
		density = old_density // Avoid changing density directly in normal circumstances, without the setter.
		if(!can_step)
			return FALSE
	return ..()

///Call back post buckle to a mob to offset your visual height
/mob/post_buckle_mob(mob/living/M)
	var/height = M.get_mob_buckling_height(src)
	M.pixel_y = initial(M.pixel_y) + height
	if(M.layer < layer)
		M.layer = layer + 0.1
///Call back post unbuckle from a mob, (reset your visual height here)
/mob/post_unbuckle_mob(mob/living/M)
	M.layer = initial(M.layer)
	M.pixel_y = initial(M.pixel_y)

///returns the height in pixel the mob should have when buckled to another mob.
/mob/proc/get_mob_buckling_height(mob/seat)
	if(isliving(seat))
		var/mob/living/L = seat
		if(L.mob_size <= MOB_SIZE_SMALL) //being on top of a small mob doesn't put you very high.
			return 0
	return 9

///Can the mob interact() with an atom?
/mob/proc/can_interact_with(atom/A, treat_mob_as_adjacent)
	if(IsAdminGhost(src))
		return TRUE
	var/datum/dna/mob_dna = has_dna()
	if(mob_dna?.check_mutation(/datum/mutation/telekinesis) && tkMaxRangeCheck(src, A))
		return TRUE
	if(treat_mob_as_adjacent && src == A.loc)
		return TRUE
	return Adjacent(A)

///Can the mob use Topic to interact with machines
/mob/proc/canUseTopic(atom/movable/M, be_close=FALSE, no_dexterity=FALSE, no_tk=FALSE, need_hands = FALSE, floor_okay=FALSE)
	return

///Can this mob use storage
/mob/proc/canUseStorage()
	return FALSE
/**
  * Check if the other mob has any factions the same as us
  *
  * If exact match is set, then all our factions must match exactly
  */
/mob/proc/faction_check_mob(mob/target, exact_match)
	if(exact_match) //if we need an exact match, we need to do some bullfuckery.
		var/list/faction_src = faction.Copy()
		var/list/faction_target = target.faction.Copy()
		if(!("[REF(src)]" in faction_target)) //if they don't have our ref faction, remove it from our factions list.
			faction_src -= "[REF(src)]" //if we don't do this, we'll never have an exact match.
		if(!("[REF(target)]" in faction_src))
			faction_target -= "[REF(target)]" //same thing here.
		return faction_check(faction_src, faction_target, TRUE)
	return faction_check(faction, target.faction, FALSE)
/*
 * Compare two lists of factions, returning true if any match
 *
 * If exact match is passed through we only return true if both faction lists match equally
 */
/proc/faction_check(list/faction_A, list/faction_B, exact_match)
	var/list/match_list
	if(exact_match)
		match_list = faction_A&faction_B //only items in both lists
		var/length = LAZYLEN(match_list)
		if(length)
			return (length == LAZYLEN(faction_A)) //if they're not the same len(gth) or we don't have a len, then this isn't an exact match.
	else
		match_list = faction_A&faction_B
		return LAZYLEN(match_list)
	return FALSE


/**
  * Fully update the name of a mob
  *
  * This will update a mob's name, real_name, mind.name, GLOB.manifest records, pda, id and traitor text
  *
  * Calling this proc without an oldname will only update the mob and skip updating the pda, id and records ~Carn
  */
/mob/proc/fully_replace_character_name(oldname,newname)
	log_message("[src] name changed from [oldname] to [newname]", LOG_OWNERSHIP)
	if(!newname)
		return 0

	log_played_names(ckey,newname)

	real_name = newname
	name = newname
	if(mind)
		mind.name = newname
		if(mind.key)
			log_played_names(mind.key,newname) //Just in case the mind is unsynced at the moment.

	if(oldname)
		//update the manifest records! This is goig to be a bit costly.
		replace_records_name(oldname,newname)

		//update our pda and id if we have them on our person
		replace_identification_name(oldname,newname)

		for(var/datum/mind/T in SSticker.minds)
			for(var/datum/objective/obj in T.get_all_objectives())
				// Only update if this player is a target
				if(obj.target && obj.target.current && obj.target.current.real_name == name)
					obj.update_explanation_text()
	return 1

///Updates GLOB.manifest records with new name , see mob/living/carbon/human
/mob/proc/replace_records_name(oldname,newname)
	return

///update the ID name of this mob
/mob/proc/replace_identification_name(oldname,newname)
	var/list/searching = GetAllContents()
	var/search_id = 1
	var/search_pda = 1

	for(var/A in searching)
		if( search_id && istype(A, /obj/item/card/id) )
			var/obj/item/card/id/ID = A
			if(ID.registered_name == oldname)
				ID.registered_name = newname
				ID.update_label()
				if(ID.registered_account?.account_holder == oldname)
					ID.registered_account.account_holder = newname
				if(!search_pda)
					break
				search_id = 0

		else if(search_pda && istype(A, /obj/item/modular_computer/tablet))
			var/obj/item/modular_computer/tablet/PDA = A
			if(PDA.saved_identification == oldname)
				PDA.saved_identification = newname
				PDA.update_id_display()
				if(!search_id)
					break
				search_pda = 0

/mob/proc/update_stat()
	return

/mob/proc/update_health_hud()
	return

/// Changes the stamina HUD based on new information
/mob/proc/update_stamina_hud()
	return

///Update the lighting plane and sight of this mob (sends COMSIG_MOB_UPDATE_SIGHT)
/mob/proc/update_sight()
	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_SIGHT)
	sync_lighting_plane_alpha()

///Set the lighting plane hud alpha to the mobs lighting_alpha var
/mob/proc/sync_lighting_plane_alpha()
	if(hud_used)
		var/atom/movable/screen/plane_master/lighting/L = hud_used.plane_masters["[LIGHTING_PLANE]"]
		if (L)
			L.alpha = lighting_alpha
		var/atom/movable/screen/plane_master/additive_lighting/LA = hud_used.plane_masters["[LIGHTING_PLANE_ADDITIVE]"]
		if(LA)
			var/bloom = ADDITIVE_LIGHTING_PLANE_ALPHA_NORMAL
			if(client?.prefs) //If this ever doesn't work for some reason add update_sight() to /mob/living/Login()
				bloom = client.prefs.read_preference(/datum/preference/numeric/bloom) * (ADDITIVE_LIGHTING_PLANE_ALPHA_MAX / 100)
			LA.alpha = lighting_alpha * (bloom / 255)



///Update the mouse pointer of the attached client in this mob
/mob/proc/update_mouse_pointer()
	if(!client)
		return
	if (client.cooldown_cursor_time > world.time)
		return
	if(client.mouse_pointer_icon != initial(client.mouse_pointer_icon))//only send changes to the client if theyre needed
		client.mouse_pointer_icon = initial(client.mouse_pointer_icon)
	if(examine_cursor_icon && client.keys_held["Shift"]) //mouse shit is hardcoded, make this non hard-coded once we make mouse modifiers bindable
		client.mouse_pointer_icon = examine_cursor_icon
	if(istype(loc, /obj/vehicle/sealed))
		var/obj/vehicle/sealed/E = loc
		if(E.mouse_pointer)
			client.mouse_pointer_icon = E.mouse_pointer
	if(client.mouse_override_icon)
		client.mouse_pointer_icon = client.mouse_override_icon

GLOBAL_LIST_INIT(mouse_cooldowns, list(
	'icons/effects/cooldown_cursors/cooldown_1.dmi',
	'icons/effects/cooldown_cursors/cooldown_2.dmi',
	'icons/effects/cooldown_cursors/cooldown_3.dmi',
	'icons/effects/cooldown_cursors/cooldown_4.dmi',
	'icons/effects/cooldown_cursors/cooldown_5.dmi',
	'icons/effects/cooldown_cursors/cooldown_6.dmi',
	'icons/effects/cooldown_cursors/cooldown_7.dmi',
	'icons/effects/cooldown_cursors/cooldown_8.dmi',
	'icons/effects/cooldown_cursors/cooldown_9.dmi',
))

/client/var/cooldown_cursor_time

/client/proc/give_cooldown_cursor(time, override = FALSE)
	set waitfor = FALSE
	// Ignore the cooldown cursor if we have a longer one already applied
	if (world.time + time < cooldown_cursor_time && !override)
		return
	cooldown_cursor_time = world.time + time
	var/end_time = cooldown_cursor_time
	var/start_time = world.time
	var/current_cursor = 1
	for (var/cursor_icon in GLOB.mouse_cooldowns)
		// Set the cursor and wait
		mouse_pointer_icon = cursor_icon
		// Sleep until we are where we should be
		var/next_cursor_time = start_time + current_cursor * time / length(GLOB.mouse_cooldowns)
		sleep(next_cursor_time - world.time)
		// Someone else is managing the cursor
		// Someone else is managing a cooldown timer, allow them since they overrode us
		if (mouse_pointer_icon != cursor_icon || cooldown_cursor_time != end_time)
			return
		current_cursor ++
	// Somehow we finished a bit early
	if (world.time < end_time)
		sleep(end_time - world.time)
		if (mouse_pointer_icon != GLOB.mouse_cooldowns[length(GLOB.mouse_cooldowns)] || cooldown_cursor_time != end_time)
			return
	cooldown_cursor_time = null
	mob.update_mouse_pointer()

/client/proc/clear_cooldown_cursor(time)
	if (!(mouse_pointer_icon in GLOB.mouse_cooldowns))
		return
	mouse_pointer_icon = initial(mouse_pointer_icon)
	cooldown_cursor_time = 0


/// This mob can read
/mob/proc/is_literate()
	return FALSE

/**
 * Checks if there is enough light where the mob is located
 *
 * Args:
 *  light_amount (optional) - A decimal amount between 1.0 through 0.0 (default is 0.2)
**/
/mob/proc/has_light_nearby(light_amount = LIGHTING_TILE_IS_DARK)
	var/turf/mob_location = get_turf(src)
	return mob_location.get_lumcount() > light_amount

/**
 * Can this mob see in the dark
 *
 * This checks all traits, glasses, and robotic eyeball implants to see if the mob can see in the dark
 * this does NOT check if the mob is missing it's eyeballs. Also see_in_dark is a BYOND mob var (that defaults to 2)
**/
/mob/proc/has_nightvision()
	return see_in_dark >= NIGHTVISION_FOV_RANGE

///Can this mob read (is literate and not blind)
/mob/proc/can_read(obj/O)
	if(is_blind())
		to_chat(src, span_warning("You are blind and can't read anything!"))
		return FALSE
		//to_chat(src, span_warning("As you are trying to read [O], you suddenly feel very stupid!"))
	if(!is_literate())
		to_chat(src, span_warning("You try to read [O], but can't comprehend any of it."))
		return FALSE

	if(!has_light_nearby() && !has_nightvision())
		to_chat(src, span_warning("It's too dark in here to read!"))
		return FALSE

	return TRUE

///Get the id card on this mob
/mob/proc/get_idcard(hand_first)
	return

/mob/proc/get_id_in_hand()
	return

/**
  * Get the mob VV dropdown extras
  */
/mob/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "---------")
	VV_DROPDOWN_OPTION(VV_HK_GIB, "Gib")
	VV_DROPDOWN_OPTION(VV_HK_GIVE_SPELL, "Give Spell")
	VV_DROPDOWN_OPTION(VV_HK_REMOVE_SPELL, "Remove Spell")
	VV_DROPDOWN_OPTION(VV_HK_GIVE_DISEASE, "Give Disease")
	VV_DROPDOWN_OPTION(VV_HK_GODMODE, "Toggle Godmode")
	VV_DROPDOWN_OPTION(VV_HK_DROP_ALL, "Drop Everything")
	VV_DROPDOWN_OPTION(VV_HK_REGEN_ICONS, "Regenerate Icons")
	VV_DROPDOWN_OPTION(VV_HK_PLAYER_PANEL, "Show player panel")
	VV_DROPDOWN_OPTION(VV_HK_BUILDMODE, "Toggle Buildmode")
	VV_DROPDOWN_OPTION(VV_HK_DIRECT_CONTROL, "Assume Direct Control")
	VV_DROPDOWN_OPTION(VV_HK_GIVE_DIRECT_CONTROL, "Give Direct Control")
	VV_DROPDOWN_OPTION(VV_HK_OFFER_GHOSTS, "Offer Control to Ghosts")

/mob/vv_do_topic(list/href_list)
	. = ..()
	if(href_list[VV_HK_REGEN_ICONS] && check_rights(R_ADMIN))
		regenerate_icons()

	if(href_list[VV_HK_PLAYER_PANEL] && check_rights(R_ADMIN))
		usr.client.holder.show_player_panel(src)

	if(href_list[VV_HK_GIVE_SPELL] && check_rights(R_FUN))
		usr.client.give_spell(src)

	if(href_list[VV_HK_GODMODE] && check_rights(R_FUN))
		usr.client.cmd_admin_godmode(src)

	if(href_list[VV_HK_REMOVE_SPELL] && check_rights(R_FUN))
		usr.client.remove_spell(src)

	if(href_list[VV_HK_GIVE_DISEASE] && check_rights(R_FUN))
		usr.client.give_disease(src)

	if(href_list[VV_HK_GIB] && check_rights(R_FUN))
		usr.client.cmd_admin_gib(src)

	if(href_list[VV_HK_BUILDMODE] && check_rights(R_BUILD))
		togglebuildmode(src)

	if(href_list[VV_HK_DROP_ALL] && check_rights(R_FUN))
		usr.client.cmd_admin_drop_everything(src)

	if(href_list[VV_HK_DIRECT_CONTROL] && check_rights(R_ADMIN))
		usr.client.cmd_assume_direct_control(src)

	if(href_list[VV_HK_GIVE_DIRECT_CONTROL] && check_rights(R_ADMIN))
		usr.client.cmd_give_direct_control(src)

	if(href_list[VV_HK_OFFER_GHOSTS] && check_rights(R_ADMIN))
		offer_control(src)

/**
  * extra var handling for the logging var
  */
/mob/vv_get_var(var_name)
	switch(var_name)
		if("logging")
			return debug_variable(var_name, logging, 0, src, FALSE)
	. = ..()

/mob/vv_auto_rename(new_name)
	//Do not do parent's actions, as we *usually* do this differently.
	fully_replace_character_name(real_name, new_name)

///Show the language menu for this mob
/mob/verb/open_language_menu_verb()
	set name = "Open Language Menu"
	set category = "IC"
	if(isnewplayer(src))
		return
	get_language_holder().open_language_menu(usr)

///Adjust the nutrition of a mob
/mob/proc/adjust_nutrition(change) //Honestly FUCK the oldcoders for putting nutrition on /mob someone else can move it up because holy hell I'd have to fix SO many typechecks
	nutrition = max(0, nutrition + change)

///Force set the mob nutrition
/mob/proc/set_nutrition(change) //Seriously fuck you oldcoders.
	nutrition = max(0, change)

/mob/proc/update_equipment_speed_mods()
	var/speedies = equipped_speed_mods()
	if(!speedies)
		remove_movespeed_modifier(/datum/movespeed_modifier/equipment_speedmod)
	else
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/equipment_speedmod, multiplicative_slowdown = speedies)

/// Gets the combined speed modification of all worn items
/// Except base mob type doesnt really wear items
/mob/proc/equipped_speed_mods()
	for(var/obj/item/I in held_items)
		if(I.item_flags & SLOWS_WHILE_IN_HAND)
			. += I.slowdown

// Returns TRUE if the hearer should hear radio noises
/mob/proc/hears_radio()
	return TRUE

/mob/proc/set_stat(new_stat)
	if(new_stat == stat)
		return
	SEND_SIGNAL(src, COMSIG_MOB_STATCHANGE, new_stat)
	. = stat
	stat = new_stat
	update_action_buttons_icon(TRUE)

/mob/key_down(key, client/client, full_key)
	..()
	SEND_SIGNAL(src, COMSIG_MOB_KEYDOWN, key, client, full_key)

#undef MOB_FACE_DIRECTION_DELAY
