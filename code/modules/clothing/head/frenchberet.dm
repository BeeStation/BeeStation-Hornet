/obj/item/clothing/head/frenchberet
	name = "french beret"
	desc = "A quality beret, infused with the aroma of chain-smoking, wine-swilling Parisians. You feel less inclined to engage in military conflict, for some reason."
	icon_state = "beret"
	greyscale_config = /datum/greyscale_config/beret
	greyscale_config_worn = /datum/greyscale_config/beret/worn
	greyscale_colors = "#972A2A"
	dynamic_hair_suffix = ""
	dying_key = DYE_REGISTRY_BERET

/obj/item/clothing/head/frenchberet/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/speechmod, file_path = FRENCH_TALK_FILE, end_string = list(" Honh honh honh!"," Honh!"," Zut Alors!"), end_string_chance = 3, slots = ITEM_SLOT_HEAD)
