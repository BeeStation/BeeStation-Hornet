// Debug plant - It has every possible genes.
/obj/item/seeds/debug
	name = "pack of debugging crop seeds"
	desc = "This shouldn't exist."
	icon_state = "seed-soybean"
	species = "debug"
	plantname = "debugging Plants"
	product = /obj/item/reagent_containers/food/snacks/grown/soybeans
	maturation = 1
	production = 1
	potency = 100
	yield = 10
	growthstages = 4
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'
	icon_grow = "soybean-grow"
	icon_dead = "soybean-dead"
	genes = list()
	mutatelist = list()
	reagents_set = list(
		/datum/reagent/consumable/nutriment = list(5, 10),
		/datum/reagent/consumable/nutriment/vitamin = list(4, 8))

/obj/item/reagent_containers/food/snacks/grown/debug
	seed = /obj/item/seeds/debug
	name = "debugging plant"
	desc = "it shouldn't exist..."
	gender = PLURAL
	icon_state = "soybeans"
	filling_color = "#F0E68C"
	bitesize_mod = 2
	foodtype = VEGETABLES
	grind_results = list(/datum/reagent/consumable/soymilk = 0)
	tastes = list("soy" = 1)
	wine_power = 20
	roundstart = 0



/obj/item/seeds/debug/Initialize(mapload)
	. = ..()
	for(var/each in subtypesof(/datum/plant_gene/trait))
		var/datum/plant_gene/trait/T = new each
		genes += T
	research_identifier = rand(0, 9999999)
