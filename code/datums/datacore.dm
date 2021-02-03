/datum/datacore
	var/medical[] = list()
	var/medicalPrintCount = 0
	var/general[] = list()
	var/security[] = list()
	var/securityPrintCount = 0
	var/securityCrimeCounter = 0
	//This list tracks characters spawned in the world and cannot be modified in-game. Currently referenced by respawn_character().
	var/locked[] = list()
	var/datum/callback/roundend_callback //Used to call upload_security_records() on roundend

/datum/datacore/New()
	..()
	roundend_callback = CALLBACK(src,.proc/upload_security_records)
	SSticker.OnRoundend(roundend_callback)

/datum/datacore/Destroy() //This currently never happens, but better to future-proof it
	SSticker.round_end_events -= roundend_callback
	. = ..()

/datum/data
	var/name = "data"

/datum/data/record
	name = "record"
	var/list/fields = list()

/datum/data/record/Destroy()
	if(src in GLOB.data_core.medical)
		GLOB.data_core.medical -= src
	if(src in GLOB.data_core.security)
		GLOB.data_core.security -= src
		for(var/datum/data/crime/C as() in fields["crim"])
			GLOB.data_core.purge_db_record(src, C)
	if(src in GLOB.data_core.general)
		GLOB.data_core.general -= src
	if(src in GLOB.data_core.locked)
		GLOB.data_core.locked -= src

	for(var/field in fields)
		if(islist(fields[field]))
			if(field == "crim") //Handled above
				continue
			for(var/datum/data/D in fields[field])
				qdel(D)
			UNLINT(fields[field].Cut()) //We check if it's a list above, so I assume it's safe to unlint this
	. = ..()

/datum/data/crime
	name = "crime"
	var/crimeName = ""
	var/crimeDetails = ""
	var/author = ""
	var/authorCkey = ""
	var/time = ""
	var/fine = 0
	var/paid = 0
	var/dataId = 0
	var/fromDB = FALSE
	var/had_special_role = FALSE

/datum/datacore/proc/createCrimeEntry(cname = "", cdetails = "", author = "", time = "", fine = 0, author_ckey = "", from_db = FALSE)
	var/datum/data/crime/c = new /datum/data/crime
	c.crimeName = cname
	c.crimeDetails = cdetails
	c.author = author
	c.time = time
	c.fine = fine
	c.paid = 0
	c.dataId = ++securityCrimeCounter
	c.authorCkey = author_ckey
	c.fromDB = from_db
	return c

/datum/datacore/proc/addCitation(id = "", datum/data/crime/crime)
	for(var/datum/data/record/R as() in security)
		if(R.fields["id"] == id)
			var/list/crimes = R.fields["citation"]
			crimes |= crime
			return

/datum/datacore/proc/removeCitation(id, cDataId)
	for(var/datum/data/record/R as() in security)
		if(R.fields["id"] == id)
			var/list/crimes = R.fields["citation"]
			for(var/datum/data/crime/crime in crimes)
				if(crime.dataId == text2num(cDataId))
					crimes -= crime
					qdel(crime)
					return

/datum/datacore/proc/payCitation(id, cDataId, amount)
	for(var/datum/data/record/R as() in security)
		if(R.fields["id"] == id)
			var/list/crimes = R.fields["citation"]
			for(var/datum/data/crime/crime in crimes)
				if(crime.dataId == text2num(cDataId))
					crime.paid = crime.paid + amount
					var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_SEC)
					D.adjust_money(amount)
					return

/**
  * Adds crime to security record.
  *
  * Is used to add single crime to someone's security record.
  * Arguments:
  * * id - record id.
  * * datum/data/crime/crime - premade array containing every variable, usually created by createCrimeEntry.
  */
/datum/datacore/proc/addCrime(id = "", datum/data/crime/crime)
	for(var/datum/data/record/R as() in security)
		if(R.fields["id"] == id)
			var/list/crimes = R.fields["crim"]

			if(R.fields["ckey"])
				var/mob/M = get_mob_by_ckey(R.fields["ckey"])
				if(M?.mind?.special_role)
					crime.had_special_role = TRUE

			crimes |= crime
			return

/**
  * Deletes crime from security record.
  *
  * Is used to delete single crime to someone's security record.
  * Arguments:
  * * id - record id.
  * * cDataId - id of already existing crime.
  */
/datum/datacore/proc/removeCrime(id, cDataId)
	for(var/datum/data/record/R as() in security)
		if(R.fields["id"] == id)
			var/list/crimes = R.fields["crim"]
			for(var/datum/data/crime/crime in crimes)
				if(crime.dataId == text2num(cDataId))
					purge_db_record(R, crime)
					crimes -= crime
					qdel(crime)
					return

