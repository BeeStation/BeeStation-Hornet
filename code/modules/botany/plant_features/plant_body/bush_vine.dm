/*
	Tomato Bush-Vine
*/
/datum/plant_feature/body/bush_vine
	species_name = "arbor parva"
	name = "bush"
	icon_state = "bush_vine"
	overlay_positions = list(list(17, 21), list(14, 18), list(20, 19), list(13, 15), list(22, 16), list(13, 11), list(21, 10))
	yields = PLANT_BODY_YIELD_MEDIUM
	yield_cooldown_time = PLANT_BODY_YIELD_TIME_FAST
	max_harvest = PLANT_BODY_HARVEST_MEDIUM
	upper_fruit_size = PLANT_FRUIT_SIZE_SMALL
	seeds = 2

/datum/plant_feature/body/bush_vine/chili
	name = "chili bush"
	icon_state = "bush_vine_2"

/datum/plant_feature/body/bush_vine/coffee
	name = "coffee bush"
	icon_state = "bush_vine_2"

/datum/plant_feature/body/bush_vine/eggplant
	name = "eggplant vine"

/datum/plant_feature/body/bush_vine/soybean
	name = "soybean stalk"

/datum/plant_feature/body/bush_vine/tomato
	name = "tomato vine"

/*
	Berry Bush
*/
/datum/plant_feature/body/bush_vine/berry
	species_name = "parvum parva fructum"
	name = "berry bush"
	icon_state = "bush_berry"
	overlay_positions = list(list(17, 15), list(14, 17), list(21, 16), list(12, 10), list(17, 9), list(22, 9), list(15, 11), list(19, 19), list(12, 17))
	random_plant = TRUE

/*
	Flower Bush
*/
/datum/plant_feature/body/bush_vine/flower
	species_name = "flosculus arboris"
	name = "flower bush"
	icon_state = "bush_flower"
	draw_below_water = FALSE
	random_plant = TRUE
	overlay_positions = list(list(10, 6), list(13, 7), list(17, 9), list(21, 8), list(24, 6), list(13, 5), list(21, 4))

/datum/plant_feature/body/bush_vine/flower/cotton
	name = "cotton bush"

/*
	Grape Vine
*/
/datum/plant_feature/body/bush_vine/grape
	species_name = "uva arbor"
	name = "grape vine"
	icon_state = "grape_vine_2"
	overlay_positions = list(list(10, 15), list(10, 21), list(11, 18), list(14, 20), list(13, 17), list(15, 15), list(13, 12), list(17, 16), list(25, 18), list(29, 14), list(25, 15), list(20, 10))

/*
	Ambrosia bush
*/
/datum/plant_feature/body/bush_vine/ambrosia
	species_name = "folium rubi"
	name = "ambrosia bush"
	icon_state = "sprouting_bush"
	draw_below_water = FALSE
	overlay_positions = list(list(16, 10), list(18, 11))
	whitelist_features = list(/datum/plant_feature/fruit/ambrosia, /datum/plant_feature/roots)
	random_plant = TRUE

/*
	Nettle bush
*/
/datum/plant_feature/body/bush_vine/nettle
	species_name = "aculeatum rubi"
	name = "nettle bush"
	icon_state = "missing"
	draw_below_water = FALSE
	overlay_positions = list(list(24, 6))
	plant_traits = list(/datum/plant_trait/body/thorns/thrower)

/datum/plant_feature/body/bush_vine/nettle/thistle
	name = "thistle bush"

/datum/plant_feature/body/bush_vine/nettle/kudzu
	name = "kudzu vine"

/*
	Cannabis bush
*/
/datum/plant_feature/body/bush_vine/cannabis
	species_name = "ridiculam rubi"
	name = "cannabis bush"
	icon_state = "bush_spiky_2"
	overlay_positions = list(list(17, 16), list(17, 10), list(13, 14), list(21, 14), list(19, 21))
	seeds = 5

/datum/plant_feature/body/bush_vine/cannabis/tobacco
	name = "tobacco bush"

/*
	Tea bush
*/
/datum/plant_feature/body/bush_vine/tea
	species_name = "asperae rubi"
	name = "tea bush"
	icon_state = "missing"
	draw_below_water = FALSE
	overlay_positions = list(list(24, 6))
