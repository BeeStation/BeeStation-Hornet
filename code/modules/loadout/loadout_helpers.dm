/**
 * Equips this mob with a given outfit and loadout items as per the passed preferences.
 *
 * Loadout items override the pre-existing item in the corresponding slot of the job outfit.
 * Some job items are preserved after being overridden - belt items, ear items, and glasses.
 * The rest of the slots, the items are overridden completely and deleted.
 *
 * Species with special outfits are snowflaked to have loadout items placed in their bags instead of overriding the outfit.
 *
 * * outfit - the job outfit we're equipping
 * * preference_source - the preferences to draw loadout items from.
 * * visuals_only - whether we call special equipped procs, or if we just look like we equipped it
 */
/mob/living/carbon/human/proc/equip_outfit_and_loadout(
	datum/outfit/outfit = /datum/outfit,
	datum/preferences/preference_source,
	visuals_only = FALSE,
)
	if(isnull(preference_source))
		return equipOutfit(outfit, visuals_only)

	var/datum/outfit/equipped_outfit
	if(ispath(outfit, /datum/outfit))
		equipped_outfit = new outfit()
	else if(istype(outfit, /datum/outfit))
		equipped_outfit = outfit
	else
		CRASH("Invalid outfit passed to equip_outfit_and_loadout ([outfit])")

	var/list/loadout_datums = loadout_list_to_datums(preference_source.equipped_gear)
	var/jumpsuit_style = preference_source.read_character_preference(/datum/preference/choiced/jumpsuit_style)

	// Insert loadout item paths into the outfit slots before equipping
	for(var/datum/gear/item as anything in loadout_datums)
		item.insert_path_into_outfit(equipped_outfit, src, visuals_only, jumpsuit_style)

	// Equip the outfit with loadout items baked in
	if(!equipped_outfit.equip(src, visuals_only))
		return FALSE

	// Handle any snowflake post-equip effects
	var/list/new_contents = get_all_gear()
	var/update = NONE
	for(var/datum/gear/item as anything in loadout_datums)
		var/item_path = (item.skirt_path && jumpsuit_style == PREF_SKIRT) ? item.skirt_path : item.path
		var/obj/item/equipped = locate(item_path) in new_contents
		if(isnull(equipped))
			continue
		update |= item.on_equip_item(
			equipped_item = equipped,
			preference_source = preference_source,
			equipper = src,
			visuals_only = visuals_only,
		)

	if(update)
		update_clothing(update)

	return TRUE

/**
 * Takes a list of gear IDs (such as equipped_gear from preferences)
 * and returns a list of their singleton gear datums.
 *
 * * loadout_list - the list of gear IDs to look up
 *
 * Returns a list of singleton datums
 */
/proc/loadout_list_to_datums(list/loadout_list) as /list
	var/list/datums = list()

	if(!length(GLOB.gear_datums))
		CRASH("No gear datums in the global gear list!")

	for(var/gear_id in loadout_list)
		var/datum/gear/actual_datum = GLOB.gear_datums[gear_id]
		if(!istype(actual_datum, /datum/gear))
			stack_trace("Could not find ([gear_id]) gear item in the global list of gear datums!")
			continue

		datums += actual_datum

	return datums

/**
 * Place our item path into the appropriate slot of the passed outfit datum.
 *
 * Slot assignment rules:
 * - Belt, ears, and glasses slots preserve the displaced outfit item by moving it to backpack_contents.
 * - All other slots are overridden and replaced without preservation.
 * - Plasmaman head/uniform slots are snowflaked into backpack_contents instead.
 * - Items with no slot are placed in backpack_contents.
 *
 * Arguments:
 * * equipped_outfit - the outfit we're inserting our item path into
 * * equipper - the mob being equipped
 * * visuals_only - if TRUE, skip non-visual items (no backpack contents)
 * * jumpsuit_style - the player's skirt preference, for selecting skirt variant paths
 */
