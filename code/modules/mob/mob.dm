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
	focus = null
	for (var/alert in alerts)
		clear_alert(alert, TRUE)
	if(observers?.len)
		for(var/M in observers)
			var/mob/dead/observe = M
			observe.reset_perspective(null)
	qdel(hud_used)
	for(var/cc in client_colours)
		qdel(cc)
	client_colours = null
	ghostize()
	if(mind?.current == src) //Let's just be safe yeah? This will occasionally be cleared, but not always. Can't do it with ghostize without changing behavior
		mind.set_current(null)
	QDEL_LIST(mob_spell_list)
	for(var/datum/action/A as() in actions)
		if(istype(A.target, /obj/effect/proc_holder))
			A.Remove(src) // Mind's spells' actions should only be removed
		else
			qdel(A) // Other actions can be safely deleted
	actions.Cut()
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

	var/t =	"<span class='notice'>Coordinates: [x],[y] \n</span>"
	t +=	"<span class='danger'>Temperature: [environment.return_temperature()] \n</span>"
	for(var/id in environment.get_gases())
		if(environment.get_moles(id))
			t+="<span class='notice'>[GLOB.gas_data.names[id]]: [environment.get_moles(id)] \n</span>"

	to_chat(usr, t)

/**
  * Return the desc of this mob for a photo
  */
/mob/proc/get_photo_description(obj/item/camera/camera)
	return "You can also see a ... thing?"

/**
  * Show a message to this mob (visual or audible)
  */
/mob/proc/show_message(msg, type, alt_msg, alt_type, avoid_highlighting = FALSE)//Message, type of message (1 or 2), alternative message, alt message type (1 or 2)

	if(!client)
		return

	msg = copytext_char(msg, 1, MAX_MESSAGE_LEN)

	if(type)
		if(type & MSG_VISUAL && is_blind() )//Vision related
			if(!alt_msg)
				return
			else
				msg = alt_msg
				type = alt_type

		if(type & MSG_AUDIBLE && !can_hear())//Hearing related
			if(!alt_msg)
				return
			else
				msg = alt_msg
				type = alt_type
				if(type & MSG_VISUAL && is_blind())
					return
	// voice muffling
	if(stat == UNCONSCIOUS)
		if(type & MSG_AUDIBLE) //audio
			to_chat(src, "<I>... You can almost hear something ...</I>")
		return
	to_chat(src, msg, avoid_highlighting = avoid_highlighting)


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
		message = "<span class='emote'><b>[src]</b>[separation][message]</span>"
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

		if(is_emote && M.should_show_chat_message(src, null, TRUE) && !M.is_blind())
			show_to += M

		M.show_message(msg, MSG_VISUAL, blind_message, MSG_AUDIBLE)

	//Create the chat message
	if(length(show_to))
		create_chat_message(src, null, show_to, raw_msg, null, visible_message_flags)

/mob/visible_message(message, self_message, blind_message, vision_distance = DEFAULT_MESSAGE_RANGE, list/ignored_mobs, list/visible_message_flags, separation = " ")
	. = ..()
	if(self_message)
		show_message(self_message, MSG_VISUAL, blind_message, MSG_AUDIBLE)

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
		message = "<span class='emote'><b>[src]</b>[separation][message]</span>"

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
	if(self_message)
		show_message(self_message, MSG_AUDIBLE, deaf_message, MSG_VISUAL)

///Returns the client runechat visible messages preference according to the message type.
/atom/proc/runechat_prefs_check(mob/target, list/visible_message_flags)
	if(!(target.client?.prefs.toggles & PREFTOGGLE_RUNECHAT_GLOBAL) || !(target.client.prefs.toggles & PREFTOGGLE_RUNECHAT_NONMOBS))
		return FALSE
	if(LAZYFIND(visible_message_flags, CHATMESSAGE_EMOTE) && !(target.client.prefs.toggles & PREFTOGGLE_RUNECHAT_EMOTES))
		return FALSE
	return TRUE

/mob/runechat_prefs_check(mob/target, list/visible_message_flags)
	if(!(target.client?.prefs.toggles & PREFTOGGLE_RUNECHAT_GLOBAL))
		return FALSE
	if(LAZYFIND(visible_message_flags, CHATMESSAGE_EMOTE) && !(target.client.prefs.toggles & PREFTOGGLE_RUNECHAT_EMOTES))
		return FALSE
	return TRUE

///Get the item on the mob in the storage slot identified by the id passed in
/mob/proc/get_item_by_slot(slot_id)
	return null

///Is the mob restrained
/mob/proc/restrained(ignore_grab)
	return

