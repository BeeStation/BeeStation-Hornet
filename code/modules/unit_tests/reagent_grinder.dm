/**
 * Unit test to check for if reagent grinders process correctly.
 *
 * Accepts each item that has grind_results not null OR has an assigned juice_typepath variable
 * Grinds/Juices it
 * Checks if the output is what we expect from grinding/juicing that item
 *
 */

/datum/unit_test/reagent_grinder

/datum/unit_test/reagent_grinder/Run()
	message_admins("Running Reagent Grinder Test")
	grind_items()
	juice_items()


/datum/unit_test/reagent_grinder/proc/grind_items()
	var/list/item_list = subtypesof(/obj/item)
	for(var/item as anything in item_list)
		message_admins("GRINDING: [item_list]")
	for(var/obj/item/item as anything in item_list)
		item = new()
		if(!item.grind_results && !item.juice_typepath && !item.is_grindable())
			QDEL_NULL(item)
			return
		message_admins("Now grinding: [item]")
		var/obj/machinery/reagentgrinder/grinder = allocate(/obj/machinery/reagentgrinder)

		message_admins("Moved [item] into grinder")
		item.forceMove(grinder)
		grinder.holdingitems[item] = TRUE
		grinder.grind()
		message_admins("[item] grinded with the following ingredients in beaker: [grinder.beaker.reagents], expecting [item.grind_results]")
		TEST_ASSERT((grinder.beaker.reagents != item.grind_results), "No reagents in beaker after attempted grinding in [item], supposed to have [item.grind_results]!")
		QDEL_NULL(item)

/datum/unit_test/reagent_grinder/proc/juice_items()
	var/list/item_list = subtypesof(/obj/item)
	for(var/item as anything in item_list)
		message_admins("JUICING: [item_list]")
	for(var/obj/item/item as anything in item_list)
		item = new()
		if(!item.grind_results && !item.juice_typepath && !item.is_grindable())
			QDEL_NULL(item)
			return

		message_admins("Now juicing: [item]")
		var/obj/machinery/reagentgrinder/grinder = allocate(/obj/machinery/reagentgrinder)

		message_admins("Moved [item] into juicer")
		item.forceMove(grinder)
		grinder.holdingitems[item] = TRUE
		grinder.juice()
		message_admins("[item] juiced with the following ingredients in beaker: [grinder.beaker.reagents], expecting [item.juice_typepath]")
		TEST_ASSERT((grinder.beaker.reagents != item.juice_typepath), "No reagents in beaker after attempted juicing in [item], supposed to have [item.juice_typepath]!")
		QDEL_NULL(item)
