/*
	Glowshroom
*/
/datum/plant_feature/fruit/mushroom/glowshroom
	species_name = "meridiem fungus"
	name = "glowshroom"
	icon_state = "button"
	colour_overlay = "glow_colour"
	colour_override = "#a6ff00"
	seed_icon_state = "mycelium-glowshroom"
	fruit_product = /obj/item/food/grown/mushroom/glowshroom
	total_volume = PLANT_FRUIT_VOLUME_MICRO
	growth_time = PLANT_FRUIT_GROWTH_FAST
	plant_traits = list(/datum/plant_trait/fruit/biolight/green)
	fast_reagents = list(/datum/reagent/uranium/radium = PLANT_REAGENT_SMALL, /datum/reagent/phosphorus = PLANT_REAGENT_SMALL)
	mutations = list(/datum/plant_feature/fruit/mushroom/glowshroom/glowcap)
	genetic_budget = 3

/datum/plant_feature/fruit/mushroom/glowshroom/New(datum/component/plant/_parent)
	. = ..()
	var/mutable_appearance/emissive = emissive_appearance(icon, colour_overlay)
	emissive.color = colour_override
	feature_appearance.add_overlay(emissive)

/*
	Glowcap
*/
/datum/plant_feature/fruit/mushroom/glowshroom/glowcap
	species_name = "fulgur fungus"
	name = "glowcap"
	colour_override = "#f00"
	seed_icon_state = "mycelium-glowcap"
	fruit_product = /obj/item/food/grown/mushroom/glowshroom/glowcap
	plant_traits = list(/datum/plant_trait/fruit/biolight/red)
	fast_reagents = list(/datum/reagent/teslium = PLANT_REAGENT_SMALL)
	mutations = list(/datum/plant_feature/fruit/mushroom/glowshroom/shadow)

/*
	Glowcap
*/
/datum/plant_feature/fruit/mushroom/glowshroom/shadow
	species_name = "umbra fungus"
	name = "shadowshroom"
	colour_override = "#2f2636"
	seed_icon_state = "mycelium-shadowshroom"
	fruit_product = /obj/item/food/grown/mushroom/glowshroom/shadowshroom
	plant_traits = list(/datum/plant_trait/fruit/biolight/dark)
	fast_reagents = list(/datum/reagent/uranium/radium = PLANT_REAGENT_MEDIUM)
	mutations = list(/datum/plant_feature/fruit/mushroom/glowshroom)
