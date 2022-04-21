// Grass
/obj/item/seeds/grass
	name = "pack of grass seeds"
	desc = "These seeds grow into grass. Yummy!"
	icon_state = "seed-grass"
	species = "grass"
	plantname = "Grass"
	product = /obj/item/reagent_containers/food/snacks/grown/grass
	lifespan = 40
	endurance = 40
	maturation = 2
	production = 5
	yield = 5
	growthstages = 2
	icon_grow = "grass-grow"
	icon_dead = "grass-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/grass/carpet, /obj/item/seeds/grass/fairy)
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.02, /datum/reagent/hydrogen = 0.05)

/obj/item/reagent_containers/food/snacks/grown/grass
	seed = /obj/item/seeds/grass
	name = "grass"
	desc = "Green and lush."
	icon_state = "grassclump"
	filling_color = "#32CD32"
	bitesize_mod = 2
	var/stacktype = /obj/item/stack/tile/grass
	var/tile_coefficient = 0.02 // 1/50
	wine_power = 15

/obj/item/reagent_containers/food/snacks/grown/grass/attack_self(mob/user)
	to_chat(user, "<span class='notice'>You prepare the astroturf.</span>")
	var/grassAmt = 1 + round(seed.potency * tile_coefficient) // The grass we're holding
	for(var/obj/item/reagent_containers/food/snacks/grown/grass/G in user.loc) // The grass on the floor
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
	product = /obj/item/reagent_containers/food/snacks/grown/grass/fairy
	icon_grow = "fairygrass-grow"
	genes = list(/datum/plant_gene/trait/repeated_harvest, /datum/plant_gene/trait/glow/blue)
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.02, /datum/reagent/hydrogen = 0.05, /datum/reagent/drug/space_drugs = 0.15)

/obj/item/reagent_containers/food/snacks/grown/grass/fairy
	seed = /obj/item/seeds/grass/fairy
	name = "fairygrass"
	desc = "Glowing, and smells fainly of mushrooms."
	icon_state = "fairygrassclump"
	filling_color = "#3399ff"
	stacktype = /obj/item/stack/tile/fairygrass
	discovery_points = 300

/obj/item/reagent_containers/food/snacks/grown/grass/fairy/attack_self(mob/user)
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
	product = /obj/item/reagent_containers/food/snacks/grown/grass/carpet
	mutatelist = list()
	rarity = 10

/obj/item/reagent_containers/food/snacks/grown/grass/carpet
	seed = /obj/item/seeds/grass/carpet
	name = "carpet"
	desc = "The textile industry's dark secret."
	icon_state = "carpetclump"
	stacktype = /obj/item/stack/tile/carpet
	can_distill = FALSE
