/obj/item/clothing/head/cone
	desc = "This cone is trying to warn you of something!"
	name = "warning cone"
	icon = 'icons/obj/janitor.dmi'
	worn_icon = 'icons/mob/clothing/head/utility.dmi'
	icon_state = "cone"
	inhand_icon_state = null
	force = 1
	throwforce = 3
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	attack_verb_continuous = list("warns", "cautions", "smashes")
	attack_verb_simple = list("warn", "caution", "smash")
	resistance_flags = NONE


/obj/item/clothing/head/cowboy
	name = "ranching hat"
	desc = "King of the plains, the half cow half man mutant, the cowboy."
	icon = 'icons/obj/clothing/head/cowboy.dmi'
	worn_icon = 'icons/mob/clothing/head/cowboy.dmi'
	icon_state = "cowboy_alt"

/obj/item/clothing/head/cowboy/science
	name = "slime ranching hat"
	desc = "King of the labs, the half slime half man mutant, the slimeboy."
	icon_state = "cowboy_alt_science"

/////////////////
//DONATOR ITEMS//
/////////////////

/obj/item/clothing/head/costume/gangsterwig
	name = "gangstar wig"
	desc = "Like father like son."
	icon_state = "gangster_wig"
	flags_inv = HIDEHAIR

/obj/item/clothing/head/costume/oldhat
	name = "old man hat"
	desc = "OH MY GOD."
	icon_state = "oldmanhat"

/obj/item/clothing/head/costume/marine
	name = "mariner hat"
	desc = "There's nothing quite like the ocean breeze in the morning."
	icon_state = "marine"

/obj/item/clothing/head/costume/chicken_head_retro
	name = "chicken head"
	desc = "Looks just like a real one."
	icon_state = "chicken"
	flags_inv = HIDEHAIR
