/datum/techweb_node/comptech
	id = "comptech"
	tech_tier = 1
	display_name = "Computer Consoles"
	description = "Computers and how they work."
	prereq_ids = list("datatheory")
	design_ids = list(
		"cargo",
		"cargorequest",
		"comconsole",
		"crewconsole",
		"idcardconsole",
		"libraryconsole",
		"mining",
		"photobooth",
		"objective",
		"rdcamera",
		"seccamera",
		"security_photobooth"
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2000)

/datum/techweb_node/computer_hardware_basic
	id = "computer_hardware_basic"
	tech_tier = 1
	display_name = "Basic Computer Hardware"
	description = "Necessary basic components for Modular Computer assembly."
	prereq_ids = list("datatheory")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)
	design_ids = list(
		"antivirus",
		"bat_nano",
		"bat_micro",
		"cardslot",
		"cpu_small",
		"pcpu_small",
		"netcard_basic",
		"netcard_wired",
		"portadrive_basic",
		"ssd_micro",
		"ssd_small"
	)

/datum/techweb_node/computer_shells
	id = "computer_shells"
	tech_tier = 1
	display_name = "Computer Shells"
	description = "Production of modular computer shells for assembly."
	prereq_ids = list("datatheory")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2000)
	design_ids = list(
		"shell_pda",
		"shell_tablet",
		"shell_laptop"
	)

/datum/techweb_node/computer_hardware_advanced
	id = "computer_hardware_advanced"
	tech_tier = 2
	display_name = "Advanced Computer Hardware"
	description = "Standard quality components and functional parts."
	prereq_ids = list("computer_hardware_basic")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	design_ids = list(
		"antivirus2",
		"bat_normal",
		"bat_advanced",
		"hdd_basic",
		"hdd_advanced",
		"hdd_cluster",
		"netcard_advanced",
		"cpu_normal",
		"pcpu_normal",
		"portadrive_advanced",
		"miniprinter",
		"printer",
		"sensorpackage",
		"comp_camera",
		"signalpart"
	)

/datum/techweb_node/computer_hardware_super
	id = "computer_hardware_super"
	tech_tier = 3
	display_name = "Superior Computer Hardware"
	description = "Superior quality components and useful parts."
	prereq_ids = list("computer_hardware_advanced")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3500)
	design_ids = list(
		"antivirus3",
		"aislot",
		"APClink",
		"portadrive_super",
		"bat_super",
		"hdd_super",
		"cardslot2"
	)

/datum/techweb_node/computer_hardware_experimental
	id = "computer_hardware_experimental"
	tech_tier = 4
	display_name = "Experimental Computer Hardware"
	description = "Experimental parts currently in development. Test cautiously."
	prereq_ids = list("computer_hardware_super", "telecomms")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 4000)
	design_ids = list(
		"antivirus4",
		"XNetCard"
	)

/datum/techweb_node/computer_board_gaming
	id = "computer_board_gaming"
	tech_tier = 1
	display_name = "Arcade Games"
	description = "For the slackers on the station."
	prereq_ids = list("comptech")
	design_ids = list(
		"arcade_battle",
		"arcade_orion",
		"slotmachine",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)
