//every quirk in this folder should be coded around being applied on spawn
//these are NOT "mob quirks" like GOTTAGOFAST, but exist as a medium to apply them and other different effects
/datum/quirk
	/// The name of the quirk
	var/name = "Test Quirk"
	/// The description of the quirk
	var/desc = "This is a test quirk."
	///Positive if the quirk is beneficial to gameplay, negative if the quirk is restrictive/harmful, 0 if the quirk has no substantial impact on gameplay
	var/quirk_value = 0
	/// Flags related to this quirk.
	var/quirk_flags = QUIRK_HUMAN_ONLY
	/// Reference to the mind currently tied to this quirk datum.
	var/datum/mind/quirk_holder
	/// Reference to the mob currently tied to this quirk datum. Quirks are not singletons.
	var/mob/living/quirk_target
	/// Text displayed when this quirk is assigned to a mob (and not transferred)
	var/gain_text
	/// Text displayed when this quirk is removed from a mob (and not transferred)
	var/lose_text
	///This text will appear on medical records for the trait.
	var/medical_record_text
	/// if applicable, apply and remove this mob trait
	var/mob_trait
	/// When making an abstract quirk (in OOP terms), don't forget to set this var to the type path for that abstract quirk.
	var/abstract_parent_type = /datum/quirk
	/// The icon to show in the preferences menu.
	/// This references a tgui icon, so it can be FontAwesome or a tgfont (with a tg- prefix).
	var/icon
	/// A list of items people can receive from mail who have this quirk enabled
	/// The base weight for the each quirk's mail goodies list to be selected is 5
	/// then the item selected is determined by pick(selected_quirk.mail_goodies)
	var/mail_goodies = list()
	/// Accent to be used in accent traits
	var/accent_to_use = null

/datum/quirk/Destroy()
	if(quirk_holder)
		remove_from_current_holder()

	return ..()

/// Called when quirk_holder is qdeleting. Simply qdels this datum and lets Destroy() handle the rest.
/datum/quirk/proc/on_holder_qdeleting(datum/mind/source, force)
	SIGNAL_HANDLER
	qdel(src)

/**
 * Adds the quirk to a new quirk_holder.
 *
 * Performs logic to make sure new_holder is a valid holder of this quirk.
 * Returns FALSEy if there was some kind of error. Returns TRUE otherwise.
 * Arguments:
 * * new_holder - The mind to add this quirk to.
 * * new_target - The mob to apply the quirk effects to.
 * * quirk_transfer - If this is being added to the holder as part of a quirk transfer. Quirks can use this to decide not to spawn new items or apply any other one-time effects.
 */
/datum/quirk/proc/add_to_holder(datum/mind/new_holder, mob/living/new_target, quirk_transfer = FALSE, client/client_source)
	if(!new_holder)
		CRASH("Quirk attempted to be added to null mind.")

	if((quirk_flags & QUIRK_HUMAN_ONLY) && !ishuman(new_target))
		CRASH("Human only quirk attempted to be added to non-human mob.")

	if(!new_target || new_target.has_quirk(type))
		CRASH("Quirk attempted to be added to null or already-quirked mob.")

	if(quirk_holder)
		CRASH("Attempted to add quirk to a holder when it already has a holder.")

	quirk_holder = new_holder
	quirk_target = new_target
	quirk_holder.quirks += src
	// If we weren't passed a client source try to use a present one
	client_source ||= new_target.client

	if(mob_trait)
		ADD_TRAIT(quirk_target, mob_trait, QUIRK_TRAIT)

	add(client_source)

	if(quirk_flags & QUIRK_PROCESSES)
		START_PROCESSING(SSquirks, src)

	if(!quirk_transfer)
		if(gain_text)
			to_chat(quirk_holder, gain_text)
		add_unique(client_source)

		if(new_target.client)
			post_add()
		else
			RegisterSignal(new_target, COMSIG_MOB_LOGIN, PROC_REF(on_quirk_holder_first_login))

	RegisterSignal(quirk_holder, COMSIG_QDELETING, PROC_REF(on_holder_qdeleting))

	return TRUE

