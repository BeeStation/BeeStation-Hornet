/datum/computer_file/program/records
	filename = "ntrecords"
	filedesc = "Records"
	extended_desc = "Allows the user to view several basic records from the crew."
	category = PROGRAM_CATEGORY_MISC
	program_icon = "clipboard"
	program_icon_state = "crew"
	tgui_id = "NtosRecords"
	size = 4
	available_on_ntnet = FALSE
	power_consumption = 60 WATT

	var/mode

/datum/computer_file/program/records/medical
	filedesc = "Medical Records"
	filename = "medrecords"
	program_icon_state = "med-records"
	program_icon = "book-medical"
	extended_desc = "Allows the user to view several basic medical records from the crew."
	transfer_access = list(ACCESS_MEDICAL, ACCESS_HEADS)
	available_on_ntnet = TRUE
	mode = "medical"
	power_consumption = 60 WATT

/datum/computer_file/program/records/security
	filedesc = "Security Records"
	filename = "secrecords"
	program_icon_state = "sec-records"
	extended_desc = "Allows the user to view several basic security records from the crew."
	transfer_access = list(ACCESS_SECURITY, ACCESS_HEADS)
	available_on_ntnet = TRUE
	mode = "security"
	power_consumption = 60 WATT

/datum/computer_file/program/records/proc/GetRecordsReadable()
	var/list/all_records = list()


	switch(mode)
		if("security")
			for(var/datum/record/crew/person in GLOB.manifest.general)
				var/list/current_record = list()

				current_record["age"] = person.age
				current_record["fingerprint"] = person.fingerprint
				current_record["gender"] = person.gender
				current_record["name"] = person.name
				current_record["rank"] = person.rank
				current_record["species"] = person.species
				current_record["wanted"] = person.wanted_status

				all_records += list(current_record)
		if("medical")
			for(var/datum/record/crew/person in GLOB.manifest.general)
				var/list/current_record = list()

				current_record["name"] = person.name
				current_record["rank"] = person.rank
				current_record["species"] = person.species
				current_record["gender"] = person.gender
				current_record["age"] = person.age
				current_record["b_dna"] = person.dna_string
				current_record["bloodtype"] = person.blood_type
				current_record["ma_dis"] = person.major_disabilities_desc
				current_record["mi_dis"] = person.minor_disabilities_desc
				current_record["physical_status"] = person.physical_status
				current_record["mental_status"] = person.mental_status
				current_record["notes"] = person.medical_notes

				all_records += list(current_record)

	return all_records



/datum/computer_file/program/records/ui_data(mob/user)
	var/list/data = list()
	data["records"] = GetRecordsReadable()
	data["mode"] = mode
	return data
