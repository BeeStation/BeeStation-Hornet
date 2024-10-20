/datum/preference/choiced/quirk/phobia
	db_key = "quirk_phobia"
	required_quirk = /datum/quirk/trauma

/datum/preference/choiced/quirk/phobia/init_possible_values()
	return ..() + assoc_to_keys(GLOB.available_random_trauma_list)
