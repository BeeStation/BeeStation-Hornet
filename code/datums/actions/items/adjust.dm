/datum/action/item_action/adjust
	name = "Adjust Item"

/datum/action/item_action/adjust/New(master)
	..()
	var/obj/item/item_target = master
	name = "Adjust [item_target.name]"