//Removes a persistent security record crime from the DB
/datum/datacore/proc/purge_db_record(datum/data/record/R, datum/data/crime/crime)
	if(crime.fromDB && R.fields["ckey"] && SSdbcore.Connect()) //We can ignore the config because it has to be enabled for fromDB to be true
		var/datum/DBQuery/query_remove_crime = SSdbcore.NewQuery(
		"DELETE FROM [format_table_name("criminal_records")] WHERE ckey = :ckey AND author_ckey = :author_ckey AND crime = :crime AND details = :details",
		list("ckey" = R.fields["ckey"], "author_ckey" = crime.authorCkey, "crime" = crime.crimeName, "details" = crime.crimeDetails))

		query_remove_crime.Execute(async = TRUE)
		qdel(query_remove_crime)

/**
  * Adds details to a crime.
  *
  * Is used to add or replace details to already existing crime.
  * Arguments:
  * * id - record id.
  * * cDataId - id of already existing crime.
  * * details - data you want to add.
  */
/datum/datacore/proc/addCrimeDetails(id, cDataId, details)
	for(var/datum/data/record/R as() in security)
		if(R.fields["id"] == id)
			var/list/crimes = R.fields["crim"]
			for(var/datum/data/crime/crime in crimes)
				if(crime.dataId == text2num(cDataId))
					crime.crimeDetails = details
					return

/datum/datacore/proc/manifest()
	for(var/mob/dead/new_player/N as() in GLOB.new_player_list)
		if(N.new_character)
			log_manifest(N.ckey,N.new_character.mind,N.new_character)
		if(ishuman(N.new_character))
			manifest_inject(N.new_character, N.client)
		CHECK_TICK

/datum/datacore/proc/manifest_modify(name, assignment)
	var/datum/data/record/foundrecord = find_record("name", name, GLOB.data_core.general)
	if(foundrecord)
		foundrecord.fields["rank"] = assignment

/datum/datacore/proc/get_manifest()
	var/list/manifest_out = list()
	var/list/departments = list(
		"Command" = GLOB.command_positions,
		"Security" = GLOB.security_positions,
		"Engineering" = GLOB.engineering_positions,
		"Medical" = GLOB.medical_positions,
		"Science" = GLOB.science_positions,
		"Supply" = GLOB.supply_positions,
		"Civilian" = GLOB.civilian_positions,
		"Silicon" = GLOB.nonhuman_positions
	)
	for(var/datum/data/record/t as() in GLOB.data_core.general)
		var/name = t.fields["name"]
		var/rank = t.fields["rank"]
		var/has_department = FALSE
		for(var/department in departments)
			var/list/jobs = departments[department]
			if(rank in jobs)
				if(!manifest_out[department])
					manifest_out[department] = list()
				manifest_out[department] += list(list(
					"name" = name,
					"rank" = rank
				))
				has_department = TRUE
				break
		if(!has_department)
			if(!manifest_out["Misc"])
				manifest_out["Misc"] = list()
			manifest_out["Misc"] += list(list(
				"name" = name,
				"rank" = rank
			))
	return manifest_out

/datum/datacore/proc/get_manifest_html(monochrome = FALSE)
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


