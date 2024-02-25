/datum/objective/forged_manifest
	name = "forged manifest"
	martyr_compatible = TRUE
	var/person_name
	var/age
	var/gender
	var/job
	var/species

	var/fail_reasons

/datum/objective/forged_manifest/New()
	..()

	gender = pick(MALE, FEMALE)
	species = pick(GLOB.roundstart_races)
	var/datum/species/species_datum = GLOB.species_list[species]
	species_datum = new species_datum
	var/datum/data/record/R
	do
		person_name = species_datum.random_name(gender)
		R = find_record("name", person_name, GLOB.data_core.general)
	while(R)
	age = rand(20, 80)
	job = pick(get_all_jobs())

	update_explanation_text()

/datum/objective/forged_manifest/update_explanation_text()
	..()
	explanation_text = "Make a fake person information in the Crew Manifest System with said information:\n\t[person_name], [gender], [age], [species], [job]."

/datum/objective/forged_manifest/check_completion()
	fail_reasons = ""
	var/datum/data/record/R = find_record("name", person_name, GLOB.data_core.general)
	if(!R)
		fail_reasons = "Data doesn't exist."
		return FALSE

	if(R.fields["age"] != age)
		fail_reasons += "Age:[R.fields["age"]]"
	if(lowertext(R.fields["gender"]) != gender)
		if(fail_reasons)
			fail_reasons += ", "
		fail_reasons += "Gender:[R.fields["gender"]]"
	if(R.fields["rank"] != job)
		if(fail_reasons)
			fail_reasons += ", "
		fail_reasons += "Job:[R.fields["rank"]]"
	if(R.fields["species"] != species)
		if(fail_reasons)
			fail_reasons += ", "
		fail_reasons += "Species:[R.fields["species"]]"

	if(fail_reasons)
		fail_reasons += "."
		return FALSE

	return TRUE

/datum/objective/forged_manifest/get_completion_message()
	if(fail_reasons)
		return "[explanation_text] <span class='redtext'>[fail_reasons]</span>"

	return "[explanation_text] <span class='grentext'>False person information was forged!</span>"
