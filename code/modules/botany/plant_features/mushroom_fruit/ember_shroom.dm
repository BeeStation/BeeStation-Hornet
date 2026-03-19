/*
	Embershroom
*/
/datum/plant_feature/fruit/mushroom/embershroom
	species_name = "calidum sporis"
	name = "embershroom"
	icon_state = "ball"
	colour_overlay = "ball_colour"
	colour_override = "#505050"
	seed_icon_state = "mycelium-ember"
	fruit_product = /obj/item/food/grown/ash_flora/mushroom_stem
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	total_volume = PLANT_FRUIT_VOLUME_MICRO
	growth_time = PLANT_FRUIT_GROWTH_FAST
	fast_reagents = list(/datum/reagent/consumable/tinlux = PLANT_REAGENT_SMALL, /datum/reagent/drug/space_drugs = PLANT_REAGENT_SMALL)
	mutations = list(/datum/plant_feature/fruit/mushroom/embershroom/inocybe)

/*
	Inocybe
*/
/datum/plant_feature/fruit/mushroom/embershroom/inocybe
	species_name = "inocybe sporis"
	name = "inocybe"
	icon_state = "button"
	colour_overlay = "button_colour"
	seed_icon_state = "mycelium-inocybe"
	fruit_product = /obj/item/food/grown/ash_flora/mushroom_cap
	fast_reagents = list(/datum/reagent/toxin/mindbreaker = 0.04, /datum/reagent/consumable/entpoly = 0.08, /datum/reagent/drug/mushroomhallucinogen = 0.04)
	mutations = list(/datum/plant_feature/fruit/mushroom/embershroom/porcini)

/*
	Porcini
*/
/datum/plant_feature/fruit/mushroom/embershroom/porcini
	species_name = "porcini sporis"
	name = "porcini"
	icon_state = "chanterelle"
	colour_overlay = "chanterelle_colour"
	seed_icon_state = "mycelium-porcini"
	fruit_product = /obj/item/food/grown/ash_flora/mushroom_leaf
	fast_reagents = list(/datum/reagent/consumable/nutriment = 0.06, /datum/reagent/consumable/vitfro = 0.04, /datum/reagent/drug/nicotine = 0.04)
	mutations = list(/datum/plant_feature/fruit/mushroom/embershroom/polypore)

/*
	Polypore
*/
/datum/plant_feature/fruit/mushroom/embershroom/polypore
	species_name = "polypore sporis"
	name = "polypore"
	icon_state = "fly"
	colour_overlay = "fly_colour"
	seed_icon_state = "mycelium-polypore"
	fruit_product = /obj/item/food/grown/ash_flora/shavings
	fast_reagents = list(/datum/reagent/consumable/sugar = 0.06, /datum/reagent/consumable/ethanol = 0.04, /datum/reagent/stabilizing_agent = 0.06, /datum/reagent/toxin/minttoxin = 0.02)
	mutations = list(/datum/plant_feature/fruit/mushroom/embershroom)
