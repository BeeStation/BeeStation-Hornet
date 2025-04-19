///Ok foodstuffs act kinda in a funky way, as their category is pre-defined in here as you can see, so nonly the subcategory needs to be defined!

/datum/crafting_recipe/food
	mass_craftable = TRUE
	crafting_flags = parent_type::crafting_flags | CRAFT_TRANSFERS_REAGENTS | CRAFT_CLEARS_REAGENTS
	/// A rough equivilance for how much nutrition this recipe's result will provide
	var/total_nutriment_factor = 0

/datum/crafting_recipe/food/on_craft_completion(mob/user, atom/result)
	SHOULD_CALL_PARENT(TRUE)
	. = ..()
	if(istype(result) && !isnull(user.mind))
		ADD_TRAIT(result, TRAIT_FOOD_CHEF_MADE, REF(user.mind))

/datum/crafting_recipe/food/New()
	. = ..()
	if(ispath(result, /obj/item/food))
		var/obj/item/food/result_food = new result()
		for(var/datum/reagent/consumable/nutriment as anything in result_food.food_reagents)
			total_nutriment_factor += initial(nutriment.nutriment_factor) * result_food.food_reagents[nutriment]
		qdel(result_food)

	parts |= reqs

/datum/crafting_recipe/food/crafting_ui_data()
	var/list/data = list()

	if(ispath(result, /obj/item/food))
		var/obj/item/food/item = result
		data["foodtypes"] = bitfield_to_list(initial(item.foodtypes), FOOD_FLAGS)
	data["nutriments"] = total_nutriment_factor

	return data
