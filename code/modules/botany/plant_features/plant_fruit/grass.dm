/*
	Grass
	Generic fruit with no reagents that grows fast
*/
/datum/plant_feature/fruit/grass
	species_name = "gramen viridis"
	name = "grass"
	icon_state = "grass"
	seed_icon_state = "seed-grass"
	fruit_product = /obj/item/food/grown/grass
	total_volume = 0
	growth_time = PLANT_FRUIT_GROWTH_VERY_FAST
	skip_animation = TRUE
	mutations = list(/datum/plant_feature/fruit/grass/carpet)
	whitelist_features = list(/datum/plant_feature/body/tuber/grass, /datum/plant_feature/roots)

/*
	Carpet
*/
/datum/plant_feature/fruit/grass/carpet
	species_name = "gramen otium"
	name = "carpet"
	icon_state = "carpet"
	seed_icon_state = "seed-carpet"
	fruit_product = /obj/item/food/grown/grass/carpet
	mutations = list(/datum/plant_feature/fruit/grass/shamrock)

/*
	Clovers
*/
/datum/plant_feature/fruit/grass/shamrock
	species_name = "gramen trifolium"
	name = "shamrock"
	icon_state = "shamrock"
	seed_icon_state = "seed-shamrock"
	fruit_product = /obj/item/food/grown/grass/shamrock
	mutations = list(/datum/plant_feature/fruit/grass/fairy = 5)

/*
	Fairy Grass
*/
/datum/plant_feature/fruit/grass/fairy
	species_name = "gramen mediocris"
	name = "fairy grass"
	icon_state = "fairy_grass"
	seed_icon_state = "seed-fairygrass"
	plant_traits = list(/datum/plant_trait/fruit/biolight/pink)
	fruit_product = /obj/item/food/grown/grass/fairy
	mutations = list(/datum/plant_feature/fruit/grass)

/datum/plant_feature/fruit/grass/fairy/New(datum/component/plant/_parent)
	. = ..()
	var/mutable_appearance/emissive = emissive_appearance(icon, colour_overlay)
	emissive.color = colour_override
	feature_appearance.add_overlay(emissive)

/datum/plant_feature/fruit/grass/fairy/setup_fruit(datum/source, harvest_amount, list/_visual_fruits, skip_growth)
	. = ..()
	//Inherit the colour of any bio light we have
	var/datum/plant_trait/fruit/biolight/light = locate(/datum/plant_trait/fruit/biolight) in plant_traits
	if(!light)
		return
	for(var/fruit_index as anything in visual_fruits)
		var/obj/effect/fruit_effect = visual_fruits[fruit_index]
		fruit_effect.color = light.glow_color
