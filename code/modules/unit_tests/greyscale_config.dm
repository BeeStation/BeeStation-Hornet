/// Makes sure items using GAGS have all the icon states needed to work
/datum/unit_test/greyscale_item_icon_states

/datum/unit_test/greyscale_item_icon_states/Run()
	for(var/obj/item/item_path as anything in subtypesof(/obj/item))
		var/held_icon_state = initial(item_path.inhand_icon_state) || initial(item_path.icon_state)

		var/datum/greyscale_config/lefthand = SSgreyscale.configurations["[initial(item_path.greyscale_config_inhand_left)]"]
		if(lefthand && !lefthand.icon_states[held_icon_state])
			Fail("[lefthand.DebugName()] is missing a sprite for the held lefthand for [item_path]. Expected icon state: '[held_icon_state]'")

		var/datum/greyscale_config/righthand = SSgreyscale.configurations["[initial(item_path.greyscale_config_inhand_right)]"]
		if(righthand && !righthand.icon_states[held_icon_state])
			Fail("[righthand.DebugName()] is missing a sprite for the held righthand for [item_path]. Expected icon state: '[held_icon_state]'")

		var/datum/greyscale_config/worn = SSgreyscale.configurations["[initial(item_path.greyscale_config_worn)]"]
		var/worn_icon_state = initial(item_path.worn_icon_state) || initial(item_path.icon_state)
		if(worn && !worn.icon_states[worn_icon_state])
			Fail("[worn.DebugName()] is missing a sprite for the worn overlay for [item_path]. Expected icon state: '[worn_icon_state]'")

		var/datum/greyscale_config/belt = SSgreyscale.configurations["[initial(item_path.greyscale_config_belt)]"]
		var/belt_icon_state = initial(item_path.belt_icon_state) || initial(item_path.icon_state)
		if(belt && !belt.icon_states[belt_icon_state])
			Fail("[belt.DebugName()] is missing a sprite for the belt overlay for [item_path]. Expected icon state: '[belt_icon_state]'")

/// Makes sure objects using greyscale configs have, if any, the correct number of colors
/datum/unit_test/greyscale_color_count

/datum/unit_test/greyscale_color_count/Run()
	for(var/atom/thing as anything in subtypesof(/atom))
		var/datum/greyscale_config/config = SSgreyscale.configurations["[initial(thing.greyscale_config)]"]
		if(!config)
			continue
		var/list/colors = splittext(initial(thing.greyscale_colors), "#")
		if(!length(colors))
			continue
		var/number_of_colors = length(colors) - 1
		if(config.expected_colors != number_of_colors)
			Fail("[thing] has the wrong amount of colors configured for [config.DebugName()]. Expected [config.expected_colors] but only found [number_of_colors].")
