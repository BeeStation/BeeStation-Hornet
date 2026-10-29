///Plant growths on a diona's body
/obj/item/organ/diona_growth
	abstract_type = /obj/item/organ/diona_growth
	icon = 'icons/mob/diona_markings.dmi'

	zone = BODY_ZONE_CHEST

	restyle_flags = EXTERNAL_RESTYLE_PLANT

	organ_flags = parent_type::organ_flags | ORGAN_EXTERNAL

/datum/bodypart_overlay/mutant/diona
	layers = list(EXTERNAL_ADJACENT = BODY_ADJ_LAYER)
	///Hidden by suits that cover the jumpsuit, unless the suit lists the wearer's species in species_exception
	var/hidden_by_suit = TRUE

/datum/bodypart_overlay/mutant/diona/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner, mob/living/carbon/owner)
	. = ..()
	var/mob/living/carbon/human/human_owner = bodypart_owner.owner
	if(!. || !hidden_by_suit || !(human_owner?.obscured_slots & HIDEJUMPSUIT))
		return
	return is_type_in_list(human_owner.dna.species, human_owner.wear_suit?.species_exception)

/obj/item/organ/diona_growth/leaves
	name = "diona leaves"
	desc = "A tangle of leaves that once grew on a diona."
	icon_state = "m_diona_leaves_chest_ADJ"
	slot = ORGAN_SLOT_EXTERNAL_DIONA_LEAVES
	dna_block = DNA_DIONA_LEAVES_BLOCK
	bodypart_overlay = /datum/bodypart_overlay/mutant/diona/leaves

/datum/bodypart_overlay/mutant/diona/leaves
	feature_key = FEATURE_DIONA_LEAVES

/datum/bodypart_overlay/mutant/diona/leaves/get_global_feature_list()
	return GLOB.diona_leaves_list

/obj/item/organ/diona_growth/thorns
	name = "diona thorns"
	desc = "A cluster of thorns that once grew on a diona."
	icon_state = "m_diona_thorns_chest_ADJ"
	slot = ORGAN_SLOT_EXTERNAL_DIONA_THORNS
	dna_block = DNA_DIONA_THORNS_BLOCK
	bodypart_overlay = /datum/bodypart_overlay/mutant/diona/thorns

/datum/bodypart_overlay/mutant/diona/thorns
	feature_key = FEATURE_DIONA_THORNS

/datum/bodypart_overlay/mutant/diona/thorns/get_global_feature_list()
	return GLOB.diona_thorns_list

/obj/item/organ/diona_growth/flowers
	name = "diona flowers"
	desc = "A bunch of flowers that once grew on a diona."
	icon_state = "m_diona_flowers_chest_ADJ"
	slot = ORGAN_SLOT_EXTERNAL_DIONA_FLOWERS
	dna_block = DNA_DIONA_FLOWERS_BLOCK
	bodypart_overlay = /datum/bodypart_overlay/mutant/diona/flowers

/datum/bodypart_overlay/mutant/diona/flowers
	feature_key = FEATURE_DIONA_FLOWERS

/datum/bodypart_overlay/mutant/diona/flowers/get_global_feature_list()
	return GLOB.diona_flowers_list

/obj/item/organ/diona_growth/moss
	name = "diona moss"
	desc = "A clump of moss that once grew on a diona."
	icon_state = "m_diona_moss_chest_ADJ"
	slot = ORGAN_SLOT_EXTERNAL_DIONA_MOSS
	dna_block = DNA_DIONA_MOSS_BLOCK
	bodypart_overlay = /datum/bodypart_overlay/mutant/diona/moss

/datum/bodypart_overlay/mutant/diona/moss
	feature_key = FEATURE_DIONA_MOSS

/datum/bodypart_overlay/mutant/diona/moss/get_global_feature_list()
	return GLOB.diona_moss_list

/obj/item/organ/diona_growth/pbody
	name = "diona p-body"
	desc = "A knot of bark that once grew on a diona's chest."
	icon_state = "m_diona_pbody_chest_ADJ"
	slot = ORGAN_SLOT_EXTERNAL_DIONA_PBODY
	dna_block = DNA_DIONA_PBODY_BLOCK
	bodypart_overlay = /datum/bodypart_overlay/mutant/diona/pbody

/datum/bodypart_overlay/mutant/diona/pbody
	feature_key = FEATURE_DIONA_PBODY

/datum/bodypart_overlay/mutant/diona/pbody/get_global_feature_list()
	return GLOB.diona_pbody_list

/obj/item/organ/diona_growth/mushroom
	name = "diona mushroom"
	desc = "A mushroom that once grew on a diona's head."
	icon_state = "m_diona_mushroom_head_ADJ"
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_DIONA_MUSHROOM
	dna_block = DNA_DIONA_MUSHROOM_BLOCK
	bodypart_overlay = /datum/bodypart_overlay/mutant/diona/mushroom

/datum/bodypart_overlay/mutant/diona/mushroom
	feature_key = FEATURE_DIONA_MUSHROOM
	hidden_by_suit = FALSE

/datum/bodypart_overlay/mutant/diona/mushroom/get_global_feature_list()
	return GLOB.diona_mushroom_list

/obj/item/organ/diona_growth/antennae
	name = "diona antennae"
	desc = "A pair of stalks that once grew on a diona's head."
	icon_state = "m_diona_antennae_head_ADJ"
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_DIONA_ANTENNAE
	dna_block = DNA_DIONA_ANTENNAE_BLOCK
	bodypart_overlay = /datum/bodypart_overlay/mutant/diona/antennae

/datum/bodypart_overlay/mutant/diona/antennae
	feature_key = FEATURE_DIONA_ANTENNAE
	hidden_by_suit = FALSE

/datum/bodypart_overlay/mutant/diona/antennae/get_global_feature_list()
	return GLOB.diona_antennae_list

/obj/item/organ/diona_growth/eyes
	name = "diona eye growths"
	desc = "Bark and eyes that once grew on a diona's head."
	icon_state = "m_diona_eyes_bugeyes_head_ADJ"
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_DIONA_EYES
	dna_block = DNA_DIONA_EYES_BLOCK
	bodypart_overlay = /datum/bodypart_overlay/mutant/diona/eyes

/datum/bodypart_overlay/mutant/diona/eyes
	feature_key = FEATURE_DIONA_EYES
	hidden_by_suit = FALSE

/datum/bodypart_overlay/mutant/diona/eyes/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner, mob/living/carbon/owner)
	return ..() && !(bodypart_owner.owner?.obscured_slots & (HIDEEYES|HIDEHAIR))

/datum/bodypart_overlay/mutant/diona/eyes/get_global_feature_list()
	return GLOB.diona_eyes_list
