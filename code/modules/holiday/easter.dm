/datum/round_event_control/easter
	name = "Easter Eggselence"
	holidayID = EASTER
	typepath = /datum/round_event/easter
	weight = -1
	max_occurrences = 1
	earliest_start = 0 MINUTES

/datum/round_event/easter/announce(fake)
	priority_announce(pick("Hip-hop into Easter!","Find some Bunny's stash!","Today is National 'Hunt a Wabbit' Day.","Be kind, give Chocolate Eggs!"), sound = SSstation.announcer.get_rand_alert_sound())


/datum/round_event_control/rabbitrelease
	name = "Release the Rabbits!"
	holidayID = EASTER
	typepath = /datum/round_event/rabbitrelease
	weight = 5
	max_occurrences = 10

/datum/round_event/rabbitrelease/announce(fake)
	priority_announce("Unidentified furry objects detected coming aboard [station_name()]. Beware of Adorable-ness.", "Fluffy Alert", ANNOUNCER_ALIENS)


/datum/round_event/rabbitrelease/start()
	for(var/obj/effect/landmark/R in GLOB.landmarks_list)
		if(R.name != "blobspawn")
			if(prob(35))
				if(isspaceturf(R.loc))
					new /mob/living/simple_animal/chicken/rabbit/space(R.loc)
				else
					new /mob/living/simple_animal/chicken/rabbit(R.loc)

/mob/living/simple_animal/chicken/rabbit
	name = "\improper rabbit"
	desc = "The hippiest hop around."
	icon = 'icons/mob/easter.dmi'
	icon_state = "rabbit_white"
	icon_living = "rabbit_white"
	icon_dead = "rabbit_white_dead"
	speak = list("Hop into Easter!","Come get your eggs!","Prizes for everyone!")
	speak_emote = list("sniffles","twitches")
	speak_language = /datum/language/metalanguage // everyone should understand happy easter
	emote_hear = list("hops.")
	emote_see = list("hops around","bounces up and down")
	butcher_results = list(/obj/item/food/meat/slab = 1)
	egg_type = /obj/item/suprise_egg
	food_type = /obj/item/food/grown/carrot
	eggsleft = 10
	eggsFertile = FALSE
	icon_prefix = "rabbit"
	feedMessages = list("It nibbles happily.","It noms happily.")
	layMessage = list("hides an egg.","scampers around suspiciously.","begins making a huge racket.","begins shuffling.")

/mob/living/simple_animal/chicken/rabbit/space
	icon_prefix = "s_rabbit"
	icon_state = "s_rabbit_white"
	icon_living = "s_rabbit_white"
	icon_dead = "s_rabbit_white_dead"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	unsuitable_atmos_damage = 0

/obj/item/storage/basket
	name = "basket"
	desc = "Handwoven basket."
	icon = 'icons/obj/storage/basket.dmi'
	icon_state = "basket"
	w_class = WEIGHT_CLASS_BULKY
	resistance_flags = FLAMMABLE

/obj/item/storage/basket/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_combined_w_class = 21

//Easter Baskets
/obj/item/storage/basket/easter
	name = "Easter Basket"

/obj/item/storage/basket/easter/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.can_hold = typecacheof(list(/obj/item/food/egg, /obj/item/food/chocolateegg, /obj/item/food/boiledegg))

/obj/item/storage/basket/easter/proc/countEggs()
	cut_overlays()
	add_overlay("basket-grass")
	add_overlay("basket-egg[min(contents.len, 5)]")

/obj/item/storage/basket/easter/Exited(atom/movable/gone, direction)
	. = ..()
	countEggs()

/obj/item/storage/basket/easter/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	countEggs()

//Bunny Suit
/obj/item/clothing/head/costume/bunnyhead
	name = "Easter Bunny Head"
	icon_state = "bunnyhead"
	item_state = null
	desc = "Considerably more cute than 'Frank'."
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT

/obj/item/clothing/suit/bunnysuit
	name = "Easter Bunny Suit"
	desc = "Hop Hop Hop!"
	icon_state = "bunnysuit"
	icon = 'icons/obj/clothing/suits/costume.dmi'
	worn_icon = 'icons/mob/clothing/suits/costume.dmi'
	item_state = null
	slowdown = -0.2
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT

