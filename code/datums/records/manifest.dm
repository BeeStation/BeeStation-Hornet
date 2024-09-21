/datum/manifest
	/// All of the crew records.
	var/list/general = list()
	/// This list tracks characters spawned in the world and cannot be modified in-game. Currently referenced by respawn_character().
	var/list/locked = list()

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
		locked_dna = record_dna,
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
		// Crew specific
		lock_ref = REF(lockfile),
		major_disabilities = person.get_quirk_string(FALSE, CAT_QUIRK_MAJOR_DISABILITY, from_scan = TRUE),
		major_disabilities_desc = person.get_quirk_string(TRUE, CAT_QUIRK_MAJOR_DISABILITY),
		minor_disabilities = person.get_quirk_string(FALSE, CAT_QUIRK_MINOR_DISABILITY, from_scan = TRUE),
		minor_disabilities_desc = person.get_quirk_string(TRUE, CAT_QUIRK_MINOR_DISABILITY),
		quirk_notes = person.get_quirk_string(TRUE, CAT_QUIRK_NOTES),
	)
