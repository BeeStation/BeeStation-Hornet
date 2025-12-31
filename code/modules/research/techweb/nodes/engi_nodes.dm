/datum/techweb_node/base
	id = TECHWEB_NODE_BASE
	tech_tier = 0
	starting_node = TRUE
	display_name = "Basic Research Technology"
	description = "NT default research technologies."
	// Default research tech, prevents bricking
	design_ids = list(
		"basic_capacitor",
		"basic_cell",
		"basic_matter_bin",
		"basic_micro_laser",
		"basic_scanning",
		"beaker",
		"bucket",
		"circuit_imprinter",
		"conveyor_belt",
		"conveyor_switch",
		"dest_tagger",
		"destructive_analyzer",
		"duct_tape",
		"epaperread",
		"fax",
		"glasses_prescription",
		"handlabel",
		"large_beaker",
		"larry",
		"light_replacer",
		"mechfab",
		"micro_mani",
		"oven_tray",
		"package_wrap",
		"paystand",
		"plasmaglass",
		"plasmareinforcedglass",
		"plasteel",
		"plastitanium",
		"plastitaniumglass",
		"plumbing_rcd",
		"portable_thermomachine",
		"rdconsole",
		"rdserver",
		"rdservercontrol",
		"rglass",
		"salestagger",
		"sec_38",
		"sec_38b",
		"sec_beanbag_slug",
		"sec_Brslug",
		"sec_bshot",
		"sec_bapshot",
		"sec_dart",
		"sec_Islug",
		"sec_rshot",
		"sec_slug",
		"tech_disk",
		"titaniumglass",
		"xenoa_labeler",
		"xlarge_beaker",
	)

/datum/techweb_node/basic_tools
	id = TECHWEB_NODE_BASIC_TOOLS
	tech_tier = 0
	starting_node = TRUE
	display_name = "Basic Tools"
	description = "Basic mechanical, electronic, surgical and botanical tools."
	design_ids = list(
		"airlock_painter",
		"analyzer",
		"blood_filter",
		"cable_coil",
		"cautery",
		"circular_saw",
		"crowbar",
		"cultivator",
		"decal_painter",
		"discovery_scanner",
		"hatchet",
		"hemostat",
		"mop",
		"multitool",
		"pipe_painter",
		"plant_analyzer",
		"retractor",
		"scalpel",
		"screwdriver",
		"shovel",
		"spade",
		"stethoscope",
		"surgical_drapes",
		"surgicaldrill",
		"syringe",
		"tile_sprayer",
		"tscanner",
		"welding_helmet",
		"welding_tool",
		"wirebrush",
		"wirecutters",
		"wrench",
	)

/datum/techweb_node/engineering
	id = TECHWEB_NODE_ENGINEERING
	tech_tier = 1
	display_name = "Industrial Engineering"
	description = "A refresher course on modern engineering technology."
	prereq_ids = list(TECHWEB_NODE_BASE)
	design_ids = list(
		"adv_capacitor",
		"adv_matter_bin",
		"adv_scanning",
		"airalarm_electronics",
		"airlock_board",
		"apc_control",
		"atmos_control",
		"atmosalerts",
		"autolathe",
		"cell_charger",
		"emergency_oxygen_engi",
		"emergency_oxygen",
		"emitter",
		"firealarm_electronics",
		"firelock_board",
		"grounding_rod",
		"high_cell",
		"high_micro_laser",
		"machine_igniter",
		"mass_driver",
		"mesons",
		"nano_mani",
		"oxygen_tank",
		"pacman",
		"plasma_tank",
		"plasmaman_tank_belt",
		"plasmaman_tank",
		"power control",
		"powermonitor",
		"recharger",
		"recycler",
		"researchdisk_locator",
		"rped",
		"scanner_gate",
		"shieldwallgen",
		"shieldwallgen_atmos",
		"solarcontrol",
		"stack_console",
		"stack_machine",
		"suit_storage_unit",
		"tesla_coil",
		"thermomachine",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)

