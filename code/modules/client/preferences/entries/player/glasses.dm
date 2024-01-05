/datum/preference/toggle/glasses_color
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	default_value = FALSE
	db_key = "glasses_color"
	preference_type = PREFERENCE_PLAYER

/datum/preference/toggle/glasses_color/apply_to_client(client/client, value)
	if(!ishuman(client.mob))
		return
	var/mob/living/carbon/human/H = client.mob
	var/obj/item/clothing/glasses/G = H.glasses
	if(!istype(G) || !G.glass_colour_type)
		return
	H.update_glasses_color(G, TRUE)
