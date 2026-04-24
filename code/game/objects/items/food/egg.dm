////////////////////////////////////////////EGGS////////////////////////////////////////////

/obj/item/food/chocolateegg
	name = "chocolate egg"
	desc = "Such, sweet, fattening food."
	icon = 'icons/obj/food/egg.dmi'
	icon_state = "chocolateegg"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/sugar = 2,
		/datum/reagent/consumable/cocoa = 2,
		/datum/reagent/consumable/nutriment/vitamin = 1
	)
	tastes = list("chocolate" = 4, "sweetness" = 1)
	foodtypes = JUNKFOOD | SUGAR
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_TINY
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/egg
	name = "egg"
	desc = "An egg!"
	icon = 'icons/obj/food/egg.dmi'
	icon_state = "egg"
	inhand_icon_state = "egg"
	food_reagents = list(
		/datum/reagent/consumable/eggyolk = 2, /datum/reagent/consumable/eggwhite = 4
	)
	microwaved_type = /obj/item/food/boiledegg
	foodtypes = MEAT | RAW
	w_class = WEIGHT_CLASS_TINY
	ant_attracting = FALSE
	decomp_type = /obj/item/food/egg/rotten
	decomp_req_handle = TRUE //so laid eggs can actually become chickens
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/egg/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/boiledegg, rand(15 SECONDS, 20 SECONDS), TRUE, TRUE)

/*
/obj/item/food/egg/make_microwaveable()
	AddElement(/datum/element/microwavable, /obj/item/food/boiledegg)
*/

/obj/item/food/egg/rotten
	food_reagents = list(/datum/reagent/consumable/eggrot = 10, /datum/reagent/consumable/mold = 10)
	microwaved_type = /obj/item/food/boiledegg/rotten
	foodtypes = GROSS
	preserved_food = TRUE

/obj/item/food/egg/rotten/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/boiledegg/rotten, rand(15 SECONDS, 20 SECONDS), TRUE, TRUE)

/obj/item/food/egg/gland
	desc = "An egg! It looks weird..."

/obj/item/food/egg/gland/Initialize(mapload)
	. = ..()
	reagents.add_reagent(get_random_reagent_id(CHEMICAL_RNG_GENERAL), 15)

	var/color = mix_color_from_reagents(reagents.reagent_list)
	add_atom_colour(color, FIXED_COLOUR_PRIORITY)

/obj/item/food/egg/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if (..()) // was it caught by a mob?
		return

	var/turf/T = get_turf(hit_atom)
	new/obj/effect/decal/cleanable/food/egg_smudge(T)
	reagents.expose(hit_atom, TOUCH)
	qdel(src)

/obj/item/food/egg/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/C = W
		var/clr = C.crayon_color

		if(!(clr in list("blue", "green", "mime", "orange", "purple", "rainbow", "red", "yellow")))
			to_chat(usr, span_notice("[src] refuses to take on this colour!"))
			return

		to_chat(usr, span_notice("You colour [src] with [W]."))
		icon_state = "egg-[clr]"

	else if(is_reagent_container(W))
		var/obj/item/reagent_containers/dunk_test_container = W
		if (!dunk_test_container.is_drainable() || !dunk_test_container.reagents.has_reagent(/datum/reagent/water))
			return

		to_chat(user, span_notice("You check if [src] is rotten."))
		if(istype(src, /obj/item/food/egg/rotten))
			to_chat(user, span_warning("[src] floats in the [dunk_test_container]!"))
		else
			to_chat(user, span_notice("[src] sinks into the [dunk_test_container]!"))
	else
		..()

