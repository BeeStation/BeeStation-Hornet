/*
	Destroying Angel
*/
/datum/plant_feature/fruit/mushroom/destroying_angel
	species_name = "album mortis"
	name = "destroying angel"
	icon_state = "destroying_angel"
	seed_icon_state = "mycelium-angel"
	fruit_product = /obj/item/food/grown/mushroom/angel
	total_volume = PLANT_FRUIT_VOLUME_MICRO
	growth_time = PLANT_FRUIT_GROWTH_FAST
	fast_reagents = list(/datum/reagent/toxin/amatoxin = PLANT_REAGENT_SMALL, /datum/reagent/drug/mushroomhallucinogen = PLANT_REAGENT_SMALL, /datum/reagent/toxin/amanitin = PLANT_REAGENT_MEDIUM)
	mutations = list(/datum/plant_feature/fruit/mushroom/fly)

/*
	Fly Amanita
*/
/datum/plant_feature/fruit/mushroom/fly
	species_name = "rufus alba"
	name = "fly amanita"
	icon_state = "fly"
	colour_overlay = "fly_colour"
	colour_override = "#c45d5d"
	seed_icon_state = "mycelium-amanita"
	fruit_product = /obj/item/food/grown/mushroom/amanita
	total_volume = PLANT_FRUIT_VOLUME_MICRO
	growth_time = PLANT_FRUIT_GROWTH_FAST
	fast_reagents = list(/datum/reagent/toxin/amatoxin = PLANT_REAGENT_MEDIUM, /datum/reagent/drug/mushroomhallucinogen = PLANT_REAGENT_SMALL, /datum/reagent/growthserum = PLANT_REAGENT_SMALL)
	mutations = list(/datum/plant_feature/fruit/mushroom/destroying_angel)
