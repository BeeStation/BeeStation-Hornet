/datum/techweb_node/basic_circuitry
	id = TECHWEB_NODE_BASIC_CIRCUITRY
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
		"comp_iterator",
		"comp_get_column",
		"comp_get_name",
		"comp_gps",
		"comp_relative_coords",
		"comp_health",
		"comp_hear",
		"comp_index_table",
		"comp_index",
		"comp_install_detector",
		"comp_length",
		"comp_light",
		"comp_list_literal",
		"comp_logic",
		"comp_mmi",
		"comp_module",
		"comp_multiplexer",
		"comp_not",
		"comp_noop",
		"comp_ntnet_receive",
		"comp_ntnet_send",
		"comp_pathfind",
		"comp_pressuresensor",
		"comp_radio",
		"comp_random",
		"comp_reagent_injector",
		"comp_round",
		"comp_router",
		"comp_select_query",
		"comp_self",
		"comp_soundemitter",
		"comp_species",
		"comp_speech",
		"comp_split",
		"comp_string_contains",
		"comp_switch_case",
		"comp_tempsensor",
		"comp_textcase",
		"comp_tonumber",
		"comp_tostring",
		"comp_trim",
		"comp_typecast",
		"compact_remote_shell",
		"component_printer",
		"integrated_circuit",
		"module_duplicator",
		"usb_cable",
		"comp_gate_toggle",
		"comp_gate_set_reset",
	)

/datum/techweb_node/circuit_templates
	id = TECHWEB_NODE_CIRCUIT_TEMPLATES
	tech_tier = 0
	starting_node = TRUE
	display_name = "Professor's Circuits"
	description = "I need some help with circuits. Can you lend a hand?"
	design_ids = list(
		"template_notes",
		"template_hello_world",
		"template_greeter",
		"template_ticker",
		"template_simple_math",
		"template_times_table",
		"template_coin_flip",
		"template_atmos_checker",
	)

/datum/techweb_node/math_circuits
	id = TECHWEB_NODE_MATH_CIRCUITS
	tech_tier = 1
	display_name = "Math Circuitry"
	description = "Development of more complex mathematical components for all your number manipulating needs"
	prereq_ids = list(TECHWEB_NODE_BASIC_CIRCUITRY, TECHWEB_NODE_DATATHEORY)
	design_ids = list(
		"comp_adv_trig",
		"comp_bitflag",
		"comp_bitwise",
		"comp_hyper_trig",
		"comp_trig",
		"comp_abs",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/list_circuits
	id = TECHWEB_NODE_LIST_CIRCUITS
	tech_tier = 1
	display_name = "List Circuitry"
	description = "Configures new integrated circuit components capable of representing one dimensional data structures such as arrays, stacks, and queues."
	prereq_ids = list(TECHWEB_NODE_BASIC_CIRCUITRY, TECHWEB_NODE_DATATHEORY)
	design_ids = list(
		"comp_append",
		"comp_index",
		"comp_length",
		"comp_list_constructor",
		"comp_list_length_constructor",
		"comp_pop",
		"comp_write",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/adv_shells
	id = TECHWEB_NODE_ADV_SHELLS
	tech_tier = 2
	display_name = "Advanced Shell Research"
	description = "Grants access to more complicated shell designs."
	prereq_ids = list(TECHWEB_NODE_BASIC_CIRCUITRY, TECHWEB_NODE_ENGINEERING)
	design_ids = list(
		"assembly_shell",
		"bot_shell",
		//"comp_mod_action",
		"controller_shell",
		"door_shell",
		//"module_shell",
		"money_bot_shell",
		"scanner_gate_shell",
		"scanner_shell",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/bci_shells
	id = TECHWEB_NODE_BCI_SHELLS
	tech_tier = 2
	display_name = "Brain-Computer Interfaces"
	description = "Grants access to biocompatable shell designs and components."
	prereq_ids = list(TECHWEB_NODE_ADV_SHELLS)
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
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/movable_shells_tech
	id = TECHWEB_NODE_MOVABLE_SHELLS
	tech_tier = 2
	display_name = "Movable Shell Research"
	description = "Grants access to movable shells."
	prereq_ids = list(TECHWEB_NODE_ADV_SHELLS, TECHWEB_NODE_ROBOTICS)
	design_ids = list(
		"comp_pull",
		"drone_shell",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/server_shell_tech
	id = TECHWEB_NODE_SERVER_SHELL
	tech_tier = 2
	display_name = "Server Technology Research"
	description = "Grants access to a server shell that has a very high capacity for components."
	prereq_ids = list(TECHWEB_NODE_ADV_SHELLS, TECHWEB_NODE_COMPUTER_HARDWARE_BASIC)
	design_ids = list("server_shell")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/advanced_circuit_templates
	id = TECHWEB_NODE_ADVANCED_CIRCUIT_TEMPLATES
	tech_tier = 2
	display_name = "Advanced Circuit Templates"
	description = "Circuit Templates. Some broken, some not very useful"
	prereq_ids = list(TECHWEB_NODE_MATH_CIRCUITS, TECHWEB_NODE_LIST_CIRCUITS, TECHWEB_NODE_ADV_SHELLS, TECHWEB_NODE_BCI_SHELLS, TECHWEB_NODE_MOVABLE_SHELLS, TECHWEB_NODE_SERVER_SHELL)
	design_ids = list(
		"template_broken_translator",
		"template_scanning_gate",
		"template_circuit_vendor"
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)
