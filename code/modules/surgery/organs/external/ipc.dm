///An IPC's face display
/obj/item/organ/ipc_screen
	name = "positronic display"
	desc = "The face screen of an IPC. Without a chassis to power it, it's just a dark pane of glass."
	icon = 'icons/mob/ipc_accessories.dmi'
	icon_state = "m_ipc_screen_static_ADJ"

	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_IPC_SCREEN

	dna_block = DNA_IPC_SCREEN_BLOCK

	bodypart_overlay = /datum/bodypart_overlay/mutant/ipc_screen

	organ_flags = ORGAN_ROBOTIC | ORGAN_EXTERNAL

/obj/item/organ/ipc_screen/on_mob_insert(mob/living/carbon/receiver, special, movement_flags)
	. = ..()
	update_glow()

/obj/item/organ/ipc_screen/on_mob_remove(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	REMOVE_LUM_SOURCE(organ_owner, LUM_SOURCE_MUTANT_BODYPART)

///Shows the named screen accessory, recoloured to the owner's eye colour
/obj/item/organ/ipc_screen/proc/set_screen(screen_name)
	bodypart_overlay.set_appearance_from_name(screen_name)
	bodypart_overlay.inherit_color(bodypart_owner, force = TRUE)
	owner?.update_body_parts()

/obj/item/organ/ipc_screen/proc/set_powered(powered)
	var/datum/bodypart_overlay/mutant/ipc_screen/screen = bodypart_overlay
	screen.powered = powered
	update_glow()
	owner.update_body_parts()

/obj/item/organ/ipc_screen/proc/update_glow()
	var/datum/bodypart_overlay/mutant/ipc_screen/screen = bodypart_overlay
	if(screen.powered)
		ADD_LUM_SOURCE(owner, LUM_SOURCE_MUTANT_BODYPART)
	else
		REMOVE_LUM_SOURCE(owner, LUM_SOURCE_MUTANT_BODYPART)

/datum/bodypart_overlay/mutant/ipc_screen
	layers = list(EXTERNAL_ADJACENT = BODY_ADJ_LAYER)
	feature_key = FEATURE_IPC_SCREEN
	color_source = ORGAN_COLOR_OVERRIDE
	// A blocker drawn over the screen would hide its own emissive
	blocks_emissive = EMISSIVE_BLOCK_NONE
	///Unpowered screens draw nothing
	var/powered = TRUE

/datum/bodypart_overlay/mutant/ipc_screen/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner, mob/living/carbon/owner)
	return ..() && powered && !(bodypart_owner.owner?.obscured_slots & HIDEEYES)

/datum/bodypart_overlay/mutant/ipc_screen/override_color(obj/item/bodypart/bodypart_owner)
	var/mob/living/carbon/human/human_owner = bodypart_owner.owner
	return human_owner?.eye_color_left

/datum/bodypart_overlay/mutant/ipc_screen/get_global_feature_list()
	return GLOB.ipc_screens_list

///An IPC's antenna or other head attachment
/obj/item/organ/ipc_antenna
	name = "IPC antenna"
	desc = "A head attachment pulled from an IPC chassis."
	icon = 'icons/mob/ipc_accessories.dmi'
	icon_state = "m_ipc_antenna_antennae_ADJ"

	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_IPC_ANTENNA

	dna_block = DNA_IPC_ANTENNA_BLOCK

	bodypart_overlay = /datum/bodypart_overlay/mutant/ipc_antenna

	organ_flags = ORGAN_ROBOTIC | ORGAN_EXTERNAL

/datum/bodypart_overlay/mutant/ipc_antenna
	// Each antenna only has sprites for some of these layers
	layers = list(
		EXTERNAL_FRONT = BODY_FRONT_LAYER,
		EXTERNAL_ADJACENT = BODY_ADJ_LAYER,
		)
	feature_key = FEATURE_IPC_ANTENNA
	color_source = ORGAN_COLOR_OVERRIDE

/datum/bodypart_overlay/mutant/ipc_antenna/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner, mob/living/carbon/owner)
	return ..() && !(bodypart_owner.owner?.obscured_slots & HIDEEARS)

/datum/bodypart_overlay/mutant/ipc_antenna/override_color(obj/item/bodypart/bodypart_owner)
	var/mob/living/carbon/human/human_owner = bodypart_owner.owner
	return human_owner?.hair_color

/datum/bodypart_overlay/mutant/ipc_antenna/get_global_feature_list()
	return GLOB.ipc_antennas_list
