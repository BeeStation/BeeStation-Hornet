/*
	Tower-cap
*/
//TODO: - Sprites
/datum/plant_feature/fruit/mushroom/tower
	species_name = "turrim fungus"
	name = "tower-cap"
	icon_state = "tower"
	colour_overlay = "tower_colour"
	colour_override = "#57a02c"
	fruit_product = /obj/item/grown/log
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM
	fast_reagents = list(/datum/reagent/carbon = PLANT_REAGENT_LARGE)
	mutations = list(/datum/plant_feature/fruit/mushroom/tower/steel)
	var/stem_colour = "#ff7c01"

/datum/plant_feature/fruit/mushroom/tower/New(datum/component/plant/_parent)
	. = ..()
	//Remove overlays and paint our stem
	feature_appearance.cut_overlays()
	feature_appearance.color = stem_colour
	//Re-add overlays
	if(colour_overlay)
		var/mutable_appearance/coloured_parts = mutable_appearance(icon, colour_overlay, color = islist(colour_override) ? "#fff" : colour_override)
		coloured_parts.appearance_flags = RESET_COLOR
		feature_appearance.add_overlay(coloured_parts)
	else
		feature_appearance.color = islist(colour_override) ? "#fff" : colour_override

/*
	Steel-cap
*/
//TODO: - Sprites
/datum/plant_feature/fruit/mushroom/tower/steel
	species_name = "ferro fungus"
	name = "steel-cap"
	colour_override = "#ffee00"
	fruit_product = /obj/item/grown/log/steel
	fast_reagents = list(/datum/reagent/iron = PLANT_REAGENT_LARGE)
	mutations = list(/datum/plant_feature/fruit/mushroom/tower)
	stem_colour = "#befffa"
