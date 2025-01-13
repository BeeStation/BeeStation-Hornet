/obj/item/clothing/mask/surgical
	name = "sterile mask"
	desc = "A sterile mask designed to help prevent the spread of diseases."
	icon_state = "sterile"
	item_state = "s_mask"
	w_class = WEIGHT_CLASS_TINY
	flags_inv = HIDEFACE|HIDESNOUT
	flags_cover = MASKCOVERSMOUTH
	visor_flags_inv = HIDEFACE|HIDESNOUT
	visor_flags_cover = MASKCOVERSMOUTH
	gas_transfer_coefficient = 0.9
	armor_type = /datum/armor/mask_surgical
	actions_types = list(/datum/action/item_action/adjust)

/datum/armor/mask_surgical
	bio = 100

/obj/item/clothing/mask/surgical/attack_self(mob/user)
	adjustmask(user)
