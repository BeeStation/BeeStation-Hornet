/datum/computer_file/program/virosymptoms
	filename = "virosymptoms"
	filedesc = "Virology Symptoms"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "med-records"
	extended_desc = "This program provides an overview of all known virus symptoms and their thresholds."
	size = 2
	requires_ntnet = TRUE
	available_on_ntnet = TRUE
	tgui_id = "NtosViroSymptoms"
	program_icon = "book-medical"
	transfer_access = list(ACCESS_MEDICAL)

/datum/computer_file/program/virosymptoms/proc/GetSymptoms()
	var/list/all_symptoms = list()
	for(var/D in SSdisease.list_symptoms)
		var/datum/symptom/S = new D
		if (S.level == -1) continue
		var/list/this = list()
		this["name"] = S.name
		this["desc"] = S.desc
		this["stealth"] = S.stealth
		this["resistance"] = S.resistance
		this["stage_speed"] = S.stage_speed
		this["transmission"] = S.transmission
		this["level"] = S.level
		this["threshold_desc"] = S.Threshold(S)
		this["severity"] = S.severity
		all_symptoms[S.name] += this
	return all_symptoms

/datum/computer_file/program/virosymptoms/ui_data(mob/user)
	var/list/data = get_header_data()
	data["symptoms"] = GetSymptoms()
	return data