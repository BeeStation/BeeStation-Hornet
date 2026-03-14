/*
	lemon
*/
/datum/plant_feature/fruit/lemon
	species_name = "citrus uvam"
	name = "lemon"
	icon_state = "citrus"
	colour_override = "#ffe600"
	fruit_product = /obj/item/food/grown/citrus/lemon
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	mutations = list(/datum/plant_feature/fruit/lemon/lime)

/*
	Lime
*/
/datum/plant_feature/fruit/lemon/lime
	species_name = "citrus viridis"
	name = "lime"
	icon_state = "citrus"
	colour_override = "#2bff00"
	fruit_product = /obj/item/food/grown/citrus
	mutations = list(/datum/plant_feature/fruit/lemon/combustible = 20)

/*
	Combustible Lemon
*/
/datum/plant_feature/fruit/lemon/combustible
	species_name = "citrus crepitus"
	name = "combustible lemon"
	icon_state = "citrus"
	colour_override = "#ff3c00"
	fruit_product = /obj/item/food/grown/firelemon
	plant_traits = list(/datum/plant_trait/fruit/temperature, /datum/plant_trait/fruit/liquid_contents/sensitive)
	fast_reagents = list(/datum/reagent/sulfur = PLANT_REAGENT_SMALL, /datum/reagent/medicine/charcoal = PLANT_REAGENT_MEDIUM,
	/datum/reagent/saltpetre = PLANT_REAGENT_SMALL, /datum/reagent/blackpowder = PLANT_REAGENT_MEDIUM)
	mutations = list(/datum/plant_feature/fruit/lemon)
