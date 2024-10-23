// Note: tails only work in humans. They use human-specific parameters and rely on human code for displaying.

/obj/item/organ/tail
	name = "tail"
	desc = "A severed tail. What did you cut this off of?"
	visual = TRUE
	icon_state = "severedtail"
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_TAIL
	var/tail_type = "None"

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

/obj/item/organ/tail/cat/Insert(mob/living/carbon/human/H, special = 0, drop_if_replaced = TRUE, pref_load = FALSE)
	..()
	if(pref_load && istype(H))
		H.update_body()
		return
	if(istype(H))
		var/default_part = H.dna.species.mutant_bodyparts["tail_human"]
		if(!default_part || default_part == "None")
			H.dna.species.mutant_bodyparts["tail_human"] = tail_type
			H.dna.features["tail_human"] = tail_type
			H.update_body()

/obj/item/organ/tail/cat/Remove(mob/living/carbon/human/H,  special = 0, pref_load = FALSE)
	..()
	if(pref_load && istype(H))
		color = H.hair_color
		H.update_body()
		return
	if(istype(H))
		H.dna.features["tail_human"] = "None"
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
	tail_type = "Smooth"
	var/spines = "None"

/obj/item/organ/tail/lizard/Insert(mob/living/carbon/human/H, special = 0, drop_if_replaced = TRUE, pref_load = FALSE)
	..()
	if(istype(H))
		// Checks here are necessary so it wouldn't overwrite the tail of a lizard it spawned in
		var/default_part = H.dna.species.mutant_bodyparts["tail_lizard"]
		if(!default_part || default_part == "None")
			H.dna.features["tail_lizard"] = H.dna.species.mutant_bodyparts["tail_lizard"] = tail_type

		default_part = H.dna.species.mutant_bodyparts["spines"]
		if(!default_part || default_part == "None")
			H.dna.features["spines"] = H.dna.species.mutant_bodyparts["spines"] = spines
		H.update_body()

/datum/species/lizard/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	var/real_tail_type = C.dna.features["tail_lizard"]
	var/real_spines = C.dna.features["spines"]

	. = ..()

	// Special handler for loading preferences. If we're doing it from a preference load, we'll want
	// to make sure we give the appropriate lizard tail AFTER we call the parent proc, as the parent
	// proc will overwrite the lizard tail. Species code at its finest.
	if(pref_load)
		C.dna.features["tail_lizard"] = real_tail_type
		C.dna.features["spines"] = real_spines

		var/obj/item/organ/tail/lizard/new_tail = new /obj/item/organ/tail/lizard()

		new_tail.tail_type = C.dna.features["tail_lizard"]
		C.dna.species.mutant_bodyparts["tail_lizard"] = new_tail.tail_type

		new_tail.spines = C.dna.features["spines"]
		C.dna.species.mutant_bodyparts["spines"] = new_tail.spines

		// organ.Insert will qdel any existing organs in the same slot, so
		// we don't need to manage that.
		new_tail.Insert(C, TRUE, FALSE)

/obj/item/organ/tail/lizard/Remove(mob/living/carbon/human/H, special = 0, pref_load = FALSE)
	..()
	if(istype(H))
		H.dna.species.mutant_bodyparts -= "tail_lizard"
		H.dna.species.mutant_bodyparts -= "spines"
		color = "#" + H.dna.features["mcolor"]
		tail_type = H.dna.features["tail_lizard"]
		spines = H.dna.features["spines"]
		H.update_body()

/obj/item/organ/tail/lizard/before_organ_replacement(obj/item/organ/replacement)
	. = ..()
	var/obj/item/organ/tail/lizard/new_tail = replacement

	if(!istype(new_tail))
		return

	new_tail.tail_type = tail_type
	new_tail.spines = spines

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
