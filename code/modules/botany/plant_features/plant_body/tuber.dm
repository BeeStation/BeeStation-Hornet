/*
	Tuber, generic
*/
/datum/plant_feature/body/tuber
	species_name = "infra lutum"
	name = "tuber"
	icon_state = ""
	overlay_positions = list(list(16,6))
	yields = PLANT_BODY_YIELD_MICRO
	yield_cooldown_time = PLANT_BODY_YIELD_TIME_FAST
	max_harvest = PLANT_BODY_HARVEST_MICRO
	use_mouse_offset = TRUE
	slot_size = PLANT_BODY_SLOT_SIZE_SMALL
	draw_below_water = FALSE
	growth_time = PLANT_BODY_GROWTH_VERY_FAST
	seeds = 5
	genetic_budget = 2
	///Pre-made mask for making fruits look burried
	var/icon/tuber_mask
	var/do_mask = TRUE

/datum/plant_feature/body/tuber/New(datum/component/plant/_parent)
	. = ..()
	if(do_mask)
		tuber_mask = icon(icon, "tuber_mask")

/datum/plant_feature/body/tuber/apply_fruit_overlay(obj/effect/fruit_effect, offset_x, offset_y)
	. = ..()
	if(do_mask)
		fruit_effect.add_filter("tuber_mask", 1, alpha_mask_filter(icon = tuber_mask, flags = MASK_INVERSE))

/datum/plant_feature/body/tuber/catch_harvest(datum/source, mob/user, list/temp_fruits, dummy_harvest)
	. = ..()
	if(yields <= 0)
		SEND_SIGNAL(parent, COMSIG_PLANT_UPROOTED,  null, null, parent.plant_item.loc)
		parent.plant_item.forceMove(get_turf(parent.plant_item))
		qdel(parent.plant_item)

/*
	Grass Tuber
*/
/datum/plant_feature/body/tuber/grass
	overlay_positions = list(list(16, 2))
	seeds = 1
	do_mask = FALSE
	yields = PLANT_BODY_YIELD_FOREVER
	yield_cooldown_time = PLANT_BODY_YIELD_TIME_FAST
	slot_size = PLANT_BODY_SLOT_SIZE_MICRO
	use_mouse_offset = FALSE
	layer_offset = 0
	genetic_budget = 1
	whitelist_features = list(/datum/plant_feature/fruit/grass, /datum/plant_feature/roots)
	dictionary_override = /datum/plant_feature/body/tuber
