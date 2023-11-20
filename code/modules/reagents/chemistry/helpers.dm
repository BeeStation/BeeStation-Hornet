/// returns a reagent holder from a mob. This proc exists because a mob doesn't have a reagent holder. "veins" organ holds it.
/atom/proc/get_reagent_holder()
	return reagents

/mob/living/carbon/get_reagent_holder()
	var/obj/item/organ/veins/veins = getorganslot(ORGAN_SLOT_VEINS)
	if(!veins)
		CRASH("A mob that hasn't a reagent holder is detected, and a code tried to get its reagent holder.")
		// This shouldn't happen because 'veins' is an important organ.
	return veins.reagents
	// this is a temporary proc.

/* this is actual code that should be implemented, but for now, not until our chem system refactored.
/mob/living/carbon/get_reagent_holder(target_organ=SOMETHING)
	switch(target_organ)
		if(ORGAN_SLOT_VEINS)
			var/obj/item/organ/veins/veins = getorganslot(ORGAN_SLOT_VEINS)
			return veins.reagents
		if(ORGAN_SLOT_LIVER)
			var/obj/item/organ/liver/liver = getorganslot(ORGAN_SLOT_LIVER)
			return liver.reagents
		if(ORGAN_SLOT_LUNGS)
			var/obj/item/organ/lungs/lungs = getorganslot(ORGAN_SLOT_LUNGS)
			return lungs.reagents
		if(ORGAN_SLOT_STOMACH)
			var/obj/item/organ/stomach/stomach = getorganslot(ORGAN_SLOT_STOMACH)
			return stomach.reagents

	So, this is why this proc exists. "reagents" will be too tynamic to a carbon
*/
