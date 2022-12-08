#define ANTAGONISM_MINIMAL_TIME 5 // 1 is identical to 1 min in DB

/// prevents non-antag griefing - returns TRUE if they are eligible to do so
/proc/check_antagonism_minimal_playtime(mob/M, behavior="unknown activity", req_time=ANTAGONISM_MINIMAL_TIME)
	world.log << "checking antagonism"
	if (!CONFIG_GET(flag/use_exp_track_for_antagonism_behavior))
		return TRUE // if this system is not used in config, returns TRUE
	if (!CONFIG_GET(flag/use_exp_tracking))
		return TRUE // if we don't exp tracking, no way to track playtime. returns TRUE
	if(locate(/datum/antagonist) in M.mind.antag_datums)
		return TRUE // antag shouldn't be restricted by this.

	// copy-paste from `job_report.dm`
	var/client/owner = M.client
	var/list/play_records = owner.prefs.exp
	if (!play_records.len)
		owner.set_exp_from_db()
		play_records = owner.prefs.exp
		if (!play_records.len)
			return TRUE // having nothing seems DB is broken. returns TRUE anyway.
	var/playing_time = play_records[EXP_TYPE_LIVING]
	if(playing_time >= req_time)
		message_admins("[ADMIN_LOOKUPFLW(M)] tried '[behavior]' - they are not antag, but accepted with [playing_time] minutes playing time.")
		log_admin("[key_name(M)] tried '[behavior]' - they are not antag, but accepted with [playing_time] minutes playing time.")
		return TRUE

	message_admins("[ADMIN_LOOKUPFLW(M)] tried '[behavior]', but it is rejected as they are not antag, and have not enough playtime. ([playing_time] minutes)")
	log_admin("[key_name(M)] tried '[behavior]', but it is rejected as they are not antag, and have not enough playtime. ([playing_time] minutes)")
	return FALSE
