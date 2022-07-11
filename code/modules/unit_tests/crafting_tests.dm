/datum/unit_test/validate_crafting_categories/Run()
	var/list/failing = list()
	world.log << "testing crafting recipes"
	for(var/datum/crafting_recipe/recipe as() in subtypesof(/datum/crafting_recipe))
		world.log << "Checking [recipe.type]"
		if(recipe.category == CAT_NONE && recipe.subcategory != CAT_NONE)
			failing += "[recipe.type]"
	if(!length(failing))
		return
	Fail("The following crafting recipes have set a subcategory without setting the category: [failing.Join(" \n")]")