//Egg prizes and egg spawns!
/obj/item/surprise_egg
	name = "wrapped egg"
	desc = "A chocolate egg containing a little something special. Unwrap and enjoy!"
	icon_state = "egg"
	resistance_flags = FLAMMABLE
	w_class = WEIGHT_CLASS_TINY
	icon = 'icons/obj/food/egg.dmi'
	//lefthand_file = 'icons/mob/inhands/items/food_lefthand.dmi'
	//righthand_file = 'icons/mob/inhands/items/food_righthand.dmi'
	obj_flags = UNIQUE_RENAME

/obj/item/suprise_egg/loaded/Initialize(mapload)
	. = ..()
	var/eggcolor = pick("blue","green","mime","orange","purple","rainbow","red","yellow")
	icon_state = "egg-[eggcolor]"

/obj/item/suprise_egg/proc/dispensePrize(turf/where)
	var/static/list/prize_list = list(
		/obj/item/clothing/head/costume/bunnyhead,
		/obj/item/clothing/suit/bunnysuit,
		/obj/item/food/grown/carrot,
		/obj/item/toy/balloon,
		/obj/item/toy/gun,
		/obj/item/toy/sword,
		/obj/item/toy/talking/AI,
		/obj/item/toy/talking/owl,
		/obj/item/toy/talking/griffin,
		/obj/item/toy/minimeteor,
		/obj/item/toy/clockwork_watch,
		/obj/item/toy/toy_xeno,
		/obj/item/toy/foamblade,
		/obj/item/toy/plush/carpplushie,
		/obj/item/toy/redbutton,
		/obj/item/toy/windupToolbox,
		/obj/item/clothing/head/collectable/rabbitears
	) + subtypesof(/obj/item/toy/mecha)
	var/won = pick(prize_list)
	new won(where)
	new/obj/item/food/chocolateegg(where)

/obj/item/suprise_egg/attack_self(mob/user)
	..()
	to_chat(user, "<span class='notice'>You unwrap [src] and find a prize inside!</span>")
	dispensePrize(get_turf(user))
	qdel(src)

//Easter Recipes + food
/obj/item/food/hotcrossbun
	bite_consumption = 2
	name = "hot-cross bun"
	desc = "The Cross represents the Assistants that died for your sins."
	icon_state = "hotcrossbun"
	foodtypes = SUGAR | GRAIN
	tastes = list("easter")

/datum/crafting_recipe/food/hotcrossbun
	name = "Hot-Cross Bun"
	reqs = list(
		/obj/item/food/bread/plain = 1,
		/datum/reagent/consumable/sugar = 1
	)
	result = /obj/item/food/hotcrossbun
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/briochecake
	name = "Brioche cake"
	reqs = list(
		/obj/item/food/cake/plain = 1,
		/datum/reagent/consumable/sugar = 2
	)
	result = /obj/item/food/cake/brioche
	subcategory = CAT_MISCFOOD

/obj/item/food/scotchegg
	name = "scotch egg"
	desc = "A boiled egg wrapped in a delicious, seasoned meatball."
	icon = 'icons/obj/food/egg.dmi'
	icon_state = "scotchegg"
	bite_consumption = 3
	food_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/vitamin = 2)

/datum/crafting_recipe/food/scotchegg
	name = "Scotch egg"
	reqs = list(
		/datum/reagent/consumable/sodiumchloride = 1,
		/datum/reagent/consumable/blackpepper = 1,
		/obj/item/food/boiledegg = 1,
		/obj/item/food/meatball = 1
	)
	result = /obj/item/food/scotchegg
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/mammi
	name = "Mammi"
	reqs = list(
		/obj/item/food/bread/plain = 1,
		/obj/item/food/chocolatebar = 1,
		/datum/reagent/consumable/milk = 5
	)
	result = /obj/item/food/soup/mammi
	subcategory = CAT_MISCFOOD

/obj/item/food/chocolatebunny
	name = "chocolate bunny"
	desc = "Contains less than 10% real rabbit!"
	icon_state = "chocolatebunny"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/sugar = 2, /datum/reagent/consumable/cocoa = 2, /datum/reagent/consumable/nutriment/vitamin = 1)

/datum/crafting_recipe/food/chocolatebunny
	name = "Chocolate bunny"
	reqs = list(
		/datum/reagent/consumable/sugar = 2,
		/obj/item/food/chocolatebar = 1
	)
	result = /obj/item/food/chocolatebunny
	subcategory = CAT_MISCFOOD
