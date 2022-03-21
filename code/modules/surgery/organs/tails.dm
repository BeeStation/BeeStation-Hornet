// Note: tails only work in humans. They use human-specific parameters and rely on human code for displaying.

/obj/item/organ/tail
	name = "tail"
	desc = "A severed tail. What did you cut this off of?"
	icon_state = "severedtail"
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_TAIL
	var/tail_type = "None"
//MonkeStation Edit Start: Tail Overhaul
	var/wagging = FALSE
	var/list/mutant_bodypart_name = list() //The organ that goes under H.dna.species.mutant_bodyparts
	var/list/wagging_mutant_name //The WAGGING state for the organ that goes under H.dna.species.mutant_bodyparts
	//All new tails need to be added to the switch in handle_mutant_bodyparts() under species.dm
//MonkeStation Edit End

/obj/item/organ/tail/cat
	name = "cat tail"
	desc = "A severed cat tail. Who's wagging now?"
	tail_type = "Cat"
	//MonkeStation Edit Start: Tail Overhaul
	mutant_bodypart_name = list("tail_human")
	wagging_mutant_name = list("waggingtail_human")
	//MonkeStation Edit End

//MonkeStation Edit Start: Tail Overhaul
/obj/item/organ/tail/Insert(mob/living/carbon/human/H, special = 0, drop_if_replaced = TRUE)
	..()
	if(istype(H))
		if(!(mutant_bodypart_name in H.dna.species.mutant_bodyparts))
			H.dna.species.mutant_bodyparts |= mutant_bodypart_name
//MonkeStation Edit End
			H.dna.features["tail_human"] = tail_type
			H.update_body()

/obj/item/organ/tail/Remove(mob/living/carbon/human/H,  special = 0)
	..()
	if(istype(H))
		H.dna.features["tail_human"] = "None"
//MonkeStation Edit Start: Tail Overhaul
		if(wagging)
			H.dna.species.mutant_bodyparts -= wagging_mutant_name
			wagging = FALSE
		else
			H.dna.species.mutant_bodyparts -= mutant_bodypart_name
//MonkeStation Edit End
		H.update_body()

/obj/item/organ/tail/lizard
	name = "lizard tail"
	desc = "A severed lizard tail. Somewhere, no doubt, a lizard hater is very pleased with themselves."
	color = "#116611"
	tail_type = "Smooth"
	var/spines = "None"
	//MonkeStation Edit Start: Tail Overhaul
	mutant_bodypart_name = list("tail_lizard", "spines")
	wagging_mutant_name = list("waggingtail_lizard", "waggingspines")
	//MonkeStation Edit End

/obj/item/organ/tail/lizard/Insert(mob/living/carbon/human/H, special = 0, drop_if_replaced = TRUE)
	..()
	if(istype(H))
		// Checks here are necessary so it wouldn't overwrite the tail of a lizard it spawned in
		if(!("spines" in H.dna.species.mutant_bodyparts))
			H.dna.features["spines"] = spines
			H.dna.species.mutant_bodyparts |= "spines"
		H.update_body()

/obj/item/organ/tail/lizard/Remove(mob/living/carbon/human/H,  special = 0)
	..()
	if(istype(H))
		H.dna.species.mutant_bodyparts -= "spines"
		color = "#" + H.dna.features["mcolor"]
		tail_type = H.dna.features["tail_lizard"]
		spines = H.dna.features["spines"]
		H.update_body()
