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
	var/spawned_mob = /mob/living/carbon/monkey

/obj/item/food/monkeycube/proc/Expand()
	if(GLOB.total_cube_monkeys >= CONFIG_GET(number/max_cube_monkeys))
		visible_message("<span class='warning'>[src] refuses to expand!</span>")
		return
	var/mob/spammer = get_mob_by_ckey(fingerprintslast)
	var/mob/living/bananas = new spawned_mob(drop_location(), TRUE, spammer)
	if(faction)
		bananas.faction = faction
	if (!QDELETED(bananas))
		visible_message("<span class='notice'>[src] expands!</span>")
		bananas.log_message("Spawned via [src] at [AREACOORD(src)], Last attached mob: [key_name(spammer)].", LOG_ATTACK)
	else if (!spammer) // Visible message in case there are no fingerprints
		visible_message("<span class='notice'>[src] fails to expand!</span>")
	qdel(src)

/obj/item/food/monkeycube/syndicate
	faction = list("neutral", FACTION_SYNDICATE)

/obj/item/food/monkeycube/gorilla
	name = "gorilla cube"
	desc = "A Waffle Co. brand gorilla cube. Now with extra molecules!"
	bite_consumption = 20
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 15
	)
	tastes = list("the jungle" = 1, "bananas" = 1, "jimmies" = 1)
	spawned_mob = /mob/living/simple_animal/hostile/gorilla

/*
/obj/item/food/monkeycube/chicken
	name = "chicken cube"
	desc = "A new Nanotrasen classic, the chicken cube. Tastes like everything!"
	bite_consumption = 20
	food_reagents = list(/datum/reagent/consumable/eggyolk = 30, /datum/reagent/medicine/strange_reagent = 1)
	tastes = list("chicken" = 1, "the country" = 1, "chicken bouillon" = 1)
	spawned_mob = /mob/living/simple_animal/chicken

/obj/item/food/monkeycube/bee
	name = "bee cube"
	desc = "We were sure it was a good idea. Just add water."
	bite_consumption = 20
	food_reagents = list(/datum/reagent/consumable/honey = 10, /datum/reagent/toxin = 5, /datum/reagent/medicine/strange_reagent = 1)
	tastes = list("buzzing" = 1, "honey" = 1, "regret" = 1)
	spawned_mob = /mob/living/simple_animal/hostile/bee
*/