///Is the mob incapacitated
/mob/proc/incapacitated(ignore_restraints = FALSE, ignore_grab = FALSE, check_immobilized = FALSE)
	return

/**
  * This proc is called whenever someone clicks an inventory ui slot.
  *
  * Mostly tries to put the item into the slot if possible, or call attack hand
  * on the item in the slot if the users active hand is empty
  */
/mob/proc/attack_ui(slot)
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
			I.attack_hand(src)

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
/mob/proc/equip_to_slot_if_possible(obj/item/W, slot, qdel_on_fail = FALSE, disable_warning = FALSE, redraw_mob = TRUE, bypass_equip_delay_self = FALSE)
	if(!istype(W))
		return FALSE
	if(!W.mob_can_equip(src, null, slot, disable_warning, bypass_equip_delay_self))
		if(qdel_on_fail)
			qdel(W)
		else if(!disable_warning)
			to_chat(src, "<span class='warning'>You are unable to equip that!</span>")
		return FALSE
	equip_to_slot(W, slot, redraw_mob) //This proc should not ever fail.
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
/mob/proc/equip_to_slot_or_del(obj/item/W, slot)
	return equip_to_slot_if_possible(W, slot, TRUE, TRUE, FALSE, TRUE)

/**
  * Auto equip the passed in item the appropriate slot based on equipment priority
  *
  * puts the item "W" into an appropriate slot in a human's inventory
  *
  * returns 0 if it cannot, 1 if successful
  */
/mob/proc/equip_to_appropriate_slot(obj/item/W)
	if(!istype(W))
		return 0
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
		if(equip_to_slot_if_possible(W, slot, 0, 1, 1)) //qdel_on_fail = 0; disable_warning = 1; redraw_mob = 1
			return 1

	return 0

// Convinience proc.  Collects crap that fails to equip either onto the mob's back, or drops it.
// Used in job equipping so shit doesn't pile up at the start loc.
/mob/living/carbon/human/proc/equip_or_collect(var/obj/item/W, var/slot)
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
			var/datum/component/storage/STR = B.GetComponent(/datum/component/storage)
			if(STR.can_be_inserted(W, stop_messages=TRUE))
				STR.handle_item_insertion(W,1)
			return B

/**
  * Reset the attached clients perspective (viewpoint)
  *
  * reset_perspective() set eye to common default : mob on turf, loc otherwise
  * reset_perspective(thing) set the eye to the thing (if it's equal to current default reset to mob perspective)
  */
/mob/proc/reset_perspective(atom/A)
	if(client)
		if(A)
			if(ismovable(A))
				//Set the the thing unless it's us
				if(A != src)
					client.perspective = EYE_PERSPECTIVE
					client.eye = A
				else
					client.eye = client.mob
					client.perspective = MOB_PERSPECTIVE
			else if(isturf(A))
				//Set to the turf unless it's our current turf
				if(A != loc)
					client.perspective = EYE_PERSPECTIVE
					client.eye = A
				else
					client.eye = client.mob
					client.perspective = MOB_PERSPECTIVE
			else
				//Do nothing
		else
			//Reset to common defaults: mob if on turf, otherwise current loc
			if(isturf(loc))
				client.eye = client.mob
				client.perspective = MOB_PERSPECTIVE
			else
				client.perspective = EYE_PERSPECTIVE
				client.eye = loc
		return TRUE

/**
  * Examine a mob
  *
  * mob verbs are faster than object verbs. See
  * [this byond forum post](https://secure.byond.com/forum/?post=1326139&page=2#comment8198716)
  * for why this isn't atom/verb/examine()
  */
/mob/verb/examinate(atom/A as mob|obj|turf in view()) //It used to be oview(12), but I can't really say why
	set name = "Examine"
	set category = "IC"

	if(isturf(A) && !(sight & SEE_TURFS) && !(A in view(client ? client.view : world.view, src)))
		// shift-click catcher may issue examinate() calls for out-of-sight turfs
		return

	if(is_blind(src) && !blind_examine_check(A))
		return

	face_atom(A)
	var/list/result = A.examine(src)

	to_chat(src, EXAMINE_BLOCK(jointext(result, "\n")))
	SEND_SIGNAL(src, COMSIG_MOB_EXAMINATE, A)

/mob/proc/blind_examine_check(atom/examined_thing)
	return TRUE