/datum/datacore/proc/manifest_inject(mob/living/carbon/human/H, client/C)
	set waitfor = FALSE
	var/static/list/show_directions = list(SOUTH, WEST)
	if(H.mind && (H.mind.assigned_role != H.mind.special_role))
		var/assignment
		if(H.mind.assigned_role)
			assignment = H.mind.assigned_role
		else if(H.job)
			assignment = H.job
		else
			assignment = "Unassigned"

		var/static/record_id_num = 1001
		var/id = num2hex(record_id_num++,6)
		if(!C)
			C = H.client
		var/image = get_id_photo(H, C, show_directions)
		var/datum/picture/pf = new
		var/datum/picture/ps = new
		pf.picture_name = "[H]"
		ps.picture_name = "[H]"
		pf.picture_desc = "This is [H]."
		ps.picture_desc = "This is [H]."
		pf.picture_image = icon(image, dir = SOUTH)
		ps.picture_image = icon(image, dir = WEST)
		var/obj/item/photo/photo_front = new(null, pf)
		var/obj/item/photo/photo_side = new(null, ps)

		//These records should ~really~ be merged or something
		//General Record
		var/datum/data/record/G = new()
		G.fields["id"]			= id
		G.fields["name"]		= H.real_name
		G.fields["rank"]		= assignment
		G.fields["age"]			= H.age
		G.fields["species"]	= H.dna.species.name
		G.fields["fingerprint"]	= rustg_hash_string(RUSTG_HASH_MD5, H.dna.uni_identity)
		G.fields["p_stat"]		= "Active"
		G.fields["m_stat"]		= "Stable"
		G.fields["sex"]			= H.gender
		G.fields["photo_front"]	= photo_front
		G.fields["photo_side"]	= photo_side
		general += G

		//Medical Record
		var/datum/data/record/M = new()
		M.fields["id"]			= id
		M.fields["name"]		= H.real_name
		M.fields["blood_type"]	= H.dna.blood_type
		M.fields["b_dna"]		= H.dna.unique_enzymes
		M.fields["mi_dis"]		= "None"
		M.fields["mi_dis_d"]	= "No minor disabilities have been declared."
		M.fields["ma_dis"]		= "None"
		M.fields["ma_dis_d"]	= "No major disabilities have been diagnosed."
		M.fields["alg"]			= "None"
		M.fields["alg_d"]		= "No allergies have been detected in this patient."
		M.fields["cdi"]			= "None"
		M.fields["cdi_d"]		= "No diseases have been diagnosed at the moment."
		M.fields["notes"]		= "No notes."
		medical += M

		//Security Record

		security += generate_security_record(id, H)

		//Locked Record
		var/datum/data/record/L = new()
		L.fields["id"]			= rustg_hash_string(RUSTG_HASH_MD5, "[H.real_name][H.mind.assigned_role]")	//surely this should just be id, like the others?
		L.fields["name"]		= H.real_name
		L.fields["rank"] 		= H.mind.assigned_role
		L.fields["age"]			= H.age
		L.fields["sex"]			= H.gender
		L.fields["blood_type"]	= H.dna.blood_type
		L.fields["b_dna"]		= H.dna.unique_enzymes
		L.fields["identity"]	= H.dna.uni_identity
		L.fields["species"]		= H.dna.species.type
		L.fields["features"]	= H.dna.features
		L.fields["image"]		= image
		L.fields["mindref"]		= H.mind
		locked += L
	return

/datum/datacore/proc/generate_security_record(id, mob/living/carbon/human/H)
	var/datum/data/record/S = new()
	S.fields["ckey"]		= H.ckey
	S.fields["id"]			= id
	S.fields["name"]		= H.real_name
	S.fields["criminal"]	= "None"
	S.fields["citation"]	= list()
	S.fields["crim"]		= list()
	S.fields["notes"]		= "No notes."
	if(CONFIG_GET(flag/persist_security_records) && SSdbcore.Connect())
		var/datum/DBQuery/crime_record = SSdbcore.NewQuery(
			"SELECT crime, details, author, author_ckey, character_name FROM [format_table_name("criminal_records")] WHERE ckey = :ckey",
			list("ckey" = H.ckey)
		)
		if(crime_record.Execute(async = TRUE))
			while(crime_record.NextRow())
				if(!H.client.prefs.be_random_name && (H.real_name != crime_record.item[5] && reject_bad_name(crime_record.item[5]) != null)) // Tie the records to the character unless they're using random names or the name isn't valid.
					continue
				S.fields["crim"] += createCrimeEntry(cname = crime_record.item[1], cdetails = crime_record.item[2], author = crime_record.item[3], time = "Archived", author_ckey = crime_record.item[4])

		qdel(crime_record)
	return S

/datum/datacore/proc/upload_security_records()
	if(!CONFIG_GET(flag/persist_security_records))
		return
	var/list/data_to_upload = list()
	for(var/datum/data/record/S as() in GLOB.data_core.security)
		if(!S.fields["ckey"] || !S.fields["name"])
			continue
		var/list/crimes = S.fields["crim"]
		for(var/datum/data/crime/C in crimes)
			if(C.fromDB || C.had_special_role || C.fine > 0) //We don't want citations, crimes committed while antag, and we don't want to reupload existing crimes
				continue

			data_to_upload += list(list("ckey" = S.fields["ckey"], "crime" = C.crimeName, "details" = C.crimeDetails, "author" = C.author, "author_ckey" = C.authorCkey, "character_name" = S.fields["name"]))

	SSdbcore.MassInsert(format_table_name("criminal_records"), data_to_upload, duplicate_key = FALSE)


/datum/datacore/proc/get_id_photo(mob/living/carbon/human/H, client/C, show_directions = list(SOUTH))
	var/datum/job/J = SSjob.GetJob(H.mind.assigned_role)
	var/datum/preferences/P
	if(!C)
		C = H.client
	if(C)
		P = C.prefs
	return get_flat_human_icon(null, J, P, DUMMY_HUMAN_SLOT_MANIFEST, show_directions)
