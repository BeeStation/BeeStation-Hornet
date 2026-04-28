// Grass
/obj/item/seeds/grass
	name = "pack of grass seeds"
	desc = "These seeds grow into grass. Yummy!"
	icon_state = "seed-grass"
	species = "grass"
	plantname = "Grass"
	product = /obj/item/food/grown/grass
	lifespan = 160
	endurance = 40
	maturation = 2
	production = 5
	yield = 5
	growthstages = 2
	icon_grow = "grass-grow"
	icon_dead = "grass-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/grass/carpet, /obj/item/seeds/grass/fairy, /obj/item/seeds/grass/shamrock)
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.02, /datum/reagent/hydrogen = 0.05)

/obj/item/food/grown/grass
	seed = /obj/item/seeds/grass
	name = "grass"
	desc = "Green and lush."
	icon_state = "grassclump"
	bite_consumption_mod = 0.5 // Grazing on grass
	var/stacktype = /obj/item/stack/tile/grass
	var/tile_coefficient = 0.02 // 1/50
	wine_power = 15

/obj/item/food/grown/grass/attack_self(mob/user)
	to_chat(user, span_notice("You prepare the astroturf."))
	var/grassAmt = 1 + round(seed.potency * tile_coefficient) // The grass we're holding
	for(var/obj/item/food/grown/grass/G in user.loc) // The grass on the floor
		if(G.type != type)
			continue
		grassAmt += 1 + round(G.seed.potency * tile_coefficient)
		qdel(G)
	new stacktype(user.drop_location(), grassAmt)
	qdel(src)

//Fairygrass
/obj/item/seeds/grass/fairy
	name = "pack of fairygrass seeds"
	desc = "These seeds grow into a more mystical grass."
	icon_state = "seed-fairygrass"
	species = "fairygrass"
	plantname = "Fairygrass"
	product = /obj/item/food/grown/grass/fairy
	icon_grow = "fairygrass-grow"
	genes = list(/datum/plant_gene/trait/repeated_harvest, /datum/plant_gene/trait/glow/blue)
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.02, /datum/reagent/hydrogen = 0.05, /datum/reagent/drug/space_drugs = 0.15)

/obj/item/food/grown/grass/fairy
	seed = /obj/item/seeds/grass/fairy
	name = "fairygrass"
	desc = "Glowing, and smells fainly of mushrooms."
	icon_state = "fairygrassclump"
	bite_consumption_mod = 1
	stacktype = /obj/item/stack/tile/fairygrass
	discovery_points = 300

/obj/item/food/grown/grass/fairy/attack_self(mob/user)
	var/datum/plant_gene/trait/glow/G = null
	for(var/datum/plant_gene/trait/glow/gene in seed.genes)
		G = gene
		break

	stacktype = initial(stacktype)

	if(G)
		switch(G.type)
			if(/datum/plant_gene/trait/glow/white)
				stacktype = /obj/item/stack/tile/fairygrass/white
			if(/datum/plant_gene/trait/glow/red)
				stacktype = /obj/item/stack/tile/fairygrass/red
			if(/datum/plant_gene/trait/glow/yellow)
				stacktype = /obj/item/stack/tile/fairygrass/yellow
			if(/datum/plant_gene/trait/glow/green)
				stacktype = /obj/item/stack/tile/fairygrass/green
			if(/datum/plant_gene/trait/glow/orange)
				stacktype = /obj/item/stack/tile/fairygrass/orange
			if(/datum/plant_gene/trait/glow/blue)
				stacktype = /obj/item/stack/tile/fairygrass/blue
			if(/datum/plant_gene/trait/glow/purple)
				stacktype = /obj/item/stack/tile/fairygrass/purple
			if(/datum/plant_gene/trait/glow/pink)
				stacktype = /obj/item/stack/tile/fairygrass/pink
			if(/datum/plant_gene/trait/glow/shadow)
				stacktype = /obj/item/stack/tile/fairygrass/dark

	. = ..()

// Carpet
/obj/item/seeds/grass/carpet
	name = "pack of carpet seeds"
	desc = "These seeds grow into stylish carpet samples."
	icon_state = "seed-carpet"
	species = "carpet"
	plantname = "Carpet"
	product = /obj/item/food/grown/grass/carpet
	mutatelist = list()
	rarity = 10

/obj/item/food/grown/grass/carpet
	seed = /obj/item/seeds/grass/carpet
	name = "carpet"
	desc = "The textile industry's dark secret."
	icon_state = "carpetclump"
	stacktype = /obj/item/stack/tile/carpet
	can_distill = FALSE

// shamrocks
/obj/item/seeds/grass/shamrock
	name = "pack of shamrock seeds"
	desc = "These seeds grow into shamrock producing plants."
	icon_state = "seed-shamrock"
	species = "shamrock"
	plantname = "Shamrock Plants"
	product = /obj/item/food/grown/grass/shamrock
	mutatelist = list()
	rarity = 10
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	reagents_add = list(/datum/reagent/nitrogen = 0.1, /datum/reagent/consumable/nutriment = 0.02)

/obj/item/food/grown/grass/shamrock
	seed = /obj/item/seeds/grass/shamrock
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

/obj/item/food/grown/grass/shamrock/Initialize(mapload, /obj/item/seeds/new_seed)
	. = ..()
	if(prob(0.001)) // 0.001% chance to be a clover
		name = "four leafed clover"
		desc = "A rare sought after trinket said to grant luck to it's holder."
		icon_state = "clover"
