// Watermelon
/obj/item/food/grown/watermelon
	seed = /obj/item/plant_seeds/preset/watermelon
	name = "watermelon"
	desc = "It's full of watery goodness."
	icon_state = "watermelon"
	bite_consumption_mod = 2
	w_class = WEIGHT_CLASS_NORMAL
	foodtypes = FRUIT
	juice_typepath = /datum/reagent/consumable/watermelonjuice
	wine_power = 40

/obj/item/food/grown/watermelon/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/watermelonslice, 5, 20, screentip_verb = "Slice")

/obj/item/food/grown/watermelon/make_dryable()
	return //No drying

// Holymelon
/obj/item/food/grown/holymelon
	name = "holymelon"
	desc = "The water within this melon has been blessed by some deity that's particularly fond of watermelon."
	icon_state = "holymelon"
	bite_consumption_mod = 2
	wine_power = 70 //Water to wine, baby.
	wine_flavor = "divinity"
	discovery_points = 300

/obj/item/food/grown/holymelon/make_dryable()
	return //No drying

/obj/item/food/grown/holymelon/make_edible()
	AddComponent(/datum/component/edible, \
		initial_reagents = food_reagents, \
		food_flags = food_flags, \
		foodtypes = foodtypes, \
		volume = max_volume, \
		eat_time = eat_time, \
		tastes = tastes, \
		eatverbs = eatverbs,\
		bite_consumption = bite_consumption, \
		microwaved_type = microwaved_type, \
		junkiness = junkiness, \
		check_liked = CALLBACK(src, PROC_REF(check_holyness)))
/*
 * Callback to be used with the edible component.
 * Checks whether or not the person eating the holymelon
 * is a holy_role (chaplain), as chaplains love holymelons.
 */
/obj/item/food/grown/holymelon/proc/check_holyness(mob/mob_eating)
	if(!ishuman(mob_eating))
		return
	var/mob/living/carbon/human/holy_person = mob_eating
	if(!holy_person.mind?.holy_role || HAS_TRAIT(holy_person, TRAIT_AGEUSIA))
		return
	to_chat(holy_person, span_notice("Truly, a piece of heaven!"))
	SEND_SIGNAL(holy_person, COMSIG_ADD_MOOD_EVENT, "Divine_chew", /datum/mood_event/holy_consumption)
	return FOOD_LIKED

/obj/item/food/grown/holymelon/Initialize(mapload)
	. = ..()
	var/uses = 1
	if(seed)
		uses = round(get_fruit_trait_power(src) * 2.3)
	AddComponent(/datum/component/anti_magic, \
	_source = src, \
	antimagic_flags = (MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY),\
	charges = uses, \
	drain_antimagic = CALLBACK(src, PROC_REF(block_magic)),\
	expiration = CALLBACK(src, PROC_REF(expire))) //deliver us from evil o melon god

/obj/item/food/grown/holymelon/proc/block_magic(mob/user, major)
	if(major)
		to_chat(user, span_warning("[src] hums slightly, and seems to decay a bit."))

/obj/item/food/grown/holymelon/proc/expire(mob/user)
	to_chat(user, span_warning("[src] rapidly turns into ash!"))
	qdel(src)
	new /obj/effect/decal/cleanable/ash(drop_location())

// ballolon
/obj/item/food/grown/ballolon
	name = "ballolon"
	desc = "A organic balloon, lighter then air."
	icon_state = "ballolon"
	inhand_icon_state = "ballolon"
	lefthand_file = 'icons/mob/inhands/misc/balloons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/balloons_righthand.dmi'
	filling_color = "#e35b6f"
	throw_range = 1
	throw_speed = 1
	discovery_points = 300
