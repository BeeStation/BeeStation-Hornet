/// Editing this will cause UI issues.
#define MAX_CRIME_NAME_LEN 24

/**
 * Record datum. Used for crew records and admin locked records.
 */
/datum/record
	/// Age of the character
	var/age
	/// Their blood type
	var/blood_type
	/// Character appearance
	var/mutable_appearance/character_appearance
	/// DNA string
	var/dna_string
	/// Fingerprint string (md5)
	var/fingerprint
	/// The character's gender
	var/gender
	/// The character's initial rank at roundstart
	var/initial_rank
	/// The character's name
	var/name = "Unknown"
	/// The character's rank
	var/rank
	/// The character's HUD icon
	var/hud
	/// The character's department
	var/active_department
	/// The character's species
	var/species

/datum/record/New(
	age = 18,
	blood_type = "?",
	character_appearance,
	dna_string = "Unknown",
	fingerprint = "?????",
	gender = "Other",
	initial_rank = "Unassigned",
	name = "Unknown",
	rank = "Unassigned",
	hud = "None",
	active_department = NONE,
	species = "Human",
)
	src.age = age
	src.blood_type = blood_type
	src.character_appearance = character_appearance
	src.dna_string = dna_string
	src.fingerprint = fingerprint
	src.gender = gender
	src.initial_rank = rank
	src.name = name
	src.rank = rank
	src.hud = hud
	src.active_department = active_department
	src.species = species

/**
 * Crew record datum
 */
/datum/record/crew
	/// List of citations
	var/list/citations = list()
	/// List of crimes
	var/list/crimes = list()
	/// Unique ID generated that is used to fetch lock record
	var/lock_ref
	/// Names of major disabilities
	var/major_disabilities
	/// Fancy description of major disabilities
	var/major_disabilities_desc
	/// List of medical notes
	var/list/medical_notes = list()
	/// Names of minor disabilities
	var/minor_disabilities
	/// Fancy description of minor disabilities
	var/minor_disabilities_desc
	/// Physical status of this person in medical records.
	var/physical_status
	/// Mental status of this person in medical records.
	var/mental_status
	/// Positive and neutral quirk strings
	var/quirk_notes
	/// Security note
	var/security_note
	/// Current arrest status
	var/wanted_status = WANTED_NONE

	///Photo used for records, which we store here so we don't have to constantly make more of.
	var/list/obj/item/photo/record_photos

/datum/record/crew/New(
	age = 18,
	blood_type = "?",
	character_appearance,
	dna_string = "Unknown",
	fingerprint = "?????",
	gender = "Other",
	initial_rank = "Unassigned",
	name = "Unknown",
	rank = "Unassigned",
	hud = "None",
	active_department = NONE,
	species = "Human",
	/// Crew specific
	lock_ref,
	medical_notes,
	major_disabilities = "None",
	major_disabilities_desc = "No disabilities have been diagnosed at the moment.",
	minor_disabilities = "None",
	minor_disabilities_desc = "No disabilities have been diagnosed at the moment.",
	physical_status = PHYSICAL_ACTIVE,
	mental_status = MENTAL_STABLE,
	quirk_notes,
	security_note,
	wanted_status = WANTED_NONE,
)
	. = ..()
	src.lock_ref = lock_ref
	src.major_disabilities = major_disabilities
	src.major_disabilities_desc = major_disabilities_desc
	src.minor_disabilities = minor_disabilities
	src.minor_disabilities_desc = minor_disabilities_desc
	src.physical_status = physical_status
	src.mental_status = mental_status
	src.quirk_notes = quirk_notes

	GLOB.manifest.general += src

/datum/record/crew/Destroy()
	GLOB.manifest.general -= src
	QDEL_LAZYLIST(record_photos)
	return ..()


/datum/record/crew/proc/get_info_list()
	var/list/list_of_medical_notes
	for(var/datum/medical_note/medical_note in medical_notes)
		list_of_medical_notes += list(medical_note.get_info_list())

	return list(
		age = src.age,
		blood_type = src.blood_type,
		record_ref = FAST_REF(src),
		dna = src.dna_string,
		gender = src.gender,
		major_disabilities = src.major_disabilities_desc,
		minor_disabilities = src.minor_disabilities_desc,
		physical_status = src.physical_status,
		mental_status = src.mental_status,
		name = src.name,
		quirk_notes = src.quirk_notes,
		rank = src.rank,
		species = src.species,
		medical_notes = list_of_medical_notes
		)


