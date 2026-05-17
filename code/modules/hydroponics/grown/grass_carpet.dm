/obj/item/food/grown/grass
	seed = /obj/item/plant_seeds/preset/grass
	name = "grass"
	desc = "Green and lush."
	icon_state = "grassclump"
	bite_consumption_mod = 0.5 // Grazing on grass
	var/stacktype = /obj/item/stack/tile/grass
	var/tile_coefficient = 0.02 // 1/50
	wine_power = 15

/obj/item/food/grown/grass/attack_self(mob/user)
	to_chat(user, span_notice("You prepare the astroturf."))
	var/potency = get_fruit_trait_power(src) * 50
	var/grassAmt = 1 + round(potency * tile_coefficient) // The grass we're holding
	for(var/obj/item/food/grown/grass/G in user.loc) // The grass on the floor
		if(G.type != type)
			continue
		grassAmt += 1 + round(potency * tile_coefficient)
		qdel(G)
	new stacktype(user.drop_location(), grassAmt)
	qdel(src)

//Fairygrass
/obj/item/food/grown/grass/fairy
	name = "fairygrass"
	desc = "Glowing, and smells fainly of mushrooms."
	icon_state = "fairygrassclump"
	bite_consumption_mod = 1
	stacktype = /obj/item/stack/tile/fairygrass
	discovery_points = 300

/obj/item/food/grown/grass/fairy/attack_self(mob/user)
	var/list/genes = list()
	SEND_SIGNAL(src, COMSIG_PLANT_GET_GENES, genes)
	genes = genes[PLANT_GENE_INDEX_FEATURES]
	if(!length(genes))
		return ..()
	var/datum/plant_trait/fruit/biolight/light = locate(/datum/plant_trait/fruit/biolight) in genes
	if(!light)
		return ..()
	switch(light.type)
		if(/datum/plant_trait/fruit/biolight/yellow)
			stacktype = /obj/item/stack/tile/fairygrass/yellow
		if(/datum/plant_trait/fruit/biolight/white)
			stacktype = /obj/item/stack/tile/fairygrass/white
		if(/datum/plant_trait/fruit/biolight/red)
			stacktype = /obj/item/stack/tile/fairygrass/red
		if(/datum/plant_trait/fruit/biolight/green)
			stacktype = /obj/item/stack/tile/fairygrass/green
		if(/datum/plant_trait/fruit/biolight/orange)
			stacktype = /obj/item/stack/tile/fairygrass/orange
		if(/datum/plant_trait/fruit/biolight/blue)
			stacktype = /obj/item/stack/tile/fairygrass/blue
		if(/datum/plant_trait/fruit/biolight/purple)
			stacktype = /obj/item/stack/tile/fairygrass/purple
		if(/datum/plant_trait/fruit/biolight/pink)
			stacktype = /obj/item/stack/tile/fairygrass/pink
		if(/datum/plant_trait/fruit/biolight/dark)
			stacktype = /obj/item/stack/tile/fairygrass/dark
		else
			stacktype = initial(stacktype)
	return ..()

// Carpet
/obj/item/food/grown/grass/carpet
	name = "carpet"
	desc = "The textile industry's dark secret."
	icon_state = "carpetclump"
	stacktype = /obj/item/stack/tile/carpet
	can_distill = FALSE

// shamrocks
/obj/item/food/grown/grass/shamrock
	name = "shamrock"
	desc = "Luck of the irish."
	icon_state = "shamrock"
	worn_icon_state = "geranium"
	slot_flags = ITEM_SLOT_HEAD
	bite_consumption_mod = 3
	can_distill = FALSE

/obj/item/food/grown/grass/shamrock/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_HEAD)
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "flower_worn", /datum/mood_event/flower_worn, src)

/obj/item/food/grown/grass/shamrock/dropped(mob/living/carbon/user)
	..()
	if(user.head != src)
		return
	else
		SEND_SIGNAL(user, COMSIG_CLEAR_MOOD_EVENT, "flower_worn")

//clover
CREATION_TEST_IGNORE_SUBTYPES(/obj/item/food/grown/grass/shamrock)

/obj/item/food/grown/grass/shamrock/Initialize(mapload)
	. = ..()
	if(prob(0.001)) // 0.001% chance to be a clover
		name = "four leafed clover"
		desc = "A rare sought after trinket said to grant luck to it's holder."
		icon_state = "clover"
