/*
	Cotton
	Volumeless fruit type that grows fast
*/
/datum/plant_feature/fruit/cotton
	species_name = "bombacio mollis"
	name = "cotton"
	icon_state = "cotton"
	fruit_product = /obj/item/grown/cotton
	total_volume = 0
	growth_time = PLANT_FRUIT_GROWTH_FAST
	mutations = list(/datum/plant_feature/fruit/cotton/durathread = 20)

/*
	Durathread
*/
/datum/plant_feature/fruit/cotton/durathread
	species_name = "bombacio lenta"
	name = "durathread"
	icon_state = "cotton"
	colour_override = "#595976"
	fruit_product = /obj/item/grown/cotton/durathread
	mutations = list(/datum/plant_feature/fruit/cotton)
