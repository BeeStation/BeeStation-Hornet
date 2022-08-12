/obj/item/storage/box/hardsuit_tracking_upgrades
	name = "hardsuit tracking upgrades"

/obj/item/storage/box/hardsuit_tracking_upgrades/PopulateContents()
	new /obj/item/hardsuit_track_upgrade(src)
	new /obj/item/hardsuit_track_upgrade(src)
	new /obj/item/hardsuit_track_upgrade(src)

/obj/item/hardsuit_track_upgrade
	name = "hardsuit tracking beacon upgrade"
	desc = "An upgrade that can be placed into hardsuits to enable them to track other hardsuits with this item."
	icon = 'icons/obj/module.dmi'
	icon_state = "datadisk1"
	w_class = WEIGHT_CLASS_TINY
	item_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
