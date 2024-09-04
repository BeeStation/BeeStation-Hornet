
/mob/living/carbon/human/dummy
	real_name = "Test Dummy"
	status_flags = GODMODE|CANPUSH
	mouse_drag_pointer = MOUSE_INACTIVE_POINTER
	var/in_use = FALSE

INITIALIZE_IMMEDIATE(/mob/living/carbon/human/dummy)

/mob/living/carbon/human/dummy/Initialize(mapload)
	. = ..()
	remove_from_all_data_huds()

/mob/living/carbon/human/dummy/prepare_data_huds()
	return

/mob/living/carbon/human/dummy/Destroy()
	in_use = FALSE
	return ..()

/mob/living/carbon/human/dummy/Life()
	return

/mob/living/carbon/human/dummy/proc/wipe_state()
	delete_equipment()
	cut_overlays()
	// Wipe anything from custom icon appearances (AI/cyborg)
	icon = initial(icon)
	icon_state = initial(icon_state)

/mob/living/carbon/human/dummy/setup_human_dna()
	create_dna(src)
	randomize_human(src)
	dna.initialize_dna(skip_index = TRUE) //Skip stuff that requires full round init.

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
	D.in_use = TRUE
	return D

/proc/unset_busy_human_dummy(slotnumber)
	if(!slotnumber)
		return
	var/mob/living/carbon/human/dummy/D = GLOB.human_dummy_list[slotnumber]
	if(istype(D))
		D.wipe_state()
		D.in_use = FALSE

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
	target.dna.features["mcolor"] = COLOR_VIBRANT_LIME
	target.dna.features["ethcolor"] = COLOR_WHITE
	target.dna.features["lizard_markings"] = get_consistent_feature_entry(SSaccessories.lizard_markings_list)
	target.dna.features["ears"] = get_consistent_feature_entry(SSaccessories.ears_list)
	target.dna.features["frills"] = get_consistent_feature_entry(SSaccessories.frills_list)
	target.dna.features["horns"] = get_consistent_feature_entry(SSaccessories.horns_list)
	target.dna.features["moth_antennae"] = get_consistent_feature_entry(SSaccessories.moth_antennae_list)
	target.dna.features["moth_markings"] = get_consistent_feature_entry(SSaccessories.moth_markings_list)
	target.dna.features["moth_wings"] = get_consistent_feature_entry(SSaccessories.moth_wings_list)
	target.dna.features["snout"] = get_consistent_feature_entry(SSaccessories.snouts_list)
	target.dna.features["spines"] = get_consistent_feature_entry(SSaccessories.spines_list)
	target.dna.features["tail_cat"] = get_consistent_feature_entry(SSaccessories.tails_list_human) // it's a lie
	target.dna.features["tail_lizard"] = get_consistent_feature_entry(SSaccessories.tails_list_lizard)
	target.dna.features["tail_monkey"] = get_consistent_feature_entry(SSaccessories.tails_list_monkey)
	target.dna.features["pod_hair"] = get_consistent_feature_entry(SSaccessories.pod_hair_list)
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

/mob/living/carbon/human/consistent/setup_human_dna()
	create_consistent_human_dna(src)
	fully_replace_character_name(real_name, "John Doe")

/mob/living/carbon/human/consistent/domutcheck()
	return // We skipped adding any mutations so this runtimes
