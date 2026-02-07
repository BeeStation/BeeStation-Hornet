/datum/preference/choiced/uplink_location
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	preference_type = PREFERENCE_CHARACTER
	db_key = "uplink_loc"
	can_randomize = FALSE

/datum/preference/choiced/uplink_location/init_possible_values()
	return list(UPLINK_PDA, UPLINK_RADIO, UPLINK_PEN)

/datum/preference/choiced/uplink_location/compile_constant_data()
	var/list/data = ..()

	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = list(
		UPLINK_PDA = "PDA",
		UPLINK_RADIO = "Radio",
		UPLINK_PEN = "Pen"
	)

	return data

/datum/preference/choiced/uplink_location/create_default_value()
	return UPLINK_PDA

/datum/preference/choiced/uplink_location/apply_to_human(mob/living/carbon/human/target, value)
	return
