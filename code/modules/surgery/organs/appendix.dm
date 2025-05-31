/obj/item/organ/appendix
	name = "appendix"
	icon_state = "appendix"
	visual = FALSE
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_APPENDIX

	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY

	now_failing = span_warning("An explosion of pain erupts in your lower right abdomen!")
	now_fixed = span_info("The pain in your abdomen has subsided.")

	var/inflamed

/obj/item/organ/appendix/update_icon()
	if(inflamed)
		icon_state = "appendixinflamed"
		name = "inflamed appendix"
	else
		icon_state = "appendix"
		name = "appendix"

/obj/item/organ/appendix/on_life(delta_time, times_fired)
	..()
	if(!(organ_flags & ORGAN_FAILING))
		return
	var/mob/living/carbon/M = owner
	if(M)
		M.adjustToxLoss(2 * delta_time, TRUE, TRUE)//forced to ensure people don't use it to gain tox as slime person

/obj/item/organ/appendix/get_availability(datum/species/owner_species, mob/living/owner_mob)
	return owner_species.mutantappendix

/obj/item/organ/appendix/on_remove(mob/living/carbon/organ_owner)
	. = ..()
	for(var/datum/disease/appendicitis/A in organ_owner.diseases)
		A.cure()
		inflamed = TRUE
	update_icon()

/obj/item/organ/appendix/on_insert(mob/living/carbon/organ_owner)
	. = ..()
	if(inflamed)
		organ_owner.ForceContractDisease(new /datum/disease/appendicitis(), FALSE, TRUE)
