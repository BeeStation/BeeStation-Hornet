/datum/unit_test/limbsanity

/datum/unit_test/limbsanity/Run()
	for(var/path in subtypesof(/obj/item/bodypart) - list(/obj/item/bodypart/arm, /obj/item/bodypart/leg)) /// removes the abstract items.
		var/obj/item/bodypart/part = new path(null)
		if(part.is_dimorphic)
			if(!icon_exists(UNLINT(part.should_draw_greyscale ? part.icon_greyscale : part.icon_static), "[part.limb_id]_[part.body_zone]_m"))
				Fail("[path] does not have a valid icon for male variants")
			if(!icon_exists(UNLINT(part.should_draw_greyscale ? part.icon_greyscale : part.icon_static), "[part.limb_id]_[part.body_zone]_f"))
				Fail("[path] does not have a valid icon for female variants")
		else if(!icon_exists(UNLINT(part.should_draw_greyscale ? part.icon_greyscale : part.icon_static), "[part.limb_id]_[part.body_zone]"))
			Fail("[path] does not have a valid icon")