/mob/living/blind_examine_check(atom/examined_thing)
	//need to be next to something and awake
	if(!Adjacent(examined_thing) || incapacitated())
		to_chat(src, "<span class='warning'>Something is there, but you can't see it!</span>")
		return FALSE

	var/active_item = get_active_held_item()
	if(active_item && active_item != examined_thing)
		to_chat(src, "<span class='warning'>Your hands are too full to examine this!</span>")
		return FALSE

	//you can only initiate exaimines if you have a hand, it's not disabled, and only as many examines as you have hands
	/// our active hand, to check if it's disabled/detatched
	var/obj/item/bodypart/active_hand = has_active_hand()? get_active_hand() : null
	if(!active_hand || active_hand.is_disabled() || LAZYLEN(do_afters) >= get_num_arms())
		to_chat(src, "<span class='warning'>You don't have a free hand to examine this!</span>")
		return FALSE

	//you can only queue up one examine on something at a time
	if(examined_thing in do_afters)
		return FALSE

	to_chat(src, "<span class='notice'>You start feeling around for something...</span>")
	visible_message("<span class='notice'> [name] begins feeling around for \the [examined_thing.name]...</span>")

	/// how long it takes for the blind person to find the thing they're examining
	var/examine_delay_length = rand(1 SECONDS, 2 SECONDS)
	if(isobj(examined_thing))
		examine_delay_length *= 1.5
	else if(ismob(examined_thing) && examined_thing != src)
		examine_delay_length *= 2

	if(examine_delay_length > 0 && !do_after(src, examine_delay_length, target = examined_thing))
		to_chat(src, "<span class='notice'>You can't get a good feel for what is there.</span>")
		return FALSE

	//now we touch the thing we're examining
	/// our current intent, so we can go back to it after touching
	var/previous_intent = a_intent
	a_intent = INTENT_HELP
	examined_thing.attack_hand(src)
	a_intent = previous_intent

	return TRUE

/**
  * Point at an atom
  *
  * mob verbs are faster than object verbs. See
  * [this byond forum post](https://secure.byond.com/forum/?post=1326139&page=2#comment8198716)
  * for why this isn't atom/verb/pointed()
  *
  * note: ghosts can point, this is intended
  *
  * visible_message will handle invisibility properly
  *
  * overridden here and in /mob/dead/observer for different point span classes and sanity checks
  */
/mob/verb/pointed(atom/A as mob|obj|turf in view())
	set name = "Point To"
	set category = "Object"

	if(!src || !isturf(src.loc) || !(A in view(src.loc)))
		return FALSE
	if(istype(A, /obj/effect/temp_visual/point))
		return FALSE

	var/turf/tile = get_turf(A)
	if (!tile)
		return FALSE

	var/turf/our_tile = get_turf(src)
	var/obj/visual = new /obj/effect/temp_visual/point(our_tile, invisibility)
	animate(visual, pixel_x = (tile.x - our_tile.x) * world.icon_size + A.pixel_x, pixel_y = (tile.y - our_tile.y) * world.icon_size + A.pixel_y, time = 1.7, easing = EASE_OUT)

	SEND_SIGNAL(src, COMSIG_MOB_POINTED, A)
	return TRUE

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

	if(ismecha(loc))
		return

	if(incapacitated())
		return

	var/obj/item/I = get_active_held_item()
	if(I)
		I.attack_self(src)
		update_inv_hands()
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
//		mind.show_memory(src)
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

	if (CONFIG_GET(flag/norespawn))
		return
	if ((stat != DEAD || !( SSticker )))
		to_chat(usr, "<span class='boldnotice'>You must be dead to use this!</span>")
		return

	log_game("[key_name(usr)] used abandon mob.")

	to_chat(usr, "<span class='boldnotice'>Please roleplay correctly!</span>")

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
  * Topic call back for any mob
  *
  * * Unset machines if "mach_close" sent
  * * refresh the inventory of machines in range if "refresh" sent
  * * handles the strip panel equip and unequip as well if "item" sent
  */
/mob/Topic(href, href_list)
	if(href_list["mach_close"])
		var/t1 = text("window=[href_list["mach_close"]]")
		unset_machine()
		src << browse(null, t1)

	if(href_list["item"] && usr.canUseTopic(src, BE_CLOSE, NO_DEXTERY))
		var/slot = text2num(href_list["item"])
		var/hand_index = text2num(href_list["hand_index"])
		var/obj/item/what
		if(hand_index)
			what = get_item_for_held_index(hand_index)
			slot = list(slot,hand_index)
		else
			what = get_item_by_slot(slot)
		if(what)
			if(!(what.item_flags & ABSTRACT))
				usr.stripPanelUnequip(what,src,slot)
		else
			usr.stripPanelEquip(what,src,slot)

// The src mob is trying to strip an item from someone
// Defined in living.dm
/mob/proc/stripPanelUnequip(obj/item/what, mob/who)
	return

