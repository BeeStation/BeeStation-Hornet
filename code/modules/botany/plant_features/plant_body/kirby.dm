/*
	Kirby base
*/
/datum/plant_feature/body/kirby
	species_name = "genus plantae"
	icon = 'icons/obj/hydroponics/features/kirby_body.dmi'
	icon_state = "plant-01"
	overlay_positions = list()
	yields = PLANT_BODY_YIELD_SMALL
	yield_cooldown_time = PLANT_BODY_YIELD_TIME_MEDIUM
	max_harvest = PLANT_BODY_HARVEST_SMALL
	growth_time = PLANT_BODY_GROWTH_FAST

/datum/plant_feature/body/kirby/New(datum/component/plant/_parent)
	name = "[capitalize(pick(GLOB.adjectives))] [pick(GLOB.first_names)]"
	_parent?.plant_item?.name = name
	return ..()

/datum/plant_feature/body/kirbyd/growth_step(step)
	. = ..()
	parent.plant_item.add_emitter(/obj/emitter/plant_dust, "dust", 10, lifespan = 20)

//tall
/datum/plant_feature/body/kirby/tall
	icon_state = "plant-06-1"
	overlay_positions = list(list(16, 23), list(20, 21), list(14, 20), list(17, 17), list(21, 16), list(14, 14), list(15, 19), list(20, 10))

/datum/plant_feature/body/kirby/tall/cousin
	icon_state = "plant-06"

//bushy
/datum/plant_feature/body/kirby/bushy
	icon_state = "plant-08"
	overlay_positions = list(list(16, 20), list(21, 19), list(15, 16), list(23, 14), list(19, 12))

//birch
/datum/plant_feature/body/kirby/birch
	icon_state = "plant-26"
	overlay_positions = list(list(7, 24), list(15, 21), list(10, 16), list(20, 15), list(27, 17))
	mutations = list(/datum/plant_feature/body/tree/birch)

//tree
/datum/plant_feature/body/kirby/tree
	icon_state = "plant-21"
	overlay_positions = list(list(7, 24), list(15, 21), list(10, 16), list(20, 15), list(27, 17))

//tropic
/datum/plant_feature/body/kirby/tropic
	icon_state = "plant-33"
	overlay_positions = list(list(19, 24), list(10, 21), list(15, 17), list(11, 11), list(21, 12))

//cherry
/datum/plant_feature/body/kirby/cherry
	icon_state = "plant-10"
	overlay_positions = list(list(7, 24), list(15, 21), list(10, 16), list(20, 15), list(27, 17))
	mutations = list(/datum/plant_feature/body/tree/cherry)

//floor_foliage
/datum/plant_feature/body/kirby/floor_foliage
	icon_state = "plant-01"
	overlay_positions = list()

//pretender
/datum/plant_feature/body/kirby/pretender
	icon_state = "plant-31"
	overlay_positions = list(list(16, 19))

//shielded
/datum/plant_feature/body/kirby/shielded
	icon_state = "plant-32"
	overlay_positions = list()
	draw_below_water = FALSE

//pandora
/datum/plant_feature/body/kirby/pandora
	icon_state = "plant-09"
	overlay_positions = list()

//sticks
/datum/plant_feature/body/kirby/sticks
	icon_state = "plant-18"
	overlay_positions = list(list(12, 19), list(18, 25))
	draw_below_water = FALSE

/datum/plant_feature/body/kirby/sticks/cousin
	icon_state = "plant-18-1"

//not_tomato
/datum/plant_feature/body/kirby/not_tomato
	icon_state = "plant-30"
	overlay_positions = list(list(22, 14), list(11, 15), list(12, 7), list(20, 8))
	draw_below_water = FALSE

//not_tomato
/datum/plant_feature/body/kirby/hair
	icon_state = "plant-29"
	overlay_positions = list()
	draw_below_water = FALSE

//wood
/datum/plant_feature/body/kirby/wood
	icon_state = "plant-02"
	overlay_positions = list(list(16, 17), list(10, 11), list(19, 10))

/datum/plant_feature/body/kirby/wood/cousin
	icon_state = "plant-02-1"

//sharp
/datum/plant_feature/body/kirby/sharp
	icon_state = "plant-05"
	overlay_positions = list()

//alien
/datum/plant_feature/body/kirby/alien
	icon_state = "plant-13"
	overlay_positions = list(list(16, 22))

/datum/plant_feature/body/kirby/alien/apply_fruit_overlay(obj/effect/fruit_effect, offset_x, offset_y)
	//Overwrite this so we don't inherit mirroring and other bullshit
	fruit_effect.pixel_x = offset_x-17
	fruit_effect.pixel_y = offset_y-16
	parent.plant_item.vis_contents += fruit_effect
	fruit_overlays += fruit_effect

//monstera
/datum/plant_feature/body/kirby/monstera
	icon_state = "monstera"
	overlay_positions = list(list(10, 10), list(15, 13), list(19, 8), list(24, 11))
	draw_below_water = FALSE

/datum/plant_feature/body/kirby/monstera/New(datum/component/plant/_parent)
	. = ..()
	name = "Ashley II"
	_parent?.plant_item?.name = name

//fries
/datum/plant_feature/body/kirby/fries
	icon_state = "plant-20"
	overlay_positions = list(list(19, 19), list(9, 16), list(11, 9))
