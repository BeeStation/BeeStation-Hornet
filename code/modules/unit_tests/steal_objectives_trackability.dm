/datum/unit_test/trackable/Run()
	var/list/fails = list()
	for (var/datum/objective_item/steal/item as() in subtypesof(/datum/objective_item/steal))
		if (ispath(item, /datum/objective_item/special) || ispath(item, /datum/objective_item/stack))
			continue
		var/item_target = initial(item.special_track_type) || initial(item.targetitem)
		// Accepted ignore: AIs get deleted during init but will be trackable
		if (ispath(item_target, /mob/living/silicon/ai))
			continue
		var/atom/created = new item_target(run_loc_floor_bottom_left)
		if (!created.GetComponent(/datum/component/trackable))
			fails += "[item_target] is not trackable but is the target of a steal objective. Add the following code:\n[item_target]/ComponentInitialize()\n\t. = ..()\n\tAddComponent(/datum/component/trackable)"
		qdel(created)
	for (var/atom/a in run_loc_floor_bottom_left)
		qdel(a)
	if (length(fails))
		Fail(jointext(fails, "\n"))
