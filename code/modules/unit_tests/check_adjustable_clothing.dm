/datum/unit_test/adjustable_clothing/Run()
	var/list/failing = list()
	var/list/valid_states = icon_states('icons/mob/uniform.dmi')
	for(var/obj/item/clothing/under/path as() in subtypesof(/obj/item/clothing/under))
		if(initial(path.can_adjust))
			//Check for adjustable clothing
			//Get the item colour
			var/icon_name = initial(path.item_color)
			//If not existing, get the icon state
			if(!icon_name)
				icon_name = initial(path.icon_state)
			//Check if the original icon exists (Ignore parent types)
			if(!(icon_name in valid_states))
				continue
			//Add the adjusted modifier
			icon_name = "[icon_name]_d"
			//Check for the icon
			if(!(icon_name in valid_states))
				failing += path
	if(!length(failing))
		return
	Fail("The following clothing items have can_adjust set to true, but have no adjusted icon state: [failing.Join(" \n")]")
