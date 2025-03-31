/datum/preference/choiced/quirk/prosthetic_limb_location
	db_key = "quirk_prosthetic_limb_location"
	required_quirk = /datum/quirk/prosthetic_limb

/datum/preference/choiced/quirk/prosthetic_limb_location/init_possible_values()
	return ..() + list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)

/datum/preference/choiced/quirk/prosthetic_limb_location/compile_constant_data()
	var/list/data = ..()

	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = list(
		"Random" = "Random",
		BODY_ZONE_L_ARM = "Left Arm",
		BODY_ZONE_R_ARM = "Right Arm",
		BODY_ZONE_L_LEG = "Left Leg",
		BODY_ZONE_R_LEG = "Right Leg",
	)

	return data
