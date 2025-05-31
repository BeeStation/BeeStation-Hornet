// Note: tails only work in humans. They use human-specific parameters and rely on human code for displaying.

/obj/item/organ/tail
	name = "tail"
	desc = "A severed tail. What did you cut this off of?"
	visual = TRUE
	icon_state = "severedtail"
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_TAIL
	var/tail_type

/obj/item/organ/tail/proc/is_wagging(mob/living/carbon/human/H)
	return FALSE

/obj/item/organ/tail/proc/set_wagging(mob/living/carbon/human/H, wagging = FALSE)
	return FALSE

/obj/item/organ/tail/proc/toggle_wag(mob/living/carbon/human/H)
	return set_wagging(H, !is_wagging(H))

/obj/item/organ/tail/cat
	name = "cat tail"
	desc = "A severed cat tail. Who's wagging now?"
	tail_type = "Cat"

	organ_traits = list(TRAIT_LIGHT_LANDING)

/obj/item/organ/tail/cat/Insert(mob/living/carbon/human/H, special = 0, drop_if_replaced = TRUE, pref_load = FALSE)
	..()
	if(istype(H))
		H.dna.species.mutant_bodyparts["tail_human"] = tail_type

		H.update_body()

/obj/item/organ/tail/cat/Remove(mob/living/carbon/human/H,  special = 0, pref_load = FALSE)
	..()
	if(istype(H))
		H.dna.species.mutant_bodyparts -= "tail_human"
		color = H.hair_color
		H.update_body()

/obj/item/organ/tail/cat/is_wagging(mob/living/carbon/human/H)
	if(!H?.dna?.species)
		return FALSE
	return (H.dna.species.mutant_bodyparts["waggingtail_human"])

/obj/item/organ/tail/cat/set_wagging(mob/living/carbon/human/H, wagging = FALSE)
	. = FALSE
	if(!H?.dna?.species)
		return FALSE
	var/datum/species/species = H.dna.species
	if(wagging)
		species.mutant_bodyparts["waggingtail_human"] = species.mutant_bodyparts["tail_human"]
		species.mutant_bodyparts -= "tail_human"
		. = TRUE
	else
		species.mutant_bodyparts["tail_human"] = species.mutant_bodyparts["waggingtail_human"]
		species.mutant_bodyparts -= "waggingtail_human"
	H.update_body()

/obj/item/organ/tail/lizard
	name = "lizard tail"
	desc = "A severed lizard tail. Somewhere, no doubt, a lizard hater is very pleased with themselves."
	color = "#116611"
	var/spines

/obj/item/organ/tail/lizard/Insert(mob/living/carbon/human/H, special = 0, drop_if_replaced = TRUE, pref_load = FALSE)
	..()
	if(istype(H))
		// Checks here are necessary so it wouldn't overwrite the tail of a lizard it spawned in
		if(!tail_type && H.dna.features["tail_lizard"])
			tail_type = H.dna.features["tail_lizard"]
		else
			H.dna.features["tail_lizard"] = tail_type || "Smooth"
			H.dna.update_uf_block(DNA_LIZARD_TAIL_BLOCK)
		H.dna.species.mutant_bodyparts["tail_lizard"] = tail_type

		if(!spines && H.dna.features["spines"])
			spines = H.dna.features["spines"]
		else
			H.dna.features["spines"] = spines || "None"
			H.dna.update_uf_block(DNA_SPINES_BLOCK)
		H.dna.species.mutant_bodyparts["spines"] = spines

		H.update_body()

/obj/item/organ/tail/lizard/Remove(mob/living/carbon/human/H, special = 0, pref_load = FALSE)
	..()
	if(istype(H))
		H.dna.species.mutant_bodyparts -= "tail_lizard"
		H.dna.species.mutant_bodyparts -= "spines"
		color = "#" + H.dna.features["mcolor"]
		tail_type = H.dna.features["tail_lizard"]
		spines = H.dna.features["spines"]
		H.update_body()

/obj/item/organ/tail/lizard/is_wagging(mob/living/carbon/human/H)
	if(!H?.dna?.species)
		return FALSE
	return (H.dna.species.mutant_bodyparts["waggingtail_lizard"])

/obj/item/organ/tail/lizard/set_wagging(mob/living/carbon/human/H, wagging = FALSE)
	. = FALSE
	if(!H?.dna?.species)
		return
	var/datum/species/species = H.dna.species
	if(wagging)
		species.mutant_bodyparts |= list("waggingtail_lizard" = species.mutant_bodyparts["tail_lizard"],
										"waggingspines" = species.mutant_bodyparts["spines"])
		species.mutant_bodyparts -= list("tail_lizard", "spines")
		. = TRUE
	else
		species.mutant_bodyparts |= list("tail_lizard" = species.mutant_bodyparts["waggingtail_lizard"],
										"spines" = species.mutant_bodyparts["waggingspines"])
		species.mutant_bodyparts -= list("waggingtail_lizard", "waggingspines")
	H.update_body()
