/datum/plant_feature/fruit/mushroom
	icon = 'icons/obj/hydroponics/features/mushroom.dmi'
	icon_state = "destroying_angel"
	genetic_budget = 1
	//Mushrooms have no needs
	plant_needs = list()
	//We can fit on only mushroom bodies, but any kind of roots
	whitelist_features = list(/datum/plant_feature/body/mushroom, /datum/plant_feature/roots)
	feature_catagories = PLANT_FEATURE_FRUIT
	growth_time = PLANT_FRUIT_GROWTH_VERY_FAST
