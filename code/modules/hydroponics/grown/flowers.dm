// Grown Flowers
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
/obj/item/food/grown/flower/poppy
	seed = /obj/item/plant_seeds/preset/poppy
	name = "poppy"
	desc = "Long-used as a symbol of rest, peace, and death."
	icon_state = "poppy"
	distill_reagent = /datum/reagent/consumable/ethanol/vermouth

// Lily
/obj/item/food/grown/flower/lily
	seed = /obj/item/plant_seeds/preset/lily
	name = "lily"
	desc = "A beautiful white flower with rich symbolism. The lily is said to represent love and affection as well as purity and innocence in some cultures."
	icon_state = "lily"
	discovery_points = 300

//Spacemans's Trumpet
/obj/item/food/grown/flower/trumpet
	seed = /obj/item/plant_seeds/preset/trumpet
	name = "spaceman's trumpet"
	desc = "A vivid flower that smells faintly of freshly cut grass. Touching the flower seems to stain the skin some time after contact, yet most other surfaces seem to be unaffected by this phenomenon."
	icon_state = "spacemanstrumpet"
	foodtypes = VEGETABLES
	slot_flags = null

// Geranium
/obj/item/food/grown/flower/geranium
	seed = /obj/item/plant_seeds/preset/geranium
	name = "geranium"
	desc = "A cluster of small purple geranium flowers. They symbolize happiness, good health, wishes and friendship and are generally associated with positive emotions."
	icon_state = "geranium"
	discovery_points = 300

//Forget-Me-Not
/obj/item/food/grown/flower/forgetmenot
	seed = /obj/item/plant_seeds/preset/forget
	name = "forget-me-not"
	desc = "A clump of small blue flowers, they are primarily associated with rememberance, respect and loyalty."
	icon_state = "forget_me_not"
	discovery_points = 300

// Harebell
/obj/item/food/grown/flower/harebell
	seed = /obj/item/plant_seeds/preset/harebell
	name = "harebell"
	desc = "\"I'll sweeten thy sad grave: thou shalt not lack the flower that's like thy face, pale primrose, nor the azured hare-bell, like thy veins; no, nor the leaf of eglantine, whom not to slander, out-sweeten'd not thy breath.\""
	icon_state = "harebell"
	distill_reagent = /datum/reagent/consumable/ethanol/vermouth

// Sunflower
/obj/item/grown/sunflower // FLOWER POWER!
	seed = /obj/item/plant_seeds/preset/sunflower
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
/obj/item/food/grown/flower/moonflower
	seed = /obj/item/plant_seeds/preset/moonflower
	name = "moonflower"
	desc = "Store in a location at least 50 yards away from werewolves."
	icon_state = "moonflower"
	foodtypes = null
	distill_reagent = /datum/reagent/consumable/ethanol/absinthe //It's made from flowers.
	discovery_points = 300

// Novaflower
/obj/item/grown/novaflower
	seed = /obj/item/plant_seeds/preset/novaflower
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

/obj/item/grown/novaflower/Initialize(mapload)
	..()
	force = round((5 + (get_fruit_trait_power(src) * 8)), 1)

/obj/item/grown/novaflower/attack(mob/living/carbon/M, mob/user)
	if(!..())
		return
	if(isliving(M))
		to_chat(M, span_danger("You are lit on fire from the intense heat of the [name]!"))
		M.adjust_fire_stacks(get_fruit_trait_power(src)+1)
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
