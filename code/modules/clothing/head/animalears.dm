/obj/item/clothing/head/costume/kitty
	name = "kitty ears"
	desc = "A pair of kitty ears. Meow!"
	icon_state = "kitty"
	color = "#999999"


	dog_fashion = /datum/dog_fashion/head/kitty

/obj/item/clothing/head/costume/kitty/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/haircolor_clothing)

/obj/item/clothing/head/costume/kitty/genuine
	desc = "A pair of kitty ears. A tag on the inside says \"Hand made from real cats.\""

/obj/item/clothing/head/costume/rabbitears
	name = "rabbit ears"
	desc = "Wearing these makes you look useless, and only good for your sex appeal."
	icon_state = "bunny"
	clothing_flags = SNUG_FIT


	dog_fashion = /datum/dog_fashion/head/rabbit

/obj/item/clothing/head/costume/rabbitears/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/haircolor_clothing)
