
//Current rate: 135000 research points in 90 minutes

//Base Nodes
/datum/techweb_node/base
	id = "base"
	tech_tier = 0
	starting_node = TRUE
	display_name = "Basic Research Technology"
	description = "NT default research technologies."
	// Default research tech, prevents bricking
	design_ids = list(
		"antivirus",
		"basic_capacitor",
		"basic_cell",
		"basic_matter_bin",
		"basic_micro_laser",
		"basic_scanning",
		"beaker",
		"bucket",
		"circuit_imprinter",
		"design_disk",
		"dest_tagger",
		"destructive_analyzer",
		"experimentor",
		"fax",
		"glasses_prescription",
		"handlabel",
		"large_beaker",
		"larry",
		"light_replacer",
		"mechfab",
		"micro_mani",
		"package_wrap",
		"paystand",
		"plasmaglass",
		"plasmareinforcedglass",
		"plasteel",
		"plastitanium",
		"plastitaniumglass",
		"plumbing_rcd",
		"rdconsole",
		"rdserver",
		"rdservercontrol",
		"rglass",
		"sec_38",
		"sec_38b",
		"sec_beanbag_slug",
		"sec_Brslug",
		"sec_bshot",
		"sec_dart",
		"sec_Islug",
		"sec_rshot",
		"sec_slug",
		"space_heater",
		"tech_disk",
		"titaniumglass",
		"xenoa_labeler",
		"xlarge_beaker",
	)

/datum/techweb_node/mmi
	id = "mmi"
	tech_tier = 1
	starting_node = TRUE
	display_name = "Man Machine Interface"
	description = "A slightly Frankensteinian device that allows human brains to interface natively with software APIs."
	design_ids = list("mmi")

/datum/techweb_node/cyborg
	id = "cyborg"
	tech_tier = 1
	starting_node = TRUE
	display_name = "Cyborg Construction"
	description = "Sapient robots with preloaded tool modules and programmable laws."
	design_ids = list(
		"borg_chest",
		"borg_head",
		"borg_l_arm",
		"borg_l_leg",
		"borg_r_arm",
		"borg_r_leg",
		"borg_suit",
		"borg_upgrade_rename",
		"borg_upgrade_restart",
		"borgupload",
		"cyborgrecharger",
		"robocontrol",
		"sflash",
	)

/datum/techweb_node/mech
	id = "mecha"
	tech_tier = 1
	starting_node = TRUE
	display_name = "Mechanical Exosuits"
	description = "Mechanized exosuits that are several magnitudes stronger and more powerful than the average human."
	design_ids = list(
		"firefighter_chassis",
		"mech_hydraulic_clamp",
		"mech_recharger",
		"mecha_tracking",
		"mechacontrol",
		"mechapower",
		"ripley_chassis",
		"ripley_left_arm",
		"ripley_left_leg",
		"ripley_main",
		"ripley_peri",
		"ripley_right_arm",
		"ripley_right_leg",
		"ripley_torso",
		"ripleyupgrade",
	)

/datum/techweb_node/mech_tools
	id = "mech_tools"
	tech_tier = 1
	starting_node = TRUE
	display_name = "Basic Exosuit Equipment"
	description = "Various tools fit for basic mech units"
	design_ids = list(
		"mech_drill",
		"mech_extinguisher",
		"mech_mscanner",
	)

