/**
 * ## Spellbook entries
 *
 * Wizard spellbooks are automatically populated with
 * a list of every spellbook entry subtype when they're made.
 *
 * Wizards can then buy entries from the book to learn magic,
 * invoke rituals, or summon items.
 */
/datum/spellbook_entry
	/// The name of the entry
	var/name
	/// The description of the entry
	var/desc
	/// The type of spell that the entry grants (typepath)
	var/datum/action/spell/spell_type
	/// What category the entry falls in
	var/category
	/// How many book charges does the spell take
	var/cost = 2
	/// How many times has the spell been purchased. Compared against limit.
	var/times = 0
	/// The limit on number of purchases from this entry in a given spellbook. If null, infinite are allowed.
	var/limit
	/// Is this refundable?
	var/refundable = TRUE
	/// Flavor. Verb used in saying how the spell is aquired. Ex "[Learn] Fireball" or "[Summon] Ghosts"
	var/buy_word = "Learn"
	/// The cooldown of the spell
	var/cooldown
	/// Whether the spell requires wizard garb or not
	var/requires_wizard_garb = FALSE
	/// Used so you can't have specific spells together
	var/list/no_coexistance_typecache
	/// Wildmagic wizard apprentice should not get these
	var/no_random = FALSE
	/// Locking the purchase down for whatever reason
	var/locked = FALSE
/datum/spellbook_entry/New()
	no_coexistance_typecache = typecacheof(no_coexistance_typecache)

	if(ispath(spell_type))
		if(isnull(limit))
			limit = initial(spell_type.spell_max_level)
		if(initial(spell_type.spell_requirements) & SPELL_REQUIRES_WIZARD_GARB)
			requires_wizard_garb = TRUE

/**
 * Determines if this entry can be purchased from a spellbook
 * Used for configs / round related restrictions.
 *
 * Return FALSE to prevent the entry from being added to wizard spellbooks, TRUE otherwise
 */
/datum/spellbook_entry/proc/can_be_purchased()
	if(!name || !desc || !category || locked) // Erroneously set or abstract
		return FALSE
	return TRUE

/**
 * Checks if the user, with the supplied spellbook, can purchase the given entry.
 *
 * Arguments
 * * user - the mob who's buying the spell
 * * book - what book they're buying the spell from
 *
 * Return TRUE if it can be bought, FALSE otherwise
 */
/datum/spellbook_entry/proc/can_buy(mob/living/carbon/human/user, obj/item/spellbook/book)
	if(book.uses < cost)
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
/datum/spellbook_entry/proc/buy_spell(mob/living/carbon/human/user, obj/item/spellbook/book)
	var/datum/action/spell/existing = locate(spell_type) in user.actions
	if(existing)
		var/before_name = existing.name
		if(!existing.level_spell())
			to_chat(user, ("<span class='warning'>This spell cannot be improved further!</span>"))
			return FALSE

		to_chat(user, ("<span class='notice'>You have improved [before_name] into [existing.name].</span>"))
		name = existing.name

		//we'll need to update the cooldowns for the spellbook
		set_spell_info()
		log_spellbook("[key_name(user)] improved their knowledge of [initial(existing.name)] to level [existing.spell_level] for [cost] points")
		SSblackbox.record_feedback("nested tally", "wizard_spell_improved", 1, list("[name]", "[existing.spell_level]"))
		log_purchase(user.key)
		return TRUE

	//No same spell found - just learn it
	var/datum/action/spell/new_spell = new spell_type(user.mind || user)
	new_spell.Grant(user)
	to_chat(user, ("<span class='notice'>You have learned [new_spell.name].</span>"))

	log_spellbook("[key_name(user)] learned [new_spell] for [cost] points")
	SSblackbox.record_feedback("tally", "wizard_spell_learned", 1, name)
	log_purchase(user.key)
	return TRUE

/datum/spellbook_entry/proc/log_purchase(key)
	if(!islist(GLOB.wizard_spellbook_purchases_by_key[key]))
		GLOB.wizard_spellbook_purchases_by_key[key] = list()

	for(var/list/log as anything in GLOB.wizard_spellbook_purchases_by_key[key])
		if(log[LOG_SPELL_TYPE] == type)
			log[LOG_SPELL_AMOUNT]++
			return

	var/list/to_log = list(
		LOG_SPELL_TYPE = type,
		LOG_SPELL_AMOUNT = 1,
	)
	GLOB.wizard_spellbook_purchases_by_key[key] += list(to_log)

