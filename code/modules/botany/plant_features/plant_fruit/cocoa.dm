/*
	Cocoa
*/
/datum/plant_feature/fruit/cocoa
	species_name = "cocos delectamentum"
	name = "cocoa"
	icon_state = "pod"
	colour_override = "#d0703d"
	fruit_product = /obj/item/food/grown/cocoapod
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/consumable/cocoa = PLANT_REAGENT_MEDIUM)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	mutations = list(/datum/plant_feature/fruit/cocoa)

/*
	Vanilla
*/
/datum/plant_feature/fruit/cocoa/vanilla
	species_name = "cocos alius"
	name = "vanilla"
	icon_state = "pod"
	colour_override = "#362218"
	fruit_product = /obj/item/food/grown/vanillapod
	fast_reagents = list(/datum/reagent/consumable/vanilla = PLANT_REAGENT_MEDIUM)
	mutations = list(/datum/plant_feature/fruit/cocoa/bungo = 5)

/*
	Bungo = Lungo
*/
/datum/plant_feature/fruit/cocoa/bungo
	species_name = "cocos mortem"
	name = "bungo"
	icon_state = "pod"
	colour_override = "#e4cf15"
	fruit_product = /obj/item/food/grown/bungofruit
	fast_reagents = list(/datum/reagent/toxin/bungotoxin = PLANT_REAGENT_SMALL)
	mutations = list(/datum/plant_feature/fruit/cocoa)
