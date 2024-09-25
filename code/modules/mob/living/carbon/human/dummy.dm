
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

/// Provides a dummy that is consistently bald, white, naked, etc.
/mob/living/carbon/human/dummy/consistent

/mob/living/carbon/human/dummy/consistent/setup_human_dna()
	create_dna(src)
	dna.initialize_dna(skip_index = TRUE)
	dna.features["body_markings"] = "None"
	dna.features["ears"] = "Cat"
	dna.features["ethcolor"] = GLOB.color_list_ethereal["Cyan"]
	dna.features["frills"] = "None"
	dna.features["horns"] = "None"
	dna.features["mcolor"] = "4c4"
	dna.features["moth_antennae"] = "Plain"
	dna.features["moth_markings"] = "None"
	dna.features["moth_wings"] = "Plain"
	dna.features["snout"] = "Round"
	dna.features["spines"] = "None"
	dna.features["tail_human"] = "Cat"
	dna.features["tail_lizard"] = "Smooth"
	dna.features["apid_stripes"] = "thick"
	dna.features["apid_headstripes"] = "thick"
	dna.features["apid_antenna"] = "curled"
	dna.features["insect_type"] = "fly"
	dna.features["ipc_screen"] = "BSOD"
	dna.features["ipc_antenna"] = "None"
	dna.features["ipc_chassis"] = "Morpheus Cyberkinetics (Custom)"
	dna.features["psyphoza_cap"] = "Portobello"

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