/datum/record/crew/proc/add_medical_note(list/params)
	if(!params["content"])
		return FALSE
	var/content = STRIP_HTML_FULL(params["content"], MAX_MESSAGE_LEN)

	var/datum/medical_note/new_note = new(usr.name, content)
	while(length(medical_notes) > 2)
		medical_notes.Cut(1, 2)

	medical_notes += new_note
	return TRUE

/datum/record/crew/proc/delete_medical_note(list/params)
	var/datum/medical_note/old_note = locate(params["note_ref"]) in medical_notes
	if(isnull(old_note))
		return FALSE

	medical_notes -= old_note
	qdel(old_note)
	return TRUE

/datum/record/crew/proc/set_physical_status(list/params)
	var/new_physical_status = params["physical_status"]
	if(!new_physical_status || !(new_physical_status in PHYSICAL_STATUSES))
		return FALSE

	physical_status = new_physical_status
	return TRUE

/datum/record/crew/proc/set_mental_status(list/params)
	var/new_mental_status = params["mental_status"]
	if(!new_mental_status || !(new_mental_status in MENTAL_STATUSES))
		return FALSE

	mental_status = new_mental_status
	return TRUE

/// Deletes medical information from a record.
/datum/record/crew/proc/anonymize_record_info()

	age = 18
	blood_type = pick(list("A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"))
	dna_string = "Unknown"
	gender = "Unknown"
	major_disabilities = ""
	major_disabilities_desc = ""
	medical_notes.Cut()
	minor_disabilities = ""
	minor_disabilities_desc = ""
	physical_status = ""
	mental_status = ""
	name = "Unknown"
	quirk_notes = ""
	rank = "Unknown"
	species = "Unknown"

	return TRUE

/// Voids crimes, or sets someone to discharged if they have none left.
/datum/record/crew/proc/invalidate_crime(mob/user, list/params)
	var/acquitted = TRUE
	var/datum/crime_record/to_void = locate(params["crime_ref"]) in crimes
	if(!to_void)
		to_void = locate(params["crime_ref"]) in citations
		// No need to change status after invalidatation of citation
		acquitted = FALSE
		if(!to_void)
			return FALSE

	if(user != to_void.author && !has_armory_access(user))
		return FALSE

	to_void.valid = FALSE
	to_void.voider = user
	user.investigate_log("[key_name(user)] has invalidated [name]'s crime: [to_void.name]", INVESTIGATE_RECORDS)

	for(var/datum/crime_record/incident in crimes)
		if(!incident.valid)
			continue
		acquitted = FALSE
		break

	if(acquitted)
		wanted_status = WANTED_DISCHARGED
		user.investigate_log("[key_name(user)] has invalidated [name]'s last valid crime. Their status is now [WANTED_DISCHARGED].", INVESTIGATE_RECORDS)

	update_matching_security_huds(name)

	return TRUE

/// Deletes security information from a record.
/datum/record/crew/proc/delete_security_record()
	citations.Cut()
	crimes.Cut()
	security_note = "None."
	wanted_status = WANTED_NONE
	return TRUE

