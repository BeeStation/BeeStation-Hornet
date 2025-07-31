

/**
 * ## Magician entries (possibly ripped off of wizard entries)
 *
 * Magician books are automatically populated with
 * a list of every magic entry subtype when they're made.
 *
 * Magicians can then buy entries from their book to learn magic,
 * invoke rituals, or summon items.
 */
/datum/magician_entry
	/// The name of the entry
	var/name
	/// The description of the entry
	var/desc
	/// The type of spell that the entry grants (typepath)
	var/datum/action/spell/spell_type
	/// What category the entry falls in
	var/category
	/// How much 'knowledge' does the spell costs
	var/cost = 2
	/// How many times has the spell been purchased. Compared against limit.
	var/times = 0
	/// The limit on number of purchases from this entry in a given magician book. If null, infinite are allowed.
	var/limit
	/// The cooldown of the spell
	var/cooldown
	/// Whether the spell requires magician focus or not
	var/requires_magician_focus = FALSE
	/// Used so you can't have specific spells together
	var/list/no_coexistance_typecache
	/// Locking the purchase down for whatever reason
	var/locked = FALSE
	/// Magician level required for spell/item purchase.
	var/magician_level = MAGICIAN_LEVEL_NOVICE // default required level to unlock this entry
	/// The magician's current XP needed to level up, used for progression.
	var/magician_xp_to_next = MAGICIAN_XP_TO_NEXT
	/// The magician's current XP, used for progression.
	var/magician_xp = MAGICIAN_XP
	/// The magician levels themselves.
	var/list/MAGICIAN_LEVELS = list(MAGICIAN_LEVEL_NOVICE, MAGICIAN_LEVEL_APPRENTICE, MAGICIAN_LEVEL_JOURNEYMAN, MAGICIAN_LEVEL_EXPERT, MAGICIAN_LEVEL_MASTER)
	/// How much XP is rewarded._dm_db_new_con()
	var/xp_reward = 1


/datum/magician_entry/New()
	no_coexistance_typecache = typecacheof(no_coexistance_typecache)

	if(ispath(spell_type))
		var/datum/action/spell/tmp = new spell_type()
		if(tmp.spell_requirements & SPELL_REQUIRES_MAGICIAN_FOCUS)
			requires_magician_focus = TRUE
		qdel(tmp)

/**
 * Determines if this entry can be purchased from a magician book
 * Used for configs / round related restrictions and levels.
 *
 * Return FALSE to prevent the entry from being added to magician books, TRUE otherwise
 */
/datum/magician_entry/proc/can_be_purchased(obj/item/magician/book)
	if(!name || !desc || !category || locked)
		return FALSE

	var/book_level_index = MAGICIAN_LEVELS.Find(magician_level)
	var/required_level_index = MAGICIAN_LEVELS.Find(magician_level)
	if(book_level_index < required_level_index)
		return FALSE

	return TRUE


/**
 * Checks if the user, with the supplied magician book, can purchase the given entry.
 *
 * Arguments
 * * user - the mob who's buying the spell
 * * book - what book they're buying the spell from
 *
 * Return TRUE if it can be bought, FALSE otherwise
 */
/datum/magician_entry/proc/can_buy(mob/living/carbon/human/user, obj/item/magician/book/book)
	if(book.magic_knowledge < cost)
		return FALSE
	if(!isnull(limit) && times >= limit)
		return FALSE
	for(var/spell in user.actions)
		if(is_type_in_typecache(spell, no_coexistance_typecache))
			return FALSE
	return TRUE

/**
 * Actually buy the entry for the user
 *
 * Arguments
 * * user - the mob who's bought the spell
 * * book - what book they've bought the spell from
 *
 * Return TRUE if the purchase was successful, FALSE otherwise
 */
