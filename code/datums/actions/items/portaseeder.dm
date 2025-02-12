/datum/action/item_action/portaseeder_dissolve
	name = "Activate Seed Extractor"

/datum/action/item_action/portaseeder_dissolve/on_activate(mob/user, atom/target)
	var/obj/item/storage/bag/plants/portaseeder/H = target
	H.dissolve_contents()