/// Handles adding a crime to a particular record.
/datum/record/crew/proc/add_crime(mob/user, list/params)
	var/input_name = trim(params["name"], MAX_CRIME_NAME_LEN)
	if(!input_name)
		to_chat(user, "<span class='warning'>You must enter a name for the crime.</span>")
		playsound(src, 'sound/machines/terminal_error.ogg', 75, TRUE)
		return FALSE

	var/max = CONFIG_GET(number/maxfine)
	if(params["fine"] > max)
		to_chat(user, "<span class='warning'>The maximum fine is [max] credits.</span>")
		playsound(src, 'sound/machines/terminal_error.ogg', 75, TRUE)
		return FALSE

	var/input_details
	if(params["details"])
		input_details = trim(params["details"], MAX_MESSAGE_LEN)

	if(params["fine"] == 0)
		var/datum/crime_record/new_crime = new(name = input_name, details = input_details, author = user)
		crimes += new_crime
		wanted_status = WANTED_ARREST
		user.investigate_log("New Crime: <strong>[input_name]</strong> | Added to [name] by [key_name(user)]", INVESTIGATE_RECORDS)

		update_matching_security_huds(name)
		return TRUE

	var/datum/crime_record/citation/new_citation = new(name = input_name, details = input_details, author = user, fine = params["fine"])

	citations += new_citation
	new_citation.alert_owner(user, src, name, "You have been issued a [params["fine"]]cr citation for [input_name]. Fines are payable at Security.")
	user.investigate_log("New Citation: <strong>[input_name]</strong> Fine: [params["fine"]] | Added to [name] by [key_name(user)]", INVESTIGATE_RECORDS)

	return TRUE

/// Handles editing a crime on a particular record.
/datum/record/crew/proc/edit_crime(mob/user, list/params)
	var/datum/crime_record/editing_crime = locate(params["crime_ref"]) in crimes
	if(!editing_crime?.valid)
		editing_crime = locate(params["crime_ref"]) in citations //One last hail mary.
		if(!editing_crime?.valid)
			return FALSE

	if(user != editing_crime.author && !has_armory_access(user)) // only warden/hos/command can edit crimes they didn't author
		return FALSE

	if(params["name"] && length(params["name"]) > 2 && params["name"] != editing_crime.name)
		editing_crime.name = trim(params["name"], MAX_CRIME_NAME_LEN)
		return TRUE

	if(params["description"] && length(params["description"]) > 2 && params["description"] != editing_crime.details)
		var/new_details = STRIP_HTML_FULL(params["description"], MAX_MESSAGE_LEN)
		editing_crime.details = new_details
		return TRUE

	return FALSE


/datum/record/crew/proc/set_security_note(list/params)
	var/new_security_note = params["security_note"]
	security_note = trim(new_security_note, MAX_MESSAGE_LEN)

/datum/record/crew/proc/set_wanted_status(list/params)
	var/new_wanted_status = params["status"]
	if(!new_wanted_status || !(new_wanted_status in WANTED_STATUSES()))
		return FALSE
	if(new_wanted_status == WANTED_ARREST && !length(crimes))
		return FALSE
	wanted_status = new_wanted_status

	update_matching_security_huds(name)
	return TRUE


/// Only qualified personnel can edit records.
/datum/record/crew/proc/has_armory_access(mob/user)
	if(issiliconoradminghost(user))
		return TRUE
	if(!isliving(user))
		return FALSE
	var/mob/living/player = user

	var/obj/item/card/id/auth = player.get_idcard(TRUE)
	if(!auth)
		return FALSE

	if(!(ACCESS_ARMORY in auth.GetAccess()))
		return FALSE

	return TRUE


/**
 * Admin locked record
 */
/datum/record/locked
	/// Mob's dna
	var/datum/dna/dna
	/// Mind datum
	var/datum/mind/mind

/datum/record/locked/New(
	age = 18,
	blood_type = "?",
	character_appearance,
	dna_string = "Unknown",
	fingerprint = "?????",
	gender = "Other",
	initial_rank = "Unassigned",
	name = "Unknown",
	rank = "Unassigned",
	species = "Human",
	/// Locked specific
	datum/dna/dna,
	datum/mind/mind,
)
	. = ..()
	src.dna = dna
	src.mind = mind

	GLOB.manifest.locked += src

/datum/record/locked/Destroy()
	GLOB.manifest.locked -= src
	return ..()

/// A helper proc to get the front photo of a character from the record.
/// Handles calling `get_photo()`, read its documentation for more information.
/datum/record/crew/proc/get_front_photo()
	return get_photo("photo_front", SOUTH)

/// A helper proc to get the side photo of a character from the record.
/// Handles calling `get_photo()`, read its documentation for more information.
/datum/record/crew/proc/get_side_photo()
	return get_photo("photo_side", WEST)

