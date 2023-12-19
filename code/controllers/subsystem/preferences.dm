/// The subsystem used to serialize preferences when marked dirty.
/// This will mostly be saving preference changes that happen outside the UI.
SUBSYSTEM_DEF(preferences)
	name = "Preference Serialization"
	priority = FIRE_PRIORITY_PREFERENCES
	flags = SS_POST_FIRE_TIMING|SS_NO_INIT
	runlevels = RUNLEVEL_INIT|RUNLEVEL_LOBBY|RUNLEVELS_DEFAULT
	// Length we should queue preferences writes against - prevents short-term unnecessary rewrites to the database.
	wait = 5 SECONDS

	/// A list ckeys -> weakrefs to preference datums waiting to be serialized.
	var/list/datums = list()

/datum/controller/subsystem/preferences/proc/queue_write(datum/preferences/prefs)
	if(!prefs.parent?.ckey) // No client ckey? No write. Prefs are written on logout anyway due to the UI closing.
		return
	var/ckey = ckey(prefs.parent.ckey)
	if(datums[ckey]) // already queued
		return
	datums[ckey] = WEAKREF(prefs)
	prefs.ui_update() // for queue preview
	log_preferences("[ckey]: Queued preference write.")

/datum/controller/subsystem/preferences/fire(resumed)
	for(var/ckey in datums)
		var/datum/weakref/ref = datums[ckey]
		var/datum/preferences/prefs = ref.resolve()
		if(QDELETED(prefs))
			datums -= ckey
			continue
		if(prefs.save_locked) // don't save right now, but stay queued
			continue
		prefs.save_locked = TRUE
		if(prefs.ready_to_save_character())
			prefs.save_character()
		if(prefs.ready_to_save_player())
			prefs.save_preferences()
		prefs.save_locked = FALSE
		datums -= ckey
		prefs.ui_update() // for queue preview
		if (MC_TICK_CHECK)
			return
