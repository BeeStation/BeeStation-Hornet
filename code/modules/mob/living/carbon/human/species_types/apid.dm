/datum/species/apid
	// Beepeople, god damn it.
	name = "Apids"
	id = "apid"
	say_mod = "buzzes"
	default_color = "FFE800"
	species_traits = list(LIPS, NOEYESPRITES)
	mutant_bodyparts = list("apid_wings")
	default_features = list("apid_wings" = "Apid Wings")
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID, MOB_BUG)
	mutanttongue = /obj/item/organ/tongue/bee
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/apid
	liked_food = VEGETABLES | FRUIT
	disliked_food = GROSS | DAIRY
	toxic_food = MEAT | RAW
	mutanteyes = /obj/item/organ/eyes/apid
	mutantlungs = /obj/item/organ/lungs/apid
	heatmod = 1.5
	coldmod = 1.5
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT

/datum/species/apid/after_equip_job(datum/job/J, mob/living/carbon/human/H)
	H.grant_language(/datum/language/apidite)

/datum/species/apid/check_species_weakness(obj/item/weapon, mob/living/attacker)
	if(istype(weapon, /obj/item/melee/flyswatter))
		return 29 //Bees get x30 damage from flyswatters
	return 0

/datum/species/apid/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	. = ..()
	if(chem.type == /datum/reagent/toxin/pestkiller)
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM)

/obj/item/clothing/shoes/bhop/apid
	name = "apid wings"
	desc = "Apid wings that allow for the ability to dash forward."
	icon = 'icons/mob/neck.dmi'
	icon_state = "apid_wings"
	item_state = "apid_wings"
	item_color = null
	resistance_flags = null
	pocket_storage_component_path = null
	actions_types = list(/datum/action/item_action/bhop)
	permeability_coefficient = 0.05
	strip_delay = 30
	jumpdistance = 7 
	jumpspeed = 4
	recharging_rate = 45 
	recharging_time = 0 
	slot_flags = ITEM_SLOT_NECK

/obj/item/clothing/shoes/bhop/apid/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, "apidwings")

/datum/species/apid/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	C.equip_to_slot_or_del(new /obj/item/clothing/shoes/bhop/apid(C), SLOT_NECK)
