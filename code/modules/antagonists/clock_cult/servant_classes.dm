//Inath-Neq, Sevtug, Nezbere, and Nzcrentr

GLOBAL_LIST_INIT(servant_classes, list())

/datum/clockcult/servant_class
	var/class_name = "haqrsvarq"
	var/class_description = "The great power of ratvar has granted this with... nothing?"
	var/list/class_clothing = list(
		SLOT_BACK = /obj/item/storage/backpack/chameleon,
		SLOT_HEAD = /obj/item/clothing/head/chameleon,
		SLOT_SHOES = /obj/item/clothing/shoes/chameleon,
		SLOT_W_UNIFORM = /obj/item/clothing/under/chameleon,
		SLOT_GLOVES = /obj/item/clothing/gloves/color/yellow,
		SLOT_WEAR_ID = /obj/item/card/id
	)
	var/list/class_equiptment = list()
	var/list/global_scriptures = list(
		/datum/clockcult/scripture/abscond,
		/datum/clockcult/scripture/slab/kindle,
		/datum/clockcult/scripture/slab/hateful_manacles
	)
	var/list/class_scriptures = list()

/datum/clockcult/servant_class/proc/equip_mob(mob/living/carbon/C, drop_old=TRUE)
	if(!istype(C))
		return FALSE
	for(var/slot in class_equiptment)
		C.equip_to_slot_or_del(class_clothing[slot], slot)
	for(var/equipment in class_equiptment)
		C.equip_to_slot_or_del(class_equiptment[equipment], equipment)
	return TRUE

/datum/clockcult/servant_class/vanguard
	class_name = "Inath-Neq"
	class_description = "Good for converting and sabotage. Crossbow"

/datum/clockcult/servant_class/fright
	class_name = "Sevtug"
	class_description = "Strong weapons, offensive capability, the best defense is offense. Sword"

/datum/clockcult/servant_class/armorer
	class_name = "Nezbere"
	class_description = "Good armour, defensive structures, in charge of keeping /them/ out. Hammer"

/datum/clockcult/servant_class/amperage
	class_name = "Nzcrentr"
	class_description = "Supportive class, in charge of maintaining the warriors. Spear"