// The src mob is trying to place an item on someone
// Defined in living.dm
/mob/proc/stripPanelEquip(obj/item/what, mob/who)
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

/**
  * Convert a list of spells into a displyable list for the statpanel
  *
  * Shows charge and other important info
  */
/mob/proc/get_spell_stat_data(list/spells, current_tab)
	var/list/stat_data = list()
	for(var/obj/effect/proc_holder/spell/S in spells)
		if(S.can_be_cast_by(src) && current_tab == S.panel)
			client.stat_update_mode = STAT_MEDIUM_UPDATE
			switch(S.charge_type)
				if("recharge")
					stat_data["[S.name]"] = GENERATE_STAT_TEXT("[S.charge_counter/10.0]/[S.charge_max/10]")
				if("charges")
					stat_data["[S.name]"] = GENERATE_STAT_TEXT("[S.charge_counter]/[S.charge_max]")
				if("holdervar")
					stat_data["[S.name]"] = GENERATE_STAT_TEXT("[S.holder_var_type] [S.holder_var_amount]")
	return stat_data

#define MOB_FACE_DIRECTION_DELAY 1

// facing verbs
/**
  * Returns true if a mob can turn to face things
  *
  * Conditions:
  * * client.last_turn > world.time
  * * not dead or unconcious
  * * not anchored
  * * no transform not set
  * * we are not restrained
  */
/mob/proc/canface()
	if(world.time < client.last_turn)
		return FALSE
	if(stat == DEAD || stat == UNCONSCIOUS)
		return FALSE
	if(anchored)
		return FALSE
	if(notransform)
		return FALSE
	if(restrained())
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

///This might need a rename but it should replace the can this mob use things check
/mob/proc/IsAdvancedToolUser()
	return FALSE

/mob/proc/swap_hand()
	var/obj/item/held_item = get_active_held_item()
	if(SEND_SIGNAL(src, COMSIG_MOB_SWAP_HANDS, held_item) & COMPONENT_BLOCK_SWAP)
		to_chat(src, "<span class='warning'>Your other hand is too busy holding [held_item].</span>")
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
/mob/proc/notify_ghost_cloning(var/message = "Someone is trying to revive you. Re-enter your corpse if you want to be revived!", var/sound = 'sound/effects/genetics.ogg', var/atom/source = null, flashwindow)
	var/mob/dead/observer/ghost = get_ghost()
	if(ghost)
		ghost.notify_cloning(message, sound, source, flashwindow)
		return ghost

///Add a spell to the mobs spell list
/mob/proc/AddSpell(obj/effect/proc_holder/spell/S)
	mob_spell_list += S
	S.action.Grant(src)

///Remove a spell from the mobs spell list
/mob/proc/RemoveSpell(obj/effect/proc_holder/spell/spell)
	if(!spell)
		return
	for(var/X in mob_spell_list)
		var/obj/effect/proc_holder/spell/S = X
		if(istype(S, spell))
			mob_spell_list -= S
			qdel(S)

///Return any anti magic atom on this mob that matches the magic type
/mob/proc/anti_magic_check(magic = TRUE, holy = FALSE, major = TRUE, self = FALSE)
	if(!magic && !holy)
		return
	var/list/protection_sources = list()
	if(SEND_SIGNAL(src, COMSIG_MOB_RECEIVE_MAGIC, src, magic, holy, major, self, protection_sources) & COMPONENT_BLOCK_MAGIC)
		if(protection_sources.len)
			return pick(protection_sources)
		else
			return src
	if((magic && HAS_TRAIT(src, TRAIT_ANTIMAGIC)) || (holy && HAS_TRAIT(src, TRAIT_HOLY)))
		return src

///Return any anti artifact atom on this mob
/mob/proc/anti_artifact_check(self = FALSE)
	var/list/protection_sources = list()
	if(SEND_SIGNAL(src, COMSIG_MOB_RECEIVE_ARTIFACT, src, self, protection_sources) & COMPONENT_BLOCK_ARTIFACT)
		if(protection_sources.len)
			return pick(protection_sources)
		else
			return src

/**
  * Buckle to another mob
  *
  * You can buckle on mobs if you're next to them since most are dense
  *
  * Turns you to face the other mob too
  */
/mob/buckle_mob(mob/living/M, force = FALSE, check_loc = TRUE)
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

///can the mob be buckled to something by default?
/mob/proc/can_buckle()
	return TRUE

///can the mob be unbuckled from something by default?
/mob/proc/can_unbuckle()
	return 1

///Can the mob interact() with an atom?
/mob/proc/can_interact_with(atom/A, treat_mob_as_adjacent)
	if(IsAdminGhost(src))
		return TRUE
	if(treat_mob_as_adjacent && src == A.loc)
		return TRUE
	return Adjacent(A)

