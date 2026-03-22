//Contains: Engineering department jumpsuits

/obj/item/clothing/under/rank/engineering
	icon = 'icons/obj/clothing/under/engineering.dmi'
	worn_icon = 'icons/mob/clothing/under/engineering.dmi'
	armor_type = /datum/armor/rank_engineering
	resistance_flags = NONE


/datum/armor/rank_engineering
	bio = 10
	fire = 60
	acid = 20

/obj/item/clothing/under/rank/engineering/chief_engineer
	desc = "It's a high visibility jumpsuit given to those engineers insane enough to achieve the rank of \"Chief Engineer\"."
	name = "chief engineer's jumpsuit"
	icon_state = "chiefengineer"
	inhand_icon_state = "gy_suit"	//TODO replace it
	worn_icon_state = "chiefengineer"
	armor_type = /datum/armor/engineering_chief_engineer
	resistance_flags = NONE


/datum/armor/engineering_chief_engineer
	bio = 10
	fire = 80
	acid = 40
	bleed = 10

/obj/item/clothing/under/rank/engineering/chief_engineer/skirt
	desc = "It's a high visibility jumpskirt given to those engineers insane enough to achieve the rank of \"Chief Engineer\"."
	name = "chief engineer's jumpskirt"
	icon_state = "chiefengineer_skirt"
	inhand_icon_state = "gy_suit"
	armor_type = /datum/armor/chief_engineer_skirt
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	dying_key = DYE_REGISTRY_JUMPSKIRT


/datum/armor/chief_engineer_skirt
	fire = 80
	acid = 40
	bleed = 10

/obj/item/clothing/under/rank/engineering/atmospheric_technician
	desc = "It's a jumpsuit worn by atmospheric technicians."
	name = "atmospheric technician's jumpsuit"
	icon_state = "atmos"
	inhand_icon_state = "atmos_suit"
	resistance_flags = NONE

/obj/item/clothing/under/rank/engineering/atmospheric_technician/skirt
	desc = "It's a jumpskirt worn by atmospheric technicians."
	name = "atmospheric technician's jumpskirt"
	icon_state = "atmos_skirt"
	inhand_icon_state = "atmos_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	dying_key = DYE_REGISTRY_JUMPSKIRT

/obj/item/clothing/under/rank/engineering/engineer
	desc = "It's an orange high visibility jumpsuit worn by engineers."
	name = "engineer's jumpsuit"
	icon_state = "engine"
	inhand_icon_state = "engi_suit"
	armor_type = /datum/armor/engineering_engineer
	resistance_flags = NONE

/datum/armor/engineering_engineer
	fire = 60
	acid = 20
	bleed = 10

/obj/item/clothing/under/rank/engineering/engineer/hazard
	name = "engineer's hazard jumpsuit"
	desc = "A high visibility jumpsuit made from fire resistant materials."
	icon_state = "hazard"
	inhand_icon_state = "syndicate-orange"
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/engineering/engineer/skirt
	desc = "It's an orange high visibility jumpskirt worn by engineers."
	name = "engineer's jumpskirt"
	icon_state = "engine_skirt"
	inhand_icon_state = "engi_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	dying_key = DYE_REGISTRY_JUMPSKIRT

