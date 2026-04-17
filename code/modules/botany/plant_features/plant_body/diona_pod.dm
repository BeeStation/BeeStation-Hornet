/*
	Diona Pod
*/
/datum/plant_feature/body/diona_pod
	species_name = "terra arbore"
	name = "diona vine"
	icon_state = "diona_vine"
	draw_below_water = FALSE
	yields = PLANT_BODY_YIELD_MICRO
	yield_cooldown_time = PLANT_BODY_YIELD_TIME_SLOW
	max_harvest = PLANT_BODY_HARVEST_MICRO
	slot_size = PLANT_BODY_SLOT_SIZE_LARGEST
	growth_time = PLANT_BODY_GROWTH_MEDIUM
	can_copy = FALSE
	can_remove = FALSE
	overlay_positions = list(list(24, 6))
	whitelist_features = list(/datum/plant_feature/fruit/cabbage/diona, /datum/plant_feature/roots)

/datum/plant_feature/body/diona_pod/growth_step(step)
	. = ..()
	playsound(parent.plant_item, 'sound/effects/rustle.ogg', 30, TRUE)
	var/obj/emitter/confetti/leaves/particles = parent.plant_item.add_emitter(/obj/emitter/confetti/leaves, "leaves", 10, lifespan = 20)
	particles.set_colour("#64A344")
	parent.plant_item.add_emitter(/obj/emitter/plant_dust, "dust", 10, lifespan = 20)
	draw_below_water = step >= growth_stages ? initial(draw_below_water) : TRUE
	update_water_render()