///Can the mob use Topic to interact with machines
/mob/proc/canUseTopic(atom/movable/M, be_close=FALSE, no_dextery=FALSE, no_tk=FALSE)
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
  * This will update a mob's name, real_name, mind.name, GLOB.data_core records, pda, id and traitor text
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
		//update the datacore records! This is goig to be a bit costly.
		replace_records_name(oldname,newname)

		//update our pda and id if we have them on our person
		replace_identification_name(oldname,newname)

		for(var/datum/mind/T in SSticker.minds)
			for(var/datum/objective/obj in T.get_all_objectives())
				// Only update if this player is a target
				if(obj.target && obj.target.current && obj.target.current.real_name == name)
					obj.update_explanation_text()
	return 1

///Updates GLOB.data_core records with new name , see mob/living/carbon/human
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

		else if(search_pda && istype(A, /obj/item/modular_computer/tablet/pda))
			var/obj/item/modular_computer/tablet/pda/PDA = A
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

///Update the mouse pointer of the attached client in this mob
/mob/proc/update_mouse_pointer()
	if (!client)
		return
	client.mouse_pointer_icon = initial(client.mouse_pointer_icon)
	if (ismecha(loc))
		var/obj/mecha/M = loc
		if(M.mouse_pointer)
			client.mouse_pointer_icon = M.mouse_pointer
	else if (istype(loc, /obj/vehicle/sealed))
		var/obj/vehicle/sealed/E = loc
		if(E.mouse_pointer)
			client.mouse_pointer_icon = E.mouse_pointer


///This mob is abile to read books
/mob/proc/is_literate()
	return FALSE

///Can this mob read (is literate and not blind)
/mob/proc/can_read(obj/O)
	if(is_blind())
		to_chat(src, "<span class='warning'>As you are trying to read [O], you suddenly feel very stupid!</span>")
		return
	if(!is_literate())
		to_chat(src, "<span class='notice'>You try to read [O], but can't comprehend any of it.</span>")
		return
	return TRUE

///Can this mob hold items
/mob/proc/can_hold_items()
	return FALSE

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

	if(href_list[VV_HK_GODMODE] && check_rights(R_FUN))
		usr.client.cmd_admin_godmode(src)

	if(href_list[VV_HK_GIVE_SPELL] && check_rights(R_FUN))
		usr.client.give_spell(src)

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
/mob/verb/open_language_menu()
	set name = "Open Language Menu"
	set category = "IC"

	var/datum/language_holder/H = get_language_holder()
	H.open_language_menu(usr)

///Adjust the nutrition of a mob
/mob/proc/adjust_nutrition(var/change) //Honestly FUCK the oldcoders for putting nutrition on /mob someone else can move it up because holy hell I'd have to fix SO many typechecks
	nutrition = max(0, nutrition + change)

///Force set the mob nutrition
/mob/proc/set_nutrition(var/change) //Seriously fuck you oldcoders.
	nutrition = max(0, change)

///Set the movement type of the mob and update it's movespeed
/mob/setMovetype(newval)
	. = ..()
	update_movespeed(FALSE)

/// Updates the grab state of the mob and updates movespeed
/mob/setGrabState(newstate)
	. = ..()
	if(grab_state == GRAB_PASSIVE)
		remove_movespeed_modifier(MOVESPEED_ID_MOB_GRAB_STATE, update=TRUE)
	else
		add_movespeed_modifier(MOVESPEED_ID_MOB_GRAB_STATE, update=TRUE, priority=100, override=TRUE, multiplicative_slowdown=grab_state*3, blacklisted_movetypes=FLOATING)

/mob/proc/update_equipment_speed_mods()
	var/speedies = equipped_speed_mods()
	if(!speedies)
		remove_movespeed_modifier(MOVESPEED_ID_MOB_EQUIPMENT, update=TRUE)
	else
		add_movespeed_modifier(MOVESPEED_ID_MOB_EQUIPMENT, update=TRUE, priority=100, override=TRUE, multiplicative_slowdown=speedies, blacklisted_movetypes=FLOATING)

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

/mob/proc/set_active_storage(new_active_storage)
	if(active_storage)
		UnregisterSignal(active_storage, COMSIG_PARENT_QDELETING)
	active_storage = new_active_storage
	if(active_storage)
		RegisterSignal(active_storage, COMSIG_PARENT_QDELETING, .proc/active_storage_deleted)

/mob/proc/active_storage_deleted(datum/source)
	SIGNAL_HANDLER
	set_active_storage(null)
