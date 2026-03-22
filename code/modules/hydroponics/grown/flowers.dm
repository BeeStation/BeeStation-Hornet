// Grown Flowers
/obj/item/seeds/flower
	name = "pack of generic flower seeds"
	desc = "You should not be seeing this."
	icon_state = null
	worn_icon_state = null
	endurance = 10
	maturation = 8
	yield = 6
	potency = 20
	growthstages = 3
	growing_icon = 'icons/obj/hydroponics/growing_flowers.dmi'

/obj/item/food/grown/flower
	name = "generic flower"
	desc = "You should not be seeing this"
	icon_state = null
	worn_icon_state = null
	slot_flags = ITEM_SLOT_HEAD
	bite_consumption_mod = 2
	worn_icon = 'icons/mob/clothing/head/hydroponics.dmi'
	food_reagents = null //get the unit test off our back
	foodtypes = VEGETABLES | GROSS

/obj/item/food/grown/flower/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_HEAD)
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "flower_worn", /datum/mood_event/flower_worn, src)

/obj/item/food/grown/flower/dropped(mob/living/carbon/user)
	..()
	if(user.head != src)
		return
	else
		SEND_SIGNAL(user, COMSIG_CLEAR_MOOD_EVENT, "flower_worn")

// Poppy
/obj/item/seeds/flower/poppy
	name = "pack of poppy seeds"
	desc = "These seeds grow into poppies."
	icon_state = "seed-poppy"
	species = "poppy"
	plantname = "Poppy Plants"
	product = /obj/item/food/grown/flower/poppy
	icon_grow = "poppy-grow"
	icon_dead = "poppy-dead"
	mutatelist = list(/obj/item/seeds/flower/geranium, /obj/item/seeds/flower/lily)
	reagents_add = list(/datum/reagent/medicine/morphine = 0.15, /datum/reagent/medicine/bicaridine = 0.2, /datum/reagent/consumable/nutriment = 0.05)

/obj/item/food/grown/flower/poppy
	seed = /obj/item/seeds/flower/poppy
	name = "poppy"
	desc = "Long-used as a symbol of rest, peace, and death."
	icon_state = "poppy"
	distill_reagent = /datum/reagent/consumable/ethanol/vermouth

// Lily
/obj/item/seeds/flower/lily
	name = "pack of lily seeds"
	desc = "These seeds grow into lilies."
	icon_state = "seed-lily"
	species = "lily"
	plantname = "Lily Plants"
	product = /obj/item/food/grown/flower/lily
	icon_grow = "lily-grow"
	icon_dead = "lily-dead"
	mutatelist = list(/obj/item/seeds/flower/trumpet)

/obj/item/food/grown/flower/lily
	seed = /obj/item/seeds/flower/lily
	name = "lily"
	desc = "A beautiful white flower with rich symbolism. The lily is said to represent love and affection as well as purity and innocence in some cultures."
	icon_state = "lily"
	discovery_points = 300

//Spacemans's Trumpet
/obj/item/seeds/flower/trumpet
	name = "pack of spaceman's trumpet seeds"
	desc = "A plant sculpted by extensive genetic engineering. The spaceman's trumpet is said to bear no resemblance to its wild ancestors. Inside NT AgriSci circles it is better known as NTPW-0372."
	icon_state = "seed-trumpet"
	species = "spacemanstrumpet"
	plantname = "Spaceman's Trumpet Plant"
	product = /obj/item/food/grown/flower/trumpet
	lifespan = 240
	production = 5
	maturation = 12
	yield = 4
	growthstages = 4
	weed_rate = 2
	weed_chance = 10
	icon_grow = "spacemanstrumpet-grow"
	icon_dead = "spacemanstrumpet-dead"
	mutatelist = list()
	genes = list(/datum/plant_gene/reagent/polypyr)
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.05)
	rarity = 30

CREATION_TEST_IGNORE_SUBTYPES(/obj/item/seeds/flower/trumpet)

/obj/item/seeds/flower/trumpet/Initialize(mapload,nogenes)
	. = ..()
	if(!nogenes)
		unset_mutability(/datum/plant_gene/reagent/polypyr, PLANT_GENE_EXTRACTABLE)

/obj/item/food/grown/flower/trumpet
	seed = /obj/item/seeds/flower/trumpet
	name = "spaceman's trumpet"
	desc = "A vivid flower that smells faintly of freshly cut grass. Touching the flower seems to stain the skin some time after contact, yet most other surfaces seem to be unaffected by this phenomenon."
	icon_state = "spacemanstrumpet"
	foodtypes = VEGETABLES
	slot_flags = null

