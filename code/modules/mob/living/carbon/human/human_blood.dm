/obj/item/proc/update_blood_overlay()
	if(!blood_DNA)
		cut_overlay(blood_overlay)
		return
	var/blood_color = get_blood_state_color(blood_state)
	if(!blood_color)
		blood_color = COLOR_BLOOD
	var/mutable_appearance/blood = mutable_appearance('icons/effects/blood.dmi', "bloodclothing", -1)
	blood.color = blood_color
	add_overlay(blood)
	blood_overlay = blood

/mob/living/carbon/human/proc/get_blood_state()
	if(dna?.species?.id == SPECIES_ETHEREAL)
		return "LE"
	return "blood"
