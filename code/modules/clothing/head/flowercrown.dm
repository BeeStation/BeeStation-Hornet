/obj/item/clothing/head/flowercrown
	name = "generic flower crown"
	desc = "You should not be seeing this"
	icon = 'icons/obj/clothing/head/hydroponics.dmi'
	worn_icon = 'icons/mob/clothing/head/hydroponics.dmi'
	icon_state = "lily_crown"

	attack_verb_continuous = list("crowns")
	attack_verb_simple = list("crown")

/obj/item/clothing/head/flowercrown/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_HEAD)
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "flower_crown_worn", /datum/mood_event/flower_crown_worn, src)

/obj/item/clothing/head/flowercrown/dropped(mob/living/carbon/user)
	..()
	if(user.head != src)
		return
	else
		SEND_SIGNAL(user, COMSIG_CLEAR_MOOD_EVENT, "flower_crown_worn")

/obj/item/clothing/head/flowercrown/rainbowbunch
	name = "rainbow flower crown"
	desc = "A flower crown made out of the flowers of the rainbow bunch plant."
	icon_state_preview = "rainbow_bunch_crown_1"

/obj/item/clothing/head/flowercrown/rainbowbunch/Initialize(mapload)
	. = ..()
	var/crown_type = rand(1,4)
	switch(crown_type)
		if(1)
			desc += " This one has red, yellow and white flowers."
			icon_state = "rainbow_bunch_crown_1"
		if(2)
			desc += " This one has blue, yellow, green and white flowers."
			icon_state = "rainbow_bunch_crown_2"
		if(3)
			desc += " This one has red, blue, purple and pink flowers."
			icon_state = "rainbow_bunch_crown_3"
		if(4)
			desc += " This one has yellow, green and white flowers."
			icon_state = "rainbow_bunch_crown_4"

/obj/item/clothing/head/flowercrown/sunflower
	name = "sunflower crown"
	desc = "A bright flower crown made out sunflowers that is sure to brighten up anyone's day!"
	icon_state = "sunflower_crown"

/obj/item/clothing/head/flowercrown/poppy
	name = "poppy crown"
	desc = "A flower crown made out of a string of bright red poppies."
	icon_state = "poppy_crown"

/obj/item/clothing/head/flowercrown/lily
	name = "lily crown"
	desc = "A leafy flower crown with a cluster of large white lilies at at the front."
	icon_state = "lily_crown"
