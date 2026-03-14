/*
	Banana
*/
/datum/plant_feature/fruit/banana
	species_name = "lycopersicum solanum"
	name = "banana"
	icon_state = "banana"
	bunch_icon = "banana_bunch"
	fruit_product = /obj/item/food/grown/banana
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin/large,
	/datum/plant_trait/fruit/slippery)
	fast_reagents = list(/datum/reagent/consumable/banana = PLANT_REAGENT_MEDIUM, /datum/reagent/potassium = PLANT_REAGENT_MEDIUM)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	mutations = list(/datum/plant_feature/fruit/banana/mime)

/*
	Mimana
*/
/datum/plant_feature/fruit/banana/mime
	species_name = "lycopersicum mimum"
	name = "mimana"
	icon_state = "mimana"
	bunch_icon = "mimana_bunch"
	fruit_product = /obj/item/food/grown/banana/mime
	fast_reagents = list(/datum/reagent/consumable/nothing = PLANT_REAGENT_MEDIUM, /datum/reagent/toxin/mutetoxin = PLANT_REAGENT_MEDIUM)
	mutations = list(/datum/plant_feature/fruit/banana/bluespace = 15)

/*
	Bluespace Banana
*/
/datum/plant_feature/fruit/banana/bluespace
	species_name = "lycopersicum fatum"
	name = "bluespace banana"
	icon_state = "mimana"
	bunch_icon = "mimana_bunch"
	colour_override = "#4abaff"
	fruit_product = /obj/item/food/grown/banana/bluespace
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin/large,
	/datum/plant_trait/fruit/slippery, /datum/plant_trait/fruit/bluespace)
	fast_reagents = list(/datum/reagent/bluespace = PLANT_REAGENT_SMALL)
	mutations = list(/datum/plant_feature/fruit/banana)

/*
	Bombnana
*/
/datum/plant_feature/fruit/banana/bomb
	name = "bombnana"
	fruit_product = /obj/item/food/grown/banana/bombanana
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin/large,
	/datum/plant_trait/fruit/slippery)
	mutations = list()
