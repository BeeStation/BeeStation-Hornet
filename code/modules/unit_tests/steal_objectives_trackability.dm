/datum/unit_test/trackable/Run()
	for (var/datum/objective_item/steal/item as anything in subtypesof(/datum/objective_item/steal))
		var/item_path = initial(item.special_track_type) || initial(item.targetitem)
		// Accepted ignore: AIs get deleted during init but will be trackable
		if (ispath(item_path, /mob/living/silicon/ai))
			continue
		// can't use allocate() because we need to force qdel the item (nuclear authentication disk has the stationloving component)
		var/atom/created = new item_path(run_loc_floor_bottom_left)
		if (!GLOB.tracks_by_type[item_path])
			TEST_FAIL("[item_path] is not trackable but is the target of a steal objective. Give it the /datum/element/trackable element.")
		qdel(created, force = TRUE)
