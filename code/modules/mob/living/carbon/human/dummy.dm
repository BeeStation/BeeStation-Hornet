
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

/proc/create_consistent_human_dna(mob/living/carbon/human/target)
	target.create_dna()
	target.dna.features["body_markings"] = "None"
	target.dna.features["ears"] = "Cat"
	target.dna.features["ethcolor"] = GLOB.color_list_ethereal["Cyan"]
	target.dna.features["frills"] = "None"
	target.dna.features["horns"] = "None"
	target.dna.features["mcolor"] = "4c4"
	target.dna.features["moth_antennae"] = "Plain"
	target.dna.features["moth_markings"] = "None"
	target.dna.features["moth_wings"] = "Plain"
	target.dna.features["snout"] = "Round"
	target.dna.features["spines"] = "None"
	target.dna.features["tail_human"] = "Cat"
	target.dna.features["tail_lizard"] = "Smooth"
	target.dna.features["apid_stripes"] = "thick"
	target.dna.features["apid_headstripes"] = "thick"
	target.dna.features["apid_antenna"] = "curled"
	target.dna.features["insect_type"] = "fly"
	target.dna.features["ipc_screen"] = "BSOD"
	target.dna.features["ipc_antenna"] = "None"
	target.dna.features["ipc_chassis"] = "Morpheus Cyberkinetics (Custom)"
	target.dna.features["psyphoza_cap"] = "Portobello"
	target.dna.features["diona_leaves"] = "None"
	target.dna.features["diona_thorns"] = "None"
	target.dna.features["diona_flowers"] = "None"
	target.dna.features["diona_moss"] = "None"
	target.dna.features["diona_mushroom"] = "None"
	target.dna.features["diona_antennae"] = "None"
	target.dna.features["diona_eyes"] = "None"
	target.dna.features["diona_pbody"] = "None"

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
	ADD_TRAIT(src, INSTANT_DO_AFTER, INNATE_TRAIT)

/mob/living/carbon/human/consistent/setup_human_dna()
	create_consistent_human_dna(src)
	fully_replace_character_name(real_name, "John Doe")

/mob/living/carbon/human/consistent/domutcheck()
	return // We skipped adding any mutations so this runtimes

/mob/living/carbon/human/consistent/ClickOn(atom/A, params)
	next_click = -1
	next_move = -1
	. = ..()
