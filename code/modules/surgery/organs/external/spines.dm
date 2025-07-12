///A lizards spines (those things on their back), but also including tail spines (gasp)
/obj/item/organ/external/spines
	name = "lizard spines"
	desc = "Not an actual spine, obviously."
	icon_state = "spines"

	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_EXTERNAL_SPINES

	preference = "feature_lizard_spines"

	dna_block = DNA_SPINES_BLOCK
	restyle_flags = EXTERNAL_RESTYLE_FLESH

	bodypart_overlay = /datum/bodypart_overlay/mutant/spines

/obj/item/organ/external/spines/Insert(mob/living/carbon/receiver, special, movement_flags)
	// If we have a tail, attempt to add a tail spines overlay
	var/obj/item/organ/external/tail/our_tail = receiver.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL)
	our_tail?.try_insert_tail_spines(our_tail.bodypart_owner)
	return ..()

/obj/item/organ/external/spines/Remove(mob/living/carbon/organ_owner, special, movement_flags)
	// If we have a tail, remove any tail spines overlay
	var/obj/item/organ/external/tail/our_tail = organ_owner.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL)
	our_tail?.remove_tail_spines(our_tail.bodypart_owner)
	return ..()

///Bodypart overlay for spines
/datum/bodypart_overlay/mutant/spines
	layers = EXTERNAL_ADJACENT|EXTERNAL_BEHIND
	feature_key = "spines"

/datum/bodypart_overlay/mutant/spines/get_global_feature_list()
	return GLOB.spines_list

/datum/bodypart_overlay/mutant/spines/can_draw_on_bodypart(mob/living/carbon/human/human)
	. = ..()
	if(human.wear_suit && (human.wear_suit.flags_inv & HIDEJUMPSUIT))
		return FALSE
