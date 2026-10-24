
/mob/living/carbon/human/dummy
	real_name = "Test Dummy"
	status_flags = CANPUSH
	mouse_drag_pointer = MOUSE_INACTIVE_POINTER
	visual_only_organs = TRUE
	var/in_use = FALSE

INITIALIZE_IMMEDIATE(/mob/living/carbon/human/dummy)

/mob/living/carbon/human/dummy/Initialize(mapload)
	. = ..()
	remove_from_all_data_huds()
	ADD_TRAIT(src, TRAIT_GODMODE, TRAIT_GENERIC)

// We don't want your dummy floating up and down in the preference menu.
/mob/living/carbon/human/dummy/mob_negates_gravity()
	return TRUE

/mob/living/carbon/human/dummy/prepare_data_huds()
	return

/mob/living/carbon/human/dummy/Destroy()
	in_use = FALSE
	return ..()

/mob/living/carbon/human/dummy/Life(delta_time = SSMOBS_DT, times_fired)
	return

/mob/living/carbon/human/dummy/set_species(datum/species/mrace, icon_update = TRUE)
	harvest_organs()
	return ..()

///Let's extract our dummies organs and limbs for storage, to reduce the cache missed that spamming a dummy cause
/mob/living/carbon/human/dummy/proc/harvest_organs()
	for(var/slot in list(ORGAN_SLOT_BRAIN, ORGAN_SLOT_HEART, ORGAN_SLOT_LUNGS, ORGAN_SLOT_APPENDIX, \
		ORGAN_SLOT_EYES, ORGAN_SLOT_EARS, ORGAN_SLOT_TONGUE, ORGAN_SLOT_LIVER, ORGAN_SLOT_STOMACH))
		var/obj/item/organ/current_organ = get_organ_slot(slot) //Time to cache it lads
		if(current_organ)
			current_organ.Remove(src, special = TRUE) //Please don't somehow kill our dummy
			SSwardrobe.stash_object(current_organ)

	var/datum/species/current_species = dna.species
	for(var/organ_path in current_species.mutant_organs)
		var/obj/item/organ/current_organ = get_organ_by_type(organ_path)
		if(current_organ)
			current_organ.Remove(src, special = TRUE) //Please don't somehow kill our dummy
			SSwardrobe.stash_object(current_organ)

	/*
	for(var/obj/item/organ/external/organ in internal_organs)
		if(organ.type in current_species.external_organs)
			organ.Remove(src)
			SSwardrobe.stash_object(organ)
	*/

//Instead of just deleting our equipment, we save what we can and reinsert it into SSwardrobe's store
//Hopefully this makes preference reloading not the worst thing ever
/mob/living/carbon/human/dummy/delete_equipment()
	var/list/items_to_check = get_equipped_items(INCLUDE_POCKETS|INCLUDE_HELD|INCLUDE_PROSTHETICS|INCLUDE_ABSTRACT)
	var/list/to_nuke = list() //List of items queued for deletion, can't qdel them before iterating their contents in case they hold something
	///Travel to the bottom of the contents chain, expanding it out
	for(var/i = 1; i <= length(items_to_check); i++) //Needs to be a c style loop since it can expand
		var/obj/item/checking = items_to_check[i]
		if(QDELETED(checking)) //Nulls in the list, depressing
			continue
		if(!isitem(checking)) //What the fuck are you on
			to_nuke += checking
			continue

		var/list/contents = checking.contents
		if(length(contents))
			items_to_check |= contents //Please don't make an infinite loop somehow thx
			to_nuke += checking //Goodbye
			continue

		//I'm making the bet that if you're empty of other items you're not going to OOM if reapplied. I assume you're here because I was wrong
		if(ismob(checking.loc))
			var/mob/checkings_owner = checking.loc
			checkings_owner.temporarilyRemoveItemFromInventory(checking, TRUE) //Clear out of there yeah?
		SSwardrobe.stash_object(checking)

	for(var/obj/item/delete as anything in to_nuke)
		qdel(delete)

/mob/living/carbon/human/dummy/has_equipped(obj/item/item, slot, initial = FALSE)
	SHOULD_CALL_PARENT(FALSE) // assuming direct control
	item.item_flags |= IN_INVENTORY
	if(!item.visual_equipped(src, slot, initial))
		return FALSE

	add_item_coverage(item)
	return TRUE