// Geranium
/obj/item/seeds/flower/geranium
	name = "pack of geranium seeds"
	desc = "These seeds grow into geranium."
	icon_state = "seed-geranium"
	species = "geranium"
	plantname = "Geranium Plants"
	product = /obj/item/food/grown/flower/geranium
	icon_grow = "geranium-grow"
	icon_dead = "geranium-dead"
	mutatelist = list(/obj/item/seeds/flower/forgetmenot)

/obj/item/food/grown/flower/geranium
	seed = /obj/item/seeds/flower/geranium
	name = "geranium"
	desc = "A cluster of small purple geranium flowers. They symbolize happiness, good health, wishes and friendship and are generally associated with positive emotions."
	icon_state = "geranium"
	discovery_points = 300

//Forget-Me-Not
/obj/item/seeds/flower/forgetmenot
	name = "pack of forget-me-not seeds"
	desc = "These seeds grow into forget-me-nots."
	icon_state = "seed-forget_me_not"
	species = "forget_me_not"
	plantname = "Forget-Me-Not Plants"
	product = /obj/item/food/grown/flower/forgetmenot
	endurance = 30
	maturation = 5
	yield = 4
	potency = 25
	icon_grow = "forget_me_not-grow"
	icon_dead = "forget_me_not-dead"
	mutatelist = list()
	reagents_add = list(/datum/reagent/medicine/kelotane = 0.2, /datum/reagent/consumable/nutriment = 0.05)

/obj/item/food/grown/flower/forgetmenot
	seed = /obj/item/seeds/flower/forgetmenot
	name = "forget-me-not"
	desc = "A clump of small blue flowers, they are primarily associated with rememberance, respect and loyalty."
	icon_state = "forget_me_not"
	discovery_points = 300

// Harebell
/obj/item/seeds/flower/harebell
	name = "pack of harebell seeds"
	desc = "These seeds grow into pretty little flowers."
	icon_state = "seed-harebell"
	species = "harebell"
	plantname = "Harebells"
	product = /obj/item/food/grown/flower/harebell
	lifespan = 400
	endurance = 20
	maturation = 7
	production = 1
	yield = 2
	potency = 30
	growthstages = 4
	genes = list(/datum/plant_gene/trait/plant_type/weed_hardy)
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.04)

/obj/item/food/grown/flower/harebell
	seed = /obj/item/seeds/flower/harebell
	name = "harebell"
	desc = "\"I'll sweeten thy sad grave: thou shalt not lack the flower that's like thy face, pale primrose, nor the azured hare-bell, like thy veins; no, nor the leaf of eglantine, whom not to slander, out-sweeten'd not thy breath.\""
	icon_state = "harebell"
	distill_reagent = /datum/reagent/consumable/ethanol/vermouth

// Sunflower
/obj/item/seeds/sunflower
	name = "pack of sunflower seeds"
	desc = "These seeds grow into sunflowers."
	icon_state = "seed-sunflower"
	species = "sunflower"
	plantname = "Sunflowers"
	product = /obj/item/grown/sunflower
	endurance = 20
	production = 2
	yield = 2
	growthstages = 3
	growing_icon = 'icons/obj/hydroponics/growing_flowers.dmi'
	icon_grow = "sunflower-grow"
	icon_dead = "sunflower-dead"
	mutatelist = list(/obj/item/seeds/sunflower/moonflower, /obj/item/seeds/sunflower/novaflower)
	reagents_add = list(/datum/reagent/consumable/nutriment/fat/oil = 0.08, /datum/reagent/consumable/nutriment = 0.04)

/obj/item/grown/sunflower // FLOWER POWER!
	seed = /obj/item/seeds/sunflower
	name = "sunflower"
	desc = "It's beautiful! A certain person might beat you to death if you trample these."
	icon_state = "sunflower"
	lefthand_file = 'icons/mob/inhands/weapons/plants_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/plants_righthand.dmi'
	damtype = BURN
	force = 0
	slot_flags = ITEM_SLOT_HEAD
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 1
	throw_range = 3

/obj/item/grown/sunflower/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_HEAD)
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "flower_worn", /datum/mood_event/flower_worn, src)

/obj/item/grown/sunflower/dropped(mob/living/carbon/user)
	..()
	if(user.head != src)
		return
	else
		SEND_SIGNAL(user, COMSIG_CLEAR_MOOD_EVENT, "flower_worn")


