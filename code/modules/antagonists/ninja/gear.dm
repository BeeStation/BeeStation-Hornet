/obj/item/caltrops
	name = "caltrops"
	desc = "a small spiked object left on the floor to deter pursuers"
	force = 8 // it's a sharp object
	icon = 'icons/obj/grenade.dmi'
	icon_state = "delivery"
	item_state = "flashbang"

/obj/item/caltrops/Initialize()
	. = ..()
	AddComponent(/datum/component/caltrop, 20, CALTROP_BYPASS_SHOES)