/mob/living/carbon/human/dummy/proc/wipe_state()
	delete_equipment()
	cut_overlays()

/mob/living/carbon/human/dummy/setup_human_dna()
	randomize_human_normie(src)

//Inefficient pooling/caching way.
GLOBAL_LIST_EMPTY(human_dummy_list)
GLOBAL_LIST_EMPTY(dummy_mob_list)

/proc/generate_or_wait_for_human_dummy(slotkey)
	if(!slotkey)
		return new /mob/living/carbon/human/dummy
	var/mob/living/carbon/human/dummy/D = GLOB.human_dummy_list[slotkey]
	if(istype(D))
		UNTIL(!D.in_use)
	if(QDELETED(D))
		D = new
		GLOB.human_dummy_list[slotkey] = D
		GLOB.dummy_mob_list += D
	else
		D.regenerate_icons() //they were cut in wipe_state()
	D.in_use = TRUE
	return D

/proc/generate_dummy_lookalike(slotkey, mob/target)
	if(!istype(target))
		return generate_or_wait_for_human_dummy(slotkey)

	var/mob/living/carbon/human/dummy/copycat = generate_or_wait_for_human_dummy(slotkey)

	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		carbon_target.dna.transfer_identity(copycat, transfer_SE = TRUE)

		if(ishuman(target))
			var/mob/living/carbon/human/human_target = target
			human_target.copy_clothing_prefs(copycat)

		copycat.updateappearance(icon_update=TRUE, mutcolor_update=TRUE, mutations_overlay_update=TRUE)
	else
		//even if target isn't a carbon, if they have a client we can make the
		//dummy look like what their human would look like based on their prefs
		target?.client?.prefs?.apply_prefs_to(copycat, TRUE)

	return copycat

/proc/unset_busy_human_dummy(slotkey)
	if(!slotkey)
		return
	var/mob/living/carbon/human/dummy/D = GLOB.human_dummy_list[slotkey]
	if(istype(D))
		D.wipe_state()
		D.in_use = FALSE

/proc/clear_human_dummy(slotkey)
	if(!slotkey)
		return

	var/mob/living/carbon/human/dummy/dummy = GLOB.human_dummy_list[slotkey]

	GLOB.human_dummy_list -= slotkey
	if(istype(dummy))
		GLOB.dummy_mob_list -= dummy
		qdel(dummy)

/mob/living/carbon/human/dummy/add_to_mob_list()
	return

/mob/living/carbon/human/dummy/remove_from_mob_list()
	return

/mob/living/carbon/human/dummy/add_to_alive_mob_list()
	return

/mob/living/carbon/human/dummy/remove_from_alive_mob_list()
	return

/// Takes in an accessory list and returns the first entry from that list, ensuring that we dont return SPRITE_ACCESSORY_NONE in the process.
/proc/get_consistent_feature_entry(list/accessory_feature_list)
	var/consistent_entry = (accessory_feature_list- SPRITE_ACCESSORY_NONE)[1]
	ASSERT(!isnull(consistent_entry))
	return consistent_entry

