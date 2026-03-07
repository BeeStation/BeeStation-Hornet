/*
	Kirby base
	//TODO: Monstera for Twiggy - Racc
*/
/datum/plant_feature/body/kirby
	species_name = "genus plantae"
	icon = 'icons/obj/hydroponics/features/kirby_body.dmi'
	icon_state = "plant-01"
	overlay_positions = list(list(14, 18), list(21, 20), list(20, 26), list(13, 25), list(16, 22)) //TODO: Do these for each one - Racc
	yields = PLANT_BODY_YIELD_SMALL
	yield_cooldown_time = PLANT_BODY_YIELD_TIME_MEDIUM
	max_harvest = PLANT_BODY_HARVEST_SMALL
	growth_time = PLANT_BODY_GROWTH_FAST

/datum/plant_feature/body/kirby/New(datum/component/plant/_parent)
	if(prob(1)) //Small chance for easter egg names
		name = pick(list("Ashley", "Blerp", "Pigeon", "Bacon", "TSL", "Cee Cee"))
	else
		name = "[capitalize(pick(GLOB.adjectives))] [pick(GLOB.first_names)]"
	_parent?.plant_item?.name = name
	return ..()

/datum/plant_feature/body/kirbyd/growth_step(step)
	. = ..()
	parent.plant_item.add_emitter(/obj/emitter/plant_dust, "dust", 10, lifespan = 20)

//tall
/datum/plant_feature/body/kirby/tall
	icon_state = "plant-06-1"
	overlay_positions = list(list(14, 18), list(21, 20), list(20, 26), list(13, 25), list(16, 22))

/datum/plant_feature/body/kirby/tall/cousin
	icon_state = "plant-06"

//bushy
/datum/plant_feature/body/kirby/bushy
	icon_state = "plant-08"
	overlay_positions = list(list(14, 18), list(21, 20), list(20, 26), list(13, 25), list(16, 22))

//birch
/datum/plant_feature/body/kirby/birch
	icon_state = "plant-26"
	overlay_positions = list(list(14, 18), list(21, 20), list(20, 26), list(13, 25), list(16, 22))
	mutations = list(/datum/plant_feature/body/tree/birch)

//tree
/datum/plant_feature/body/kirby/tree
	icon_state = "plant-21"
	overlay_positions = list(list(14, 18), list(21, 20), list(20, 26), list(13, 25), list(16, 22))

//tropic
/datum/plant_feature/body/kirby/tropic
	icon_state = "plant-33"
	overlay_positions = list(list(14, 18), list(21, 20), list(20, 26), list(13, 25), list(16, 22))

//cherry
/datum/plant_feature/body/kirby/cherry
	icon_state = "plant-10"
	overlay_positions = list(list(14, 18), list(21, 20), list(20, 26), list(13, 25), list(16, 22))
	mutations = list(/datum/plant_feature/body/tree/cherry)

//floor_foliage
/datum/plant_feature/body/kirby/floor_foliage
	icon_state = "plant-01"
	overlay_positions = list(list(14, 18), list(21, 20), list(20, 26), list(13, 25), list(16, 22))

//pretender
/datum/plant_feature/body/kirby/pretender
	icon_state = "plant-31"
	overlay_positions = list(list(14, 18), list(21, 20), list(20, 26), list(13, 25), list(16, 22))

//shielded
/datum/plant_feature/body/kirby/shielded
	icon_state = "plant-32"
	overlay_positions = list(list(14, 18), list(21, 20), list(20, 26), list(13, 25), list(16, 22))
	draw_below_water = FALSE

//pandora
/datum/plant_feature/body/kirby/pandora
	icon_state = "plant-09"
	overlay_positions = list(list(14, 18), list(21, 20), list(20, 26), list(13, 25), list(16, 22))

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
	overlay_positions = list(list(14, 18), list(21, 20), list(20, 26), list(13, 25), list(16, 22))
	draw_below_water = FALSE

//not_tomato
/datum/plant_feature/body/kirby/hair
	icon_state = "plant-29"
	overlay_positions = list(list(14, 18), list(21, 20), list(20, 26), list(13, 25), list(16, 22))
	draw_below_water = FALSE

//wood
/datum/plant_feature/body/kirby/wood
	icon_state = "plant-02"
	overlay_positions = list(list(14, 18), list(21, 20), list(20, 26), list(13, 25), list(16, 22))

/datum/plant_feature/body/kirby/wood/cousin
	icon_state = "plant-02-1"

//sharp
/datum/plant_feature/body/kirby/sharp
	icon_state = "plant-05"
	overlay_positions = list(list(14, 18), list(21, 20), list(20, 26), list(13, 25), list(16, 22))
