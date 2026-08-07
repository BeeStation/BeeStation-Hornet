/// Ensure every quirk has a unique icon
/datum/unit_test/quirk_icons

/datum/unit_test/quirk_icons/Run()
	var/list/used_icons = list()

	for (var/datum/quirk/quirk_type as anything in valid_subtypesof(/datum/quirk))
		var/icon = initial(quirk_type.icon)

		if (isnull(icon))
			TEST_FAIL("[quirk_type] has no icon!")
			continue

		if (icon in used_icons)
			TEST_FAIL("[icon] used in both [quirk_type] and [used_icons[icon]]!")
			continue

		used_icons[icon] = quirk_type
