/datum/action/item_action/portaseeder_dissolve
	name = "Activate Seed Extractor"

/datum/action/item_action/portaseeder_dissolve/Trigger(trigger_flags)
	var/obj/item/storage/bag/plants/portaseeder/H = target
	H.dissolve_contents()
