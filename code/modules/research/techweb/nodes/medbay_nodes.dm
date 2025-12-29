/datum/techweb_node/cloning
	id = TECHWEB_NODE_CLONING
	tech_tier = 3
	display_name = "Genetic Engineering"
	description = "We have the technology to make him."
	prereq_ids = list(TECHWEB_NODE_BIOTECH)
	design_ids = list(
		"clonecontrol",
		"clonepod",
		"clonescanner",
		"cloning_disk",
		"scan_console",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/cryotech
	id = TECHWEB_NODE_CRYOTECH
	tech_tier = 3
	display_name = "Cryostasis Technology"
	description = "Smart freezing of objects to preserve them!"
	prereq_ids = list(TECHWEB_NODE_ADV_ENGI, TECHWEB_NODE_BIOTECH)
	design_ids = list(
		"cryo_Grenade",
		"cryotube",
		"noreactsyringe",
		"splitbeaker",
		"stasis",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2000)

/datum/techweb_node/med_scanning
	id = TECHWEB_NODE_MED_SCANNER
	tech_tier = 3
	display_name = "Medical Scanning"
	description = "By taking apart the ones we already had, we figured out how to make them ourselves."
	prereq_ids = list(TECHWEB_NODE_ADV_BIOTECH)
	design_ids = list("healthanalyzer")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)

/datum/techweb_node/adv_med_scanning
	id = TECHWEB_NODE_ADV_MED_SCANNER
	tech_tier = 4
	display_name = "Advanced Medical Scanning"
	description = "By integrating advanced AI into our scanners, we can diagnose even the most minute of abnormalities. Well, the AI is doing it, but we get the credit."
	prereq_ids = list(TECHWEB_NODE_MED_SCANNER, TECHWEB_NODE_POSIBRAIN)
	design_ids = list("healthanalyzer_advanced")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
