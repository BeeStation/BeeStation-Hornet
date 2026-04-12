/datum/manifest
	/// All of the crew records.
	var/list/general = list()
	/// This list tracks characters spawned in the world and cannot be modified in-game. Currently referenced by respawn_character().
	var/list/locked = list()
	/// Total number of security rapsheet prints. Changes the header.
	var/print_count = 0

/// Builds the list of crew records for all crew members.
/datum/manifest/proc/build()
	for(var/i in GLOB.auth_new_player_list)
		var/mob/dead/new_player/authenticated/readied_player = i
		if(readied_player.new_character)
			log_manifest(readied_player.ckey,readied_player.new_character.mind,readied_player.new_character)
		if(ishuman(readied_player.new_character))
			inject(readied_player.new_character, TRUE)
		CHECK_TICK
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CREW_MANIFEST_UPDATE)

/// Gets the current manifest.
/datum/manifest/proc/get_manifest()
	/// assoc-ing to head names, so that we give their name an officer mark on crew manifest
	var/static/list/heads
	if(!heads) // do not do this in pre-runtime.
		heads = make_associative(SSdepartment.get_jobs_by_dept_id(DEPT_NAME_COMMAND))
	/// Takes a result of each crew data in a format
	var/list/manifest_out = list()

	for(var/datum/record/crew/person_record in GLOB.manifest.general)
		var/name = person_record.name
		var/rank = person_record.rank
		var/hud = person_record.hud
		var/dept_bitflags = person_record.active_department
		var/entry = list("name" = name, "rank" = rank, "hud" = hud)
		if(dept_bitflags)
			for(var/datum/department_group/department as anything in SSdepartment.get_department_by_bitflag(dept_bitflags))
				LAZYINITLIST(manifest_out[department.dept_id])
				// Append to beginning of list if captain or department head
				var/put_at_top = (hud == JOB_HUD_CAPTAIN) || (hud == JOB_HUD_ACTINGCAPTAIN) || (department.dept_id != DEPT_NAME_COMMAND && heads[rank])
				var/list/_internal = manifest_out[department.dept_id]
				_internal.Insert(put_at_top, list(entry))
		else
			LAZYINITLIST(manifest_out["Misc"])
			var/put_at_top = (hud == JOB_HUD_CAPTAIN) || (hud == JOB_HUD_ACTINGCAPTAIN) || (heads[rank])
			var/list/_internal = manifest_out["Misc"]
			_internal.Insert(put_at_top, list(entry))

	// 'manifest_out' is not sorted.
	var/list/sorted_out = list()
	for(var/datum/department_group/department as anything in SSdepartment.sorted_department_for_manifest)
		if(isnull(manifest_out[department.dept_id]))
			continue
		sorted_out[department.manifest_category_name] = manifest_out[department.dept_id] // this also changes a department name.
	return sorted_out

