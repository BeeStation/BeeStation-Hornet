/datum/antagonist/traitor
	/// A list of backstories that are allowed for this traitor.
	var/list/allowed_backstories
	/// A list of recommended backstories for this traitor, based on their murderbone status.
	var/list/recommended_backstories
	/// The actual backstory for this traitor. Can be null.
	var/datum/traitor_backstory/backstory

/datum/antagonist/traitor/proc/setup_backstories(murderbone)
	allowed_backstories = list()
	recommended_backstories = list()
	for(var/datum/traitor_backstory/path as anything in subtypesof(/datum/traitor_backstory))
		var/datum/traitor_backstory/backstory = GLOB.traitor_backstories["[path]"]
		if(!istype(backstory))
			continue
		allowed_backstories += "[path]"
		if(murderbone && backstory.murderbone)
			recommended_backstories += "[path]"

	add_menu_action()

/datum/antagonist/traitor/proc/set_backstory(datum/traitor_backstory/new_backstory)
	backstory = new_backstory
	log_game("[key_name(owner)] selected traitor backstory [new_backstory.name]")
	SSblackbox.record_feedback("tally", "traitor_backstory_selected", 1, new_backstory.name)
	give_codewords()
	equip(silent)
