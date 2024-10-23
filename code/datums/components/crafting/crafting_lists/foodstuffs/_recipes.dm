///Ok foodstuffs act kinda in a funky way, as their category is pre-defined in here as you can see, so nonly the subcategory needs to be defined!

/datum/crafting_recipe/food
	var/real_parts
	category = CAT_FOOD

/datum/crafting_recipe/food/on_craft_completion(mob/user, atom/result)
	if(user.mind)
		ADD_TRAIT(result, TRAIT_FOOD_CHEF_MADE, REF(user.mind))

/datum/crafting_recipe/food/New()
	real_parts = parts.Copy()
	parts |= reqs
