/*
	Tomato Bush-Vine
*/
/datum/plant_feature/body/bush_vine
	species_name = "arbor parva"
	name = "bush"
	icon_state = "bush_vine"
	growth_prefix = "bush"
	growth_stages = 3
	overlay_positions = list(list(17, 21), list(14, 18), list(20, 19), list(13, 15), list(22, 16), list(13, 11), list(21, 10))
	yields = PLANT_BODY_YIELD_MEDIUM
	yield_cooldown_time = PLANT_BODY_YIELD_TIME_FAST
	max_harvest = PLANT_BODY_HARVEST_MEDIUM
	upper_fruit_size = PLANT_FRUIT_SIZE_SMALL
	growth_time = PLANT_BODY_GROWTH_FAST
	seeds = 2

/datum/plant_feature/body/bush_vine/growth_step(step)
	. = ..()
	playsound(parent.plant_item, 'sound/effects/rustle.ogg', 30, TRUE)
	parent.plant_item.add_emitter(/obj/emitter/confetti/leaves, "leaves", 10, lifespan = 20)
	parent.plant_item.add_emitter(/obj/emitter/plant_dust, "dust", 10, lifespan = 20)

/datum/plant_feature/body/bush_vine/chili
	name = "chili bush"
	icon_state = "bush_vine_2"

/datum/plant_feature/body/bush_vine/coffee
	name = "coffee bush"
	icon_state = "bush_vine_2"

/datum/plant_feature/body/bush_vine/eggplant
	name = "eggplant vine"

/datum/plant_feature/body/bush_vine/soybean
	name = "soybean stalk"

/datum/plant_feature/body/bush_vine/tomato
	name = "tomato vine"

/*
	Berry Bush
*/
/datum/plant_feature/body/bush_vine/berry
	species_name = "parvum parva fructum"
	name = "berry bush"
	icon_state = "bush_berry"
	overlay_positions = list(list(17, 15), list(14, 17), list(21, 16), list(12, 10), list(17, 9), list(22, 9), list(15, 11), list(19, 19), list(12, 17))

/*
	Flower Bush
*/
/datum/plant_feature/body/bush_vine/flower
	species_name = "flosculus arboris"
	name = "flower bush"
	icon_state = "bush_flower"
	draw_below_water = FALSE
	overlay_positions = list(list(10, 6), list(13, 7), list(17, 9), list(21, 8), list(24, 6), list(13, 5), list(21, 4))
	slot_size = PLANT_BODY_SLOT_SIZE_MICRO
	whitelist_features = list(/datum/plant_feature/fruit/flower, /datum/plant_feature/roots)

/datum/plant_feature/body/bush_vine/flower/cotton
	name = "cotton bush"
	slot_size = PLANT_BODY_SLOT_SIZE_LARGE
	whitelist_features = list()

/*
	Grape Vine
*/
/datum/plant_feature/body/bush_vine/grape
	species_name = "uva arbor"
	name = "grape vine"
	icon_state = "grape_vine_2"
	growth_stages = 4
	growth_prefix = "tree"
	overlay_positions = list(list(10, 15), list(10, 21), list(11, 18), list(14, 20), list(13, 17), list(15, 15), list(13, 12), list(17, 16), list(25, 18), list(29, 14), list(25, 15), list(20, 10))
	mutations = list(/datum/plant_feature/body/bush_vine/grape/cousin)

/datum/plant_feature/body/bush_vine/grape/cousin
	icon_state = "grape_vine"
	name = "grape vine sp."
	species_name = "uva arbor sp."

/*
	Ambrosia bush
*/
/datum/plant_feature/body/bush_vine/ambrosia
	species_name = "folium rubi"
	name = "ambrosia bush"
	icon_state = "sprouting_bush"
	draw_below_water = FALSE
	overlay_positions = list(list(15, 10), list(17, 11))
	whitelist_features = list(/datum/plant_feature/fruit/ambrosia, /datum/plant_feature/roots)
	///Used to keep track of how we're effecting fruit mirrors
	var/fruit_mirror = 0

/datum/plant_feature/body/bush_vine/ambrosia/setup_fruit(skip_growth)
	. = ..()
	fruit_mirror = 0

/datum/plant_feature/body/bush_vine/ambrosia/apply_fruit_overlay(obj/effect/fruit_effect, offset_x, offset_y)
	. = ..()
	fruit_effect.pixel_x = offset_x-16
	fruit_effect.pixel_y = offset_y-16
	//Reset the fruits mirror status so we can exclusively mirror every second fruit, looks better on this plant
	fruit_effect.transform = matrix()
	if((fruit_mirror % 2) && fruit_mirror < 2)
		fruit_effect.transform = fruit_effect.transform.Scale(-1, 1)
		fruit_effect.pixel_x += 1
	fruit_mirror++

/*
	Nettle bush
*/
/datum/plant_feature/body/bush_vine/nettle
	species_name = "aculeatum rubi"
	name = "nettle bush"
	icon_state = "big_fingers"
	growth_prefix = "fern"
	growth_stages = 3
	draw_below_water = FALSE
	overlay_positions = list(list(11, 15), list(20, 14), list(15, 9), list(9, 8))
	mutations = list(/datum/plant_feature/body/bush_vine/nettle/death)
	layer_offset = 0
	slot_size = PLANT_BODY_SLOT_SIZE_MEDIUM

/datum/plant_feature/body/bush_vine/nettle/death //This is just a legacy thing dont bother with unique stats
	name = "nettle bush sp."
	species_name = "aculeatum rubi sp."
	icon_state = "big_fingers_3"
	mutations = list(/datum/plant_feature/body/bush_vine/nettle)

/datum/plant_feature/body/bush_vine/nettle/thistle
	name = "thistle bush"
	species_name = "aculeatum rubi sp."
	icon_state = "big_fingers_2"
	mutations = list()

/*
	Ivy
*/
/datum/plant_feature/body/bush_vine/kudzu
	species_name = "aculeatum hedera"
	name = "kudzu vine"
	icon_state = "kudzu"
	growth_prefix = "fern"
	growth_stages = 3
	draw_below_water = FALSE
	overlay_positions = list(list(12, 15), list(20, 14), list(16, 8), list(25, 7))
	layer_offset = 0
	slot_size = PLANT_BODY_SLOT_SIZE_SMALL

/*
	Cannabis bush
*/
/datum/plant_feature/body/bush_vine/cannabis
	species_name = "ridiculam rubi"
	name = "cannabis bush"
	icon_state = "bush_spiky_2"
	overlay_positions = list(list(17, 16), list(17, 10), list(13, 14), list(21, 14), list(19, 21))
	seeds = 5

/datum/plant_feature/body/bush_vine/cannabis/tobacco
	name = "tobacco bush"

/*
	Tea bush
*/
/datum/plant_feature/body/bush_vine/tea
	species_name = "asperae rubi"
	name = "tea bush"
	icon_state = "bush_2"
	draw_below_water = FALSE
	overlay_positions = list(list(17, 23), list(11, 20), list(23, 15), list(11, 13))
