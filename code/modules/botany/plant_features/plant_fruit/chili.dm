/*
	Chili
*/
/datum/plant_feature/fruit/chili
	species_name = "purus calidum"
	name = "chili"
	icon_state = "chili"
	icon_uneven = TRUE
	colour_override = "#f00"
	seed_icon_state = "seed-chili"
	fruit_product = /obj/item/food/grown/chili
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)
	fast_reagents = list(/datum/reagent/consumable/capsaicin = PLANT_REAGENT_MEDIUM)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	mutations = list(/datum/plant_feature/fruit/chili/ghost = 8)

/*
	Ghost Chili
*/
/datum/plant_feature/fruit/chili/ghost
	species_name = "purus exspiravit"
	name = "ghost chili"
	icon_state = "chili"
	colour_override = "#e9cdcf"
	seed_icon_state = "seed-chilighost"
	fruit_product = /obj/item/food/grown/ghost_chili
	fast_reagents = list(/datum/reagent/consumable/capsaicin = PLANT_REAGENT_MEDIUM, /datum/reagent/consumable/condensedcapsaicin = PLANT_REAGENT_MEDIUM)
	mutations = list(/datum/plant_feature/fruit/chili/blue = 3)

/*
	Blue Chili
*/
/datum/plant_feature/fruit/chili/blue
	species_name = "purus frigus"
	name = "ice pepper"
	icon_state = "chili"
	colour_override = "#4c00ff"
	seed_icon_state = "seed-icepepper"
	fruit_product = /obj/item/food/grown/icepepper
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin,
	/datum/plant_trait/fruit/temperature/cold, /datum/plant_trait/fruit/liquid_contents/sensitive)
	fast_reagents = list(/datum/reagent/consumable/frostoil = PLANT_REAGENT_MEDIUM)
	mutations = list(/datum/plant_feature/fruit/chili)