/datum/techweb_node/basic_tools
	id = "basic_tools"
	tech_tier = 0
	starting_node = TRUE
	display_name = "Basic Tools"
	description = "Basic mechanical, electronic, surgical and botanical tools."
	design_ids = list(
		"airlock_painter",
		"analyzer",
		"blood_filter",
		"cable_coil",
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

/datum/techweb_node/basic_circuitry
	id = "basic_circuitry"
	tech_tier = 0
	starting_node = TRUE
	display_name = "Basic Integrated Circuits"
	description = "Research on how to fully exploit the power of integrated circuits"
	design_ids = list(
		"circuit_multitool",
		"comp_arithmetic",
		"comp_clock",
		"comp_comparison",
		"comp_concat_list",
		"comp_concat",
		"comp_delay",
		"comp_direction",
		"comp_get_column",
		"comp_get_name",
		"comp_gps",
		"comp_health",
		"comp_hear",
		"comp_index_table",
		"comp_index",
		"comp_length",
		"comp_light",
		"comp_list_literal",
		"comp_logic",
		"comp_mmi",
		"comp_module",
		"comp_multiplexer",
		"comp_not",
		"comp_ntnet_receive",
		"comp_ntnet_send",
		"comp_pathfind",
		"comp_pressuresensor",
		"comp_radio",
		"comp_random",
		"comp_round",
		"comp_router",
		"comp_select_query",
		"comp_self",
		"comp_soundemitter",
		"comp_species",
		"comp_speech",
		"comp_speech",
		"comp_split",
		"comp_string_contains",
		"comp_tempsensor",
		"comp_textcase",
		"comp_tonumber",
		"comp_tostring",
		"comp_typecast",
		"compact_remote_shell",
		"component_printer",
		"integrated_circuit",
		"module_duplicator",
		"usb_cable",
	)

/////////////////////////Biotech/////////////////////////
/datum/techweb_node/biotech
	id = "biotech"
	tech_tier = 1
	display_name = "Biological Technology"
	description = "What makes us tick."	//the MC, silly!
	prereq_ids = list("base")
	design_ids = list(
		"beer_dispenser",
		"chem_dispenser",
		"chem_heater",
		"chem_master",
		"defibmount",
		"defibrillator",
		"genescanner",
		"medipen_atropine",
		"medipen_dex",
		"medipen_epi",
		"medspray",
		"minor_botanical_dispenser",
		"operating",
		"pandemic",
		"sleeper",
		"soda_dispenser",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/adv_biotech
	id = "adv_biotech"
	tech_tier = 2
	display_name = "Advanced Biotechnology"
	description = "Advanced Biotechnology"
	prereq_ids = list("biotech")
	design_ids = list(
		"crewpinpointer",
		"defibrillator_compact",
		"harvester",
		"holobarrier_med",
		"limbgrower",
		"meta_beaker",
		"piercesyringe",
		"plasmarefiller",
		"smoke_machine",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/bio_process
	id = "bio_process"
	tech_tier = 1
	display_name = "Biological Processing"
	description = "From slimes to kitchens."
	prereq_ids = list("biotech")
	design_ids = list(
		"deepfryer",
		"dish_drive",
		"fat_sucker",
		"gibber",
		"gibber",
		"microwave",
		"monkey_recycler",
		"processor",
		"reagentgrinder",
		"smartfridge",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/////////////////////////Advanced Surgery/////////////////////////
/datum/techweb_node/imp_wt_surgery
	id = "imp_wt_surgery"
	tech_tier = 2
	display_name = "Improved Wound-Tending Surgery"
	description = "Who would have known being more gentle with a hemostat decreases patient pain?"
	prereq_ids = list("adv_biotech")
	design_ids = list(
		"surgery_filter_upgrade",
		"surgery_heal_brute_upgrade",
		"surgery_heal_burn_upgrade",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)
	export_price = 1000


/datum/techweb_node/adv_surgery
	id = "adv_surgery"
	tech_tier = 3
	display_name = "Advanced Surgery"
	description = "When simple medicine doesn't cut it."
	prereq_ids = list("imp_wt_surgery")
	design_ids = list(
		"surgery_exp_dissection",
		"surgery_filter_upgrade_femto",
		"surgery_heal_brute_upgrade_femto",
		"surgery_heal_burn_upgrade_femto",
		"surgery_heal_combo",
		"surgery_lobotomy",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 4000

/datum/techweb_node/exp_surgery
	id = "exp_surgery"
	tech_tier = 4
	display_name = "Experimental Surgery"
	description = "When evolution isn't fast enough."
	prereq_ids = list("adv_surgery")
	design_ids = list(
		"surgery_cortex_folding",
		"surgery_cortex_imprint",
		"surgery_heal_combo_upgrade",
		"surgery_ligament_hook",
		"surgery_ligament_reinforcement",
		"surgery_muscled_veins",
		"surgery_nerve_ground",
		"surgery_nerve_splice",
		"surgery_pacify",
		"surgery_revival",
		"surgery_vein_thread",
		"surgery_viral_bond",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 5000

/datum/techweb_node/alien_surgery
	id = "alien_surgery"
	tech_tier = 5
	display_name = "Alien Surgery"
	description = "Abductors did nothing wrong."
	prereq_ids = list(
		"alientech",
		"exp_surgery",
	)
	design_ids = list(
		"surgery_brainwashing",
		"surgery_heal_combo_upgrade_femto",
		"surgery_zombie",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	export_price = 5000

/////////////////////////data theory tech/////////////////////////
/datum/techweb_node/datatheory //Computer science
	id = "datatheory"
	tech_tier = 1
	display_name = "Data Theory"
	description = "Big Data, in space!"
	prereq_ids = list("base")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/////////////////////////engineering tech/////////////////////////
/datum/techweb_node/engineering
	id = "engineering"
	tech_tier = 1
	display_name = "Industrial Engineering"
	description = "A refresher course on modern engineering technology."
	prereq_ids = list("base")
	design_ids = list(
		"aac_electronics",
		"adv_capacitor",
		"adv_matter_bin",
		"adv_scanning",
		"airalarm_electronics",
		"airlock_board",
		"antivirus2",
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
		"rad_collector",
		"recharger",
		"recycler",
		"researchdisk_locator",
		"rped",
		"scanner_gate",
		"solarcontrol",
		"stack_console",
		"stack_machine",
		"suit_storage_unit",
		"tesla_coil",
		"thermomachine",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 7500)
	export_price = 5000

/datum/techweb_node/adv_engi
	id = "adv_engi"
	tech_tier = 2
	display_name = "Advanced Engineering"
	description = "Pushing the boundaries of physics, one chainsaw-fist at a time."
	prereq_ids = list(
		"emp_basic",
		"engineering",
	)
	design_ids = list(
		"engine_goggles",
		"magboots",
		"ranged_analyzer",
		"rcd_loaded",
		"rpd_loaded",
		"weldingmask",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/anomaly
	id = "anomaly_research"
	tech_tier = 4
	display_name = "Anomaly Research"
	description = "Unlock the potential of the mysterious anomalies that appear on station."
	prereq_ids = list(
		"adv_engi",
		"practical_bluespace",
	)
	design_ids = list(
		"anomaly_neutralizer",
		"reactive_armour",
		"xenoa_gloves",
		"xenoa_list_console",
		"xenoa_list_pad",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 5000

/datum/techweb_node/high_efficiency
	id = "high_efficiency"
	tech_tier = 3
	display_name = "High Efficiency Parts"
	description = "Finely-tooled manufacturing techniques allowing for picometer-perfect precision levels."
	prereq_ids = list(
		"datatheory",
		"engineering",
	)
	design_ids = list(
		"pico_mani",
		"super_matter_bin",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 7500)
	export_price = 5000

/datum/techweb_node/adv_power
	id = "adv_power"
	tech_tier = 3
	display_name = "Advanced Power Manipulation"
	description = "How to get more zap."
	prereq_ids = list("engineering")
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
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/////////////////////////Bluespace tech/////////////////////////
/datum/techweb_node/bluespace_basic //Bluespace-memery
	id = "bluespace_basic"
	tech_tier = 4
	display_name = "Basic Bluespace Theory"
	description = "Basic studies into the mysterious alternate dimension known as bluespace."
	prereq_ids = list("base")
	design_ids = list(
		"beacon",
		"bluespace_crystal",
		"dragnetbeacon",
		"telesci_gps",
		"xenobioconsole",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/bluespace_travel
	id = "bluespace_travel"
	tech_tier = 5
	display_name = "Bluespace Travel"
	description = "Application of Bluespace for static teleportation technology."
	prereq_ids = list("practical_bluespace")
	design_ids = list(
		"bluespace_pod",
		"launchpad_console",
		"launchpad",
		"quantumpad",
		"tele_hub",
		"tele_station",
		"teleconsole",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 5000

/datum/techweb_node/micro_bluespace
	id = "micro_bluespace"
	tech_tier = 5
	display_name = "Miniaturized Bluespace Research"
	description = "Extreme reduction in space required for bluespace engines, leading to portable bluespace technology."
	prereq_ids = list(
		"bluespace_travel",
		"high_efficiency",
		"practical_bluespace",
	)
	design_ids = list(
		"antivirus4",
		"bluespace_matter_bin",
		"femto_mani",
		"quantum_keycard",
		"triphasic_scanning",
		"usb_wireless",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	export_price = 5000

/datum/techweb_node/bluespace_stabilisation
	id = "bluespace_anchor"
	tech_tier = 5
	display_name = "Bluespace Stabilisation"
	description = "Analyse and disrupt nearby bluespace instabilities, preventing anomalous translation."
	prereq_ids = list("micro_bluespace")
	design_ids = list("bsanchor")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 7500)
	export_price = 5000
	hidden = TRUE

/datum/techweb_node/bag_of_holding
	id = "bagofholding"
	tech_tier = 5
	display_name = "Bag of Holding"
	description = "Portable bluespace technology allows the production of backpacks that can store a greater volume of items than the volume of the bag."
	prereq_ids = list("micro_bluespace")
	design_ids = list("bag_holding")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000
	hidden = TRUE

/datum/techweb_node/wormhole_gun
	id = "wormholegun"
	tech_tier = 5
	display_name = "Bluespace Wormhole Projector"
	description = "Develop the research required to create a miniaturized bluespace wormhole projector, allowing you to jump between two places instantly."
	prereq_ids = list("micro_bluespace")
	design_ids = list("wormholeprojector")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 5000
	hidden = TRUE

/datum/techweb_node/quantum_spin
	id = "qswapper"
	tech_tier = 5
	display_name = "Quantum Spin Inverter"
	description = "Research the ability to create an experimental device that is able to swap the locations of two entities by switching their particles' spin values. Must be linked to another device to function."
	prereq_ids = list("micro_bluespace")
	design_ids = list("swapper")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000
	hidden = TRUE

/datum/techweb_node/practical_bluespace
	id = "practical_bluespace"
	tech_tier = 4
	display_name = "Applied Bluespace Research"
	description = "Using bluespace to make things faster and better."
	prereq_ids = list(
		"bluespace_basic",
		"engineering",
	)
	design_ids = list(
		"antivirus3",
		"bluespacebeaker",
		"bluespacesyringe",
    "bluespace_capsule",
		"bs_rped",
		"minerbag_holding",
		"ore_silo",
		"phasic_scanning",
		"roastingstick",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 5000

/datum/techweb_node/bluespace_power
	id = "bluespace_power"
	tech_tier = 4
	display_name = "Bluespace Power Technology"
	description = "Even more powerful.. power!"
	prereq_ids = list(
		"adv_power",
		"practical_bluespace",
	)
	design_ids = list(
		"bluespace_cell",
		"quadratic_capacitor",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/unregulated_bluespace
	id = "unregulated_bluespace"
	tech_tier = 5
	display_name = "Unregulated Bluespace Research"
	description = "Bluespace technology using unstable or unbalanced procedures, prone to damaging the fabric of bluespace. Outlawed by galactic conventions."
	prereq_ids = list(
		"bluespace_travel",
		"syndicate_basic",
	)
	design_ids = list("desynchronizer")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 2500


/////////////////////////plasma tech/////////////////////////
/datum/techweb_node/basic_plasma
	id = "basic_plasma"
	tech_tier = 1
	display_name = "Basic Plasma Research"
	description = "Research into the mysterious and dangerous substance, plasma."
	prereq_ids = list("engineering")
	design_ids = list("mech_generator")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/adv_plasma
	id = "adv_plasma"
	tech_tier = 2
	display_name = "Advanced Plasma Research"
	description = "Research on how to fully exploit the power of plasma."
	prereq_ids = list("basic_plasma")
	design_ids = list("mech_plasma_cutter")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/////////////////////////shuttle tech/////////////////////////
/datum/techweb_node/basic_shuttle_tech
	id = "basic_shuttle"
	tech_tier = 3
	display_name = "Basic Shuttle Research"
	description = "Research the technology required to create and use basic shuttles."
	prereq_ids = list(
		"adv_engi",
		"basic_plasma",
	)
	design_ids = list(
		"engine_heater",
		"engine_plasma",
		"shuttle_control",
		"shuttle_creator",
		"wingpack",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/nullspacebreaching
	id = "nullspacebreaching"
	display_name = "Nullspace Breaching"
	description = "Research into voidspace tunnelling, allowing us to significantly reduce flight times."
	prereq_ids = list(
		"alientech",
		"basic_shuttle",
	)
	design_ids = list(
		"engine_void",
		"wingpack_ayy",
		)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 12500)
	export_price = 5000

/datum/techweb_node/plasma_refiner
	id = "plasmarefiner"
	tech_tier = 4
	display_name = "Plasma Refining"
	description = "Development of a machine capable of safely and efficently converting plasma from a solid state to a gaseous state."
	prereq_ids = list("basic_shuttle")
	design_ids = list("plasma_refiner")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000
	hidden = TRUE

/////////////////////////integrated circuits tech/////////////////////////
/datum/techweb_node/math_circuits
	id = "math_circuits"
	tech_tier = 1
	display_name = "Math Circuitry"
	description = "Development of more complex mathematical components for all your number manipulating needs"
	prereq_ids = list(
		"basic_circuitry",
		"datatheory",
	)
	design_ids = list(
		"comp_adv_trig",
		"comp_bitflag",
		"comp_bitwise",
		"comp_hyper_trig",
		"comp_trig",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)

/datum/techweb_node/list_circuits
	id = "list_circuits"
	tech_tier = 1
	display_name = "List Circuitry"
	description = "Configures new integrated circuit components capable of representing one dimensional data structures such as arrays, stacks, and queues."
	prereq_ids = list(
		"basic_circuitry",
		"datatheory",
	)
	design_ids = list(
		"comp_append",
		"comp_index",
		"comp_length",
		"comp_list_constructor",
		"comp_list_length_constructor",
		"comp_pop",
		"comp_write",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)

/datum/techweb_node/adv_shells
	id = "adv_shells"
	tech_tier = 2
	display_name = "Advanced Shell Research"
	description = "Grants access to more complicated shell designs."
	prereq_ids = list(
		"basic_circuitry",
		"engineering",
	)
	design_ids = list(
		"assembly_shell",
		"bot_shell",
		"controller_shell",
		"door_shell",
		"money_bot_shell",
		"scanner_gate_shell",
		"scanner_shell",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/bci_shells
	id = "bci_shells"
	tech_tier = 2
	display_name = "Brain-Computer Interfaces"
	description = "Grants access to biocompatable shell designs and components."
	prereq_ids = list("adv_shells")
	design_ids = list(
		"bci_implanter",
		"bci_shell",
		"comp_bci_action",
		"comp_bar_overlay",
		"comp_counter_overlay",
		"comp_object_overlay",
		"comp_target_intercept",
		"comp_thought_listener",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 500)


/datum/techweb_node/movable_shells_tech
	id = "movable_shells"
	tech_tier = 2
	display_name = "Movable Shell Research"
	description = "Grants access to movable shells."
	prereq_ids = list(
		"adv_shells",
		"robotics",
	)
	design_ids = list(
		"comp_pull",
		"drone_shell",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3000)

/datum/techweb_node/server_shell_tech
	id = "server_shell"
	tech_tier = 2
	display_name = "Server Technology Research"
	description = "Grants access to a server shell that has a very high capacity for components."
	prereq_ids = list(
		"adv_shells",
		"computer_hardware_basic",
	)
	design_ids = list("server_shell")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3000)

/////////////////////////robotics tech/////////////////////////
/datum/techweb_node/robotics
	id = "robotics"
	tech_tier = 2
	display_name = "Basic Robotics Research"
	description = "Programmable machines that make our lives lazier."
	prereq_ids = list("base")
	design_ids = list("paicard")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/adv_robotics
	id = "adv_robotics"
	tech_tier = 3
	display_name = "Advanced Robotics Research"
	description = "It can even do the dishes!"
	prereq_ids = list("robotics")
	design_ids = list(
		"borg_upgrade_advancedmop",
		"borg_upgrade_diamonddrill",
		"borg_upgrade_trashofholding",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/neural_programming
	id = "neural_programming"
	tech_tier = 2
	display_name = "Neural Programming"
	description = "Study into networks of processing units that mimic our brains."
	prereq_ids = list(
		"biotech",
		"datatheory",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/posibrain
	id = "posibrain"
	display_name = "Positronic Brain"
	description = "Applied usage of neural technology allowing for autonomous AI units based on special metallic cubes with conductive and processing circuits."
	prereq_ids = list("neural_programming")
	design_ids = list("mmi_posi")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/cyborg_upg_util
	id = "cyborg_upg_util"
	tech_tier = 3
	display_name = "Cyborg Upgrades: Utility"
	description = "Utility upgrades for cyborgs."
	prereq_ids = list("engineering")
	design_ids = list(
		"borg_upgrade_circuitapp",
		"borg_upgrade_expand",
		"borg_upgrade_holding",
		"borg_upgrade_lavaproof",
		"borg_upgrade_rped",
		"borg_upgrade_selfrepair",
		"borg_upgrade_thrusters",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2000)
	export_price = 5000

/datum/techweb_node/cyborg_upg_med
	id = "cyborg_upg_med"
	tech_tier = 3
	display_name = "Cyborg Upgrades: Medical"
	description = "Medical upgrades for cyborgs."
	prereq_ids = list("adv_biotech")
	design_ids = list(
		"borg_upgrade_beakerapp",
		"borg_upgrade_defibrillator",
		"borg_upgrade_expandedsynthesiser",
		"borg_upgrade_piercinghypospray",
		"borg_upgrade_pinpointer",
		"borg_upgrade_surgicalprocessor",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2000)
	export_price = 5000

/datum/techweb_node/cyborg_upg_combat
	id = "cyborg_upg_combat"
	tech_tier = 3
	display_name = "Cyborg Upgrades: Combat"
	description = "Military grade upgrades for cyborgs."
	prereq_ids = list(
		"adv_engi",
		"adv_robotics",
		"weaponry",
	)
	design_ids = list("borg_upgrade_vtec")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 5000

/datum/techweb_node/cyborg_upg_service
	id = "cyborg_upg_service"
	tech_tier = 3
	display_name = "Cyborg Upgrades: Service"
	description = "Allows service borgs to specialize with various modules."
	prereq_ids = list("cyborg_upg_util")
	design_ids = list(
		"borg_upgrade_botany",
		"borg_upgrade_casino",
		"borg_upgrade_kitchen",
		"borg_upgrade_party",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1500)
	export_price = 1000

/datum/techweb_node/cyborg_upg_security
	id = "cyborg_upg_security"
	tech_tier = 4
	display_name = "Cyborg Upgrades: Security"
	description = "Militia grade upgrades for cyborgs."
	prereq_ids = list(
		"adv_engi",
		"adv_robotics",
		"weaponry",
	)
	design_ids = list(
		"borg_transform_security",
		"borg_upgrade_disablercooler",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 5000

/datum/techweb_node/cyborg_upg_security/New() //Techweb nodes don't have an init,
	. = ..()
	hidden = CONFIG_GET(flag/disable_secborg)

/datum/techweb_node/ai
	id = "ai"
	tech_tier = 3
	display_name = "Artificial Intelligence"
	description = "AI unit research."
	prereq_ids = list(
		"posibrain",
		"robotics",
	)
	design_ids = list(
		"aicore",
		"aifixer",
		"aiupload",
		"asimov_module",
		"borg_ai_control",
		"corporate_module",
		"default_module",
		"freeform_module",
		"freeformcore_module",
		"intellicard",
		"mecha_tracking_ai_control",
		"onehuman_module",
		"overlord_module",
		"oxygen_module",
		"paladin_module",
		"protectstation_module",
		"purge_module",
		"quarantine_module",
		"remove_module",
		"reset_module",
		"safeguard_module",
		"tyrant_module",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/////////////////////////EMP tech/////////////////////////
/datum/techweb_node/emp_basic //EMP tech for some reason
	id = "emp_basic"
	tech_tier = 2
	display_name = "Electromagnetic Theory"
	description = "Study into usage of frequencies in the electromagnetic spectrum."
	prereq_ids = list("base")
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
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/emp_adv
	id = "emp_adv"
	tech_tier = 3
	display_name = "Advanced Electromagnetic Theory"
	description = "Determining whether reversing the polarity will actually help in a given situation."
	prereq_ids = list("emp_basic")
	design_ids = list("ultra_micro_laser")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3000)
	export_price = 5000

/datum/techweb_node/emp_super
	id = "emp_super"
	tech_tier = 4
	display_name = "Quantum Electromagnetic Technology"	//bs
	description = "Even better electromagnetic technology."
	prereq_ids = list("emp_adv")
	design_ids = list("quadultra_micro_laser")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3000)
	export_price = 5000

/////////////////////////Clown tech/////////////////////////
/datum/techweb_node/clown
	id = "clown"
	tech_tier = 2
	display_name = "Clown Technology"
	description = "Honk?!"
	prereq_ids = list("base")
	design_ids = list(
		"air_horn",
		"borg_transform_clown",
		"clown_mine",
		"honk_chassis",
		"honk_head",
		"honk_left_arm",
		"honk_left_leg",
		"honk_right_arm",
		"honk_right_leg",
		"honk_torso",
		"honker_main",
		"honker_peri",
		"honker_targ",
		"implant_trombone",
		"mech_banana_mortar",
		"mech_honker",
		"mech_mousetrap_mortar",
		"mech_punching_face",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

////////////////////////Computer tech////////////////////////
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
		"objective",
		"rdcamera",
		"seccamera",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2000)
	export_price = 5000

/datum/techweb_node/computer_hardware_basic				//Modular computers are shitty and nearly useless so until someone makes them actually useful this can be easy to get.
	id = "computer_hardware_basic"
	tech_tier = 1
	display_name = "Computer Hardware"
	description = "How computer hardware are made."
	prereq_ids = list("comptech")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)  //they are really shitty
	export_price = 2000
	design_ids = list(
		"aislot",
		"APClink",
		"bat_advanced",
		"bat_control",
		"bat_micro",
		"bat_nano",
		"bat_normal",
		"bat_super",
		"cardslot",
		"cpu_normal",
		"cpu_small",
		"hdd_advanced",
		"hdd_basic",
		"hdd_cluster",
		"hdd_super",
		"miniprinter",
		"netcard_advanced",
		"netcard_basic",
		"netcard_wired",
		"pcpu_normal",
		"pcpu_small",
		"portadrive_advanced",
		"portadrive_basic",
		"portadrive_super",
		"sensorpackage",
		"ssd_micro",
		"ssd_small",
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
	export_price = 2000

/datum/techweb_node/comp_recordkeeping
	id = "comp_recordkeeping"
	tech_tier = 2
	display_name = "Computerized Recordkeeping"
	description = "Organized record databases and how they're used."
	prereq_ids = list("comptech")
	design_ids = list(
		"automated_announcement",
		"med_data",
		"prisonmanage",
		"secdata",
		"vendor",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)
	export_price = 2000

/datum/techweb_node/telecomms
	id = "telecomms"
	tech_tier = 3
	display_name = "Telecommunications Technology"
	description = "Subspace transmission technology for near-instant communications devices."
	prereq_ids = list(
		"bluespace_basic",
		"comptech",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000
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

/datum/techweb_node/integrated_HUDs
	id = "integrated_HUDs"
	tech_tier = 3
	display_name = "Integrated HUDs"
	description = "The usefulness of computerized records, projected straight onto your eyepiece!"
	prereq_ids = list(
		"comp_recordkeeping",
		"emp_basic",
	)
	design_ids = list(
		"diagnostic_hud",
		"health_hud",
		"scigoggles",
		"security_hud",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1500)
	export_price = 5000

/datum/techweb_node/NVGtech
	id = "NVGtech"
	tech_tier = 3
	display_name = "Night Vision Technology"
	description = "Allows seeing in the dark without actual light!"
	prereq_ids = list(
		"adv_engi",
		"emp_adv",
		"integrated_HUDs",
	)
	design_ids = list(
		"diagnostic_hud_night",
		"health_hud_night",
		"night_visision_goggles",
		"nvgmesons",
		"security_hud_night",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 5000

////////////////////////Medical////////////////////////
/datum/techweb_node/cloning
	id = "cloning"
	tech_tier = 3
	display_name = "Genetic Engineering"
	description = "We have the technology to make him."
	prereq_ids = list("biotech")
	design_ids = list(
		"clonecontrol",
		"clonepod",
		"clonescanner",
		"cloning_disk",
		"scan_console",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/cryotech
	id = "cryotech"
	tech_tier = 3
	display_name = "Cryostasis Technology"
	description = "Smart freezing of objects to preserve them!"
	prereq_ids = list(
		"adv_engi",
		"biotech",
	)
	design_ids = list(
		"cryo_Grenade",
		"cryotube",
		"noreactsyringe",
		"splitbeaker",
		"stasis",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2000)
	export_price = 4000

/datum/techweb_node/subdermal_implants
	id = "subdermal_implants"
	tech_tier = 4
	display_name = "Subdermal Implants"
	description = "Electronic implants buried beneath the skin."
	prereq_ids = list("biotech")
	design_ids = list(
		"c38_trac",
		"implant_chem",
		"implant_tracking",
		"implantcase",
		"implanter",
		"locator",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/cyber_organs
	id = "cyber_organs"
	tech_tier = 4
	display_name = "Cybernetic Organs"
	description = "We have the technology to rebuild him."
	prereq_ids = list("adv_biotech")
	design_ids = list(
		"cybernetic_heart",
		"cybernetic_liver",
		"cybernetic_lungs",
		"cybernetic_stomach",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)
	export_price = 5000

/datum/techweb_node/med_scanning
	id = "med_scanner"
	tech_tier = 3
	display_name = "Medical Scanning"
	description = "By taking apart the ones we already had, we figured out how to make them ourselves."
	prereq_ids = list("adv_biotech")
	design_ids = list("healthanalyzer")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 5000

/datum/techweb_node/adv_med_scanning
	id = "adv_med_scanner"
	tech_tier = 4
	display_name = "Advanced Medical Scanning"
	description = "By integrating advanced AI into our scanners, we can diagnose even the most minute of abnormalities. Well, the AI is doing it, but we get the credit."
	prereq_ids = list(
		"med_scanner",
		"posibrain",
	)
	design_ids = list("healthanalyzer_advanced")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 5000

/datum/techweb_node/cyber_organs_upgraded
	id = "cyber_organs_upgraded"
	tech_tier = 5
	display_name = "Upgraded Cybernetic Organs"
	description = "We have the technology to upgrade him."
	prereq_ids = list("cyber_organs")
	design_ids = list(
		"cybernetic_heart_u",
		"cybernetic_liver_u",
		"cybernetic_lungs_u",
		"cybernetic_stomach_u",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1500)
	export_price = 5000

/datum/techweb_node/ipc_organs
	id = "ipc_organs"
	tech_tier = 3
	display_name = "IPC Parts"
	description = "We have the technology to replace him."
	prereq_ids = list(
		"cyber_organs",
		"robotics",
	)
	design_ids = list(
		"power_cord",
		"robotic_ears",
		"robotic_eyes",
		"robotic_liver",
		"robotic_stomach",
		"robotic_tongue",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1500)
	export_price = 5000

/datum/techweb_node/cyber_implants
	id = "cyber_implants"
	tech_tier = 4
	display_name = "Cybernetic Implants"
	description = "Electronic implants that improve humans."
	prereq_ids = list(
		"adv_biotech",
		"datatheory",
	)
	design_ids = list(
		"ci-breather",
		"ci-diaghud",
		"ci-gloweyes",
		"ci-medhud",
		"ci-nutriment",
		"ci-sechud",
		"ci-welding",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/adv_cyber_implants
	id = "adv_cyber_implants"
	tech_tier = 5
	display_name = "Advanced Cybernetic Implants"
	description = "Upgraded and more powerful cybernetic implants."
	prereq_ids = list(
		"cyber_implants",
		"integrated_HUDs",
		"neural_programming",
	)
	design_ids = list(
		"ci-botany",
		"ci-janitor",
		"ci-nutrimentplus",
		"ci-reviver",
		"ci-surgery",
		"ci-toolset",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/combat_cyber_implants
	id = "combat_cyber_implants"
	tech_tier = 5
	display_name = "Combat Cybernetic Implants"
	description = "Military grade combat implants to improve performance."
	prereq_ids = list(
		"adv_cyber_implants",
		"high_efficiency",
		"NVGtech",
		"weaponry",
	)
	design_ids = list(
		"ci-antidrop",
		"ci-antistun",
		"ci-thermals",
		"ci-thrusters",
		"ci-xray",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000
	hidden = TRUE

/datum/techweb_node/adv_combat_cyber_implants
	id = "adv_combat_cyber_implants"
	tech_tier = 5
	display_name = "Advanced Combat Cybernetic Implants"
	description = "Experimental military cybernetic weapons."
	prereq_ids = list(
		"adv_cyber_implants",
		"syndicate_basic",
	)
	design_ids = list("hydraulic_blade")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	export_price = 10000
	hidden = TRUE

/datum/techweb_node/linkedsurgery_implant
	id = "linkedsurgery_implant"
	tech_tier = 5
	display_name = "Surgical Serverlink Brain Implant"
	description = "A bluespace implant which a holder can read surgical programs from their server with."
	prereq_ids = list(
		"exp_surgery",
		"micro_bluespace",
	)
	design_ids = list("ci-linkedsurgery")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	export_price = 10000
	hidden = TRUE

////////////////////////Tools////////////////////////
/datum/techweb_node/basic_mining
	id = "basic_mining"
	tech_tier = 1
	display_name = "Mining Technology"
	description = "Better than Efficiency V."
	prereq_ids = list("engineering")
	design_ids = list(
		"cargoexpress",
		"cooldownmod",
		"damagemod",
		"drill",
		"exploration_equipment_vendor",
		"hypermod",
		"mining_equipment_vendor",
		"ore_redemption",
		"rangemod",
		"superresonator",
		"triggermod",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/adv_mining
	id = "adv_mining"
	tech_tier = 3
	display_name = "Advanced Mining Technology"
	description = "Efficiency Level 127"	//dumb mc references
	prereq_ids = list(
		"basic_mining",
		"adv_engi",
		"adv_power",
		"adv_plasma",
	)
	design_ids = list(
		"borg_upgrade_cutter",
		"drill_diamond",
		"hypermodplus",
		"jackhammer",
		"repeatermod",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/janitor
	id = "janitor"
	tech_tier = 1
	display_name = "Advanced Sanitation Technology"
	description = "Clean things better, faster, stronger, and harder!"
	prereq_ids = list("adv_engi")
	design_ids = list(
		"advmop",
		"beartrap",
		"blutrash",
		"buffer",
		"light_replacer_bluespace",
		"spraybottle",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/botany
	id = "botany"
	tech_tier = 1
	display_name = "Botanical Engineering"
	description = "Botanical tools"
	prereq_ids = list(
		"adv_engi",
		"biotech",
	)
	design_ids = list(
		"biogenerator",
		"diskplantgene",
		"flora_gun",
		"hydro_tray",
		"plantgenes",
		"portaseeder",
		"seed_extractor",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/exp_tools
	id = "exp_tools"
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
	prereq_ids = list("adv_engi")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/sec_basic
	id = "sec_basic"
	tech_tier = 1
	display_name = "Basic Security Equipment"
	description = "Standard equipment used by security."
	design_ids = list(
		"bola_energy",
		"evidencebag",
		"flashbulb",
		"pepperspray",
		"seclite",
		"zipties",
	)
	prereq_ids = list("base")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)
	export_price = 5000

/datum/techweb_node/rcd_upgrade
	id = "rcd_upgrade"
	tech_tier = 3
	display_name = "Rapid Device Upgrade Designs"
	description = "Unlocks new designs that improve rapid devices."
	design_ids = list(
		"rcd_upgrade_frames",
		"rcd_upgrade_simple_circuits",
		"rpd_upgrade_unwrench",
	)
	prereq_ids = list("adv_engi")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/adv_rcd_upgrade
	id = "adv_rcd_upgrade"
	tech_tier = 4
	display_name = "Advanced RCD Designs Upgrade"
	description = "Unlocks new RCD designs."
	design_ids = list("rcd_upgrade_silo_link")
	prereq_ids = list(
		"bluespace_travel",
		"rcd_upgrade",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 5000


/////////////////////////weaponry tech/////////////////////////
/datum/techweb_node/landmine
	id = "nonlethal_mines"
	tech_tier = 3
	display_name = "Nonlethal Landmine Technology"
	description = "Our weapons technicians could perhaps work out methods for the creation of nonlethal landmines for security teams."
	prereq_ids = list("sec_basic")
	design_ids = list("stunmine")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)
	export_price = 5000

/datum/techweb_node/weaponry
	id = "weaponry"
	tech_tier = 3
	display_name = "Weapon Development Technology"
	description = "Our researchers have found new ways to weaponize just about everything now."
	prereq_ids = list("engineering")
	design_ids = list(
		"pin_testing",
		"tele_shield",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	export_price = 5000

/datum/techweb_node/smartmine
	id = "smart_mines"
	tech_tier = 4
	display_name = "Smart Landmine Technology"
	description = "Using IFF technology, we could develop smartmines that do not trigger for those who are mindshielded."
	prereq_ids = list(
		"engineering",
		"nonlethal_mines",
		"weaponry",
	)
	design_ids = list("stunmine_adv")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/adv_weaponry
	id = "adv_weaponry"
	tech_tier = 4
	display_name = "Advanced Weapon Development Technology"
	description = "Our weapons are breaking the rules of reality by now."
	prereq_ids = list(
		"adv_engi",
		"weaponry",
	)
	design_ids = list("pin_loyalty")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	export_price = 5000

/datum/techweb_node/advmine
	id = "adv_mines"
	tech_tier = 4
	display_name = "Advanced Landmine Technology"
	description = "We can further develop our smartmines to build some extremely capable designs."
	prereq_ids = list(
		"adv_engi",
		"smart_mines",
		"weaponry",
	)
	design_ids = list(
		"stunmine_heavy",
		"stunmine_rapid",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/electric_weapons
	id = "electronic_weapons"
	tech_tier = 4
	display_name = "Electric Weapons"
	description = "Weapons using electric technology"
	prereq_ids = list(
		"adv_power",
		"emp_basic",
		"weaponry",
	)
	design_ids = list(
		"ioncarbine",
		"stunrevolver",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/radioactive_weapons
	id = "radioactive_weapons"
	tech_tier = 5
	display_name = "Radioactive Weaponry"
	description = "Weapons using radioactive technology."
	prereq_ids = list(
		"adv_engi",
		"adv_weaponry",
	)
	design_ids = list("nuclear_gun")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000
	hidden = TRUE

/datum/techweb_node/medical_weapons
	id = "medical_weapons"
	tech_tier = 4
	display_name = "Medical Weaponry"
	description = "Weapons using medical technology."
	prereq_ids = list(
		"adv_biotech",
		"weaponry",
	)
	design_ids = list("rapidsyringe")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/beam_weapons
	id = "beam_weapons"
	tech_tier = 4
	display_name = "Beam Weaponry"
	description = "Various basic beam weapons"
	prereq_ids = list("adv_weaponry")
	design_ids = list(
		"temp_gun",
		"xray_laser",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000
	hidden = TRUE

/datum/techweb_node/adv_beam_weapons
	id = "adv_beam_weapons"
	tech_tier = 5
	display_name = "Advanced Beam Weaponry"
	description = "Various advanced beam weapons"
	prereq_ids = list("adv_weaponry")
	design_ids = list("beamrifle")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000
	hidden = TRUE

/datum/techweb_node/explosive_weapons
	id = "explosive_weapons"
	tech_tier = 3
	display_name = "Explosive & Pyrotechnical Weaponry"
	description = "If the light stuff just won't do it."
	prereq_ids = list("adv_weaponry")
	design_ids = list(
		"adv_Grenade",
		"large_Grenade",
		"pyro_Grenade",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/ballistic_weapons
	id = "ballistic_weapons"
	tech_tier = 3
	display_name = "Ballistic Weaponry"
	description = "This isn't research.. This is reverse-engineering!"
	prereq_ids = list("weaponry")
	design_ids = list(
		"mag_oldsmg_ap",
		"mag_oldsmg_ic",
		"mag_oldsmg_rubber",
		"mag_oldsmg",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/exotic_ammo
	id = "exotic_ammo"
	tech_tier = 4
	display_name = "Exotic Ammunition"
	description = "They won't know what hit em."
	prereq_ids = list(
		"adv_weaponry",
		"medical_weapons",
	)
	design_ids = list(
		"techshotshell",
		"c38_hotshot",
		"c38_iceblox",
		"shotgundartcryostasis",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000
	hidden = TRUE

/datum/techweb_node/gravity_gun
	id = "gravity_gun"
	tech_tier = 5
	display_name = "One-point Bluespace-gravitational Manipulator"
	description = "Fancy wording for gravity gun."
	prereq_ids = list(
		"adv_weaponry",
		"bluespace_travel",
	)
	design_ids = list(
		"gravitygun",
		"mech_gravcatapult",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

////////////////////////mech technology////////////////////////
/datum/techweb_node/adv_mecha
	id = "adv_mecha"
	tech_tier = 3
	display_name = "Advanced Exosuits"
	description = "For when you just aren't Gundam enough."
	prereq_ids = list("adv_robotics")
	design_ids = list("mech_repair_droid")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/odysseus
	id = "mecha_odysseus"
	tech_tier = 3
	display_name = "EXOSUIT: Odysseus"
	description = "Odysseus exosuit designs"
	prereq_ids = list("base")
	design_ids = list(
		"odysseus_chassis",
		"odysseus_head",
		"odysseus_left_arm",
		"odysseus_left_leg",
		"odysseus_main",
		"odysseus_peri",
		"odysseus_right_arm",
		"odysseus_right_leg",
		"odysseus_torso",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/gygax
	id = "mech_gygax"
	tech_tier = 4
	display_name = "EXOSUIT: Gygax"
	description = "Gygax exosuit designs"
	prereq_ids = list("adv_mecha",
		"weaponry")
	design_ids = list(
		"gygax_armor",
		"gygax_chassis",
		"gygax_head",
		"gygax_left_arm",
		"gygax_left_leg",
		"gygax_main",
		"gygax_peri",
		"gygax_right_arm",
		"gygax_right_leg",
		"gygax_targ",
		"gygax_torso",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/durand
	id = "mech_durand"
	tech_tier = 4
	display_name = "EXOSUIT: Durand"
	description = "Durand exosuit designs"
	prereq_ids = list(
		"adv_mecha",
		"adv_weaponry",
	)
	design_ids = list(
		"durand_armor",
		"durand_chassis",
		"durand_head",
		"durand_left_arm",
		"durand_left_leg",
		"durand_main",
		"durand_peri",
		"durand_right_arm",
		"durand_right_leg",
		"durand_targ",
		"durand_torso",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/phazon
	id = "mecha_phazon"
	tech_tier = 5
	display_name = "EXOSUIT: Phazon"
	description = "Phazon exosuit designs"
	prereq_ids = list(
		"adv_mecha",
		"micro_bluespace",
		"weaponry",
	)
	design_ids = list(
		"phazon_chassis",
		"phazon_torso",
		"phazon_head",
		"phazon_left_arm",
		"phazon_right_arm",
		"phazon_left_leg",
		"phazon_right_leg",
		"phazon_main",
		"phazon_peri",
		"phazon_targ",
		"phazon_armor",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000
	hidden = TRUE

/datum/techweb_node/adv_mecha_tools
	id = "adv_mecha_tools"
	tech_tier = 3
	display_name = "Advanced Exosuit Equipment"
	description = "Tools for high level mech suits"
	prereq_ids = list("adv_mecha")
	design_ids = list(
		"mech_rcd",
		"mech_thrusters",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/med_mech_tools
	id = "med_mech_tools"
	tech_tier = 3
	display_name = "Medical Exosuit Equipment"
	description = "Tools for high level mech suits"
	prereq_ids = list("adv_biotech")
	design_ids = list(
		"mech_medi_beam",
		"mech_sleeper",
		"mech_syringe_gun",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mech_modules
	id = "adv_mecha_modules"
	tech_tier = 3
	display_name = "Simple Exosuit Modules"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list(
		"adv_mecha",
		"bluespace_power",
	)
	design_ids = list(
		"mech_ccw_armor",
		"mech_energy_relay",
		"mech_generator_nuclear",
		"mech_proj_armor",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mech_scattershot
	id = "mecha_tools"
	tech_tier = 4
	display_name = "Exosuit Weapon (LBX AC 10 \"Scattershot\")"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("ballistic_weapons")
	design_ids = list("mech_scattershot")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mech_carbine
	id = "mech_carbine"
	tech_tier = 4
	display_name = "Exosuit Weapon (FNX-99 \"Hades\" Carbine)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("ballistic_weapons")
	design_ids = list("mech_carbine")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mech_ion
	id = "mmech_ion"
	tech_tier = 4
	display_name = "Exosuit Weapon (MKIV Ion Heavy Cannon)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list(
		"electronic_weapons",
		"emp_adv",
	)
	design_ids = list("mech_ion")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mech_tesla
	id = "mech_tesla"
	tech_tier = 4
	display_name = "Exosuit Weapon (MKI Tesla Cannon)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("electronic_weapons",
		"adv_power")
	design_ids = list("mech_tesla")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mech_laser
	id = "mech_laser"
	tech_tier = 4
	display_name = "Exosuit Weapon (CH-PS \"Immolator\" Laser)"
	description = "A basic piece of mech weaponry"
	prereq_ids = list("beam_weapons")
	design_ids = list("mech_laser")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mech_laser_heavy
	id = "mech_laser_heavy"
	tech_tier = 4
	display_name = "Exosuit Weapon (CH-LC \"Solaris\" Laser Cannon)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("adv_beam_weapons")
	design_ids = list("mech_laser_heavy")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mech_disabler
	id = "mech_disabler"
	tech_tier = 4
	display_name =  "Exosuit Weapon (CH-DS \"Peacemaker\" Mounted Disabler)"
	description = "A basic piece of mech weaponry"
	prereq_ids = list("beam_weapons")
	design_ids = list("mech_disabler")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mech_grenade_launcher
	id = "mech_grenade_launcher"
	tech_tier = 4
	display_name = "Exosuit Weapon (SGL-6 Grenade Launcher)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("explosive_weapons")
	design_ids = list("mech_grenade_launcher")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/clusterbang_launcher
	id = "clusterbang_launcher"
	tech_tier = 4
	display_name = "Exosuit Module (SOB-3 Clusterbang Launcher)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("explosive_weapons")
	design_ids = list("clusterbang_launcher")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mech_teleporter
	id = "mech_teleporter"
	tech_tier = 4
	display_name = "Exosuit Module (Teleporter Module)"
	description = "An advanced piece of mech Equipment"
	prereq_ids = list("micro_bluespace")
	design_ids = list("mech_teleporter")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mech_wormhole_gen
	id = "mech_wormhole_gen"
	tech_tier = 4
	display_name = "Exosuit Module (Localized Wormhole Generator)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("bluespace_travel")
	design_ids = list("mech_wormhole_gen")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mech_lmg
	id = "mech_lmg"
	tech_tier = 4
	display_name = "Exosuit Weapon (\"Ultra AC 2\" LMG)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("ballistic_weapons")
	design_ids = list("mech_lmg")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mech_diamond_drill
	id = "mech_diamond_drill"
	tech_tier = 3
	display_name =  "Exosuit Diamond Drill"
	description = "A diamond drill fit for a large exosuit"
	prereq_ids = list("adv_mining")
	design_ids = list("mech_diamond_drill")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/////////////////////////Nanites/////////////////////////
/datum/techweb_node/nanite_base
	id = "nanite_base"
	tech_tier = 2
	display_name = "Basic Nanite Programming"
	description = "The basics of nanite construction and programming."
	prereq_ids = list("datatheory")
	design_ids = list(
		"access_nanites",
		"monitoring_nanites",
		"nanite_chamber_control",
		"nanite_chamber",
		"nanite_cloud_control",
		"nanite_disk",
		"nanite_program_hub",
		"nanite_programmer",
		"nanite_remote",
		"nanite_scanner",
		"public_nanite_chamber",
		"red_diag_nanites",
		"relay_nanites",
		"relay_repeater_nanites",
		"repairing_nanites",
		"repeater_nanites",
		"research_nanites",
		"researchplus_nanites",
		"sensor_nanite_volume",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)
	export_price = 5000

/datum/techweb_node/nanite_smart
	id = "nanite_smart"
	tech_tier = 2
	display_name = "Smart Nanite Programming"
	description = "Nanite programs that require nanites to perform complex actions, act independently, roam or seek targets."
	prereq_ids = list(
		"nanite_base",
		"robotics",
	)
	design_ids = list(
		"memleak_nanites",
		"metabolic_nanites",
		"purging_nanites",
		"sensor_voice_nanites",
		"stealth_nanites",
		"voice_nanites",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 500, TECHWEB_POINT_TYPE_NANITES = 500)
	export_price = 4000

/datum/techweb_node/nanite_mesh
	id = "nanite_mesh"
	tech_tier = 2
	display_name = "Mesh Nanite Programming"
	description = "Nanite programs that require static structures and membranes."
	prereq_ids = list(
		"engineering",
		"nanite_base",
	)
	design_ids = list(
		"conductive_nanites",
		"cryo_nanites",
		"dermal_button_nanites",
		"emp_nanites",
		"hardening_nanites",
		"refractive_nanites",
		"shock_nanites",
		"temperature_nanites",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 500, TECHWEB_POINT_TYPE_NANITES = 500)
	export_price = 5000

/datum/techweb_node/nanite_bio
	id = "nanite_bio"
	tech_tier = 3
	display_name = "Biological Nanite Programming"
	description = "Nanite programs that require complex biological interaction."
	prereq_ids = list(
		"biotech",
		"nanite_base",
	)
	design_ids = list(
		"bloodheal_nanites",
		"coagulating_nanites",
		"flesheating_nanites",
		"poison_nanites",
		"regenerative_nanites",
		"sensor_crit_nanites",
		"sensor_damage_nanites",
		"sensor_death_nanites",
		"sensor_health_nanites",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 500, TECHWEB_POINT_TYPE_NANITES = 500)
	export_price = 5000

/datum/techweb_node/nanite_neural
	id = "nanite_neural"
	tech_tier = 3
	display_name = "Neural Nanite Programming"
	description = "Nanite programs affecting nerves and brain matter."
	prereq_ids = list("nanite_bio")
	design_ids = list(
		"bad_mood_nanites",
		"brainheal_nanites",
		"good_mood_nanites",
		"nervous_nanites",
		"paralyzing_nanites",
		"selfscan_nanites",
		"stun_nanites",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000, TECHWEB_POINT_TYPE_NANITES = 1000)
	export_price = 5000

/datum/techweb_node/nanite_synaptic
	id = "nanite_synaptic"
	tech_tier = 4
	display_name = "Synaptic Nanite Programming"
	description = "Nanite programs affecting mind and thoughts."
	prereq_ids = list(
		"nanite_neural",
		"neural_programming",
	)
	design_ids = list(
		"blinding_nanites",
		"hallucination_nanites",
		"mindshield_nanites",
		"mute_nanites",
		"pacifying_nanites",
		"sleep_nanites",
		"speech_nanites",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000, TECHWEB_POINT_TYPE_NANITES = 1000)
	export_price = 5000

/datum/techweb_node/nanite_harmonic
	id = "nanite_harmonic"
	tech_tier = 4
	display_name = "Harmonic Nanite Programming"
	description = "Nanite programs that require seamless integration between nanites and biology."
	prereq_ids = list(
		"nanite_bio",
		"nanite_mesh",
		"nanite_smart",
	)
	design_ids = list(
		"adrenaline_nanites",
		"aggressive_nanites",
		"brainheal_plus_nanites",
		"defib_nanites",
		"fakedeath_nanites",
		"purging_plus_nanites",
		"regenerative_plus_nanites",
		"sensor_species_nanites",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2000, TECHWEB_POINT_TYPE_NANITES = 2000)
	export_price = 8000

/datum/techweb_node/nanite_combat
	id = "nanite_military"
	tech_tier = 5
	display_name = "Military Nanite Programming"
	description = "Nanite programs that perform military-grade functions."
	prereq_ids = list(
		"nanite_harmonic",
		"syndicate_basic",
	)
	design_ids = list(
		"explosive_nanites",
		"haste_nanites",
		"meltdown_nanites",
		"nanite_sting_nanites",
		"pyro_nanites",
		"viral_nanites",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500, TECHWEB_POINT_TYPE_NANITES = 2500)
	export_price = 12500

/datum/techweb_node/nanite_hazard
	id = "nanite_hazard"
	tech_tier = 5
	display_name = "Hazard Nanite Programs"
	description = "Extremely advanced Nanite programs with the potential of being extremely dangerous."
	prereq_ids = list(
		"alientech",
		"nanite_harmonic",
	)
	design_ids = list(
		"mindcontrol_nanites",
		"mitosis_nanites",
		"spreading_nanites",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3000, TECHWEB_POINT_TYPE_NANITES = 4000)
	export_price = 15000

////////////////////////Alien technology////////////////////////
/datum/techweb_node/alientech //AYYYYYYYYLMAOO tech
	id = "alientech"
	tech_tier = 5
	display_name = "Alien Technology"
	description = "Things used by the greys."
	prereq_ids = list(
		"biotech",
		"engineering"
	)
	boost_item_paths = list(
		/obj/item/abductor,
		/obj/item/abductor/baton,
		/obj/item/cautery/alien,
		/obj/item/circuitboard/machine/abductor,
		/obj/item/circular_saw/alien,
		/obj/item/crowbar/abductor,
		/obj/item/gun/energy/alien,
		/obj/item/hemostat/alien,
		/obj/item/multitool/abductor,
		/obj/item/retractor/alien,
		/obj/item/scalpel/alien,
		/obj/item/screwdriver/abductor,
		/obj/item/surgicaldrill/alien,
		/obj/item/weldingtool/abductor,
		/obj/item/wirecutters/abductor,
		/obj/item/wrench/abductor,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 20000
	hidden = TRUE
	design_ids = list("alienalloy")

/datum/techweb_node/alientech/on_research() //Unlocks the Zeta shuttle for purchase
		SSshuttle.shuttle_purchase_requirements_met |= SHUTTLE_UNLOCK_ALIENTECH

/datum/techweb_node/alien_bio
	id = "alien_bio"
	tech_tier = 5
	display_name = "Alien Biological Tools"
	description = "Advanced biological tools."
	prereq_ids = list(
		"adv_biotech",
		"alientech",
	)
	design_ids = list(
		"alien_cautery",
		"alien_drill",
		"alien_hemostat",
		"alien_retractor",
		"alien_saw",
		"alien_scalpel",
	)
	boost_item_paths = list(
		/obj/item/abductor,
		/obj/item/abductor/baton,
		/obj/item/cautery/alien,
		/obj/item/circuitboard/machine/abductor,
		/obj/item/circular_saw/alien,
		/obj/item/crowbar/abductor,
		/obj/item/gun/energy/alien,
		/obj/item/hemostat/alien,
		/obj/item/multitool/abductor,
		/obj/item/retractor/alien,
		/obj/item/scalpel/alien,
		/obj/item/screwdriver/abductor,
		/obj/item/surgicaldrill/alien,
		/obj/item/weldingtool/abductor,
		/obj/item/wirecutters/abductor,
		/obj/item/wrench/abductor,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 20000
	hidden = TRUE

/datum/techweb_node/alien_engi
	id = "alien_engi"
	tech_tier = 5
	display_name = "Alien Engineering"
	description = "Alien engineering tools"
	prereq_ids = list(
		"adv_engi",
		"alientech",
	)
	design_ids = list(
		"alien_crowbar",
		"alien_multitool",
		"alien_screwdriver",
		"alien_welder",
		"alien_wirecutters",
		"alien_wrench",
	)
	boost_item_paths = list(
		/obj/item/abductor,
		/obj/item/abductor/baton,
		/obj/item/circuitboard/machine/abductor,
		/obj/item/crowbar/abductor,
		/obj/item/multitool/abductor,
		/obj/item/screwdriver/abductor,
		/obj/item/weldingtool/abductor,
		/obj/item/wirecutters/abductor,
		/obj/item/wrench/abductor,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 20000
	hidden = TRUE

/datum/techweb_node/syndicate_basic
	id = "syndicate_basic"
	tech_tier = 4
	display_name = "Illegal Technology"
	description = "Dangerous research used to create dangerous objects."
	prereq_ids = list(
		"adv_engi",
		"adv_weaponry",
		"explosive_weapons",
	)
	design_ids = list(
		"advanced_camera",
		"ai_cam_upgrade",
		"arcade_amputation",
		"borg_syndicate_module",
		"decloner",
		"donksoft_refill",
		"donksofttoyvendor",
		"largecrossbow",
		"suppressor",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	export_price = 5000
	hidden = TRUE

/datum/techweb_node/sticky_basic
	id = "sticky_basic"
	tech_tier = 3
	display_name = "Basic Sticky Technology"
	description = "The only thing left to do after researching this tech is to start printing out a bunch of 'kick me' signs."
	prereq_ids = list(
		"adv_engi",
		"syndicate_basic",
	)
	design_ids = list("sticky_tape")

	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 2500
	hidden = TRUE

/datum/techweb_node/sticky_advanced
	id = "sticky_advanced"
	tech_tier = 4
	display_name = "Advanced Sticky Technology"
	description = "Taking a good joke too far? Nonsense!"
	prereq_ids = list("sticky_basic")
	design_ids = list(
		"pointy_tape",
		"super_sticky_tape",
	)

	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 2500
	hidden = TRUE

//Helpers for debugging/balancing the techweb in its entirety!
/proc/total_techweb_exports()
	var/list/datum/techweb_node/processing = list()
	for(var/i in subtypesof(/datum/techweb_node))
		processing += new i
	. = 0
	for(var/i in processing)
		var/datum/techweb_node/TN = i
		. += TN.export_price

/proc/total_techweb_points()
	var/list/datum/techweb_node/processing = list()
	for(var/i in subtypesof(/datum/techweb_node))
		processing += new i
	var/datum/techweb/TW = new
	TW.research_points = list()
	for(var/i in processing)
		var/datum/techweb_node/TN = i
		TW.add_point_list(TN.research_costs)
	return TW.research_points

/proc/total_techweb_points_printout()
	var/list/datum/techweb_node/processing = list()
	for(var/i in subtypesof(/datum/techweb_node))
		processing += new i
	var/datum/techweb/TW = new
	TW.research_points = list()
	for(var/i in processing)
		var/datum/techweb_node/TN = i
		TW.add_point_list(TN.research_costs)
	return TW.printout_points()
