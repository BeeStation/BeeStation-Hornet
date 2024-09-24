/datum/manifest
	/// All of the crew records.
	var/list/general = list()
	/// This list tracks characters spawned in the world and cannot be modified in-game. Currently referenced by respawn_character().
	var/list/locked = list()
	//List used entirely just for cloning.
	var/list/cloning = list()
	/// Total number of security rapsheet prints. Changes the header.
	var/print_count = 0

/// Builds the list of crew records for all crew members.
/datum/manifest/proc/build()
	for(var/i in GLOB.new_player_list)
		var/mob/dead/new_player/readied_player = i
		if(readied_player.new_character)
			log_manifest(readied_player.ckey,readied_player.new_character.mind,readied_player.new_character)
		if(ishuman(readied_player.new_character))
			inject(readied_player.new_character)
		CHECK_TICK

/// Gets the current manifest.
/datum/manifest/proc/get_manifest()
	/// assoc-ing to head names, so that we give their name an officer mark on crew manifest
	var/static/list/heads
	if(!heads) // do not do this in pre-runtime.
		heads = make_associative(SSdepartment.get_jobs_by_dept_id(DEPT_NAME_COMMAND))
	/// Takes a result of each crew data in a format
	var/list/manifest_out = list()

	for(var/datum/record/crew/target in GLOB.manifest.general)
		var/name = target.name
		var/rank = target.rank
		var/hud = target.hud
		var/dept_bitflags = target.active_department
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

/datum/manifest/proc/inject(mob/living/carbon/human/person)
	set waitfor = FALSE

	var/mutable_appearance/character_appearance = new(person.appearance)
	var/datum/dna/stored/record_dna = new()
	person.dna.copy_dna(record_dna)
	var/person_gender = "Other"
	if(person.gender == "male")
		person_gender = "Male"
	if(person.gender == "female")
		person_gender = "Female"
	var/assignment = person.mind.assigned_role
	var/datum/bank_account/bank_account = person.get_bank_account()

	var/datum/record/locked/lockfile = new(
		age = person.age,
		blood_type = record_dna.blood_type,
		character_appearance = character_appearance,
		dna_string = record_dna.unique_enzymes,
		fingerprint = md5(record_dna.uni_identity),
		gender = person_gender,
		initial_rank = assignment,
		name = person.real_name,
		rank = assignment,
		species = record_dna.species.name,
		// Locked specifics
		dna_ref = record_dna,
		mind_ref = person.mind,
	)

	new /datum/record/crew(
		age = person.age,
		blood_type = record_dna.blood_type,
		character_appearance = character_appearance,
		dna_string = record_dna.unique_enzymes,
		fingerprint = md5(record_dna.uni_identity),
		gender = person_gender,
		initial_rank = assignment,
		name = person.real_name,
		rank = assignment,
		species = record_dna.species.name,
		active_department = bank_account.active_departments,
		// Crew specific
		lock_ref = REF(lockfile),
		major_disabilities = person.get_quirk_string(FALSE, CAT_QUIRK_MAJOR_DISABILITY, from_scan = TRUE),
		major_disabilities_desc = person.get_quirk_string(TRUE, CAT_QUIRK_MAJOR_DISABILITY),
		minor_disabilities = person.get_quirk_string(FALSE, CAT_QUIRK_MINOR_DISABILITY, from_scan = TRUE),
		minor_disabilities_desc = person.get_quirk_string(TRUE, CAT_QUIRK_MINOR_DISABILITY),
		quirk_notes = person.get_quirk_string(TRUE, CAT_QUIRK_NOTES),
	)

/// Edits the rank of the found record.
/datum/manifest/proc/modify(name, assignment)
	var/datum/record/crew/target = find_record(name)
	if(!target)
		return

	target.rank = assignment

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
		crew_record["ref"] = REF(gen_record)
		crew_record["name"] = gen_record.name
		crew_record["physical_health"] = gen_record.physical_status
		crew_record["mental_health"] = gen_record.mental_status
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
		crew_record["ref"] = REF(sec_record)
		crew_record["name"] = sec_record.name
		crew_record["status"] = sec_record.wanted_status
		crew_record["crimes"] = length(sec_record.crimes)
		security_records_out += list(crew_record)
	return security_records_out
