/datum/computer_file/program/records
	filename = "ntrecords"
	filedesc = "Records"
	extended_desc = "Allows the user to view several basic records from the crew."
	category = PROGRAM_CATEGORY_MISC
	program_icon = "clipboard"
	program_icon_state = "crew"
	tgui_id = "NtosRecords"
	size = 4
	usage_flags = PROGRAM_TABLET | PROGRAM_LAPTOP
	available_on_ntnet = FALSE

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

/datum/computer_file/program/records/security
	filedesc = "Security Records"
	filename = "secrecords"
	program_icon_state = "sec-records"
	extended_desc = "Allows the user to view several basic security records from the crew."
	transfer_access = list(ACCESS_SECURITY, ACCESS_HEADS)
	available_on_ntnet = TRUE
	mode = "security"

/datum/computer_file/program/records/proc/GetRecordsReadable()
	var/list/all_records = list()


	switch(mode)
		if("security")
			for(var/datum/data/record/person in GLOB.data_core.general)
				var/datum/data/record/security_person = find_record("id", person.fields["id"], GLOB.data_core.security)
				var/list/current_record = list()

				if(security_person)
					current_record["wanted"] = security_person.fields["criminal"]

				current_record["id"] = person.fields["id"]
				current_record["name"] = person.fields["name"]
				current_record["rank"] = person.fields["rank"]
				current_record["gender"] = person.fields["gender"]
				current_record["age"] = person.fields["age"]
				current_record["species"] = person.fields["species"]
				current_record["fingerprint"] = person.fields["fingerprint"]

				all_records += list(current_record)
		if("medical")
			for(var/datum/data/record/person in GLOB.data_core.general)
				var/list/current_record = list()

				current_record["id"] = person.fields["id"]
				current_record["name"] = person.fields["name"]
				current_record["rank"] = person.fields["rank"]
				current_record["gender"] = person.fields["gender"]
				current_record["age"] = person.fields["age"]
				current_record["species"] = person.fields["species"]

				var/datum/data/record/medical_person = find_record("id", person.fields["id"], GLOB.data_core.medical)

				if(medical_person)
					current_record["b_dna"] = medical_person.fields["b_dna"]
					current_record["bloodtype"] = medical_person.fields["blood_type"]
					current_record["mi_dis"] = medical_person.fields["mi_dis"]
					current_record["ma_dis"] = medical_person.fields["ma_dis"]
					current_record["notes"] = medical_person.fields["notes"]
					current_record["cnotes"] = medical_person.fields["notes_d"]

				all_records += list(current_record)

	return all_records



/datum/computer_file/program/records/ui_data(mob/user)
	var/list/data = list()
	data["records"] = GetRecordsReadable()
	data["mode"] = mode
	return data
