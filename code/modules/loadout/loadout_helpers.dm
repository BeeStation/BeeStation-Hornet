/**
 * Equips this mob with a given outfit and loadout items as per the passed preferences.
 *
 * Loadout items override the pre-existing item in the corresponding slot of the job outfit.
 * Anything bumped out of a slot gets boxed up. see box_displaced_loadout_gear()
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

	// We make the outfit establish its job/species baseline first
	equipped_outfit.pre_equip(src, visuals_only)

	var/list/displaced_gear = list()

	// Then we insert loadout item paths into the outfit slots, it overrides anything pre_equip() set
	for(var/datum/gear/item as anything in loadout_datums)
		item.insert_path_into_outfit(equipped_outfit, src, visuals_only, jumpsuit_style, displaced_gear)

	// Equip the outfit with loadout items baked in
	if(!equipped_outfit.finish_equip(src, visuals_only))
		return FALSE

	if(length(displaced_gear) && !visuals_only)
		box_displaced_loadout_gear(displaced_gear)

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
 * Boxes up standard gear that got bumped out of its slot by a loadout item
 *
 * A single box is spawned and shared by every displaced item from one equip pass,
 * then shoved into the mob's inventory ( preferably backpack if there's room for it)
 *
 * * gear_paths - list of item type paths to spawn inside the box
 */
/mob/living/carbon/human/proc/box_displaced_loadout_gear(list/gear_paths)
	if(!length(gear_paths))
		return
	var/obj/item/storage/box/spawned_box = new(src)
	spawned_box.name = "compression box of standard gear"
	for(var/gear_path in gear_paths)
		new gear_path(spawned_box)
	equip_to_slot_or_del(spawned_box, ITEM_SLOT_BACKPACK, TRUE)
	if(client)
		to_chat(src, span_notice("A box with your standard-issue equipment was stashed in your inventory!"))

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
 * - Any slot that already has an item on the outfit (either pre_equip() or an earlier loadout item)
 *   has that displaced item queued into displaced_gear, and be boxed up after equipping finishes.
 * - Plasmaman head/uniform slots are snowflaked garbage, and the loadout item goes in the box instead of being worn,
 *   since that gear can't be safely removed from a plasmaman
 * - Items with no slot are placed directly in backpack_contents.
 *
 * Arguments:
 * * equipped_outfit - the outfit we're inserting our item path into
 * * equipper - the mob being equipped
 * * visuals_only - if TRUE, skip non-visual items (no backpack contents, no displaced gear)
 * * jumpsuit_style - the player's skirt preference, for selecting skirt variant paths
 * * displaced_gear - list to collect item type paths bumped out of their slot, for later boxing
 */
/datum/gear/proc/insert_path_into_outfit(datum/outfit/equipped_outfit, mob/living/carbon/human/equipper, visuals_only = FALSE, jumpsuit_style = null, list/displaced_gear)
	if(!is_equippable)
		return

	// Role restriction check
	var/equipper_role = equipper.mind?.assigned_role?.title || equipper.job
	if(allowed_roles && equipper_role && !(equipper_role in allowed_roles))
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

	// Plasmaman snowflake
	if(isplasmaman(equipper) && (slot == ITEM_SLOT_HEAD || slot == ITEM_SLOT_ICLOTHING))
		if(!visuals_only)
			LAZYADD(displaced_gear, item_path)
		return

	// Assign to the outfit's slot var, queueing up whatever was already there to be boxed
	switch(slot)
		if(ITEM_SLOT_ICLOTHING)
			if(equipped_outfit.uniform && !visuals_only)
				LAZYADD(displaced_gear, equipped_outfit.uniform)
			equipped_outfit.uniform = item_path
		if(ITEM_SLOT_OCLOTHING)
			if(equipped_outfit.suit && !visuals_only)
				LAZYADD(displaced_gear, equipped_outfit.suit)
			equipped_outfit.suit = item_path
		if(ITEM_SLOT_BACK)
			if(equipped_outfit.back && !visuals_only)
				LAZYADD(displaced_gear, equipped_outfit.back)
			equipped_outfit.back = item_path
		if(ITEM_SLOT_BELT)
			if(equipped_outfit.belt && !visuals_only)
				LAZYADD(displaced_gear, equipped_outfit.belt)
			equipped_outfit.belt = item_path
		if(ITEM_SLOT_GLOVES)
			if(equipped_outfit.gloves && !visuals_only)
				LAZYADD(displaced_gear, equipped_outfit.gloves)
			equipped_outfit.gloves = item_path
		if(ITEM_SLOT_FEET)
			if(equipped_outfit.shoes && !visuals_only)
				LAZYADD(displaced_gear, equipped_outfit.shoes)
			equipped_outfit.shoes = item_path
		if(ITEM_SLOT_HEAD)
			if(equipped_outfit.head && !visuals_only)
				LAZYADD(displaced_gear, equipped_outfit.head)
			equipped_outfit.head = item_path
		if(ITEM_SLOT_MASK)
			if(equipped_outfit.mask && !visuals_only)
				LAZYADD(displaced_gear, equipped_outfit.mask)
			equipped_outfit.mask = item_path
		if(ITEM_SLOT_NECK)
			if(equipped_outfit.neck && !visuals_only)
				LAZYADD(displaced_gear, equipped_outfit.neck)
			equipped_outfit.neck = item_path
		if(ITEM_SLOT_EARS)
			if(equipped_outfit.ears && !visuals_only)
				LAZYADD(displaced_gear, equipped_outfit.ears)
			equipped_outfit.ears = item_path
		if(ITEM_SLOT_EYES)
			if(equipped_outfit.glasses && !visuals_only)
				LAZYADD(displaced_gear, equipped_outfit.glasses)
			equipped_outfit.glasses = item_path
		if(ITEM_SLOT_ID)
			if(equipped_outfit.id && !visuals_only)
				LAZYADD(displaced_gear, equipped_outfit.id)
			equipped_outfit.id = item_path
		if(ITEM_SLOT_LPOCKET)
			if(equipped_outfit.l_pocket && !visuals_only)
				LAZYADD(displaced_gear, equipped_outfit.l_pocket)
			equipped_outfit.l_pocket = item_path
		if(ITEM_SLOT_RPOCKET)
			if(equipped_outfit.r_pocket && !visuals_only)
				LAZYADD(displaced_gear, equipped_outfit.r_pocket)
			equipped_outfit.r_pocket = item_path
		if(ITEM_SLOT_SUITSTORE)
			if(equipped_outfit.suit_store && !visuals_only)
				LAZYADD(displaced_gear, equipped_outfit.suit_store)
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
	if(isnull(equipped_item))
		return NONE

	var/update_flag = NONE

	return update_flag
