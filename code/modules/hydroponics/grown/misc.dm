// Starthistle
/obj/item/seeds/starthistle
	name = "pack of starthistle seeds"
	desc = "A robust species of weed that often springs up in-between the cracks of spaceship parking lots."
	icon_state = "seed-starthistle"
	species = "starthistle"
	plantname = "Starthistle"
	product = /obj/item/reagent_containers/food/snacks/grown/starthistle
	lifespan = 70
	endurance = 50 // damm pesky weeds
	maturation = 5
	production = 1
	yield = 2
	potency = 10
	growthstages = 3
	growing_icon = 'icons/obj/hydroponics/growing_flowers.dmi'
	genes = list(/datum/plant_gene/family/weed_hardy)
	mutatelist = list(/obj/item/seeds/galaxythistle)

/*
/obj/item/seeds/starthistle/harvest(mob/user)
	var/obj/machinery/hydroponics/parent = loc
	var/seed_count = yield
	if(prob(getYield() * 20))
		seed_count++
		var/output_loc = parent.Adjacent(user) ? user.loc : parent.loc
		for(var/i in 1 to seed_count)
			var/obj/item/seeds/starthistle/harvestseeds = Copy()
			harvestseeds.forceMove(output_loc)

	parent.update_tray()*/

/obj/item/reagent_containers/food/snacks/grown/starthistle
	seed = /obj/item/seeds/starthistle
	name = "starthistle flower"
	desc = "starthistle flower."
	icon_state = "starthistle"
	filling_color = "#2d7e2d"
	bitesize_mod = 3
	foodtype = VEGETABLES
	wine_power = 35
	tastes = list("thistle" = 2, "starthistle" = 1)

//Galaxy Thistle
/obj/item/seeds/galaxythistle
	name = "pack of galaxythistle seeds"
	desc = "An impressive species of weed that is thought to have evolved from the simple milk thistle. Contains flavolignans that can help repair a damaged liver."
	icon_state = "seed-galaxythistle"
	species = "galaxythistle"
	plantname = "Galaxythistle"
	product = /obj/item/reagent_containers/food/snacks/grown/galaxythistle
	lifespan = 70
	endurance = 40
	maturation = 3
	production = 2
	yield = 2
	potency = 25
	growthstages = 3
	growing_icon = 'icons/obj/hydroponics/growing_flowers.dmi'
	genes = list(/datum/plant_gene/family/weed_hardy, /datum/plant_gene/trait/invasive)
	reagents_set = list(
		/datum/reagent/consumable/nutriment = list(4, 8),
		/datum/reagent/consumable/nutriment/vitamin = list(1, 4),
		/datum/reagent/medicine/silibinin = list(10, 15))
	mutatelist = list(/obj/item/seeds/starthistle)

/obj/item/seeds/galaxythistle/Initialize(mapload,nogenes)
	. = ..()
	if(!nogenes)
		unset_plant_gene_flags(/datum/plant_gene/trait/invasive, PLANT_GENE_COMMON_REMOVABLE)

/obj/item/reagent_containers/food/snacks/grown/galaxythistle
	seed = /obj/item/seeds/galaxythistle
	name = "galaxythistle flower head"
	desc = "This spiny cluster of florets reminds you of the highlands."
	icon_state = "galaxythistle"
	filling_color = "#1E7549"
	bitesize_mod = 3
	foodtype = VEGETABLES
	wine_power = 35
	tastes = list("thistle" = 2, "artichoke" = 1)

// Cabbage
/obj/item/seeds/cabbage
	name = "pack of cabbage seeds"
	desc = "These seeds grow into cabbages."
	icon_state = "seed-cabbage"
	species = "cabbage"
	plantname = "Cabbages"
	product = /obj/item/reagent_containers/food/snacks/grown/cabbage
	lifespan = 50
	endurance = 25
	maturation = 3
	production = 5
	yield = 4
	growthstages = 1
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'
	genes = list(/datum/plant_gene/trait/perennial)
	mutatelist = list(/obj/item/seeds/replicapod)
	reagents_set = list(
		/datum/reagent/consumable/nutriment = list(10, 12),
		/datum/reagent/consumable/nutriment/vitamin = list(4, 6))

/obj/item/reagent_containers/food/snacks/grown/cabbage
	seed = /obj/item/seeds/cabbage
	name = "cabbage"
	desc = "Ewwwwwwwwww. Cabbage."
	icon_state = "cabbage"
	filling_color = "#90EE90"
	bitesize_mod = 2
	foodtype = VEGETABLES
	wine_power = 20

// Sugarcane
/obj/item/seeds/sugarcane
	name = "pack of sugarcane seeds"
	desc = "These seeds grow into sugarcane."
	icon_state = "seed-sugarcane"
	species = "sugarcane"
	plantname = "Sugarcane"
	product = /obj/item/reagent_containers/food/snacks/grown/sugarcane
	genes = list(/datum/plant_gene/trait/perennial)
	lifespan = 60
	endurance = 50
	maturation = 3
	yield = 4
	growthstages = 3
	reagents_set = list(
		/datum/reagent/consumable/nutriment = list(0, 1),
		/datum/reagent/consumable/nutriment/vitamin = list(0, 1),
		/datum/reagent/consumable/sugar = list(25, 50))
	mutatelist = list(/obj/item/seeds/bamboo)

/obj/item/reagent_containers/food/snacks/grown/sugarcane
	seed = /obj/item/seeds/sugarcane
	name = "sugarcane"
	desc = "Sickly sweet."
	icon_state = "sugarcane"
	filling_color = "#FFD700"
	bitesize_mod = 2
	foodtype = VEGETABLES | SUGAR
	distill_reagent = /datum/reagent/consumable/ethanol/rum