/datum/magician_entry/proc/buy_spell(mob/living/carbon/human/user, obj/item/magician/book/book)
	var/datum/action/spell/existing = locate(spell_type) in user.actions
	if(existing)
		var/before_name = existing.name
		if(!existing.level_spell())
			to_chat(user, ("<span class='warning'>This spell cannot be improved further!</span>"))
			return FALSE

		to_chat(user, ("<span class='notice'>You have improved [before_name] into [existing.name].</span>"))
		name = existing.name

		set_spell_info()
		log_magician_book("[key_name(user)] improved their knowledge of [initial(existing.name)] to level [existing.spell_level] for [cost] knowledge")
		SSblackbox.record_feedback("nested tally", "magician_spell_improved", 1, list("[name]", "[existing.spell_level]"))
		log_purchase(user.key)

		book.magician_xp += xp_reward
		return TRUE

	// New spell
	var/datum/action/spell/new_spell = new spell_type(user.mind || user)
	new_spell.Grant(user)
	to_chat(user, ("<span class='notice'>You have learned [new_spell.name].</span>"))

	log_magician_book("[key_name(user)] learned [new_spell] for [cost] knowledge")
	SSblackbox.record_feedback("tally", "magician_spell_learned", 1, name)
	log_purchase(user.key)

	book.magician_xp += xp_reward

	return TRUE


/datum/magician_entry/proc/log_purchase(key)
	if(!islist(GLOB.magician_book_purchases_by_key[key]))
		GLOB.magician_book_purchases_by_key[key] = list()

	for(var/list/log as anything in GLOB.magician_book_purchases_by_key[key])
		if(log[LOG_SPELL_TYPE] == type)
			log[LOG_SPELL_AMOUNT]++
			return

	var/list/to_log = list(
		LOG_SPELL_TYPE = type,
		LOG_SPELL_AMOUNT = 1,
	)
	GLOB.magician_book_purchases_by_key[key] += list(to_log)

/**
 * Set any of the spell info saved on our entry
 * after something has occured
 *
 * For example, updating the cooldown after upgrading it
 */
/datum/magician_entry/proc/set_spell_info()
	if(!spell_type)
		return

	cooldown = (initial(spell_type.cooldown_time) / 10)

/// Item summons, they give you an item.
/datum/magician_entry/item
	/// Typepath of what item we create when purchased
	var/obj/item/item_path

/datum/magician_entry/item/buy_spell(mob/living/carbon/human/user, obj/item/magician/book/book)
	var/atom/spawned_path = new item_path(get_turf(user))
	log_magician_book("[key_name(user)] bought [src] for [cost] knowledge")
	SSblackbox.record_feedback("tally", "magician_spell_learned", 1, name)
	try_equip_item(user, spawned_path)
	log_purchase(user.key)
	return spawned_path

/// Attempts to give the item to the buyer on purchase.
/datum/magician_entry/item/proc/try_equip_item(mob/living/carbon/human/user, obj/item/to_equip)
	var/was_put_in_hands = user.put_in_hands(to_equip)
	to_chat(user, ("<span class='notice'>\A [to_equip.name] has been summoned [was_put_in_hands ? "in your hands" : "at your feet"].</span>"))

/datum/magician_entry/summon/buy_spell(mob/living/carbon/human/user, obj/item/magician/book/book)
	log_magician_book("[key_name(user)] cast [src] for [cost] knowledge")
	SSblackbox.record_feedback("tally", "magician_spell_learned", 1, name)
	log_purchase(user.key)
	return TRUE

//fixing stuff
/datum/magician_entry/proc/ui_entry()
	var/list/L = list()
	if(!name || !desc || !category)
		message_admins("ui_entry() missing info in [type]")
		return L
	L["title"] = name
	L["description"] = desc
	L["category"] = category
	L["ref"] = REF(src)
	L["cost"] = cost
	L["times"] = times
	L["cooldown"] = cooldown
	L["requires_magician_focus"] = requires_magician_focus
	L["limit"] = limit
	L["magician_level"] = magician_level
	L["no_coexistance_typecache"] = no_coexistance_typecache
	L["magician_xp"] = magician_xp
	L["magician_xp_to_next"] = magician_xp_to_next
	L["is_spell"] = !isnull(spell_type)
	return L

