/obj/item/clothing/head/helmet/space/santahat
	name = "Santa's hat"
	desc = "Ho ho ho. Merrry X-mas!"
	icon = 'icons/obj/clothing/head/wizard.dmi'
	worn_icon = 'icons/mob/clothing/head/wizard.dmi'
	icon_state = "santahat"
	item_state = "santahat"
	flags_cover = HEADCOVERSEYES
	dog_fashion = /datum/dog_fashion/head/santa
	salvage_material = /obj/item/stack/sheet/cotton/cloth
	salvage_amount = 2
	secondary_salvage_material = null

/obj/item/clothing/suit/space/santa
	name = "Santa's suit"
	desc = "Festive!"
	icon_state = "santa"
	icon = 'icons/obj/clothing/suits/wizard.dmi'
	worn_icon = 'icons/mob/clothing/suits/wizard.dmi'
	item_state = "santa"
	slowdown = 0
	allowed = list(/obj/item) //for stuffing exta special presents
	salvage_material = /obj/item/stack/sheet/cotton/cloth
	salvage_amount = 3
	secondary_salvage_material = null
