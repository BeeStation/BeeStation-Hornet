// Soybeans
/obj/item/food/grown/soybeans
	seed = /obj/item/plant_seeds/preset/soybean
	name = "soybeans"
	desc = "It's pretty bland, but oh the possibilities..."
	gender = PLURAL
	icon_state = "soybeans"
	foodtypes = VEGETABLES
	grind_results = list(/datum/reagent/consumable/soymilk = 0)
	tastes = list("soy" = 1)
	wine_power = 20

// Koibean
/obj/item/food/grown/koibeans
	name = "koibean"
	desc = "Something about these seems fishy."
	icon_state = "koibeans"
	foodtypes = VEGETABLES
	tastes = list("koi" = 1)
	wine_power = 40
	discovery_points = 300