/proc/create_consistent_human_dna(mob/living/carbon/human/target)
	target.dna.features[FEATURE_MUTANT_COLOR] = COLOR_VIBRANT_LIME
	target.dna.features[FEATURE_ETHEREAL_COLOR] = GLOB.color_list_ethereal["Cyan"]
	target.dna.features[FEATURE_LIZARD_MARKINGS] = get_consistent_feature_entry(GLOB.lizard_markings_list)
	target.dna.features[FEATURE_EARS] = get_consistent_feature_entry(GLOB.ears_list)
	target.dna.features[FEATURE_FRILLS] = get_consistent_feature_entry(GLOB.frills_list)
	target.dna.features[FEATURE_HORNS] = get_consistent_feature_entry(GLOB.horns_list)
	target.dna.features[FEATURE_MOTH_ANTENNAE] = get_consistent_feature_entry(GLOB.moth_antennae_list)
	target.dna.features[FEATURE_MOTH_MARKINGS] = get_consistent_feature_entry(GLOB.moth_markings_list)
	target.dna.features[FEATURE_MOTH_WINGS] = get_consistent_feature_entry(GLOB.moth_wings_list)
	target.dna.features[FEATURE_SNOUT] = get_consistent_feature_entry(GLOB.snouts_list)
	target.dna.features[FEATURE_SPINES] = get_consistent_feature_entry(GLOB.spines_list)
	target.dna.features[FEATURE_TAIL_CAT] = get_consistent_feature_entry(GLOB.tails_list_felinid) // it's a lie
	target.dna.features[FEATURE_TAIL_LIZARD] = get_consistent_feature_entry(GLOB.tails_list_lizard)
	target.dna.features[FEATURE_TAIL_MONKEY] = get_consistent_feature_entry(GLOB.tails_list_monkey)
	target.dna.features["apid_stripes"] = "thick"
	target.dna.features[FEATURE_APID_HEADSTRIPES] = get_consistent_feature_entry(GLOB.apid_headstripes_list)
	target.dna.features[FEATURE_APID_ANTENNA] = get_consistent_feature_entry(GLOB.apid_antenna_list)
	target.dna.features["insect_type"] = "fly"
	target.dna.features[FEATURE_IPC_SCREEN] = "BSOD"
	target.dna.features[FEATURE_IPC_ANTENNA] = get_consistent_feature_entry(GLOB.ipc_antennas_list)
	target.dna.features["ipc_chassis"] = "Morpheus Cyberkinetics (Custom)"
	target.dna.features[FEATURE_PSYPHOZA_CAP] = get_consistent_feature_entry(GLOB.psyphoza_cap_list)
	target.dna.features[FEATURE_DIONA_LEAVES] = get_consistent_feature_entry(GLOB.diona_leaves_list)
	target.dna.features[FEATURE_DIONA_THORNS] = get_consistent_feature_entry(GLOB.diona_thorns_list)
	target.dna.features[FEATURE_DIONA_FLOWERS] = get_consistent_feature_entry(GLOB.diona_flowers_list)
	target.dna.features[FEATURE_DIONA_MOSS] = get_consistent_feature_entry(GLOB.diona_moss_list)
	target.dna.features[FEATURE_DIONA_MUSHROOM] = get_consistent_feature_entry(GLOB.diona_mushroom_list)
	target.dna.features[FEATURE_DIONA_ANTENNAE] = get_consistent_feature_entry(GLOB.diona_antennae_list)
	target.dna.features[FEATURE_DIONA_EYES] = get_consistent_feature_entry(GLOB.diona_eyes_list)
	target.dna.features[FEATURE_DIONA_PBODY] = get_consistent_feature_entry(GLOB.diona_pbody_list)
	target.dna.initialize_dna(create_mutation_blocks = FALSE, randomize_features = FALSE)
	// UF and UI are nondeterministic, even though the features are the same some blocks will randomize slightly
	// In practice this doesn't matter, but this is for the sake of 100%(ish) consistency
	var/static/consistent_UF
	var/static/consistent_UI
	if(isnull(consistent_UF) || isnull(consistent_UI))
		consistent_UF = target.dna.unique_features
		consistent_UI = target.dna.unique_identity
	else
		target.dna.unique_features = consistent_UF
		target.dna.unique_identity = consistent_UI

/// Provides a dummy that is consistently bald, white, naked, etc.
/mob/living/carbon/human/dummy/consistent

/mob/living/carbon/human/dummy/consistent/setup_human_dna()
	create_consistent_human_dna(src)

/// Provides a dummy for unit_tests that functions like a normal human, but with a standardized appearance
/// Copies the stock dna setup from the dummy/consistent type
/mob/living/carbon/human/consistent
	next_click = -1
	next_move = -1

/mob/living/carbon/human/consistent/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_INSTANT_DO_AFTER, INNATE_TRAIT)

/mob/living/carbon/human/consistent/setup_human_dna()
	create_consistent_human_dna(src)
	fully_replace_character_name(real_name, "John Doe")

/mob/living/carbon/human/consistent/domutcheck()
	return // We skipped adding any mutations so this runtimes

/mob/living/carbon/human/consistent/ClickOn(atom/A, params)
	next_click = -1
	next_move = -1
	. = ..()
