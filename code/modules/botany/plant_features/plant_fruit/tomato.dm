/*
	Tomato
*/
/datum/plant_feature/fruit/tomato
	species_name = "lycopersicum solanum"
	name = "tomato"
	icon_state = "tomato"
	icon_uneven = TRUE
	seed_icon_state = "seed-tomato"
	fruit_product = /obj/item/food/grown/tomato
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin,
	/datum/plant_trait/fruit/liquid_contents)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	mutations = list(/datum/plant_feature/fruit/tomato/blood, /datum/plant_feature/fruit/tomato/blue)

/*
	Blue Tomato
*/
/datum/plant_feature/fruit/tomato/blue
	species_name = "lycopersicum caeruleum"
	name = "blue tomato"
	icon_state = "tomato-2"
	colour_override = "#00a2ff"
	seed_icon_state = "seed-bluetomato"
	fruit_product = /obj/item/food/grown/tomato/blue
	fast_reagents = list(/datum/reagent/lube = PLANT_REAGENT_MEDIUM)
	mutations = list(/datum/plant_feature/fruit/tomato/bluespace = 20)

/*
	BlueSpace Tomato
*/
/datum/plant_feature/fruit/tomato/bluespace
	species_name = "lycopersicum caeruleum cerritulus"
	name = "bluespace tomato"
	icon_state = "tomato-2"
	colour_override = "#03dfe6"
	seed_icon_state = "seed-bluespacetomato"
	fruit_product = /obj/item/food/grown/tomato/blue/bluespace
	genetic_budget = 4
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin,
	/datum/plant_trait/fruit/liquid_contents, /datum/plant_trait/fruit/bluespace)
	fast_reagents = list(/datum/reagent/bluespace = PLANT_REAGENT_SMALL)
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM
	mutations = list(/datum/plant_feature/fruit/tomato)

/datum/plant_feature/fruit/tomato/bluespace/setup_fruit(datum/source, harvest_amount, list/_visual_fruits, skip_growth)
	. = ..()
	for(var/timer as anything in growth_timers)
		var/obj/effect/fruit_effect = visual_fruits[timer]
		animate(fruit_effect, color = "#24618a", time = 0.3 SECONDS, loop = -1, flags = ANIMATION_PARALLEL)
		animate(color = "#03dfe6", time = 1 SECONDS)

/*
	Blood Tomato
*/
/datum/plant_feature/fruit/tomato/blood
	species_name = "lycopersicum sanguis"
	name = "blood tomato"
	icon_state = "tomato-2"
	colour_override = "#8d1111"
	seed_icon_state = "seed-bloodtomato"
	fruit_product = /obj/item/food/grown/tomato/blood
	fast_reagents = list(/datum/reagent/blood = PLANT_REAGENT_MEDIUM)
	mutations = list(/datum/plant_feature/fruit/tomato/killer = 10)

/*
	Killer Tomato
*/
/datum/plant_feature/fruit/tomato/killer
	species_name = "lycopersicum rabidus"
	name = "killer tomato"
	icon_state = "killer_tomato"
	seed_icon_state = "seed-killertomato"
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin,
	/datum/plant_trait/fruit/liquid_contents, /datum/plant_trait/fruit/killer)
	fruit_product = /obj/item/food/grown/tomato/killer
	mutations = list(/datum/plant_feature/fruit/tomato/friendly = 5)

/*
	Friendly Tomato
*/
/datum/plant_feature/fruit/tomato/friendly
	species_name = "lycopersicum amica"
	name = "friendly tomato"
	icon_state = "friendly_tomato"
	seed_icon_state = "seed-friendlytomato"
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin,
	/datum/plant_trait/fruit/liquid_contents, /datum/plant_trait/fruit/killer/friendly)
	fruit_product = /obj/item/food/grown/tomato/friendly
	mutations = list(/datum/plant_feature/fruit/tomato)

/obj/item/food/grown/tomato/friendly
	name = "friendly tomato"
	desc = "The real treasure are the friends we made along the way!"
	icon_state = "friendly_tomato"
