/// Global assoc list. [ckey] = [magician book entry type]
GLOBAL_LIST_EMPTY(magician_book_purchases_by_key)

/obj/item/magician
	name = "magician placeholder"
	desc = "You shouldn't see this, bug report this if you do."
	icon = 'icons/obj/magician.dmi'
	icon_state = "error"

/obj/item/magician/book
	name = "Book of Thaumaturgy"
	desc = "A book containing the secrets of stage magic."
	icon_state = "book_of_stage_magic"
	item_state = "magician"
	worn_icon_state = "book_magic"
	lefthand_file = 'icons/mob/inhands/misc/books_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/books_righthand.dmi'
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BELT
	item_flags = ISWEAPON
	drop_sound = 'sound/items/handling/book_drop.ogg'
	pickup_sound =  'sound/items/handling/book_pickup.ogg'
	attack_verb_continuous = list("bashes", "whacks", "bonks")
	attack_verb_simple = list("bash", "whack", "bonk")
	resistance_flags = FLAMMABLE

	var/magic_knowledge = 10 //basically telecrystals but for magicians.

	var/datum/mind/owner = null

	var/owner_name = "no one"

	/// A list to all magician entries within
	var/list/entries = list()

	var/list/ui_entries = list()

	var/magician_level = MAGICIAN_LEVEL_NOVICE

	var/magician_xp = MAGICIAN_XP

	var/magician_xp_to_next = MAGICIAN_XP_TO_NEXT



/obj/item/magician/book/Initialize(mapload)
	. = ..()
	prepare_spells()
	build_ui_entries()

/obj/item/magician/book/proc/build_ui_entries()
	ui_entries = list()
	for (var/datum/magician_entry/E in entries)
		ui_entries += list(E.ui_entry())

/obj/item/magician/book/Destroy(force)
	owner = null
	entries.Cut()
	return ..()

/obj/item/magician/book/examine(mob/user)
	. = ..()
	. += "<span class='notice'>This book is currently attuned to [owner_name].</span>"

/obj/item/magician/book/ui_state(mob/user)
	. = ..()
	if(!owner)
		owner = user.mind
	owner_name = owner ? owner.current.real_name : "no one"
	if(!user.can_read(src))
		return GLOB.never_state
	if(!user.mind || user.mind != owner)
		to_chat(user, span_warning("Only [owner.name] can read this book!"))
		return GLOB.never_state
	user.visible_message(span_notice("[user] opens the book of thaumaturgy and begins reading intently."))

/obj/item/magician/book/attack_self(mob/user)
	ui_interact(user)

/obj/item/magician/book/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MagicianBook", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/item/magician/book/ui_data(mob/user)
	var/list/data = list()
	data["owner"] = owner_name
	data["magicknowledge"] = magic_knowledge
	data["magician_level"] = magician_level
	data["magician_xp"] = magician_xp
	data["magician_xp_to_next"] = magician_xp_to_next

	var/list/entry_data = list()
	for (var/datum/magician_entry/entry in entries)
		entry_data += list(entry.ui_entry())

	data["magician_entry"] = entry_data
	return data


/// Instantiates our list of spellbook entries.
/obj/item/magician/book/proc/prepare_spells()
	var/entry_types = subtypesof(/datum/magician_entry)
	for(var/type in entry_types)
		var/datum/magician_entry/possible_entry = new type()
		if(!possible_entry.can_be_purchased())
			qdel(possible_entry)
			continue

		possible_entry.set_spell_info() //loads up things for the entry that require checking spell instance.
		entries |= possible_entry

//This is a MASSIVE amount of data, please be careful if you remove it from static.
/obj/item/magician/book/ui_static_data(mob/user)
	var/list/data = list()
	// Collect all info from each intry.
	var/list/entry_data = list()
	for(var/datum/magician_entry/entry as anything in entries)
		var/list/individual_entry_data = list()
		individual_entry_data["name"] = entry.name
		individual_entry_data["desc"] = entry.desc
		individual_entry_data["ref"] = REF(entry)
		individual_entry_data["requires_wizard_garb"] = entry.requires_magician_focus
		individual_entry_data["cost"] = entry.cost
		individual_entry_data["times"] = entry.times
		individual_entry_data["cooldown"] = entry.cooldown
		individual_entry_data["cat"] = entry.category
		individual_entry_data["limit"] = entry.limit
		entry_data += list(individual_entry_data)

	data["entries"] = entry_data
	return data

/obj/item/magician/book/proc/purchase_spell(spell_id)
	// Placeholder
	return

/obj/item/magician/book/ui_act(action, params)
	if(..())
		return
	var/mob/living/carbon/human/magician = usr
	switch(action)
		if("purchase")
			var/datum/magician_entry/entry = locate(params["spellref"]) in entries
			return purchase_entry(entry, magician)
	update_icon()

/// Attempts to purchased the passed entry [to_buy] for [user].
/obj/item/magician/book/proc/purchase_entry(datum/magician_entry/to_buy, mob/living/carbon/human/user)
	if(!istype(to_buy))
		CRASH("Magician book attempted to buy an invalid entry. Got: [to_buy ? "[to_buy] ([to_buy.type])" : "null"]")
	if(!to_buy.can_buy(user, src))
		return FALSE
	if(!to_buy.buy_spell(user, src))
		return FALSE

	to_buy.times++
	magic_knowledge -= to_buy.cost

	if(istype(to_buy, /datum/magician_entry/spell))
		playsound(loc, 'sound/magic/magic_block_holy.ogg', 50, 1) // Spell sound
	else
		playsound(loc, 'sound/magic/magic_missile.ogg', 50, 1) // Non-spell sound (replace with appropriate path)


	return TRUE

/obj/item/magician/book/debug
	name = "Debug Book of Thaumaturgy"
	magic_knowledge = 9999 //enough for everything you may need
