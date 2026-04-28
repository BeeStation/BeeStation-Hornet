///Get a random food item exluding the blocked ones
/proc/get_random_food()
	var/static/list/allowed_food = list()

	if(!LAZYLEN(allowed_food)) //it's static so we only ever do this once
		var/list/blocked = list(
			/obj/item/food/bread,
			/obj/item/food/breadslice,
			/obj/item/food/cake,
			/obj/item/food/cakeslice,
			/obj/item/food/clothing,
			/obj/item/food/grown,
			/obj/item/food/grown/ash_flora,
			/obj/item/food/grown/mushroom,
			/obj/item/food/grown/nettle,
			/obj/item/food/grown/shell,
			/obj/item/food/grown/shell/gatfruit,
			/obj/item/food/kebab,
			/obj/item/food/meat,
			/obj/item/food/meat/slab,
			/obj/item/food/meat/slab/human/mutant,
			/obj/item/food/pie,
			/obj/item/food/pieslice,
			/obj/item/food/pizza,
			/obj/item/food/pizzaslice,
			/obj/item/food/salad,
			/obj/item/food/soup,
		)

		var/list/unfiltered_allowed_food = subtypesof(/obj/item/food) - blocked
		for(var/obj/item/food/food as anything in unfiltered_allowed_food)
			if(!initial(food.icon_state)) //food with no icon_state should probably not be spawned
				continue
			allowed_food.Add(food)

	return pick(allowed_food)

///Gets a random drink excluding the blocked type
/proc/get_random_drink()
	var/list/blocked = list(
		/obj/item/reagent_containers/cup/soda_cans,
		/obj/item/reagent_containers/cup/glass/bottle
		)
	return pick(subtypesof(/obj/item/reagent_containers/cup/glass) - blocked)

/// Picks a string of symbols to display as the law number for hacked or ion laws
/proc/ion_num()
	return "[pick("!","@","#","$","%","^","&")][pick("!","@","#","$","%","^","&","*")][pick("!","@","#","$","%","^","&","*")][pick("!","@","#","$","%","^","&","*")]"

/proc/random_nukecode()
	var/val = rand(0, 99999)
	var/str = "[val]"
	while(length(str) < 5)
		str = "0" + str
	. = str

/proc/get_random_seed()
	var/list/blocked = list(
		/obj/item/seeds/banana/bombanana,
		/obj/item/seeds/lavaland,
		/obj/item/seeds/flower,
		/obj/item/seeds/sample,
		/obj/item/seeds/sample/alienweed,
		/obj/item/seeds/cherry/bomb
		)
	return pick(subtypesof(/obj/item/seeds) - blocked)
