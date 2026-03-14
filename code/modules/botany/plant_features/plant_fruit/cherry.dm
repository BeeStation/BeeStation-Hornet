/*
	Cherry
	Micro fruit type that grows very fast
*/
/datum/plant_feature/fruit/cherry
	species_name = "cerasus parvum"
	name = "cherry"
	icon_state = "cherry"
	colour_override = "#ff0048"
	fruit_product = /obj/item/food/grown/cherries
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/consumable/sugar = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_MICRO
	growth_time = PLANT_FRUIT_GROWTH_VERY_FAST
	mutations = list(/datum/plant_feature/fruit/cherry/blue)

/*
	Blue Cherry
*/
/datum/plant_feature/fruit/cherry/blue
	species_name = "cerasus caeruleum"
	name = "blue cherry"
	icon_state = "cherry"
	colour_override = "#6200ff"
	fruit_product = /obj/item/food/grown/bluecherries
	mutations = list(/datum/plant_feature/fruit/cherry/bulb)

/*
	Bulb Cherry
*/
/datum/plant_feature/fruit/cherry/bulb
	species_name = "cerasus bulbus"
	name = "bulb cherry"
	icon_state = "cherry"
	colour_override = "#ff5e00"
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/fruit/biolight/orange)
	fruit_product = /obj/item/food/grown/cherrybulbs
	mutations = list(/datum/plant_feature/fruit/cherry/bomb = 20)

/*
	Cherry Bomb
	The problem child
*/
/datum/plant_feature/fruit/cherry/bomb
	species_name = "cerasus crepitus"
	name = "cherry bomb"
	icon_state = "cherry"
	colour_override = "#412c20"
	fruit_product = /obj/item/food/grown/cherry_bomb
	plant_traits = list(/datum/plant_trait/fruit/temperature, /datum/plant_trait/fruit/liquid_contents/sensitive)
	fast_reagents = list(/datum/reagent/blackpowder = PLANT_REAGENT_MEDIUM)
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM
	mutations = list(/datum/plant_feature/fruit/cherry)
