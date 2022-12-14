#define ANTAGONISM_MINIMAL_TIME 180 // 1 is identical to 1 min in DB

/// checks if antagonism configuration has been set
/proc/check_antagonism_config(mob/M)
	if (!CONFIG_GET(flag/use_exp_tracking))
		return FALSE // if we don't exp tracking, no way to track playtime. returns FALSE
	if (!CONFIG_GET(flag/use_exp_track_for_antagonism_behavior))
		return FALSE // if this system is not used in config, returns FALSE
	if(length(M.mind.antag_datums))
		return FALSE // antags shouldn't be restricted by this.
	return TRUE

/// prevents non-antag griefing - returns TRUE if they are eligible to do so
/proc/check_antagonism_minimal_playtime(mob/M, behavior="unknown activity", req_time=ANTAGONISM_MINIMAL_TIME)
	if(!check_antagonism_config(M))
		return TRUE

	// copy-paste from `job_report.dm`
	var/client/owner = M.client
	var/list/play_records = owner.prefs.exp
	if (!length(play_records.len))
		owner.set_exp_from_db()
		play_records = owner.prefs.exp
		if (length(play_records.len))
			return TRUE // having nothing seems DB is broken. returns TRUE anyway.
	var/playing_time = play_records[EXP_TYPE_LIVING]
	if(playing_time >= req_time)
		message_admins("[ADMIN_LOOKUPFLW(M)] tried '[behavior]' - they are not antag, but accepted with [playing_time] minutes playing time.")
		log_admin("[key_name(M)] tried '[behavior]' - they are not antag, but accepted with [playing_time] minutes playing time.")
		return TRUE

	message_admins("[ADMIN_LOOKUPFLW(M)] tried '[behavior]', but it has been blocked as they are not antag, and are below the minimum playtime threshold. ([playing_time] minutes)")
	log_admin("[key_name(M)] tried '[behavior]', but it has been blocked as they are not antag, and are below the minimum playtime threshold. ([playing_time] minutes)")
	return FALSE

/obj/item/clothing/mask/cigarette/proc/check_cigar_antagonism(mob/living/carbon/user)
	if(!check_antagonism_config(user))
		return FALSE
	var/mob/M = get_mob_by_ckey(reagents.fingerprint_transfer)
	if(length(M.mind.antag_datums)) // if the injector is an antag, it will be allowed
		return FALSE

	for(var/each_reagent in GLOB.restricted_reagents)
		if(locate(each_reagent) in reagents.reagent_list)
			if((src != user.wear_mask) && ((fingerprintslast == reagents.fingerprint_transfer) || (fingerprintslast == user.ckey)))
				if(!check_antagonism_minimal_playtime(user, "lighting an explosive cigar on someone's mouth"))
					message_admins("[ADMIN_LOOKUPFLW(user)] has been force-ghosted. explosive cigar is automatically removed.")
					log_game("[key_name(user)] has been force-ghosted. explosive cigar is automatically removed.")
					user.log_message("[key_name(user)] has been force-ghosted. explosive cigar is automatically removed.", LOG_GAME)
					user.ghostize(FALSE)
					if(reagents.fingerprint_transfer != fingerprintslast)
						message_admins("[ADMIN_LOOKUPFLW(M)] has been force-ghosted. explosive cigar is made by them.")
						log_game("[key_name(M)] has been force-ghosted. explosive cigar is made by them.")
						M.log_message("[key_name(user)] has been force-ghosted. explosive cigar is made by them.", LOG_GAME)
						to_chat(M, "<span class='boldwarning'>You have been ghostized because the explosive cigar you made has been abused in-game. Don't help anyone to make an explosive cigar next time. Please call an admin if it was in an error.</span>")
						M.ghostize(FALSE)
					return TRUE
	return FALSE

#undef ANTAGONISM_MINIMAL_TIME
