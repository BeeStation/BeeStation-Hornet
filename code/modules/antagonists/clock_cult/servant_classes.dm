/datum/clockcult/servant_class
	var/class_name = "haqrsvarq"
	var/class_description = "The great power of ratvar has granted this with... nothing?"
	var/list/class_clothing = list(
		SLOT_BACK = /obj/item/storage/backpack/chameleon
	)
	var/list/class_equiptment = list()
	var/list/class_scriptures = list(
		/datum/clockcult/scripture/abscond
	)

/datum/clockcult/servant_class/proc/equip_mob(mob/living/carbon/C, drop_old=TRUE)
	if(!istype(C))
		return FALSE
	for(var/slot in class_equiptment)
		C.equip_to_slot_or_del(class_clothing[slot], slot)
	return TRUE
