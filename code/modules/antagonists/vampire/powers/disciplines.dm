/datum/discipline
	///Name of this Discipline.
	var/name = "ERROR"
	///Text description of this Discipline.
	var/discipline_explanation = "ERROR"

	///Icon for this Discipline
	var/icon_state = "error"

	// Lists of abilities granted per level. Set to null if unused.
	var/list/level_1 = null	// Level 1
	var/list/level_2 = null	// Level 2
	var/list/level_3 = null	// Level 3
	var/list/level_4 = null	// Level 4
	var/list/level_5 = null	// Level 5

	// Backend shit
	///What level the user has in this Discipline. In case we want to add persistant effects to having a discipline.
	var/level = 1
	///The mob that owns and is using this Discipline.
	var/mob/living/carbon/human/owner
	/// The owner's vampire datum
	var/datum/antagonist/vampire/vampiredatum_discipline

/datum/discipline/Destroy()
	vampiredatum_discipline = null
	. = ..()

/**
 * Needs to be called after we have been created and assigned to a vampire.
 */
/datum/discipline/proc/assigned_to_owner(mob/living/carbon/carbon_owner)
	owner = carbon_owner
	vampiredatum_discipline = IS_VAMPIRE(carbon_owner)

/datum/discipline/Destroy()
	vampiredatum_discipline = null
	. = ..()

// 0 is null, and false is also null, which is 0. So, we gotta use 1 as the starting point that doesn't have any abilities.
// Yes this means all levels everywhere else do not match up with this.
// You know, null kind of exists so we can tell if there is no data vs it being a 0. Just a thought, lummox.
// You can also give it a string "current" and it'll return the current set!
/datum/discipline/proc/get_abilities_with_level(what_level)
	if(what_level == "current")
		what_level = level

	if(what_level == "next")
		what_level = level + 1

	switch(what_level)
		if(1)				// 0, null, do not change
			return null
		if(2)
			return level_1
		if(3)
			return level_2
		if(4)
			return level_3
		if(5)
			return level_4
		if(6)
			return level_5
		else
			return null

/// Can't go over 5 even if you define more
/datum/discipline/proc/level_up()
	if(level >= 6)	// it's six cuz 1 is null, yadda yadda
		level = 6
		return FALSE
	else
		level++
		return TRUE

// For example, extra damage for potence.
/datum/discipline/proc/apply_discipline_quirks(datum/antagonist/vampire/clan_owner)
	return
