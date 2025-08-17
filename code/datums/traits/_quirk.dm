//every quirk in this folder should be coded around being applied on spawn
//these are NOT "mob quirks" like GOTTAGOFAST, but exist as a medium to apply them and other different effects
/datum/quirk
	/// The name of the quirk
	var/name = "Test Quirk"
	/// The description of the quirk
	var/desc = "This is a test quirk."
	/// The icon to show in the preferences menu.
	/// This references a tgui icon, so it can be FontAwesome or a tgfont (with a tg- prefix).
	var/icon
	///Positive if the quirk is beneficial to gameplay, negative if the quirk is restrictive/harmful, 0 if the quirk has no substantial impact on gameplay
	var/quirk_value = 0
	var/list/restricted_mobtypes = list(/mob/living/carbon/human) //specifies valid mobtypes, have a good reason to change this
	var/list/restricted_species //specifies valid species, use /datum/species/
	var/species_whitelist = TRUE //whether restricted_species is a whitelist or a blacklist
	/// Text displayed when this quirk is assigned to a mob (and not transferred)
	var/gain_text
	/// Text displayed when this quirk is removed from a mob (and not transferred)
	var/lose_text
	///This text will appear on medical records for the trait.
	var/medical_record_text
	var/mood_quirk = FALSE //if true, this quirk affects mood and is unavailable if moodlets are disabled
	/// if applicable, apply and remove this mob trait
	var/mob_trait
	var/process = FALSE // Does this quirk use on_process()?
	var/datum/mind/quirk_holder // The mind that contains this quirk
	var/mob/living/quirk_target // The mob that will be affected by this quirk
	/// When making an abstract quirk (in OOP terms), don't forget to set this var to the type path for that abstract quirk.
	var/abstract_parent_type = /datum/quirk

/datum/quirk/New(datum/mind/quirk_mind, mob/living/quirk_mob, spawn_effects)
	..()
	if(!quirk_mind)
		qdel(src)
		return
	if(!quirk_mob || quirk_mob.has_quirk(type))
		qdel(src)
		return
	quirk_holder = quirk_mind
	quirk_target = quirk_mob
	SSquirks.quirk_objects += src
	to_chat(quirk_target, gain_text)
	quirk_holder.quirks += src
	if(process)
		START_PROCESSING(SSquirks, src)
	RegisterSignal(quirk_holder, COMSIG_QDELETING, PROC_REF(handle_holder_del))
	RegisterSignal(quirk_target, COMSIG_QDELETING, PROC_REF(handle_mob_del))
	if(!is_valid_quirk_target(quirk_target)) //at this point the quirk is saved to the mind
		return

	if(mob_trait)
		ADD_TRAIT(quirk_target, mob_trait, ROUNDSTART_TRAIT)
	add()
	if(spawn_effects)
		add_unique()
		on_spawn()
		addtimer(CALLBACK(src, PROC_REF(post_add)), 30)

/datum/quirk/Destroy()
	if(process)
		STOP_PROCESSING(SSquirks, src)
	if(quirk_holder)
		remove()
		UnregisterSignal(quirk_holder, COMSIG_QDELETING)
		if(!QDELETED(quirk_target))
			UnregisterSignal(quirk_target, COMSIG_QDELETING)
			to_chat(quirk_target, lose_text)
		quirk_holder.quirks -= src
		if(mob_trait)
			REMOVE_TRAIT(quirk_target, mob_trait, ROUNDSTART_TRAIT)
		quirk_holder = null
		quirk_target = null
	SSquirks.quirk_objects -= src
	return ..()

/* Don't use this, use the mind's transfer_to proc instead */
/datum/quirk/proc/transfer_mob(mob/living/to_mob)
	UnregisterSignal(quirk_target, COMSIG_QDELETING)
	if(is_valid_quirk_target(quirk_target))
		if(mob_trait)
			REMOVE_TRAIT(quirk_target, mob_trait, ROUNDSTART_TRAIT)
		remove()
	quirk_target = to_mob
	if(process)
		START_PROCESSING(SSquirks, src)
	RegisterSignal(quirk_target, COMSIG_QDELETING, PROC_REF(handle_mob_del))
	if(is_valid_quirk_target(quirk_target))
		if(mob_trait)
			ADD_TRAIT(to_mob, mob_trait, ROUNDSTART_TRAIT)
		add()
	on_transfer()

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

/datum/quirk/proc/on_spawn() //these should only trigger when the character is being created for the first time, i.e. roundstart/latejoin
/datum/quirk/proc/on_process() //process() has some special checks, so this is the actual process
/datum/quirk/proc/on_transfer() //code called right before the quirk is transferred to a new mob

/datum/quirk/proc/handle_holder_del()
	SIGNAL_HANDLER
	qdel(src)

/datum/quirk/proc/handle_mob_del()
	SIGNAL_HANDLER
	UnregisterSignal(quirk_target, COMSIG_QDELETING)
	STOP_PROCESSING(SSquirks, src)
	quirk_target = null

/datum/quirk/process(delta_time)
	if(quirk_target.stat == DEAD)
		return
	if(!is_valid_quirk_target(quirk_target))
		return
	on_process(delta_time)

/datum/quirk/proc/is_valid_quirk_target(mob/living/M)
	if(!is_type_in_list(M, restricted_mobtypes))
		return
	if(!restricted_species)
		return TRUE
	else
		var/datum/dna/mob_dna = M.has_dna()
		if(!mob_dna)
			return
		var/isvalid = is_type_in_list(mob_dna.species, restricted_species)
		if(species_whitelist != isvalid)
			return
		return TRUE

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
		quirk_item = new quirk_item(get_turf(quirk_holder))

	var/mob/living/carbon/human/human_holder = quirk_holder

	var/where = human_holder.equip_in_one_of_slots(quirk_item, valid_slots, qdel_on_fail = FALSE) || default_location

	if(where == LOCATION_BACKPACK)
		open_backpack = TRUE

	if(notify_player)
		LAZYADD(where_items_spawned, span_boldnotice("You have \a [quirk_item] [where]. [flavour_text]"))

/datum/quirk/item_quirk/post_add()
	if(open_backpack)
		var/mob/living/carbon/human/human_holder = quirk_holder
		// post_add() can be called via delayed callback. Check they still have a backpack equipped before trying to open it.
		if(human_holder.back)
			human_holder.back.atom_storage.show_contents(human_holder)

	for(var/chat_string in where_items_spawned)
		to_chat(quirk_holder, chat_string)

	where_items_spawned = null

/**
 * get_quirk_string() is used to get a printable string of all the quirk traits someone has for certain criteria
 *
 * Arguments:
 * * Medical- If we want the long, fancy descriptions that show up in medical records, or if not, just the name
 * * Category- Which types of quirks we want to print out. Defaults to everything
 * * from_scan- If the source of this call is like a health analyzer or HUD, in which case QUIRK_HIDE_FROM_MEDICAL hides the quirk.
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

/datum/quirk/nearsighted/on_spawn()
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
