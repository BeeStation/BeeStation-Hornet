/**
 * Set the hair style of a human.
 * Update calls update_body_parts().
 **/
/mob/living/proc/set_hairstyle(new_style, update = TRUE)
	return

/mob/living/carbon/human/set_hairstyle(new_style, update = TRUE)
	var/obj/item/bodypart/head/my_head = get_bodypart(BODY_ZONE_HEAD)

	hair_style = new_style
	my_head?.hair_style = new_style

	if(update)
		update_body_parts()

/**
 * Set the hair color of a human.
 * Override instead sets the override value, it will not be changed away from the override value until override is set to null.
 * Update calls update_body_parts().
 **/
/mob/living/proc/set_haircolor(hex_string, override, update = TRUE)
	return

/mob/living/carbon/human/set_haircolor(hex_string, override, update = TRUE)
	var/obj/item/bodypart/head/my_head = get_bodypart(BODY_ZONE_HEAD)

	if(override)
		// aight, no head? tough luck
		my_head?.override_hair_color = hex_string
	else
		hair_color = hex_string
		my_head?.hair_color = hex_string

	if(update)
		update_body_parts()

/**
 * Set the facial hair style of a human.
 * Update calls update_body_parts().
 **/
/mob/living/proc/set_facial_hairstyle(new_style, update = TRUE)
	return

/mob/living/carbon/human/set_facial_hairstyle(new_style, update = TRUE)
	var/obj/item/bodypart/head/my_head = get_bodypart(BODY_ZONE_HEAD)

	facial_hair_style = new_style
	my_head?.facial_hair_style = new_style

	if(update)
		update_body_parts()

/**
 * Set the facial hair color of a human.
 * Override instead sets the override value, it will not be changed away from the override value until override is set to null.
 * Update calls update_body_parts().
 **/
/mob/living/proc/set_facial_haircolor(hex_string, override, update = TRUE)
	return

/mob/living/carbon/human/set_facial_haircolor(hex_string, override, update = TRUE)
	var/obj/item/bodypart/head/my_head = get_bodypart(BODY_ZONE_HEAD)

	if(override)
		// so no head? tough luck
		my_head?.override_hair_color = hex_string
	else
		facial_hair_color = hex_string
		my_head?.facial_hair_color = hex_string

	if(update)
		update_body_parts()
