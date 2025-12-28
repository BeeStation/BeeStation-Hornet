/*
	Ambrosia Vulgaris
*/
/datum/plant_feature/fruit/ambrosia
	species_name = "folium viride"
	name = "ambrosia vulgaris"
	icon_state = "ambrosia"
	fruit_product = /obj/item/food/grown/ambrosia
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin, /datum/plant_trait/nectar)
	fast_reagents = list(/datum/reagent/medicine/bicaridine = PLANT_REAGENT_SMALL, /datum/reagent/medicine/kelotane = PLANT_REAGENT_SMALL, /datum/reagent/drug/space_drugs = PLANT_REAGENT_SMALL, /datum/reagent/toxin = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	mutations = list(/datum/plant_feature/fruit/ambrosia/deus)
	whitelist_features = list(/datum/plant_feature/body/bush_vine/ambrosia, /datum/plant_feature/roots)

/*
	Ambrosia Deus
*/
/datum/plant_feature/fruit/ambrosia/deus
	species_name = "folium caeruleum"
	name = "ambrosia deus"
	icon_state = "ambrosia_2"
	colour_override = "#075f6b"
	fruit_product = /obj/item/food/grown/ambrosia/deus
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)
	fast_reagents = list(/datum/reagent/medicine/synaptizine = PLANT_REAGENT_SMALL, /datum/reagent/medicine/omnizine = PLANT_REAGENT_SMALL, /datum/reagent/drug/space_drugs = PLANT_REAGENT_SMALL)
	mutations = list(/datum/plant_feature/fruit/ambrosia/gaia = 10)

/*
	Ambrosia Vulgaris
*/
/datum/plant_feature/fruit/ambrosia/gaia
	species_name = "folium aurum"
	name = "ambrosia gaia"
	icon_state = "ambrosia_2"
	fruit_product = /obj/item/food/grown/ambrosia/gaia
	genetic_budget = 3
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)
	fast_reagents = list(/datum/reagent/medicine/earthsblood = PLANT_REAGENT_SMALL)
	mutations = list(/datum/plant_feature/fruit/ambrosia)

/datum/plant_feature/fruit/ambrosia/gaia/setup_fruit(datum/source, harvest_amount, list/_visual_fruits, skip_growth)
	. = ..()
	for(var/timer as anything in growth_timers)
		var/obj/effect/fruit_effect = visual_fruits[timer]
		animate(fruit_effect, color = "#ff0000", time = 1 SECONDS, loop = -1)
		animate(color = "#15ff00", time = 1 SECONDS)
		animate(color = "#00a2ff", time = 1 SECONDS)
