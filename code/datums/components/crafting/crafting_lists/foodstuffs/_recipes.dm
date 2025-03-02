///Ok foodstuffs act kinda in a funky way, as their category is pre-defined in here as you can see, so nonly the subcategory needs to be defined!

/datum/crafting_recipe/food
	var/real_parts
	var/total_nutriment_factor

/datum/crafting_recipe/food/New()
	if(ispath(result, /obj/item/food))
		var/obj/item/food/result_food = new result
		for(var/datum/reagent/consumable/nutriment as anything in result_food.food_reagents)
			total_nutriment_factor += initial(nutriment.nutriment_factor) * result_food.food_reagents[nutriment]
	real_parts = parts.Copy()
	parts |= reqs

/datum/crafting_recipe/food/on_craft_completion(mob/user, atom/result)
	SHOULD_CALL_PARENT(TRUE)
	. = ..()
	if(istype(result) && !isnull(user.mind))
		ADD_TRAIT(result, TRAIT_FOOD_CHEF_MADE, REF(user.mind))