/obj/item/grown/sunflower/attack(mob/M, mob/user)
	to_chat(M, "<font color='green'><b> [user] smacks you with a sunflower! </font><font color='yellow'><b>FLOWER POWER<b></font>")
	to_chat(user, "<font color='green'>Your sunflower's </font><font color='yellow'><b>FLOWER POWER</b></font><font color='green'> strikes [M]</font>")

// Moonflower
/obj/item/seeds/sunflower/moonflower
	name = "pack of moonflower seeds"
	desc = "Its petals are known for helping insomiacs around the world."
	icon_state = "seed-moonflower"
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	species = "moonflower"
	plantname = "Moonflowers"
	icon_grow = "moonflower-grow"
	icon_dead = "sunflower-dead"
	product = /obj/item/food/grown/flower/moonflower
	genes = list(/datum/plant_gene/trait/glow/purple)
	mutatelist = list()
	reagents_add = list(/datum/reagent/acetone = 0.08, /datum/reagent/consumable/ethanol/moonshine = 0.2, /datum/reagent/medicine/morphine = 0.3, /datum/reagent/consumable/nutriment = 0.02)
	rarity = 20

/obj/item/food/grown/flower/moonflower
	seed = /obj/item/seeds/sunflower/moonflower
	name = "moonflower"
	desc = "Store in a location at least 50 yards away from werewolves."
	icon_state = "moonflower"
	foodtypes = null
	distill_reagent = /datum/reagent/consumable/ethanol/absinthe //It's made from flowers.
	discovery_points = 300

// Novaflower
/obj/item/seeds/sunflower/novaflower
	name = "pack of novaflower seeds"
	desc = "These seeds grow into novaflowers."
	icon_state = "seed-novaflower"
	species = "novaflower"
	plantname = "Novaflowers"
	icon_grow = "novaflower-grow"
	icon_dead = "sunflower-dead"
	product = /obj/item/grown/novaflower
	mutatelist = list()
	reagents_add = list(/datum/reagent/consumable/condensedcapsaicin = 0.25, /datum/reagent/consumable/capsaicin = 0.3, /datum/reagent/consumable/nutriment = 0)
	rarity = 15

/obj/item/grown/novaflower
	seed = /obj/item/seeds/sunflower/novaflower
	name = "novaflower"
	desc = "These beautiful flowers have a crisp smokey scent, like a summer bonfire."
	icon_state = "novaflower"
	lefthand_file = 'icons/mob/inhands/weapons/plants_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/plants_righthand.dmi'
	damtype = BURN
	force = 0
	slot_flags = ITEM_SLOT_HEAD
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 1
	throw_range = 3
	attack_verb_continuous = list("roasts", "scorches", "burns")
	attack_verb_simple = list("roast", "scorch", "burn")
	grind_results = list(/datum/reagent/consumable/capsaicin = 0, /datum/reagent/consumable/condensedcapsaicin = 0)
	discovery_points = 300

CREATION_TEST_IGNORE_SUBTYPES(/obj/item/grown/novaflower)

/obj/item/grown/novaflower/Initialize(mapload, obj/item/seeds/new_seed)
	..()
	force = round((5 + seed.potency / 5), 1)

/obj/item/grown/novaflower/attack(mob/living/carbon/M, mob/user)
	if(!..())
		return
	if(isliving(M))
		to_chat(M, span_danger("You are lit on fire from the intense heat of the [name]!"))
		M.adjust_fire_stacks(seed.potency / 20)
		if(M.ignite_mob())
			message_admins("[ADMIN_LOOKUPFLW(user)] set [ADMIN_LOOKUPFLW(M)] on fire with [src] at [AREACOORD(user)]")
			log_game("[key_name(user)] set [key_name(M)] on fire with [src] at [AREACOORD(user)]")

/obj/item/grown/novaflower/afterattack(atom/A as mob|obj, mob/user,proximity)
	. = ..()
	if(!proximity)
		return
	if(force > 0)
		force -= rand(1, (force / 3) + 1)
	else
		to_chat(usr, span_warning("All the petals have fallen off the [name] from violent whacking!"))
		qdel(src)

/obj/item/grown/novaflower/pickup(mob/living/carbon/human/user)
	..()
	if(!user.gloves)
		to_chat(user, span_danger("The [name] burns your bare hand!"))
		user.adjustFireLoss(rand(1, 5))

/obj/item/grown/novaflower/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_HEAD)
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "flower_worn", /datum/mood_event/flower_worn, src)

/obj/item/grown/novaflower/dropped(mob/living/carbon/user)
	..()
	if(user.head != src)
		return
	else
		SEND_SIGNAL(user, COMSIG_CLEAR_MOOD_EVENT, "flower_worn")
