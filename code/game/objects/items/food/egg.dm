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

/obj/item/food/egg
	name = "egg"
	desc = "An egg!"
	icon = 'icons/obj/food/egg.dmi'
	icon_state = "egg"
	food_reagents = list(
		/datum/reagent/consumable/eggyolk = 5
	)
	microwaved_type = /obj/item/food/boiledegg
	foodtypes = MEAT | RAW
	w_class = WEIGHT_CLASS_TINY

/*
/obj/item/food/egg/make_microwaveable()
	AddElement(/datum/element/microwavable, /obj/item/food/boiledegg)
*/

/obj/item/food/egg/gland
	desc = "An egg! It looks weird..."

/obj/item/food/egg/gland/Initialize(mapload)
	. = ..()
	reagents.add_reagent(get_random_reagent_id(CHEMICAL_RNG_GENERAL), 15)

	var/color = mix_color_from_reagents(reagents.reagent_list)
	add_atom_colour(color, FIXED_COLOUR_PRIORITY)

/obj/item/food/egg/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!..()) //was it caught by a mob?
		var/turf/T = get_turf(hit_atom)
		new/obj/effect/decal/cleanable/food/egg_smudge(T)
		reagents.reaction(hit_atom, TOUCH)
		qdel(src)

/obj/item/food/egg/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/C = W
		var/clr = C.crayon_color

		if(!(clr in list("blue", "green", "mime", "orange", "purple", "rainbow", "red", "yellow")))
			to_chat(usr, "<span class='notice'>[src] refuses to take on this colour!</span>")
			return

		to_chat(usr, "<span class='notice'>You colour [src] with [W].</span>")
		icon_state = "egg-[clr]"
	else
		..()

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
	desc = "A fried egg, with a touch of salt and pepper."
	icon = 'icons/obj/food/egg.dmi'
	icon_state = "friedegg"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/nutriment/vitamin = 1
	)
	bite_consumption = 1
	tastes = list("egg" = 4, "salt" = 1, "pepper" = 1)
	foodtypes = MEAT | FRIED | BREAKFAST

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

/obj/item/food/omelette //FUCK THIS
	name = "omelette du fromage"
	desc = "That's all you can say!"
	icon = 'icons/obj/food/egg.dmi'
	icon_state = "omelette"
	trash_type = /obj/item/trash/plate
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 10,
		/datum/reagent/consumable/nutriment/vitamin = 3
	)
	bite_consumption = 1
	w_class = WEIGHT_CLASS_SMALL
	tastes = list("egg" = 1, "cheese" = 1)
	foodtypes = MEAT | BREAKFAST | DAIRY //yeah, I say this just about reaches the threshold of dairy foodgroup

/obj/item/food/omelette/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/kitchen/fork))
		var/obj/item/kitchen/fork/F = W
		if(F.forkload)
			to_chat(user, "<span class='warning'>You already have omelette on your fork!</span>")
		else
			F.icon_state = "forkloaded"
			user.visible_message("[user] takes a piece of omelette with [user.p_their()] fork!", \
				"<span class='notice'>You take a piece of omelette with your fork.</span>")

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
	trash_type = /obj/item/trash/plate
	w_class = WEIGHT_CLASS_SMALL
	tastes = list("egg" = 1, "bacon" = 1, "bun" = 1)
	foodtypes = MEAT | BREAKFAST | GRAIN

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
