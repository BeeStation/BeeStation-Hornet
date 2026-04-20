/*
	Corn Stalk
*/
/datum/plant_feature/body/corn_stalk
	species_name = "aureum culmus"
	name = "corn stalk"
	icon_state = "corn_stalk"
	growth_prefix = "stalk"
	growth_stages = 3
	use_mouse_offset = TRUE
	overlay_positions = list(list(17, 16))
	yields = PLANT_BODY_YIELD_MICRO
	yield_cooldown_time = PLANT_BODY_YIELD_TIME_SLOW //Doesn't really matter, we only get one
	max_harvest = PLANT_BODY_HARVEST_MICRO
	upper_fruit_size = PLANT_FRUIT_SIZE_SMALL
	slot_size = PLANT_BODY_SLOT_SIZE_SMALL
	growth_time = PLANT_BODY_GROWTH_VERY_FAST
	seeds = 5

/datum/plant_feature/body/corn_stalk/apply_fruit_overlay(obj/effect/fruit_effect, offset_x, offset_y)
	. = ..()
	fruit_effect.transform = fruit_effect.transform.Scale(1, -1)
	fruit_effect.pixel_y -= 1

/datum/plant_feature/body/corn_stalk/growth_step(step)
	. = ..()
	playsound(parent.plant_item, 'sound/effects/rustle.ogg', 30, TRUE)
	parent.plant_item.add_emitter(/obj/emitter/plant_dust, "dust", 10, lifespan = 20)
	draw_below_water = step >= growth_stages ? initial(draw_below_water) : TRUE
	update_water_render()


/*
	Rice Stalk
*/
/datum/plant_feature/body/corn_stalk/rice
	species_name = "stipula alba"
	name = "rice stalk"
	icon_state = "rice_stalk"
	overlay_positions = list(list(17, 16))

/*
	Wheat Stalk
*/
/datum/plant_feature/body/corn_stalk/wheat
	species_name = "bracchium aurum"
	name = "wheat stalk"
	icon_state = "wheat_stalk"
	growth_stages = 2
	overlay_positions = list(list(17, 16))

/*
	Sun Stalk
*/
/datum/plant_feature/body/corn_stalk/sunflower
	species_name = "sol culmo"
	name = "sunflower stalk"
	icon_state = "sunflower_stalk"
	overlay_positions = list(list(17, 16))

/*
	Flower Stalk
*/
/datum/plant_feature/body/corn_stalk/flower
	species_name = "stipula flos"
	name = "flower stem"
	icon_state = "flower_stalk"
	growth_stages = 1
	overlay_positions = list(list(17, 8))
	slot_size = PLANT_BODY_SLOT_SIZE_MICRO
	whitelist_features = list(/datum/plant_feature/fruit/flower, /datum/plant_feature/roots)

/datum/plant_feature/body/corn_stalk/flower/catch_harvest(datum/source, mob/user, list/temp_fruits, dummy_harvest)
	. = ..()
	if(yields <= 0)
		SEND_SIGNAL(parent, COMSIG_PLANT_UPROOTED,  null, null, parent.plant_item.loc)
		parent.plant_item.forceMove(get_turf(parent.plant_item))
		qdel(parent.plant_item)

/*
	Ground Stalk
*/
/datum/plant_feature/body/corn_stalk/ground
	species_name = "terra arbore"
	name = "ground stalk"
	icon_state = "vine_ground"
	growth_prefix = "bush"
	growth_stages = 2 //This is inherited as 2, this is a safety
	draw_below_water = FALSE
	overlay_positions = list(list(23, 7))
	yields = 1