/**
 * Checks if the user, with the supplied spellbook, can refund the entry
 *
 * Arguments
 * * user - the mob who's refunding the spell
 * * book - what book they're refunding the spell from
 *
 * Return TRUE if it can refunded, FALSE otherwise
 */
/datum/spellbook_entry/proc/can_refund(mob/living/carbon/human/user, obj/item/spellbook/book)
	if(!refundable)
		return FALSE
	if(!book.refunds_allowed)
		return FALSE

	for(var/datum/action/spell/other_spell in user.actions)
		if(initial(spell_type.name) == initial(other_spell.name))
			return TRUE

	return FALSE

/**
 * Actually refund the entry for the user
 *
 * Arguments
 * * user - the mob who's refunded the spell
 * * book - what book they're refunding the spell from
 *
 * Return -1 on failure, or return the point value of the refund on success
 */
/datum/spellbook_entry/proc/refund_spell(mob/living/carbon/human/user, obj/item/spellbook/book)
	for(var/datum/action/spell/to_refund in user.actions)
		if(initial(spell_type.name) != initial(to_refund.name))
			continue

		if(!to_refund.is_available())
			to_chat(user, span_warning("You can only refund spells that are available to cast!"))
			return -1

		var/amount_to_refund = to_refund.spell_level * cost
		if(amount_to_refund <= 0)
			return -1

		qdel(to_refund)
		name = initial(name)
		log_spellbook("[key_name(user)] refunded [src] for [amount_to_refund] points")
		return amount_to_refund

	return -1

/**
 * Set any of the spell info saved on our entry
 * after something has occured
 *
 * For example, updating the cooldown after upgrading it
 */
/datum/spellbook_entry/proc/set_spell_info()
	if(!spell_type)
		return

	cooldown = (initial(spell_type.cooldown_time) / 10)

/// Item summons, they give you an item.
/datum/spellbook_entry/item
	refundable = FALSE
	buy_word = "Summon"
	/// Typepath of what item we create when purchased
	var/obj/item/item_path

/datum/spellbook_entry/item/buy_spell(mob/living/carbon/human/user, obj/item/spellbook/book)
	var/atom/spawned_path = new item_path(get_turf(user))
	log_spellbook("[key_name(user)] bought [src] for [cost] points")
	SSblackbox.record_feedback("tally", "wizard_spell_learned", 1, name)
	try_equip_item(user, spawned_path)
	log_purchase(user.key)
	return spawned_path

/// Attempts to give the item to the buyer on purchase.
/datum/spellbook_entry/item/proc/try_equip_item(mob/living/carbon/human/user, obj/item/to_equip)
	var/was_put_in_hands = user.put_in_hands(to_equip)
	to_chat(user, ("<span class='notice'>\A [to_equip.name] has been summoned [was_put_in_hands ? "in your hands" : "at your feet"].</span>"))

/// Ritual, these cause station wide effects and are (pretty much) a blank slate to implement stuff in
/datum/spellbook_entry/summon
	category = "Rituals"
	limit = 1
	refundable = FALSE
	buy_word = "Cast"
	var/ritual_invocation // If set forces you to say a phrase as feedback when buying a summon spell

/datum/spellbook_entry/summon/buy_spell(mob/living/carbon/human/user, obj/item/spellbook/book)
	log_spellbook("[key_name(user)] cast [src] for [cost] points")
	SSblackbox.record_feedback("tally", "wizard_spell_learned", 1, name)
	log_purchase(user.key)
	say_invocation(user)
	return TRUE

/datum/spellbook_entry/summon/proc/say_invocation(mob/living/carbon/human/user)
	if(ritual_invocation)
		user.say(ritual_invocation, forced = "spell")

/// Non-purchasable flavor spells to populate the spell book with, for style.
/datum/spellbook_entry/challenge
	name = "Take the Challenge"
	category = "Challenges"
	refundable = FALSE
	buy_word = "Accept"

// See, non-purchasable.
/datum/spellbook_entry/challenge/can_buy(mob/living/carbon/human/user, obj/item/spellbook/book)
	return FALSE
