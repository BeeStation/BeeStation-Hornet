/*
	Pineapple Stalk
*/
/datum/plant_feature/body/pineapple
	species_name = "bracchium spinosum"
	name = "pineapple stalk"
	icon_state = "pineapple_stalk"
	growth_prefix = "bush"
	growth_stages = 3
	overlay_positions = list(list(17, 9))
	draw_below_water = FALSE
	yields = PLANT_BODY_YIELD_MICRO
	yield_cooldown_time = PLANT_BODY_YIELD_TIME_SLOW
	max_harvest = PLANT_BODY_HARVEST_MICRO
	upper_fruit_size = PLANT_FRUIT_SIZE_LARGE
	growth_time = PLANT_BODY_GROWTH_VERY_FAST
	seeds = 2

/datum/plant_feature/body/pineapple/growth_step(step)
	. = ..()
	playsound(parent.plant_item, 'sound/effects/rustle.ogg', 30, TRUE)
	var/obj/emitter/confetti/leaves/particles = parent.plant_item.add_emitter(/obj/emitter/confetti/leaves, "leaves", 10, lifespan = 20)
	particles.set_colour("#64A344")
	parent.plant_item.add_emitter(/obj/emitter/plant_dust, "dust", 10, lifespan = 20)
	//Extra logic for in-growth layering
	if(step >= growth_stages)
		draw_below_water = initial(draw_below_water)
	else
		draw_below_water = TRUE
	var/obj/item/plant_tray/tray = parent.plant_item.loc
	if(istype(tray))
		parent.plant_item.pixel_y = step < growth_stages ? tray.plant_offset[2]+2 : tray.plant_offset[2]
	update_water_render()
