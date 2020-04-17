/datum/species/apid
	name = "Apids"
	id = "apid"
	say_mod = "buzzes"
	default_color = "FFE800"
	species_traits = list(LIPS, NOEYESPRITES)
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID, MOB_BUG)
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/apid
	liked_foods = VEGETABLES | FRUIT
	disliked_foods = GROSS | DAIRY
	toxic_food = MEAT | RAW
	mutanteyes = /obj/item/organ/eyes/apid
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
