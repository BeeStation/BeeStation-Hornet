#define WIZARD_DESC "GREETINGS. WE'RE THE WIZARDS OF THE WIZARD'S FEDERATION. \
	Choose between a variety of powerful spells in order to cause chaos among Space Station 13."
/datum/role_preference/antagonist/wizard
	name = "Wizard"
	description = WIZARD_DESC
	antag_datum = /datum/antagonist/wizard
	preview_outfit = /datum/outfit/wizard

/datum/role_preference/midround_ghost/wizard
	name = "Wizard (Midround)"
	description = WIZARD_DESC
	antag_datum = /datum/antagonist/wizard
	use_icon = /datum/role_preference/antagonist/wizard

#undef WIZARD_DESC
