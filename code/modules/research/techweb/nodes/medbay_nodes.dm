/datum/techweb_node/cloning
	tech_tier = 3
	display_name = "Genetic Engineering"
	description = "We have the technology to make him."
	prerequisite_nodes = list(/datum/techweb_node/biotech)
	unlocked_designs = list(
		/datum/design/board/clonecontrol,
		/datum/design/board/clonepod,
		/datum/design/board/clonescanner,
		/datum/design/cloning_disk,
		/datum/design/board/scan_console,
		/datum/design/flesh_reshapers,
		/datum/design/flesh_reshapers/medical,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/cryotech
	tech_tier = 3
	display_name = "Cryostasis Technology"
	description = "Smart freezing of objects to preserve them!"
	prerequisite_nodes = list(/datum/techweb_node/adv_engi, /datum/techweb_node/biotech)
	unlocked_designs = list(
		/datum/design/cryo_grenade,
		/datum/design/board/cryotube,
		/datum/design/noreactsyringe,
		/datum/design/noreactbeaker,
		/datum/design/board/stasis,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/med_scanning
	tech_tier = 3
	display_name = "Medical Scanning"
	description = "By taking apart the ones we already had, we figured out how to make them ourselves."
	prerequisite_nodes = list(/datum/techweb_node/adv_biotech)
	unlocked_designs = list(/datum/design/healthanalyzer)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/adv_med_scanning
	tech_tier = 4
	display_name = "Advanced Medical Scanning"
	description = "By integrating advanced AI into our scanners, we can diagnose even the most minute of abnormalities. Well, the AI is doing it, but we get the credit."
	prerequisite_nodes = list(/datum/techweb_node/med_scanning, /datum/techweb_node/posibrain)
	unlocked_designs = list(/datum/design/healthanalyzer_advanced)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_MEDICAL)