/// Removes the quirk from the current quirk_holder.
/datum/quirk/proc/remove_from_current_holder(quirk_transfer = FALSE)
	if(!quirk_holder)
		CRASH("Attempted to remove quirk from the current holder when it has no current holder.")

	UnregisterSignal(quirk_holder, list(COMSIG_MOB_LOGIN, COMSIG_QDELETING))

	quirk_holder.quirks -= src

	if(!quirk_transfer && !QDELETED(quirk_target) && lose_text)
		to_chat(quirk_target, lose_text)

	if(mob_trait && !QDELETED(quirk_target))
		REMOVE_TRAIT(quirk_target, mob_trait, QUIRK_TRAIT)

	if(quirk_flags & QUIRK_PROCESSES)
		STOP_PROCESSING(SSquirks, src)

	remove()

	quirk_holder = null
	quirk_target = null

/**
 * On client connection set quirk preferences.
 *
 * Run post_add to set the client preferences for the quirk.
 * Clear the attached signal for login.
 * Used when the quirk has been gained and no client is attached to the mob.
 */
/datum/quirk/proc/on_quirk_holder_first_login(mob/living/source)
	SIGNAL_HANDLER

	if(source == quirk_target)
		UnregisterSignal(source, COMSIG_MOB_LOGIN)
		post_add()

/// Any effect that should be applied every single time the quirk is added to any mob, even when transferred.
/datum/quirk/proc/add(client/client_source)
	return

/// Any effects from the proc that should not be done multiple times if the quirk is transferred between mobs.
/// Put stuff like spawning items in here.
/datum/quirk/proc/add_unique(client/client_source)
	return

/// Removal of any reversible effects added by the quirk.
/datum/quirk/proc/remove()
	return

/// Any special effects or chat messages which should be applied.
/// This proc is guaranteed to run if the mob has a client when the quirk is added.
/// Otherwise, it runs once on the next COMSIG_MOB_LOGIN.
/datum/quirk/proc/post_add()
	return

/// Subtype quirk that has some bonus logic to spawn items for the player.
/datum/quirk/item_quirk
	/// Lazylist of strings describing where all the quirk items have been spawned.
	var/list/where_items_spawned
	/// If true, the backpack automatically opens on post_add(). Usually set to TRUE when an item is equipped inside the player's backpack.
	var/open_backpack = FALSE
	abstract_parent_type = /datum/quirk/item_quirk

/**
 * Handles inserting an item in any of the valid slots provided, then allows for post_add notification.
 *
 * If no valid slot is available for an item, the item is left at the mob's feet.
 * Arguments:
 * * quirk_item - The item to give to the quirk holder. If the item is a path, the item will be spawned in first on the player's turf.
 * * valid_slots - Assoc list of descriptive location strings to item slots that is fed into [/mob/living/carbon/proc/equip_in_one_of_slots]. list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK)
 * * flavour_text - Optional flavour text to append to the where_items_spawned string after the item's location.
 * * default_location - If the item isn't possible to equip in a valid slot, this is a description of where the item was spawned.
 * * notify_player - If TRUE, adds strings to where_items_spawned list to be output to the player in [/datum/quirk/item_quirk/post_add()]
 */
/datum/quirk/item_quirk/proc/give_item_to_holder(quirk_item, list/valid_slots, flavour_text = null, default_location = "at your feet", notify_player = TRUE)
	if(ispath(quirk_item))
		quirk_item = new quirk_item(get_turf(quirk_target))

	var/mob/living/carbon/human/human_holder = quirk_target

	var/where = human_holder.equip_in_one_of_slots(quirk_item, valid_slots, qdel_on_fail = FALSE) || default_location

	if(where == LOCATION_BACKPACK)
		open_backpack = TRUE

	if(notify_player)
		LAZYADD(where_items_spawned, span_boldnotice("You have \\a [quirk_item] [where]. [flavour_text]"))

