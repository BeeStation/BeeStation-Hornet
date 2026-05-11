/datum/plant_feature/fruit/mushroom/mess
	species_name = "revoltus sporis"
	name = "charr shroom"
	icon_state = "plump"
	colour_overlay = "plump_colour"
	colour_override = "#3b302a"
	seed_icon_state = "mycelium-polypore"
	fruit_product = /obj/item/food/badrecipe
	total_volume = PLANT_FRUIT_VOLUME_MICRO
	growth_time = PLANT_FRUIT_GROWTH_FAST
	fast_reagents = list(/datum/reagent/drug/space_drugs = PLANT_REAGENT_SMALL)
	mutations = list(/datum/plant_feature/fruit/mushroom/mess/meat)

/datum/plant_feature/fruit/mushroom/mess/meat
	species_name = "escam sporis"
	name = "meat shroom"
	icon_state = "plump"
	colour_override = "#c74444"
	seed_icon_state = "mycelium-glowcap"
	fruit_product = /obj/item/food/meat/slab/human/mutant/psyphoza
	fast_reagents = list()
	mutations = list(/datum/plant_feature/fruit/mushroom/mess)
