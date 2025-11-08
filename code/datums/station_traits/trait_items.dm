/obj/item/birthday_invite
	name = "birthday invitation"
	desc = "A card stating that it's someone's birthday today."
	resistance_flags = FLAMMABLE
	w_class = WEIGHT_CLASS_TINY

/obj/item/birthday_invite/proc/setup_card(birthday_name)
	desc = "A card stating that its [birthday_name]'s birthday today."
	icon_state = "paperslip_words"
	icon = 'icons/obj/bureaucracy.dmi'

/obj/item/clothing/head/costume/party
	name = "party hat"
	desc = "A crappy paper hat that you are REQUIRED to wear."
	icon_state = "party_hat"
	greyscale_config =  /datum/greyscale_config/party_hat
	greyscale_config_worn = /datum/greyscale_config/party_hat_worn
	flags_inv = 0
	armor_type = /datum/armor/none
	var/static/list/hat_colors = list(
		COLOR_RED,
		COLOR_ORANGE,
		COLOR_VIVID_YELLOW,
		COLOR_LIME,
		COLOR_CYAN,
		COLOR_VIOLET,
	)

/obj/item/clothing/head/costume/party/Initialize(mapload)
	set_greyscale(colors = list(pick(hat_colors)))
	return ..()

/obj/item/clothing/head/costume/party/festive
	name = "festive paper hat"
	icon_state = "xmashat_grey"
	greyscale_config = /datum/greyscale_config/festive_hat
	greyscale_config_worn = /datum/greyscale_config/festive_hat_worn
