// Chili
/obj/item/food/grown/chili
	seed = /obj/item/plant_seeds/preset/chili
	name = "chili"
	desc = "It's spicy! Wait... IT'S BURNING ME!!"
	icon_state = "chilipepper"
	bite_consumption_mod = 2
	foodtypes = FRUIT
	wine_power = 20

// Ice Chili
/obj/item/food/grown/icepepper
	name = "ice pepper"
	desc = "It's a mutant strain of chili."
	icon_state = "icepepper"
	bite_consumption_mod = 5
	foodtypes = FRUIT
	wine_power = 30
	discovery_points = 300

// Ghost Chili
/obj/item/food/grown/ghost_chili
	name = "ghost chili"
	desc = "It seems to be vibrating gently."
	icon_state = "ghostchilipepper"
	var/mob/living/carbon/human/held_mob
	bite_consumption_mod = 5
	foodtypes = FRUIT
	wine_power = 50
	discovery_points = 300

/obj/item/food/grown/ghost_chili/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if( ismob(loc) )
		held_mob = loc
		START_PROCESSING(SSobj, src)

/obj/item/food/grown/ghost_chili/process(delta_time)
	if(held_mob && loc == held_mob)
		if(held_mob.is_holding(src))
			if(istype(held_mob) && held_mob.gloves)
				return
			held_mob.adjust_bodytemperature(7.5 * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time)
			if(DT_PROB(5, delta_time))
				to_chat(held_mob, span_warning("Your hand holding [src] burns!"))
	else
		held_mob = null
		..()
