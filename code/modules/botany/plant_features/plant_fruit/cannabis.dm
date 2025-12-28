/*
	Generic Weed
*/
/datum/plant_feature/fruit/cannabis
	species_name = "alta folium"
	name = "cannabis" //All cannabis leafs have the same name, only observant people will tell them apart
	icon_state = "cannabis"
	fruit_product = /obj/item/food/grown/cannabis
	fast_reagents = list(/datum/reagent/drug/space_drugs = PLANT_REAGENT_MEDIUM, /datum/reagent/toxin/lipolicide = PLANT_REAGENT_MEDIUM)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	mutations = list(/datum/plant_feature/fruit/cannabis/death = 5)

/*
	Death Weed
*/
/datum/plant_feature/fruit/cannabis/death
	species_name = "mors folium"
	icon_state = "cannabis-2"
	colour_override = "#918181"
	fruit_product = /obj/item/food/grown/cannabis/death
	fast_reagents = list(/datum/reagent/drug/space_drugs = PLANT_REAGENT_MEDIUM, /datum/reagent/toxin/lipolicide = PLANT_REAGENT_MEDIUM, /datum/reagent/toxin/cyanide = PLANT_REAGENT_MEDIUM)
	mutations = list(/datum/plant_feature/fruit/cannabis/life = 10)

/*
	Life Weed
*/
/datum/plant_feature/fruit/cannabis/life
	species_name = "vita folium"
	icon_state = "cannabis-2"
	colour_override = "#deecd3"
	fruit_product = /obj/item/food/grown/cannabis/white
	fast_reagents = list(/datum/reagent/drug/space_drugs = PLANT_REAGENT_MEDIUM, /datum/reagent/toxin/lipolicide = PLANT_REAGENT_MEDIUM, /datum/reagent/medicine/omnizine = PLANT_REAGENT_MEDIUM)
	mutations = list(/datum/plant_feature/fruit/cannabis/rainbow = 15)

/*
	Rainbow Weed
*/
/datum/plant_feature/fruit/cannabis/rainbow
	species_name = "iris folium"
	icon_state = "cannabis-2"
	colour_override = "#ff0000"
	fruit_product = /obj/item/food/grown/cannabis/rainbow
	fast_reagents = list(/datum/reagent/toxin/mindbreaker = PLANT_REAGENT_MEDIUM, /datum/reagent/toxin/lipolicide = PLANT_REAGENT_MEDIUM)
	mutations = list(/datum/plant_feature/fruit/cannabis/omega = 20)

/datum/plant_feature/fruit/cannabis/rainbow/setup_fruit(datum/source, harvest_amount, list/_visual_fruits, skip_growth)
	. = ..()
	for(var/timer as anything in growth_timers)
		var/obj/effect/fruit_effect = visual_fruits[timer]
		animate(fruit_effect, color = "#ff0000", time = 1 SECONDS, loop = -1)
		animate(color = "#15ff00", time = 1 SECONDS)
		animate(color = "#00a2ff", time = 1 SECONDS)

/*
	Omega Weed
*/
/datum/plant_feature/fruit/cannabis/omega
	species_name = "omega folium"
	icon_state = "cannabis-2"
	colour_override = "#15ff00"
	genetic_budget = 4
	fruit_product = /obj/item/food/grown/cannabis/ultimate
	fast_reagents = list(/datum/reagent/drug/space_drugs = PLANT_REAGENT_MICRO, /datum/reagent/toxin/mindbreaker = PLANT_REAGENT_MICRO, /datum/reagent/toxin/lipolicide = PLANT_REAGENT_MICRO, /datum/reagent/mercury = PLANT_REAGENT_MICRO,
	/datum/reagent/lithium = PLANT_REAGENT_MICRO, /datum/reagent/medicine/atropine = PLANT_REAGENT_MICRO, /datum/reagent/medicine/haloperidol = PLANT_REAGENT_MICRO, /datum/reagent/drug/methamphetamine = PLANT_REAGENT_MICRO,
	/datum/reagent/consumable/capsaicin = PLANT_REAGENT_MICRO, /datum/reagent/barbers_aid = PLANT_REAGENT_MICRO, /datum/reagent/drug/bath_salts = PLANT_REAGENT_MICRO, /datum/reagent/toxin/itching_powder = PLANT_REAGENT_MICRO,
	/datum/reagent/drug/crank = PLANT_REAGENT_MICRO, /datum/reagent/drug/krokodil = PLANT_REAGENT_MICRO, /datum/reagent/toxin/histamine = PLANT_REAGENT_MICRO)
	total_volume = PLANT_FRUIT_VOLUME_VERY_LARGE
	growth_time = PLANT_FRUIT_GROWTH_SLOW
	mutations = list(/datum/plant_feature/fruit/cannabis)

/datum/plant_feature/fruit/cannabis/omega/setup_fruit(datum/source, harvest_amount, list/_visual_fruits, skip_growth)
	. = ..()
	for(var/timer as anything in growth_timers)
		var/obj/effect/fruit_effect = visual_fruits[timer]
		animate(fruit_effect, color = "#ffffff", time = 1 SECONDS, loop = -1, flags = ANIMATION_PARALLEL)
		animate(color = "#15ff00", time = 1 SECONDS)
