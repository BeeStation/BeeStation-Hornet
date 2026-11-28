/obj/item/clothing/head/utility/welding
	name = "welding helmet"
	desc = "A head-mounted face cover designed to protect the wearer completely from space-arc eye."
	icon_state = "welding"
	inhand_icon_state = "welding"
	custom_materials = list(/datum/material/iron=1750, /datum/material/glass=400)
	flash_protect = FLASH_PROTECTION_WELDER
	tint = 2
	armor_type = /datum/armor/utility_welding
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDESNOUT
	actions_types = list(/datum/action/item_action/toggle)
	visor_flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDESNOUT
	visor_flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	visor_vars_to_toggle = VISOR_FLASHPROTECT | VISOR_TINT
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	resistance_flags = FIRE_PROOF
	clothing_flags = SNUG_FIT | STACKABLE_HELMET_EXEMPT

/datum/armor/utility_welding
	melee = 10
	fire = 100
	acid = 60
	stamina = 5

/obj/item/clothing/head/utility/welding/attack_self(mob/user)
	adjust_visor(user)

/obj/item/clothing/head/utility/welding/update_icon_state()
	. = ..()
	icon_state = "[initial(icon_state)][up ? "up" : ""]"
	inhand_icon_state = "[initial(inhand_icon_state)][up ? "off" : ""]"
