// Watermelon
/obj/item/seeds/watermelon
	name = "pack of watermelon seeds"
	desc = "These seeds grow into watermelon plants."
	icon_state = "seed-watermelon"
	species = "watermelon"
	plantname = "Watermelon Vines"
	product = /obj/item/food/grown/watermelon
	lifespan = 50
	endurance = 40
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_dead = "watermelon-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/watermelon/holy, /obj/item/seeds/watermelon/ballolon)
	reagents_add = list(/datum/reagent/water = 0.2, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.2)

/obj/item/seeds/watermelon/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] is swallowing [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	user.gib()
	new product(drop_location())
	qdel(src)
	return MANUAL_SUICIDE

/obj/item/food/grown/watermelon
	seed = /obj/item/seeds/watermelon
	name = "watermelon"
	desc = "It's full of watery goodness."
	icon_state = "watermelon"
	bite_consumption_mod = 2
	w_class = WEIGHT_CLASS_NORMAL
	foodtypes = FRUIT
	juice_results = list(/datum/reagent/consumable/watermelonjuice = 0)
	wine_power = 40

/obj/item/food/grown/watermelon/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/watermelonslice, 5, 20)

/obj/item/food/grown/watermelon/make_dryable()
	return //No drying

// Holymelon
/obj/item/seeds/watermelon/holy
	name = "pack of holymelon seeds"
	desc = "These seeds grow into holymelon plants."
	icon_state = "seed-holymelon"
	species = "holymelon"
	plantname = "Holy Melon Vines"
	product = /obj/item/food/grown/holymelon
	genes = list(/datum/plant_gene/trait/glow/yellow)
	mutatelist = list()
	reagents_add = list(/datum/reagent/water/holywater = 0.2, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1)
	rarity = 20

/obj/item/food/grown/holymelon
	seed = /obj/item/seeds/watermelon/holy
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
/obj/item/food/grown/holymelon/proc/check_holyness(fraction, mob/mob_eating)
	if(!ishuman(mob_eating))
		return
	var/mob/living/carbon/human/holy_person = mob_eating
	if(!holy_person.mind?.holy_role || HAS_TRAIT(holy_person, TRAIT_AGEUSIA))
		return
	to_chat(holy_person, "<span class='notice'>Truly, a piece of heaven!</span>")
	SEND_SIGNAL(holy_person, COMSIG_ADD_MOOD_EVENT, "Divine_chew", /datum/mood_event/holy_consumption)
	return FOOD_LIKED

/obj/item/food/grown/holymelon/Initialize(mapload)
	. = ..()
	var/uses = 1
	if(seed)
		uses = round(seed.potency / 20)
	AddComponent(/datum/component/anti_magic, TRUE, TRUE, uses, TRUE, CALLBACK(src, PROC_REF(block_magic)), CALLBACK(src, PROC_REF(expire))) //deliver us from evil o melon god

/obj/item/food/grown/holymelon/proc/block_magic(mob/user, major)
	if(major)
		to_chat(user, "<span class='warning'>[src] hums slightly, and seems to decay a bit.</span>")

/obj/item/food/grown/holymelon/proc/expire(mob/user)
	to_chat(user, "<span class='warning'>[src] rapidly turns into ash!</span>")
	qdel(src)
	new /obj/effect/decal/cleanable/ash(drop_location())

// ballolon
/obj/item/seeds/watermelon/ballolon
	name = "pack of ballolon seeds"
	desc = "These seeds grow into ballolon plants."
	icon_state = "seed-ballolon"
	species = "ballolon"
	plantname = "Ballolon Vines"
	product = /obj/item/food/grown/ballolon
	genes = list(/datum/plant_gene/trait/repeated_harvest, /datum/plant_gene/trait/smoke)
	mutatelist = list()
	reagents_add = list(/datum/reagent/oxygen = 0.2, /datum/reagent/hydrogen = 0.2)
	rarity = 15

/obj/item/food/grown/ballolon
	seed = /obj/item/seeds/watermelon/ballolon
	name = "ballolon"
	desc = "A organic balloon, lighter then air."
	icon_state = "ballolon"
	item_state = "ballolon"
	lefthand_file = 'icons/mob/inhands/antag/balloons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/balloons_righthand.dmi'
	filling_color = "#e35b6f"
	throw_range = 1
	throw_speed = 1
	discovery_points = 300