/datum/techweb_node/adv_engi
	id = TECHWEB_NODE_ADV_ENGI
	tech_tier = 2
	display_name = "Advanced Engineering"
	description = "Pushing the boundaries of physics, one chainsaw-fist at a time."
	prereq_ids = list(TECHWEB_NODE_EMP_BASIC, TECHWEB_NODE_ENGINEERING)
	design_ids = list(
		"engine_goggles",
		"magboots",
		"ranged_analyzer",
		"rcd_loaded",
		"rcl",
		"rpd_loaded",
		"weldingmask",
		"sheetifier",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/high_efficiency
	id = TECHWEB_NODE_HIGH_EFFICIENCY
	tech_tier = 3
	display_name = "High Efficiency Parts"
	description = "Finely-tooled manufacturing techniques allowing for picometer-perfect precision levels."
	prereq_ids = list(TECHWEB_NODE_DATATHEORY, TECHWEB_NODE_ENGINEERING)
	design_ids = list(
		"pico_mani",
		"super_matter_bin",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)

/datum/techweb_node/adv_power
	id = TECHWEB_NODE_ADV_POWER
	tech_tier = 3
	display_name = "Advanced Power Manipulation"
	description = "How to get more zap."
	prereq_ids = list(TECHWEB_NODE_ENGINEERING)
	design_ids = list(
		"circulator",
		"hyper_cell",
		"mrspacman",
		"power_compressor",
		"power_turbine_console",
		"power_turbine",
		"smes",
		"super_capacitor",
		"super_cell",
		"superpacman",
		"teg",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/bluespace_power
	id = TECHWEB_NODE_BLUESPACE_POWER
	tech_tier = 4
	display_name = "Bluespace Power Technology"
	description = "Even more powerful.. power!"
	prereq_ids = list(TECHWEB_NODE_ADV_POWER, TECHWEB_NODE_PRACTICAL_BLUESPACE)
	design_ids = list(
		"bluespace_cell",
		"quadratic_capacitor",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/micro_bluespace
	id = TECHWEB_NODE_MICRO_BLUESPACE
	tech_tier = 5
	display_name = "Miniaturized Bluespace Research"
	description = "Extreme reduction in space required for bluespace engines, leading to portable bluespace technology."
	prereq_ids = list(TECHWEB_NODE_BLUESPACE_TRAVEL, TECHWEB_NODE_HIGH_EFFICIENCY, TECHWEB_NODE_PRACTICAL_BLUESPACE)
	design_ids = list(
		"bluespace_matter_bin",
		"femto_mani",
		"quantum_keycard",
		"triphasic_scanning",
		"usb_wireless",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_5_POINTS)

/datum/techweb_node/basic_shuttle_tech
	id = TECHWEB_NODE_BASIC_SHUTTLE
	tech_tier = 3
	display_name = "Basic Shuttle Research"
	description = "Research the technology required to create and use basic shuttles."
	prereq_ids = list(TECHWEB_NODE_ADV_ENGI, TECHWEB_NODE_BASIC_PLASMA)
	design_ids = list(
		"engine_heater",
		"engine_plasma",
		"shuttle_control",
		"shuttle_creator",
		"wingpack",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/emp_basic //EMP tech for some reason
	id = TECHWEB_NODE_EMP_BASIC
	tech_tier = 2
	display_name = "Electromagnetic Theory"
	description = "Study into usage of frequencies in the electromagnetic spectrum."
	prereq_ids = list(TECHWEB_NODE_BASE)
	design_ids = list(
		"holopad",
		"holosign",
		"holosignatmos",
		"holosignengi",
		"holosignsec",
		"inducer",
		"inducersci",
		"tray_goggles",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/emp_adv
	id = TECHWEB_NODE_EMP_ADV
	tech_tier = 3
	display_name = "Advanced Electromagnetic Theory"
	description = "Determining whether reversing the polarity will actually help in a given situation."
	prereq_ids = list(TECHWEB_NODE_EMP_BASIC)
	design_ids = list("ultra_micro_laser")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)

/datum/techweb_node/emp_super
	id = TECHWEB_NODE_EMP_SUPER
	tech_tier = 4
	display_name = "Quantum Electromagnetic Technology"
	description = "Even better electromagnetic technology."
	prereq_ids = list(TECHWEB_NODE_EMP_ADV)
	design_ids = list("quadultra_micro_laser")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)

/datum/techweb_node/telecomms
	id = TECHWEB_NODE_TELECOMMS
	tech_tier = 3
	display_name = "Telecommunications Technology"
	description = "Subspace transmission technology for near-instant communications devices."
	prereq_ids = list(TECHWEB_NODE_BLUESPACE_BASIC, TECHWEB_NODE_COMPTECH)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	design_ids = list(
		"comm_monitor",
		"comm_server",
		"ntnet_relay",
		"s-amplifier",
		"s-analyzer",
		"s-ansible",
		"s-broadcaster",
		"s-bus",
		"s-crystal",
		"s-filter",
		"s-hub",
		"s-messaging",
		"s-processor",
		"s-receiver",
		"s-relay",
		"s-server",
		"s-transmitter",
		"s-treatment",
	)

/datum/techweb_node/comp_recordkeeping
	id = TECHWEB_NODE_COMP_RECORDKEEPING
	tech_tier = 2
	display_name = "Computerized Recordkeeping"
	description = "Organized record databases and how they're used."
	prereq_ids = list(TECHWEB_NODE_COMPTECH)
	design_ids = list(
		"automated_announcement",
		"records/medical",
		"prisonmanage",
		"secdata",
		"vendor",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/integrated_HUDs
	id = TECHWEB_NODE_INTEGRATED_HUDS
	tech_tier = 3
	display_name = "Integrated HUDs"
	description = "The usefulness of computerized records, projected straight onto your eyepiece!"
	prereq_ids = list(TECHWEB_NODE_COMP_RECORDKEEPING, TECHWEB_NODE_EMP_BASIC)
	design_ids = list(
		"diagnostic_hud",
		"health_hud",
		"scigoggles",
		"security_hud",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/NVGtech
	id = TECHWEB_NODE_NVGTECH
	tech_tier = 3
	display_name = "Night Vision Technology"
	description = "Allows seeing in the dark without actual light!"
	prereq_ids = list(TECHWEB_NODE_ADV_ENGI, TECHWEB_NODE_EMP_ADV, TECHWEB_NODE_INTEGRATED_HUDS)
	design_ids = list(
		"diagnostic_hud_night",
		"health_hud_night",
		"night_visision_goggles",
		"nvgmesons",
		"security_hud_night",
		"scigoggles_night",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)

/datum/techweb_node/exp_tools
	id = TECHWEB_NODE_EXP_TOOLS
	tech_tier = 3
	display_name = "Experimental Tools"
	description = "Highly advanced tools."
	design_ids = list(
		"exwelder",
		"handdrill",
		"jawsoflife",
		"laserscalpel",
		"mechanicalpinches",
		"searingtool",
		"wirebrush_adv",
	)
	prereq_ids = list(TECHWEB_NODE_ADV_ENGI)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/rcd_upgrade
	id = TECHWEB_NODE_RCD_UPGRADE
	tech_tier = 3
	display_name = "Rapid Device Upgrade Designs"
	description = "Unlocks new designs that improve rapid devices."
	design_ids = list(
		"rcd_upgrade_frames",
		"rcd_upgrade_furnishing",
		"rcd_upgrade_simple_circuits",
		"rpd_upgrade_unwrench"
	)
	prereq_ids = list(TECHWEB_NODE_ADV_ENGI)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/adv_rcd_upgrade
	id = TECHWEB_NODE_ADV_RCD_UPGRADE
	tech_tier = 4
	display_name = "Advanced RCD Designs Upgrade"
	description = "Unlocks new RCD designs."
	design_ids = list("rcd_upgrade_silo_link")
	prereq_ids = list(TECHWEB_NODE_BLUESPACE_TRAVEL, TECHWEB_NODE_RCD_UPGRADE)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
