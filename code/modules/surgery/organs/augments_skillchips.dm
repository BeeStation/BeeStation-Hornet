
/obj/item/organ/cyberimp/skillchip
	name = "cybernetic implant"
	desc = "A state-of-the-art implant that improves a baseline's functionality."
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_BRAIN_SKILLCHIP
	w_class = WEIGHT_CLASS_TINY
	var/trait	//the trait gained on implant

/obj/item/organ/cyberimp/skillchip/Insert(var/mob/living/carbon/M, var/special = 0, drop_if_replaced = FALSE)
	. = ..()
	if (trait)		
		ADD_TRAIT(M, trait, SKILLCHIP_TRAIT)

/obj/item/organ/cyberimp/skillchip/Remove(var/mob/living/carbon/M, special = FALSE)
	if (!special)
		M.setOrganLoss(ORGAN_SLOT_BRAIN, 25)
	if (!trait)		
		REMOVE_TRAIT(M, trait, SKILLCHIP_TRAIT)
	..()



