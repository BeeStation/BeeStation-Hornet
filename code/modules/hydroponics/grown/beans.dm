// Soybeans
/obj/item/seeds/soya
	name = "pack of soybean seeds"
	desc = "These seeds grow into soybean plants."
	plantname = "Soybean Plants"
	species = "soybean"
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'
	icon_state = "seed-soybean"
	icon_grow = "soybean-grow"
	icon_dead = "soybean-dead"
	growthstages = 4
	product = /obj/item/reagent_containers/food/snacks/grown/soybeans

	potency = 15
	maturation = 4
	production = 4
	bitesize_mod = 2
	bite_type = PLANT_BITE_TYPE_CONSTANT

	mutatelist = list(/obj/item/seeds/soya/koi)
	genes = list(/datum/plant_gene/trait/perennial)
	reagents_set = list(
		/datum/reagent/consumable/nutriment = list(5, 10),
		/datum/reagent/consumable/nutriment/vitamin = list(4, 8))

/obj/item/reagent_containers/food/snacks/grown/soybeans
	seed = /obj/item/seeds/soya
	name = "soybeans"
	desc = "It's pretty bland, but oh the possibilities..."
	gender = PLURAL
	icon_state = "soybeans"
	filling_color = "#F0E68C"
	foodtype = VEGETABLES
	grind_results = list(/datum/reagent/consumable/soymilk = 0)
	tastes = list("soy" = 1)
	wine_power = 20

// Koibean
/obj/item/seeds/soya/koi
	name = "pack of koibean seeds"
	desc = "These seeds grow into koibean plants."
	icon_state = "seed-koibean"
	species = "koibean"
	plantname = "Koibean Plants"
	product = /obj/item/reagent_containers/food/snacks/grown/koibeans
	potency = 10
	mutatelist = list()
	reagents_set = list(
		/datum/reagent/consumable/nutriment = list(4, 15),
		/datum/reagent/consumable/nutriment/vitamin = list(4, 12),
		/datum/reagent/toxin/carpotoxin = list(10, 25))
	rarity = 20

/obj/item/reagent_containers/food/snacks/grown/koibeans
	seed = /obj/item/seeds/soya/koi
	name = "koibean"
	desc = "Something about these seems fishy."
	icon_state = "koibeans"
	filling_color = "#F0E68C"
	bitesize_mod = 2
	foodtype = VEGETABLES
	tastes = list("koi" = 1)
	wine_power = 40
	discovery_points = 300
