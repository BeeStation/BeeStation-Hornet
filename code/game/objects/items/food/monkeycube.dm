/obj/item/food/monkeycube
	name = "monkey cube"
	desc = "Just add water!"
	icon_state = "monkeycube"
	bite_consumption = 12
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2
	)
	tastes = list("the jungle" = 1, "bananas" = 1)
	foodtypes = MEAT | SUGAR
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_TINY
	var/faction
	var/spawned_mob = /mob/living/carbon/human/species/monkey
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/monkeycube/proc/Expand()
	if(GLOB.total_cube_monkeys >= CONFIG_GET(number/max_cube_monkeys))
		visible_message(span_warning("[src] refuses to expand!"))
		return
	var/mob/spammer = get_mob_by_ckey(fingerprintslast)
	var/mob/living/bananas = new spawned_mob(drop_location(), TRUE, spammer)
	if(faction)
		bananas.faction = faction
	if (!QDELETED(bananas))
		visible_message(span_notice("[src] expands!"))
		bananas.log_message("Spawned via [src] at [AREACOORD(src)], Last attached mob: [key_name(spammer)].", LOG_ATTACK)
	else if (!spammer) // Visible message in case there are no fingerprints
		visible_message(span_notice("[src] fails to expand!"))
	qdel(src)

/obj/item/food/monkeycube/syndicate
	faction = list(FACTION_NEUTRAL, FACTION_SYNDICATE)

/obj/item/food/monkeycube/gorilla
	name = "gorilla cube"
	desc = "A Waffle Co. brand gorilla cube. Now with extra molecules!"
	icon_state = "gorillacube"
	bite_consumption = 20
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 15
	)
	tastes = list("the jungle" = 1, "bananas" = 1, "jimmies" = 1)
	spawned_mob = /mob/living/simple_animal/hostile/gorilla
