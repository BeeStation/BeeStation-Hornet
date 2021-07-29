/datum/species/snail
	name = "Snailperson"
	id = "snail"
	offset_features = list(OFFSET_UNIFORM = list(0,0), OFFSET_ID = list(0,0), OFFSET_GLOVES = list(0,0), OFFSET_GLASSES = list(0,4), OFFSET_EARS = list(0,0), OFFSET_SHOES = list(0,0), OFFSET_S_STORE = list(0,0), OFFSET_FACEMASK = list(0,0), OFFSET_HEAD = list(0,0), OFFSET_FACE = list(0,0), OFFSET_BELT = list(0,0), OFFSET_BACK = list(0,0), OFFSET_SUIT = list(0,0), OFFSET_NECK = list(0,0))
	default_color = "336600" //vomit green
	species_traits = list(MUTCOLORS, NO_UNDERWEAR)
	inherent_traits = list(TRAIT_ALWAYS_CLEAN)
	attack_verb = "slap"
	say_mod = "slurs"
	coldmod = 0.5 //snails only come out when its cold and wet
	burnmod = 1.5
	speedmod = 2
	punchdamage = 3
	siemens_coeff = 2 //snails are mostly water
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	sexes = FALSE //snails are hermaphrodites
	var/shell_type = /obj/item/storage/backpack/snail

	mutanteyes = /obj/item/organ/eyes/snail
	mutanttongue = /obj/item/organ/tongue/snail
	exotic_blood = /datum/reagent/lube

/datum/species/snail/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(istype(chem,/datum/reagent/consumable/sodiumchloride))
		H.adjustFireLoss(2)
		playsound(H, 'sound/weapons/sear.ogg', 30, 1)
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM)
		return 1

/datum/species/snail/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	var/obj/item/storage/backpack/bag = C.get_item_by_slot(ITEM_SLOT_BACK)
	if(!istype(bag, /obj/item/storage/backpack/snail))
		if(C.dropItemToGround(bag)) //returns TRUE even if its null
			C.equip_to_slot_or_del(new /obj/item/storage/backpack/snail(C), ITEM_SLOT_BACK)
	ADD_TRAIT(C, TRAIT_NOSLIPALL, SPECIES_TRAIT)

/datum/species/snail/on_species_loss(mob/living/carbon/C)
	. = ..()
	qdel(C.GetComponent(/datum/component/snailcrawl))
	REMOVE_TRAIT(C, TRAIT_NOSLIPALL, SPECIES_TRAIT)
	var/obj/item/storage/backpack/bag = C.get_item_by_slot(ITEM_SLOT_BACK)
	if(istype(bag, /obj/item/storage/backpack/snail))
		bag.emptyStorage()
		C.doUnEquip(bag, TRUE, no_move = TRUE)
		qdel(bag)

/obj/item/storage/backpack/snail
	name = "snail shell"
	desc = "Worn by snails as armor and storage compartment."
	icon_state = "snailshell"
	item_state = "snailshell"
	lefthand_file = 'icons/mob/inhands/equipment/backpack_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/backpack_righthand.dmi'
	armor = list("melee" = 20, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 0)
	max_integrity = 200
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/storage/backpack/snail/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, "snailshell")