/obj/item/food/egg/afterattack_secondary(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return

	if(!istype(target, /obj/machinery/griddle))
		return SECONDARY_ATTACK_CALL_NORMAL

	var/atom/broken_egg = new /obj/item/food/rawegg(target.loc)
	broken_egg.pixel_x = pixel_x
	broken_egg.pixel_y = pixel_y
	playsound(get_turf(user), 'sound/items/sheath.ogg', 40, TRUE)
	reagents.copy_to(broken_egg,reagents.total_volume)

	var/obj/machinery/griddle/hit_griddle = target
	hit_griddle.AddToGrill(broken_egg, user)
	target.balloon_alert(user, "cracks [src] open")

	qdel(src)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/food/egg/blue
	icon_state = "egg-blue"

/obj/item/food/egg/green
	icon_state = "egg-green"

/obj/item/food/egg/mime
	icon_state = "egg-mime"

/obj/item/food/egg/orange
	icon_state = "egg-orange"

/obj/item/food/egg/purple
	icon_state = "egg-purple"

/obj/item/food/egg/rainbow
	icon_state = "egg-rainbow"

/obj/item/food/egg/red
	icon_state = "egg-red"

/obj/item/food/egg/yellow
	icon_state = "egg-yellow"

/obj/item/food/friedegg
	name = "fried egg"
	desc = "A fried egg. Would go well with a touch of salt and pepper."
	icon = 'icons/obj/food/egg.dmi'
	icon_state = "friedegg"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 3,
		/datum/reagent/consumable/eggyolk = 1,
		/datum/reagent/consumable/nutriment/vitamin = 1
	)
	bite_consumption = 1
	tastes = list("egg" = 4)
	foodtypes = MEAT | FRIED | BREAKFAST
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/rawegg
	name = "raw egg"
	desc = "Supposedly good for you, if you can stomach it. Better fried."
	icon = 'icons/obj/food/egg.dmi'
	icon_state = "rawegg"
	food_reagents = list() //Receives all reagents from its whole egg counterpart
	bite_consumption = 1
	tastes = list("raw egg" = 6, "sliminess" = 1)
	eatverbs = list("gulp down")
	foodtypes = MEAT | RAW
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/rawegg/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/friedegg, rand(20 SECONDS, 35 SECONDS), TRUE, FALSE)

/obj/item/food/boiledegg
	name = "boiled egg"
	desc = "A hard boiled egg."
	icon = 'icons/obj/food/egg.dmi'
	icon_state = "egg"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/consumable/nutriment/vitamin = 1
	)
	tastes = list("egg" = 1)
	foodtypes = MEAT | BREAKFAST
	food_flags = FOOD_FINGER_FOOD // pretty sure I've seen people pop these in their mouths... right?
	w_class = WEIGHT_CLASS_SMALL
	ant_attracting = FALSE
	decomp_type = /obj/item/food/boiledegg/rotten
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/boiledegg/rotten
	food_reagents = list(/datum/reagent/consumable/eggrot = 10)
	tastes = list("rotten egg" = 1)
	foodtypes = GROSS
	preserved_food = TRUE

/obj/item/food/omelette //FUCK THIS
	name = "omelette du fromage"
	desc = "That's all you can say!"
	icon = 'icons/obj/food/egg.dmi'
	icon_state = "omelette"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 10,
		/datum/reagent/consumable/nutriment/vitamin = 3
	)
	bite_consumption = 1
	w_class = WEIGHT_CLASS_SMALL
	tastes = list("egg" = 1, "cheese" = 1)
	foodtypes = MEAT | BREAKFAST | DAIRY //yeah, I say this just about reaches the threshold of dairy foodgroup
	crafting_complexity = FOOD_COMPLEXITY_2
	crafted_food_buff = /datum/status_effect/food/speech/french

/obj/item/food/omelette/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/kitchen/fork))
		var/obj/item/kitchen/fork/F = W
		if(F.forkload)
			to_chat(user, span_warning("You already have omelette on your fork!"))
		else
			F.icon_state = "forkloaded"
			user.visible_message("[user] takes a piece of omelette with [user.p_their()] fork!", \
				span_notice("You take a piece of omelette with your fork."))

			var/datum/reagent/R = pick(reagents.reagent_list)
			reagents.remove_reagent(R.type, 1)
			F.forkload = R
			if(reagents.total_volume <= 0)
				qdel(src)
		return
	..()

/obj/item/food/benedict
	name = "eggs benedict"
	desc = "There is only one egg on this, how rude."
	icon = 'icons/obj/food/egg.dmi'
	icon_state = "benedict"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/nutriment = 3
	)
	w_class = WEIGHT_CLASS_SMALL
	tastes = list("egg" = 1, "bacon" = 1, "bun" = 1)
	foodtypes = MEAT | BREAKFAST | GRAIN
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/eggwrap
	name = "egg wrap"
	desc = "The precursor to Pigs in a Blanket."
	icon = 'icons/obj/food/egg.dmi'
	icon_state = "eggwrap"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/consumable/nutriment/vitamin = 3
	)
	tastes = list("egg" = 1)
	foodtypes = MEAT | VEGETABLES
	w_class = WEIGHT_CLASS_TINY
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/chawanmushi
	name = "chawanmushi"
	desc = "A legendary egg custard that makes friends out of enemies. Probably too hot for a cat to eat."
	icon = 'icons/obj/food/egg.dmi'
	icon_state = "chawanmushi"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/protein = 3,
		/datum/reagent/consumable/nutriment/vitamin = 1
	)
	tastes = list("custard" = 1)
	foodtypes = MEAT | VEGETABLES
	crafting_complexity = FOOD_COMPLEXITY_3
