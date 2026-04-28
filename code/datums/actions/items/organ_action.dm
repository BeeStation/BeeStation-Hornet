/datum/action/item_action/organ_action
	name = "Organ Action"
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/item_action/organ_action/is_available()
	var/obj/item/organ/attached_organ = master
	if(!attached_organ.owner)
		return FALSE
	return ..()

/datum/action/item_action/organ_action/toggle
	name = "Toggle Organ"

/datum/action/item_action/organ_action/toggle/New(Target)
	..()
	var/obj/item/organ/organ_target = master
	name = "Toggle [organ_target.name]"

/datum/action/item_action/organ_action/use
	name = "Use Organ"

/datum/action/item_action/organ_action/use/New(Target)
	..()
	var/obj/item/organ/organ_target = master
	name = "Use [organ_target.name]"