/// A helper proc to recreate all photos of a character from the record.
/datum/record/crew/proc/recreate_manifest_photos(add_height_chart)
	delete_photos("photo_front")
	make_photo("photo_front", SOUTH, add_height_chart)
	delete_photos("photo_side")
	make_photo("photo_side", WEST, add_height_chart)

///Deletes the existing photo for field_name
/datum/record/crew/proc/delete_photos(field_name)
	var/obj/item/photo/existing_photo = LAZYACCESS(record_photos, field_name)
	if(existing_photo)
		qdel(existing_photo)
		LAZYREMOVE(record_photos, field_name)

/**
 * You shouldn't be calling this directly, use `get_front_photo()` or `get_side_photo()`
 * instead.
 *
 * This is the proc that handles either fetching (if it was already generated before) or
 * generating (if it wasn't) the specified photo from the specified record. This is only
 * intended to be used by records that used to try to access `fields["photo_front"]` or
 * `fields["photo_side"]`, and will return an empty icon if there isn't any of the necessary
 * fields.
 *
 * Arguments:
 * * field_name - The name of the key in the `fields` list, of the record itself.
 * * orientation - The direction in which you want the character appearance to be rotated
 * in the outputed photo.
 *
 * Returns an empty `/icon` if there was no `character_appearance` entry in the `fields` list,
 * returns the generated/cached photo otherwise.
 */
/datum/record/crew/proc/get_photo(field_name, orientation = SOUTH)
	if(!field_name)
		return
	if(!character_appearance)
		return new /icon()
	var/obj/item/photo/existing_photo = LAZYACCESS(record_photos, field_name)
	if(!existing_photo)
		existing_photo = make_photo(field_name, orientation)
	return existing_photo

/**
 * make_photo
 *
 * Called if the person doesn't already have a photo, this will make a photo of the person,
 * then make a picture out of it, then finally create a new photo.
 */
/datum/record/crew/proc/make_photo(field_name, orientation, add_height_chart)
	var/icon/picture_image
	if(!isicon(character_appearance))
		var/mutable_appearance/appearance = character_appearance
		appearance.setDir(orientation)
		if(add_height_chart)
			appearance.underlays += mutable_appearance('icons/obj/machines/photobooth.dmi', "height_chart", alpha = 125, appearance_flags = RESET_ALPHA|RESET_COLOR|RESET_TRANSFORM)
		picture_image = getFlatIcon(appearance)
	else
		picture_image = character_appearance

	var/datum/picture/picture = new
	picture.picture_name = name
	picture.picture_desc = "This is [name]."
	picture.picture_image = picture_image

	var/obj/item/photo/new_photo = new(null, picture)
	LAZYSET(record_photos, field_name, new_photo)
	return new_photo

