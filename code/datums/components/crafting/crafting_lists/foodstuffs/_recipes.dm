///Ok foodstuffs act kinda in a funky way, as their category is pre-defined in here as you can see, sononly the subcategory needs to be defined!

/datum/crafting_recipe/food
	var/real_parts
	category = CAT_FOOD

/datum/crafting_recipe/food/New()
	real_parts = parts.Copy()
	parts |= reqs
