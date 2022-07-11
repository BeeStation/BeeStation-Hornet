/datum/unit_test/validate_crafting_categories/Run()
	var/list/failing = list()
	for(var/datum/crafting_recipe/recipe as() in subtypesof(/datum/crafting_recipe))
		if(initial(recipe.category) == CAT_NONE && initial(recipe.subcategory) != CAT_NONE)
			failing += "[recipe]"
	if(!length(failing))
		return
	Fail("The following crafting recipes have set a subcategory without setting the category: [failing.Join(" \n")]")