/// Returns the manifest as an html.
/datum/manifest/proc/get_html(monochrome = FALSE)
	var/list/manifest = get_manifest()
	var/dat = {"
	<head><style>
		.manifest {border-collapse:collapse;}
		.manifest td, th {border:1px solid [monochrome?"black":"#DEF; background-color:white; color:black"]; padding:.25em}
		.manifest th {height: 2em; [monochrome?"border-top-width: 3px":"background-color: #48C; color:white"]}
		.manifest tr.head th { [monochrome?"border-top-width: 1px":"background-color: #488;"] }
		.manifest tr.alt td {[monochrome?"border-top-width: 2px":"background-color: #DEF"]}
	</style></head>
	<table class="manifest" width='350px'>
	<tr class='head'><th>Name</th><th>Rank</th></tr>
	"}
	for(var/department in manifest)
		var/list/entries = manifest[department]
		dat += "<tr><th colspan=3>[department]</th></tr>"
		//JUST
		var/even = FALSE
		for(var/entry in entries)
			var/list/entry_list = entry
			dat += "<tr[even ? " class='alt'" : ""]><td>[entry_list["name"]]</td><td>[entry_list["rank"]]</td></tr>"
			even = !even

	dat += "</table>"
	dat = replacetext(dat, "\n", "")
	dat = replacetext(dat, "\t", "")
	return dat

/datum/manifest/proc/inject(mob/living/carbon/human/person, nosignal = FALSE)
	set waitfor = FALSE

	// We need to compile the overlays now, otherwise we're basically copying an empty icon.
	COMPILE_OVERLAYS(person)
	var/mutable_appearance/character_appearance = new(person.appearance)
	var/datum/dna/stored/record_dna = new()
	person.dna.copy_dna(record_dna)
	var/gender_string = "Other"
	if(person.gender == MALE)
		gender_string = "Male"
	if(person.gender == FEMALE)
		gender_string = "Female"
	var/assignment = person.mind?.assigned_role
	if(isnull(assignment))
		assignment = "None"
	var/datum/bank_account/bank_account = person.get_bank_account()

	var/datum/record/locked/lockfile = new(
		RECORD_STRICT_ARGS(
			RECORD_ARG_01 = person.age, \
			RECORD_ARG_02 = record_dna.blood_type, \
			RECORD_ARG_03 = character_appearance, \
			RECORD_ARG_04 = record_dna.unique_enzymes, \
			RECORD_ARG_05 = record_dna.unique_identity, \
			RECORD_ARG_06 = md5(record_dna.unique_identity), \
			RECORD_ARG_07 = gender_string, \
			RECORD_ARG_08 = assignment, \
			RECORD_ARG_09 = person.real_name, \
			RECORD_ARG_10 = assignment, \
			RECORD_ARG_11 = record_dna.species, \
			RECORD_ARG_12 = person.get_job_id(), \
			RECORD_ARG_13 = bank_account.active_departments \
		),
		// Locked specifics
		RECORD_LOCK_STRICT_ARGS(
			RECORD_LOCK_ARG_01 = WEAKREF(record_dna), \
			RECORD_LOCK_ARG_02 = WEAKREF(person.mind), \
			RECORD_LOCK_ARG_03 = record_dna \
		)
	)

	new /datum/record/crew(
		RECORD_STRICT_ARGS(
			RECORD_ARG_01 = person.age, \
			RECORD_ARG_02 = record_dna.blood_type, \
			RECORD_ARG_03 = character_appearance, \
			RECORD_ARG_04 = record_dna.unique_enzymes, \
			RECORD_ARG_05 = record_dna.unique_identity, \
			RECORD_ARG_06 = md5(record_dna.unique_identity), \
			RECORD_ARG_07 = gender_string, \
			RECORD_ARG_08 = assignment, \
			RECORD_ARG_09 = person.real_name, \
			RECORD_ARG_10 = assignment, \
			RECORD_ARG_11 = record_dna.species, \
			RECORD_ARG_12 = person.get_job_id(), \
			RECORD_ARG_13 = bank_account.active_departments \
		),
		// Crew specific
		RECORD_CREW_STRICT_ARGS(
			RECORD_CREW_ARG_01 = FAST_REF(lockfile), \
			RECORD_CREW_ARG_02 = null, \
			RECORD_CREW_ARG_03 = person.get_quirk_string(FALSE, CAT_QUIRK_MAJOR_DISABILITY, from_scan = TRUE), \
			RECORD_CREW_ARG_04 = person.get_quirk_string(TRUE, CAT_QUIRK_MAJOR_DISABILITY), \
			RECORD_CREW_ARG_05 = person.get_quirk_string(FALSE, CAT_QUIRK_MINOR_DISABILITY, from_scan = TRUE), \
			RECORD_CREW_ARG_06 = person.get_quirk_string(TRUE, CAT_QUIRK_MINOR_DISABILITY), \
			RECORD_CREW_ARG_07 = null, \
			RECORD_CREW_ARG_08 = null, \
			RECORD_CREW_ARG_09 = person.get_quirk_string(TRUE, CAT_QUIRK_NOTES), \
			RECORD_CREW_ARG_10 = null, \
			RECORD_CREW_ARG_11 = null \
		)
	)
	if(!nosignal)
		SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CREW_MANIFEST_UPDATE)

/// Edits the rank of the found record.
/datum/manifest/proc/modify(name, assignment, hud_state)
	var/datum/record/crew/target = find_record(name, GLOB.manifest.general)
	if(!target)
		return

	target.rank = assignment
	target.hud = hud_state
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CREW_MANIFEST_UPDATE)

/**
 * Using the name to find the record, and person in reference to the body, we recreate photos for the manifest (and records).
 * Args:
 * - name - The name of the record we're looking for, which should be the name of the person.
 * - person - The mob we're taking pictures of to update the records.
 * - add_height_chart - If we should add a height chart to the background of the photo.
 */
/datum/manifest/proc/change_pictures(name, mob/living/person, add_height_chart = FALSE)
	var/datum/record/crew/target = find_record(name, GLOB.manifest.general)
	if(!target)
		return FALSE

	target.character_appearance = new(person.appearance)
	target.recreate_manifest_photos(add_height_chart)
	return TRUE

/**
 * Supporing proc for getting general records
 * and using them as pAI ui data. This gets
 * medical information - or what I would deem
 * medical information - and sends it as a list.
 *
 * @return - list(general_records_out)
 */
/datum/manifest/proc/get_general_records()
	if(!GLOB.manifest.general)
		return list()
	/// The array of records
	var/list/general_records_out = list()
	for(var/datum/record/crew/gen_record as anything in GLOB.manifest.general)
		/// The object containing the crew info
		var/list/crew_record = list()
		crew_record["record_ref"] = FAST_REF(gen_record)
		crew_record["name"] = gen_record.name
		crew_record["physical_status"] = gen_record.physical_status
		crew_record["mental_status"] = gen_record.mental_status
		general_records_out += list(crew_record)
	return general_records_out

/**
 * Supporing proc for getting secrurity records
 * and using them as pAI ui data. Sends it as a
 * list.
 *
 * @return - list(security_records_out)
 */
/datum/manifest/proc/get_security_records()
	if(!GLOB.manifest.general)
		return list()
	/// The array of records
	var/list/security_records_out = list()
	for(var/datum/record/crew/sec_record as anything in GLOB.manifest.general)
		/// The object containing the crew info
		var/list/crew_record = list()
		crew_record["record_ref"] = FAST_REF(sec_record)
		crew_record["name"] = sec_record.name
		crew_record["status"] = sec_record.wanted_status
		crew_record["crimes"] = length(sec_record.crimes)
		security_records_out += list(crew_record)
	return security_records_out