/// Returns a paper printout of the current record's crime data.
/datum/record/crew/proc/get_rapsheet(alias, header = "Rapsheet", description = "No further details.")
	var/print_count = ++GLOB.manifest.print_count
	var/obj/item/paper/printed_paper = new
	var/final_paper_text = text("<center><b>SR-[print_count]: [header]</b></center><br>")

	final_paper_text += text("Name: []<br>Gender: []<br>Age: []<br>", name, gender, age)
	if(alias != name)
		final_paper_text += text("Alias: []<br>", alias)

	final_paper_text += text("Species: []<br>Fingerprint: []<br>Wanted Status: []<br><br>", species, fingerprint, wanted_status)

	final_paper_text += text("<center><B>Security Data</B></center><br><br>")

	final_paper_text += "Crimes:<br>"
	final_paper_text += {"<table style="text-align:center;" border="1" cellspacing="0" width="100%">
						<tr>
						<th>Crime</th>
						<th>Details</th>
						<th>Author</th>
						<th>Time Added</th>
						</tr>"}
	for(var/datum/crime_record/crime in crimes)
		if(crime.valid)
			final_paper_text += "<tr><td>[crime.name]</td>"
			final_paper_text += "<td>[crime.details]</td>"
			final_paper_text += "<td>[crime.author]</td>"
			final_paper_text += "<td>[crime.time]</td>"
		else
			for(var/i in 1 to 4)
				final_paper_text += "<td>--REDACTED--</td>"
		final_paper_text += "</tr>"
	final_paper_text += "</table><br><br>"

	final_paper_text += "Citations:<br>"
	final_paper_text  += {"<table style="text-align:center;" border="1" cellspacing="0" width="100%">
						<tr>
						<th>Citation</th>
						<th>Details</th>
						<th>Author</th>
						<th>Time Added</th>
						<th>Fine</th>
						</tr><br>"}
	for(var/datum/crime_record/citation/warrant in citations)
		final_paper_text += "<tr><td>[warrant.name]</td>"
		final_paper_text += "<td>[warrant.details]</td>"
		final_paper_text += "<td>[warrant.author]</td>"
		final_paper_text += "<td>[warrant.time]</td>"
		final_paper_text += "<td>[warrant.fine]</td>"
		final_paper_text += "</tr>"
	final_paper_text += "</table><br><br>"

	final_paper_text += text("<center>Important Notes:</center><br>")
	if(security_note)
		final_paper_text += text("- [security_note]<br>")
	if(description)
		final_paper_text += text("- [description]<br>")

	printed_paper.name = text("SR-[] '[]'", print_count, name)
	printed_paper.add_raw_text(final_paper_text)
	printed_paper.update_appearance()

	return printed_paper


/// Returns a paper printout of the current record's crime data.
/datum/record/crew/proc/get_medical_sheet()
	var/obj/item/paper/med_record_paper = new
	var/med_record_text
	med_record_text += "<CENTER><B>Medical Record</B></CENTER>"
	med_record_text += "<BR>Name: [name] Rank: [rank]"
	med_record_text += "<BR>Gender: [gender]</BR>"
	med_record_text += "<BR>Age: [age]<BR>"
	med_record_text += "<BR>\n<CENTER><B>Medical Data</B></CENTER></BR>"
	med_record_text += "<BR>Blood Type: [blood_type]</BR>"
	med_record_text += "<BR>DNA: [dna_string]</BR>"
	med_record_text += "<BR>Physical Status: [physical_status]</BR>"
	med_record_text += "<BR>Mental Status: [mental_status]</BR>"
	med_record_text += "<BR>Minor Disabilities: [minor_disabilities]</BR>"
	med_record_text += "<BR>Details: [minor_disabilities_desc]</BR>"
	med_record_text += "<BR>Major Disabilities: [major_disabilities]</BR>"
	med_record_text += "<BR>Details: [major_disabilities_desc]</BR>"
	med_record_text += "<BR>Important Notes: \t[medical_notes]</BR>"
	med_record_text += "<BR><CENTER><B>Comments/Log</B></CENTER></BR>"

	med_record_paper.name = "paper - '[name]'"
	med_record_paper.add_raw_text(med_record_text)
	med_record_paper.update_appearance()

	return med_record_paper

/**
 * Cloning record
 */
/datum/record/cloning

	var/id
	var/datum/dna/dna
	var/uni_identity
	var/SE
	var/datum/mind/mind /// Mind datum
	var/last_death
	var/factions
	var/traumas
	var/body_only
	var/implant
	var/UE
	var/bank_account


/datum/record/cloning/New(
	id,
	age = "??",
	blood_type = "?",
	dna_string = "Unknown",
	fingerprint = "?????",
	gender = "Other",
	initial_rank = "Unassigned",
	name = "Unknown",
	species = "Unknown",
	datum/dna/dna,
	uni_identity,
	SE,
	datum/mind/mind,
	last_death,
	factions,
	traumas,
	body_only,
	implant,
	UE,
	bank_account
	)
	. = ..()
	src.id = id
	src.dna = dna
	src.uni_identity = uni_identity
	src.SE = SE
	src.mind = mind
	src.last_death = last_death
	src.factions = factions
	src.traumas = traumas
	src.body_only = body_only
	src.implant = implant
	src.UE = UE
	src.bank_account = bank_account

	GLOB.manifest.cloning += src

/datum/record/cloning/Destroy()
	GLOB.manifest.cloning -= src
	return ..()

#undef MAX_CRIME_NAME_LEN
