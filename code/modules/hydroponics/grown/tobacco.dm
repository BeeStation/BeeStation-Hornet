// Tobacco
/obj/item/seeds/tobacco
	name = "pack of tobacco seeds"
	desc = "These seeds grow into tobacco plants."
	icon_state = "seed-tobacco"
	species = "tobacco"
	plantname = "Tobacco Plant"
	product = /obj/item/reagent_containers/food/snacks/grown/tobacco
	lifespan = 20
	maturation = 5
	production = 5
	yield = 10
	growthstages = 3
	icon_dead = "tobacco-dead"
	mutatelist = list(/obj/item/seeds/tobacco/space)
	reagents_add = list(/datum/reagent/drug/nicotine = 0.03, /datum/reagent/consumable/nutriment = 0.03)

/obj/item/reagent_containers/food/snacks/grown/tobacco
	seed = /obj/item/seeds/tobacco
	name = "tobacco leaves"
	desc = "Dry them out to make some smokes."
	icon_state = "tobacco_leaves"
	filling_color = "#008000"
	distill_reagent = /datum/reagent/consumable/ethanol/creme_de_menthe //Menthol, I guess.

// Space Tobacco
/obj/item/seeds/tobacco/space
	name = "pack of space tobacco seeds"
	desc = "These seeds grow into space tobacco plants."
	icon_state = "seed-stobacco"
	species = "stobacco"
	plantname = "Space Tobacco Plant"
	product = /obj/item/reagent_containers/food/snacks/grown/tobacco/space
	mutatelist = list()
	reagents_add = list(/datum/reagent/medicine/salbutamol = 0.05, /datum/reagent/drug/nicotine = 0.08, /datum/reagent/consumable/nutriment = 0.03)
	rarity = 20

/obj/item/reagent_containers/food/snacks/grown/tobacco/space
	seed = /obj/item/seeds/tobacco/space
	name = "space tobacco leaves"
	desc = "Dry them out to make some space-smokes."
	icon_state = "stobacco_leaves"
	distill_reagent = null
	wine_power = 50

//Lavaland Tobacco

obj/item/seeds/tobacco/lavaland
	name = "pack of lavaland tobacco seeds"
	desc = "These seeds grow into lavaland tobacco plants."
	icon_state = "seed-lavatobacco"
	species = "ashtobacco"
	plantname = "Lavaland Tobacco Plant"
	product = /obj/item/reagent_containers/food/snacks/grown/tobacco/lavaland
	mutatelist = list()
	reagents_add = list(/datum/reagent/medicine/salbutamol = 0.1, /datum/reagent/drug/nicotine = 0.08, /datum/reagent/toxin/lipolicide = 0.4)
	genes = list(/datum/plant_gene/trait/plant_type/fungal_metabolism)
	rarity = 20

/obj/item/reagent_containers/food/snacks/grown/tobacco/lavaland
	seed = /obj/item/seeds/tobacco/lavaland
	name = "lavaland tobacco leaves"
	desc = "Despite being called lavaland tobacco this plant has little in common with regular tobacco."
	icon_state = "ltobacco_leaves"
	distill_reagent = null
	wine_power = 10
