/*
	Nettle leaf
*/
/datum/plant_feature/fruit/nettle
	species_name = "folium aculeatum"
	name = "nettle"
	icon_state = "nettle"
	fruit_product = /obj/item/food/grown/nettle
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	plant_traits = list(/datum/plant_trait/fruit/prickles)
	fast_reagents = list(/datum/reagent/toxin/acid = PLANT_REAGENT_MEDIUM)

/*
	Death Nettle
*/
/datum/plant_feature/fruit/nettle/death
	species_name = "folium mortem"
	name = "death nettle"
	icon_state = "nettle_death"
	fruit_product = /obj/item/food/grown/nettle/death
	fast_reagents = list(/datum/reagent/toxin/acid/fluacid = PLANT_REAGENT_MEDIUM)
