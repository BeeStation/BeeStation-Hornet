//Inath-Neq, Sevtug, Nezbere, and Nzcrentr
//Note that there are only the set amount of classes of instantiated classes at once
//Every servant stores a reference to the class it uses
//So if 2 servants use  the same class, they will have the same reference to the class
//This means dynamically updating the vars for one servant will update for all others
//Which means you shouldn't have vars here related to individuals

GLOBAL_LIST_INIT(servant_classes, list())
GLOBAL_LIST_INIT(servant_global_scriptures, list(
	/datum/clockcult/scripture/abscond,
	/datum/clockcult/scripture/integration_cog,
	/datum/clockcult/scripture/slab/kindle,
	/datum/clockcult/scripture/slab/hateful_manacles,
	/datum/clockcult/scripture/create_structure/sigil_submission,
	/datum/clockcult/scripture/ark_activation,
	/datum/clockcult/scripture/clockwork_armaments,
	/datum/clockcult/scripture/cogscarab
))

/datum/clockcult/servant_class
	var/class_name = "haqrsvarq"
	var/class_description = "The great power of ratvar has granted this with... nothing?"
	var/class_ID = 0
	var/selectable = FALSE
	var/list/class_clothing = list(
		/obj/item/clothing/under/chameleon/ratvar = SLOT_W_UNIFORM,
		/obj/item/storage/backpack/chameleon = SLOT_BACK,
		/obj/item/storage/belt/utility/servant = SLOT_BELT,
		/obj/item/clothing/shoes/chameleon = SLOT_SHOES,
		/obj/item/clothing/gloves/color/yellow = SLOT_GLOVES,
		/obj/item/card/id/syndicate/ratvar = SLOT_WEAR_ID,
		/obj/item/clothing/glasses/chameleon = SLOT_GLASSES
	)
	var/list/class_equiptment = list()
	var/list/class_scriptures = list()

/datum/clockcult/servant_class/proc/equip_mob(mob/living/carbon/C, drop_old=TRUE)
	if(!istype(C))
		return FALSE
	for(var/clothes in class_clothing)
		C.equip_to_slot_or_del(new clothes, class_clothing[clothes])
	for(var/equipment in class_equiptment)
		C.equip_to_appropriate_slot(new equipment)
	return TRUE

/datum/clockcult/servant_class/vanguard
	class_name = "Inath-Neq"
	class_description = "Good for converting and sabotage. Crossbow"
	selectable = TRUE
	class_equiptment = list(
		/obj/item/twohanded/clockwork/brass_sword
	)

/datum/clockcult/servant_class/fright
	class_name = "Sevtug"
	class_description = "Strong weapons, offensive capability, the best defense is offense. Sword"
	selectable = TRUE
	class_equiptment = list(
		/obj/item/twohanded/clockwork/brass_sword
	)

/datum/clockcult/servant_class/armorer
	class_name = "Nezbere"
	class_description = "Good armour, defensive structures, in charge of keeping /them/ out. Hammer"
	selectable = TRUE
	class_equiptment = list(
		/obj/item/twohanded/clockwork/brass_sword
	)

/datum/clockcult/servant_class/amperage
	class_name = "Nzcrentr"
	class_description = "Supportive class, in charge of maintaining the warriors. Spear"
	selectable = TRUE
	class_equiptment = list(
		/obj/item/twohanded/clockwork/brass_spear
	)