/datum/gear/proc/insert_path_into_outfit(datum/outfit/equipped_outfit, mob/living/carbon/human/equipper, visuals_only = FALSE, jumpsuit_style = null)
	if(!is_equippable)
		return

	// Role restriction check
	if(allowed_roles && equipper.mind && !(equipper.mind.assigned_role in allowed_roles))
		if(equipper.client)
			to_chat(equipper, span_warning("Your current role does not permit you to spawn with [display_name]!"))
		return

	// Species restriction checks
	if(equipper.dna)
		if(species_blacklist && (equipper.dna.species.id in species_blacklist))
			if(equipper.client)
				to_chat(equipper, span_warning("Your current species does not permit you to spawn with [display_name]!"))
			return
		if(species_whitelist && !(equipper.dna.species.id in species_whitelist))
			if(equipper.client)
				to_chat(equipper, span_warning("Your current species does not permit you to spawn with [display_name]!"))
			return

	var/item_path = (skirt_path && jumpsuit_style == PREF_SKIRT) ? skirt_path : path

	if(!slot)
		if(!visuals_only)
			LAZYADD(equipped_outfit.backpack_contents, item_path)
		return

	// Plasmaman snowflake: head and uniform go into the backpack instead
	if(isplasmaman(equipper) && (slot == ITEM_SLOT_HEAD || slot == ITEM_SLOT_ICLOTHING))
		if(!visuals_only)
			LAZYADD(equipped_outfit.backpack_contents, item_path)
		return

	// Assign to the outfit's slot var, preserving displaced belt/ears/glasses into backpack_contents
	switch(slot)
		if(ITEM_SLOT_ICLOTHING)
			equipped_outfit.uniform = item_path
		if(ITEM_SLOT_OCLOTHING)
			equipped_outfit.suit = item_path
		if(ITEM_SLOT_BACK)
			equipped_outfit.back = item_path
		if(ITEM_SLOT_BELT)
			if(equipped_outfit.belt)
				LAZYADD(equipped_outfit.backpack_contents, equipped_outfit.belt)
			equipped_outfit.belt = item_path
		if(ITEM_SLOT_GLOVES)
			equipped_outfit.gloves = item_path
		if(ITEM_SLOT_FEET)
			equipped_outfit.shoes = item_path
		if(ITEM_SLOT_HEAD)
			equipped_outfit.head = item_path
		if(ITEM_SLOT_MASK)
			equipped_outfit.mask = item_path
		if(ITEM_SLOT_NECK)
			equipped_outfit.neck = item_path
		if(ITEM_SLOT_EARS)
			if(equipped_outfit.ears)
				LAZYADD(equipped_outfit.backpack_contents, equipped_outfit.ears)
			equipped_outfit.ears = item_path
		if(ITEM_SLOT_EYES)
			if(equipped_outfit.glasses)
				LAZYADD(equipped_outfit.backpack_contents, equipped_outfit.glasses)
			equipped_outfit.glasses = item_path
		if(ITEM_SLOT_ID)
			equipped_outfit.id = item_path
		if(ITEM_SLOT_LPOCKET)
			equipped_outfit.l_pocket = item_path
		if(ITEM_SLOT_RPOCKET)
			equipped_outfit.r_pocket = item_path
		if(ITEM_SLOT_SUITSTORE)
			equipped_outfit.suit_store = item_path
		else
			// Unrecognized slot — fall back to backpack
			if(!visuals_only)
				LAZYADD(equipped_outfit.backpack_contents, item_path)

/**
 * Called when this gear item has been equipped onto [equipper].
 *
 * At this point the item is in the mob's contents.
 * Override in subtypes for special post-equip behavior.
 *
 * Arguments:
 * * equipped_item - the actual item object that was equipped
 * * preference_source - the datum/preferences this loadout originated from
 * * equipper - the mob being equipped
 * * visuals_only - if TRUE, skip non-visual effects
 *
 * Returns a bitflag of slot flags to update via update_clothing()
 */
/datum/gear/proc/on_equip_item(
	obj/item/equipped_item,
	datum/preferences/preference_source,
	mob/living/carbon/human/equipper,
	visuals_only = FALSE,
)
	return NONE
