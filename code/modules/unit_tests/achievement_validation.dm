/datum/unit_test/achievement_validation/Run()
	// The category types, which have subtypes of their own
	var/list/type_blacklist = list(/datum/award/achievement/misc, /datum/award/achievement/boss)

	var/list/used_ids = list()
	for(var/typepath in subtypesof(/datum/award/achievement) - type_blacklist)
		var/datum/award/achievement/A = typepath

		TEST_ASSERT((!initial(A.database_id) in used_ids),
			"Reused database_id \"[initial(A.database_id)]\" on achievement [A]")
		else
			used_ids += initial(A.database_id)

		TEST_ASSERT((!length(initial(A.name)) > 64),
			"Achievement name too long (max 64, got [length(initial(A.name))]) on achievement [A]")

		TEST_ASSERT((!length(initial(A.desc)) > 512),
			"Achievement description too long (max 512, got [length(initial(A.desc))]) on achievement [A]")

		TEST_ASSERT((!initial(A.database_id) > 32),
			"Achievement database_id too long (max 32, got [length(initial(A.database_id))]) on achievement [A]")

		TEST_ASSERT((!initial(A.achievement_version) < 0 || initial(A.achievement_version) > 32767),
			"Achievement version out of range (0-32767, got [initial(A.achievement_version)]) on achievement [A]")
