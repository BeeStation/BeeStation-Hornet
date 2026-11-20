/datum/techweb_node/comptech
	tech_tier = 1
	display_name = "Computer Consoles"
	description = "Computers and how they work."
	prerequisite_nodes = list(/datum/techweb_node/datatheory)
	unlocked_designs = list(
		/datum/design/board/cargo,
		/datum/design/board/cargorequest,
		/datum/design/board/comconsole,
		/datum/design/board/crewconsole,
		/datum/design/board/idcardconsole,
		/datum/design/board/libraryconsole,
		/datum/design/board/mining,
		/datum/design/board/photobooth,
		/datum/design/board/objective,
		/datum/design/board/rdcamera,
		/datum/design/board/seccamera,
		/datum/design/board/security_photobooth
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/computer_hardware_basic
	tech_tier = 1
	display_name = "Basic Computer Hardware"
	description = "Necessary basic components for Modular Computer assembly."
	prerequisite_nodes = list(/datum/techweb_node/datatheory)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	unlocked_designs = list(
		/datum/design/antivirus1,
		/datum/design/battery/nano,
		/datum/design/battery/micro,
		/datum/design/cardslot,
		/datum/design/cpu/small,
		/datum/design/cpu/photonic/small,
		/datum/design/netcard/basic,
		/datum/design/netcard/wired,
		/datum/design/portabledrive/basic,
		/datum/design/disk/micro,
		/datum/design/disk/small
	)

/datum/techweb_node/computer_shells
	tech_tier = 1
	display_name = "Computer Shells"
	description = "Production of modular computer shells for assembly."
	prerequisite_nodes = list(/datum/techweb_node/datatheory)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	unlocked_designs = list(
		/datum/design/computer_shell/pda,
		/datum/design/computer_shell/tablet,
		/datum/design/computer_shell/laptop
	)

/datum/techweb_node/computer_hardware_advanced
	tech_tier = 2
	display_name = "Advanced Computer Hardware"
	description = "Standard quality components and functional parts."
	prerequisite_nodes = list(/datum/techweb_node/computer_hardware_basic)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	unlocked_designs = list(
		/datum/design/antivirus2,
		/datum/design/battery/standard,
		/datum/design/battery/large,
		/datum/design/disk/normal,
		/datum/design/disk/advanced,
		/datum/design/disk/cluster,
		/datum/design/netcard/advanced,
		/datum/design/cpu,
		/datum/design/cpu/photonic,
		/datum/design/portabledrive/advanced,
		/datum/design/miniprinter,
		/datum/design/printer,
		/datum/design/sensorpackage,
		/datum/design/camera,
		/datum/design/signaler_part
	)

/datum/techweb_node/computer_hardware_super
	tech_tier = 3
	display_name = "Superior Computer Hardware"
	description = "Superior quality components and useful parts."
	prerequisite_nodes = list(/datum/techweb_node/computer_hardware_advanced)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	unlocked_designs = list(
		/datum/design/antivirus3,
		/datum/design/aislot,
		/datum/design/APClink,
		/datum/design/portabledrive/super,
		/datum/design/battery/huge,
		/datum/design/disk/super,
		/datum/design/cardslot2
	)

/datum/techweb_node/computer_hardware_experimental
	tech_tier = 4
	display_name = "Experimental Computer Hardware"
	description = "Experimental parts currently in development. Test cautiously."
	prerequisite_nodes = list(/datum/techweb_node/computer_hardware_super, /datum/techweb_node/telecomms)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	unlocked_designs = list(
		/datum/design/antivirus4,
		/datum/design/XNetCard
	)

/datum/techweb_node/computer_board_gaming
	tech_tier = 1
	display_name = "Arcade Games"
	description = "For the slackers on the station."
	prerequisite_nodes = list(/datum/techweb_node/comptech)
	unlocked_designs = list(
		/datum/design/board/arcade_battle,
		/datum/design/board/orion_trail,
		/datum/design/board/slot_machine,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
