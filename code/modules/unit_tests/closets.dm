/// Checks that the length of the initial contents of a closet doesn't exceed its storage capacity.
/// Also checks that nothing inside that isn't immediate is a steal objective.
/datum/unit_test/closets

/datum/unit_test/closets/Run()
	var/list/all_closets = subtypesof(/obj/structure/closet)
	//Supply pods. They are sent, crashed, opened and never closed again. They also cause exceptions in nullspace.
	all_closets -= typesof(/obj/structure/closet/supplypod)
	var/list/failures = list()

	var/list/obj_item_paths = list()

	for (var/datum/objective_item/objective_item_path as() in subtypesof(/datum/objective_item))
		if (!initial(objective_item_path.require_item_spawns_at_roundstart))
			continue
		obj_item_paths |= initial(objective_item_path.targetitem)

	for(var/closet_type in all_closets)
		var/obj/structure/closet/closet = allocate(closet_type)

		// Copy is necessary otherwise closet.contents - immediate_contents returns an empty list
		var/list/immediate_contents = closet.contents.Copy()

		closet.PopulateContents()
		var/contents_len = length(closet.contents)

		if(contents_len > closet.storage_capacity)
			failures += "Initial Contents of [closet.type] ([contents_len]) exceed its storage capacity ([closet.storage_capacity])."

		for (var/obj/item/item in closet.contents - immediate_contents)
			if (item.type in obj_item_paths)
				failures += "[closet_type] contains a steal objective [item.type] in PopulateContents(). Move it to populate_contents_immediate()."
			if (item.resistance_flags & INDESTRUCTIBLE)
				failures += "[closet_type] contains the indestructible item, [item.type], in PopulateContents(). This should be in populate_contents_immediate() instead."
	if (length(failures))
		Fail(jointext(failures, "\n"))
