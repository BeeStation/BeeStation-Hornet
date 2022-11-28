///Get a random food item exluding the blocked ones
/proc/get_random_food()
	var/list/blocked = list(/obj/item/reagent_containers/food/snacks/store/bread,
		/obj/item/reagent_containers/food/snacks/breadslice,
		/obj/item/reagent_containers/food/snacks/store/cake,
		/obj/item/reagent_containers/food/snacks/cakeslice,
		/obj/item/reagent_containers/food/snacks/store,
		/obj/item/reagent_containers/food/snacks/pie,
		/obj/item/reagent_containers/food/snacks/kebab,
		/obj/item/reagent_containers/food/snacks/pizza,
		/obj/item/reagent_containers/food/snacks/pizzaslice,
		/obj/item/reagent_containers/food/snacks/salad,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/meat/slab,
		/obj/item/reagent_containers/food/snacks/soup,
		/obj/item/reagent_containers/food/snacks/grown,
		/obj/item/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/reagent_containers/food/snacks/deepfryholder,
		/obj/item/reagent_containers/food/snacks/clothing,
		/obj/item/reagent_containers/food/snacks/grown/shell, //base types
		/obj/item/reagent_containers/food/snacks/store/bread,
		/obj/item/reagent_containers/food/snacks/grown/nettle
		)
	blocked |= typesof(/obj/item/reagent_containers/food/snacks/customizable)

	return pick(subtypesof(/obj/item/reagent_containers/food/snacks) - blocked)

///Gets a random drink excluding the blocked type
/proc/get_random_drink()
	var/list/blocked = list(/obj/item/reagent_containers/food/drinks/soda_cans,
		/obj/item/reagent_containers/food/drinks/bottle
		)
	return pick(subtypesof(/obj/item/reagent_containers/food/drinks) - blocked)

/// Picks a string of symbols to display as the law number for hacked or ion laws
/proc/ion_num()
	return "[pick("!","@","#","$","%","^","&")][pick("!","@","#","$","%","^","&","*")][pick("!","@","#","$","%","^","&","*")][pick("!","@","#","$","%","^","&","*")]"

/proc/random_nukecode()
	var/val = rand(0, 99999)
	var/str = "[val]"
	while(length(str) < 5)
		str = "0" + str
	. = str

/// Picks an item from random list. value assignment is necessary since it is used as a pick weight. this works differently than 'pick()' proc
/proc/pick_by_weight(random_list)
	if(!length(random_list))
		return

	// calculate each pickweight
	var/total_value
	for(var/each in random_list)
		if(random_list[each] < 0 || !isnum(random_list[each]))
			CRASH("item pick weight is wrong - should be more than 0: [random_list[each]]")
		total_value += random_list[each]
	if(!total_value)
		return pick(random_list)

	// pick something based on pickweight
	var/rand_result = rand(total_value)
	var/count
	var/pick_result
	for(var/each in random_list)
		count++
		if(rand_result-random_list[each] <= 0)
			pick_result = random_list[count]
			break
		rand_result -= random_list[each]

	return pick_result
