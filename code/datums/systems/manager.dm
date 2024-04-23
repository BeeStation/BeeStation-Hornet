// See initialization order in /code/game/world.dm
GLOBAL_REAL(SysMgr, /datum/system_manager) = new


/**
 * Initializes all data systems and keeps track of them.
 */
/datum/system_manager
	/// List of managed data systems, post initialization.
	var/list/datum/system/managed = list()


/datum/system_manager/New()
	init_subtypes(/datum/system, managed)

// mimics subsystem
/datum/system_manager/proc/stat_entry()
	var/list/tab_data = list()
	tab_data["Datasystem Manager"] = list(
		text="Edit",
		action = "statClickDebug",
		params=list(
			"targetRef" = FAST_REF(src),
			"class"="controller",
		),
		type=STAT_BUTTON,
	)
	return tab_data
