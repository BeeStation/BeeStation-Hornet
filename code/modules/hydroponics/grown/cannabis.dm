// Cannabis
/obj/item/seeds/cannabis
	name = "pack of cannabis seeds"
	desc = "Taxable."
	icon_state = "seed-cannabis"
	species = "cannabis"
	plantname = "Cannabis Plant"
	product = /obj/item/reagent_containers/food/snacks/grown/cannabis
	maturation = 8
	potency = 20
	growthstages = 1
	growing_icon = 'goon/icons/obj/hydroponics.dmi'
	icon_grow = "cannabis-grow" // Uses one growth icons set for all the subtypes
	icon_dead = "cannabis-dead" // Same for the dead icon
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/cannabis/rainbow,
						/obj/item/seeds/cannabis/death,
						/obj/item/seeds/cannabis/white,
						/obj/item/seeds/cannabis/ultimate)
	reagents_set = list(
		/datum/reagent/drug/space_drugs = list(30, 5),
		/datum/reagent/toxin/lipolicide = list(35, 10)) // intentional values.


/obj/item/seeds/cannabis/rainbow
	name = "pack of rainbow weed seeds"
	desc = "These seeds grow into rainbow weed. Groovy."
	icon_state = "seed-megacannabis"
	species = "megacannabis"
	plantname = "Rainbow Weed"
	product = /obj/item/reagent_containers/food/snacks/grown/cannabis/rainbow
	mutatelist = list()
	reagents_set = list(
		/datum/reagent/toxin/mindbreaker = list(40, 25),
		/datum/reagent/drug/space_drugs = list(30, 5),
		/datum/reagent/toxin/lipolicide = list(25, 40),
		/datum/reagent/drug/happiness = list(40, 10)) //intentional values
	rarity = 40

/obj/item/seeds/cannabis/death
	name = "pack of deathweed seeds"
	desc = "These seeds grow into deathweed. Not groovy."
	icon_state = "seed-blackcannabis"
	species = "blackcannabis"
	plantname = "Deathweed"
	product = /obj/item/reagent_containers/food/snacks/grown/cannabis/death
	mutatelist = list(/obj/item/seeds/cannabis)
	reagents_set = list(
		/datum/reagent/toxin/cyanide = list(25, 35),
		/datum/reagent/drug/space_drugs = list(15, 35),
		/datum/reagent/toxin/lipolicide = list(15, 35))
	rarity = 40

/obj/item/seeds/cannabis/white
	name = "pack of lifeweed seeds"
	desc = "I will give unto him that is munchies of the fountain of the cravings of life, freely."
	icon_state = "seed-whitecannabis"
	species = "whitecannabis"
	plantname = "Lifeweed"
	product = /obj/item/reagent_containers/food/snacks/grown/cannabis/white
	mutatelist = list(/obj/item/seeds/cannabis)
	reagents_set = list(
		/datum/reagent/medicine/omnizine = list(25, 40),
		/datum/reagent/medicine/meclizine = list(15, 30),
		/datum/reagent/drug/space_drugs = list(15, 30),
		/datum/reagent/toxin/lipolicide = list(15, 30))
	rarity = 40


/obj/item/seeds/cannabis/ultimate
	name = "pack of omega weed seeds"
	desc = "These seeds grow into omega weed."
	icon_state = "seed-ocannabis"
	species = "ocannabis"
	plantname = "Omega Weed"
	product = /obj/item/reagent_containers/food/snacks/grown/cannabis/ultimate
	genes = list(/datum/plant_gene/trait/glow/green)
	mutatelist = list(/obj/item/seeds/cannabis)
	reagents_set = list(
		/datum/reagent/drug/space_drugs = list(30, 5),  // intentional. get it from other weeds if you want higher value.
		/datum/reagent/toxin/mindbreaker = list(30, 5), // same above.
		/datum/reagent/mercury = list(15, 30),
		/datum/reagent/lithium = list(15, 30),
		/datum/reagent/medicine/atropine = list(15, 30),
		/datum/reagent/medicine/haloperidol = list(15,30),
		/datum/reagent/drug/methamphetamine = list(15, 30),
		/datum/reagent/consumable/capsaicin = list(15, 1), // intentional. get pepper if you want capsaicin
		/datum/reagent/barbers_aid = list(15, 30),
		/datum/reagent/drug/bath_salts = list(15, 30),
		/datum/reagent/toxin/itching_powder = list(15, 30),
		/datum/reagent/drug/crank = list(15, 30),
		/datum/reagent/drug/krokodil = list(15, 30),
		/datum/reagent/toxin/histamine = list(15, 30),
		/datum/reagent/toxin/lipolicide = list(15, 10)) // intentional. same above.
	rarity = 69


// ---------------------------------------------------------------

/obj/item/reagent_containers/food/snacks/grown/cannabis
	seed = /obj/item/seeds/cannabis
	icon = 'goon/icons/obj/hydroponics.dmi'
	name = "cannabis leaf"
	desc = "Recently legalized in most galaxies."
	icon_state = "cannabis"
	filling_color = "#00FF00"
	bitesize_mod = 2
	foodtype = VEGETABLES //i dont really know what else weed could be to be honest
	tastes = list("cannabis" = 1)
	wine_power = 20

/obj/item/reagent_containers/food/snacks/grown/cannabis/rainbow
	seed = /obj/item/seeds/cannabis/rainbow
	name = "rainbow cannabis leaf"
	desc = "Is it supposed to be glowing like that...?"
	icon_state = "megacannabis"
	wine_power = 60
	discovery_points = 300

/obj/item/reagent_containers/food/snacks/grown/cannabis/death
	seed = /obj/item/seeds/cannabis/death
	name = "death cannabis leaf"
	desc = "Looks a bit dark. Oh well."
	icon_state = "blackcannabis"
	wine_power = 40
	discovery_points = 300

/obj/item/reagent_containers/food/snacks/grown/cannabis/white
	seed = /obj/item/seeds/cannabis/white
	name = "white cannabis leaf"
	desc = "It feels smooth and nice to the touch."
	icon_state = "whitecannabis"
	wine_power = 10
	discovery_points = 300

/obj/item/reagent_containers/food/snacks/grown/cannabis/ultimate
	seed = /obj/item/seeds/cannabis/ultimate
	name = "omega cannabis leaf"
	desc = "You feel dizzy looking at it. What the fuck?"
	icon_state = "ocannabis"
	volume = 420
	wine_power = 90
	discovery_points = 300
