/obj/item/clothing/head/costume/sombrero
	name = "sombrero"
	icon = 'icons/obj/clothing/head/sombrero.dmi'
	icon_state = "sombrero"
	inhand_icon_state = "sombrero"
	desc = "You can practically taste the fiesta."
	flags_inv = HIDEHAIR

	dog_fashion = /datum/dog_fashion/head/sombrero

/obj/item/clothing/head/costume/sombrero/green
	name = "green sombrero"
	desc = "As elegant as a dancing cactus."
	icon_state = "greensombrero"
	inhand_icon_state = "greensombrero"
	flags_inv = HIDEHAIR|HIDEFACE|HIDEEARS
	dog_fashion = null

/obj/item/clothing/head/costume/sombrero/shamebrero
	name = "shamebrero"
	desc = "Once it's on, it never comes off."
	icon_state = "shamebrero"
	inhand_icon_state = "shamebrero"
	dog_fashion = null

/obj/item/clothing/head/costume/sombrero/shamebrero/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, SHAMEBRERO_TRAIT)
