//Just some alt-uniforms themed around Star Trek - Pls don't sue, Mr Roddenberry ;_;


/obj/item/clothing/under/trek
	can_adjust = FALSE
	icon = 'icons/obj/clothing/under/trek.dmi'
	worn_icon = 'icons/mob/clothing/under/trek.dmi'

//TOS
/obj/item/clothing/under/trek/command
	name = "command uniform"
	desc = "The uniform worn by command officers."
	icon_state = "trek_command"
	inhand_icon_state = "y_suit"

/obj/item/clothing/under/trek/engsec
	name = "engsec uniform"
	desc = "The uniform worn by engineering/security officers."
	icon_state = "trek_engsec"
	inhand_icon_state = "r_suit"
	armor_type = /datum/armor/trek_engsec
	strip_delay = 50


/datum/armor/trek_engsec
	melee = 10
	bio = 10
	bleed = 10

/obj/item/clothing/under/trek/medsci
	name = "medsci uniform"
	desc = "The uniform worn by medical/science officers."
	icon_state = "trek_medsci"
	inhand_icon_state = "b_suit"


//TNG
/obj/item/clothing/under/trek/command/next
	icon_state = "trek_next_command"
	inhand_icon_state = "r_suit"

/obj/item/clothing/under/trek/engsec/next
	icon_state = "trek_next_engsec"
	inhand_icon_state = "y_suit"

/obj/item/clothing/under/trek/medsci/next
	icon_state = "trek_next_medsci"


//ENT
/obj/item/clothing/under/trek/command/ent
	icon_state = "trek_ent_command"
	inhand_icon_state = "bl_suit"

/obj/item/clothing/under/trek/engsec/ent
	icon_state = "trek_ent_engsec"
	inhand_icon_state = "bl_suit"

/obj/item/clothing/under/trek/medsci/ent
	icon_state = "trek_ent_medsci"
	inhand_icon_state = "bl_suit"


//Q
/obj/item/clothing/under/trek/Q
	name = "french marshall's uniform"
	desc = "Something about it feels off..."
	icon_state = "trek_Q"
	inhand_icon_state = "r_suit"