/datum/quirk/item_quirk/post_add()
	if(open_backpack)
		var/mob/living/carbon/human/human_holder = quirk_target
		// post_add() can be called via delayed callback. Check they still have a backpack equipped before trying to open it.
		if(human_holder.back?.atom_storage)
			human_holder.back.atom_storage.show_contents(human_holder)

	for(var/chat_string in where_items_spawned)
		to_chat(quirk_target, chat_string)

	where_items_spawned = null

/**
 * get_quirk_string() is used to get a printable string of all the quirk traits someone has for certain criteria
 *
 * Arguments:
 * * Medical- If we want the long, fancy descriptions that show up in medical records, or if not, just the name
 * * Category- Which types of quirks we want to print out. Defaults to everything
 * * from_scan- If the source of this call is like a health analyzer or HUD, in which case QUIRK_HIDE_FROM_SCAN hides the quirk.
 */
/mob/living/proc/get_quirk_string(medical = FALSE, category = CAT_QUIRK_ALL, from_scan = FALSE)
	if(!mind)
		return
	var/list/dat = list()
	for(var/datum/quirk/candidate as anything in mind.quirks)
		switch(category)
			if(CAT_QUIRK_MAJOR_DISABILITY)
				if(candidate.quirk_value >= -4)
					continue
			if(CAT_QUIRK_MINOR_DISABILITY)
				if(!ISINRANGE(candidate.quirk_value, -4, -1))
					continue
			if(CAT_QUIRK_NOTES)
				if(candidate.quirk_value < 0)
					continue
		dat += medical ? candidate.medical_record_text : candidate.name

	if(!dat.len)
		return medical ? "No issues have been declared." : "None"
	return medical ?  dat.Join("<br>") : dat.Join(", ")

/datum/quirk/proc/read_choice_preference(path)
	var/client/qclient = GLOB.directory[ckey(quirk_holder.key)]
	var/pref = qclient?.prefs.read_character_preference(path)
	if(pref != "Random")
		return pref

/*

Commented version of Nearsighted to help you add your own quirks
Use this as a guideline

/datum/quirk/nearsighted
	name = "Nearsighted"
	///The quirk's name

	desc = "You are nearsighted without prescription glasses, but spawn with a pair."
	///Short description, shows next to name in the quirk panel

	value = -1
	///If this is above 0, it's a positive quirk; if it's not, it's a negative one; if it's 0, it's a neutral

	mob_trait = TRAIT_NEARSIGHT
	///This define is in __DEFINES/traits.dm and is the actual "trait" that the game tracks
	///You'll need to use "HAS_TRAIT_FROM(src, X, sources)" checks around the code to check this; for instance, the Ageusia quirk is checked in taste code
	///If you need help finding where to put it, the declaration finder on GitHub is the best way to locate it

	gain_text = span_danger("Things far away from you start looking blurry.")
	lose_text = span_notice("You start seeing faraway things normally again.")
	medical_record_text = "Subject has permanent nearsightedness."
	///These three are self-explanatory

/datum/quirk/nearsighted/add_unique(client/client_source)
	var/mob/living/carbon/human/H = quirk_target
	var/obj/item/clothing/glasses/regular/glasses = new(get_turf(H))
	H.put_in_hands(glasses)
	H.equip_to_slot(glasses, ITEM_SLOT_EYES)
	H.regenerate_icons()

//This whole proc is called automatically
//It spawns a set of prescription glasses on the user, then attempts to put it into their hands, then attempts to make them equip it.
//This means that if they fail to equip it, they glasses spawn in their hands, and if they fail to be put into the hands, they spawn on the ground
//Hooray for fallbacks!
//If you don't need any special effects like spawning glasses, then you don't need an add()

*/
