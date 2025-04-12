/*
 * Scamps are minor antagonists so they can be used alongside other compatible gamemodes with ease.
 * This code is what creates them.
 */

/datum/special_role/scamp
	attached_antag_datum = /datum/antagonist/scamp
	spawn_mode = SPAWNTYPE_ROUNDSTART
	probability = 50
	proportion = 1
	latejoin_allowed = TRUE
	protected_jobs = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_WARDEN, JOB_NAME_DETECTIVE, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN)
	role_name = "Scamp"
	preference_type = /datum/role_preference/antagonist/scamp


/datum/special_role/scamp/add_antag_status_to(datum/mind/M)
	addtimer(CALLBACK(src, PROC_REF(reveal_antag_status), M), rand(10,100))

/datum/special_role/scamp/proc/reveal_antag_status(datum/mind/M)
	M.special_role = role_name
	var/datum/antagonist/special/A = M.add_antag_datum(new attached_antag_datum())
	return A
