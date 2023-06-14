/// Verifies that antag datums have banning_keys.
/datum/unit_test/antag_datum_sanity

/datum/unit_test/antag_datum_sanity/Run()
	for (var/datum/antagonist/antag as anything in subtypesof(/datum/antagonist))
		if(ispath(antag, /datum/antagonist/custom))
			continue
		var/name = initial(antag.name)
		if (!name || name == "Antagonist")
			Fail("[antag] has no name set!")
		if (!initial(antag.banning_key))
			Fail("[antag] has no banning_key set!")
		var/category = initial(antag.antagpanel_category)
		if (initial(antag.show_in_antagpanel) && (!category || category == "Uncategorized"))
			Fail("[antag] shows in the antag panel, but has no category set!")
