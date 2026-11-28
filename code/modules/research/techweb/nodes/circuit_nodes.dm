/datum/techweb_node/basic_circuitry
	display_name = "Basic Integrated Circuits"
	description = "Research on how to fully exploit the power of integrated circuits"
	node_flags = parent_type::node_flags | TECHWEB_NODE_STARTER
	unlocked_designs = list(
		/datum/design/circuit_multitool,
		/datum/design/component/arbitrary_input_amount/arithmetic,
		/datum/design/component/clock,
		/datum/design/component/comparison,
		/datum/design/component/concat_list,
		/datum/design/component/concat,
		/datum/design/component/delay,
		/datum/design/component/direction,
		/datum/design/component/iterator,
		/datum/design/component/is_null_component,
		/datum/design/component/get_column,
		/datum/design/component/get_name,
		/datum/design/component/gps,
		/datum/design/component/bci/relative_coords,
		/datum/design/component/health,
		/datum/design/component/hear,
		/datum/design/component/index_table,
		/datum/design/component/index,
		/datum/design/component/bci/install_detector,
		/datum/design/component/length,
		/datum/design/component/light,
		/datum/design/component/list_literal,
		/datum/design/component/logic,
		/datum/design/component/mmi,
		/datum/design/component/module,
		/datum/design/component/multiplexer,
		/datum/design/component/not,
		/datum/design/component/noop,
		/datum/design/component/ntnet_receive,
		/datum/design/component/ntnet_send,
		/datum/design/component/pathfind,
		/datum/design/component/pressuresensor,
		/datum/design/component/radio,
		/datum/design/component/random,
		/datum/design/component/bci/reagent_injector,
		/datum/design/component/round,
		/datum/design/component/router,
		/datum/design/component/select_query,
		/datum/design/component/self,
		/datum/design/component/soundemitter,
		/datum/design/component/species,
		/datum/design/component/speech,
		/datum/design/component/split,
		/datum/design/component/contains,
		/datum/design/component/switch_case,
		/datum/design/component/tempsensor,
		/datum/design/component/textcase,
		/datum/design/component/tonumber,
		/datum/design/component/tostring,
		/datum/design/component/trim,
		/datum/design/component/typecast,
		/datum/design/compact_remote_shell,
		/datum/design/board/component_printer,
		/datum/design/integrated_circuit,
		/datum/design/board/module_printer,
		/datum/design/usb_cable,
		/datum/design/component/gate/toggle,
		/datum/design/component/gate/set_reset,
	)

/datum/techweb_node/circuit_templates
	display_name = "Professor's Circuits"
	description = "I need some help with circuits. Can you lend a hand?"
	node_flags = parent_type::node_flags | TECHWEB_NODE_STARTER
	unlocked_designs = list(
		/datum/design/integrated_circuit_template/professors_notes,
		/datum/design/integrated_circuit_template/hello_world,
		/datum/design/integrated_circuit_template/greeter,
		/datum/design/integrated_circuit_template/ticker,
		/datum/design/integrated_circuit_template/simple_math,
		/datum/design/integrated_circuit_template/times_table,
		/datum/design/integrated_circuit_template/coin_flip,
		/datum/design/integrated_circuit_template/atmos_checker,
	)

/datum/techweb_node/math_circuits
	tech_tier = 1
	display_name = "Math Circuitry"
	description = "Development of more complex mathematical components for all your number manipulating needs"
	prerequisite_nodes = list(/datum/techweb_node/basic_circuitry, /datum/techweb_node/datatheory)
	unlocked_designs = list(
		/datum/design/component/adv_trig,
		/datum/design/component/bitflag,
		/datum/design/component/arbitrary_input_amount/bitwise,
		/datum/design/component/hyper_trig,
		/datum/design/component/trig,
		/datum/design/component/abs,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/list_circuits
	tech_tier = 1
	display_name = "List Circuitry"
	description = "Configures new integrated circuit components capable of representing one dimensional data structures such as arrays, stacks, and queues."
	prerequisite_nodes = list(/datum/techweb_node/basic_circuitry, /datum/techweb_node/datatheory)
	unlocked_designs = list(
		/datum/design/component/append,
		/datum/design/component/for_each,
		/datum/design/component/index,
		/datum/design/component/length,
		/datum/design/component/list_constructor,
		/datum/design/component/list_length_constructor,
		/datum/design/component/pop,
		/datum/design/component/write,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/adv_shells
	tech_tier = 2
	display_name = "Advanced Shell Research"
	description = "Grants access to more complicated shell designs."
	prerequisite_nodes = list(/datum/techweb_node/basic_circuitry, /datum/techweb_node/engineering)
	unlocked_designs = list(
		/datum/design/assembly_shell,
		/datum/design/bot_shell,
		/datum/design/ipc_control,
		///datum/design/component/mod_action,
		/datum/design/controller_shell,
		/datum/design/airlock_shell,
		///datum/design/mod_module_shell,
		/datum/design/money_bot_shell,
		/datum/design/scanner_gate_shell,
		/datum/design/scanner_shell,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/bci_shells
	tech_tier = 2
	display_name = "Brain-Computer Interfaces"
	description = "Grants access to biocompatable shell designs and components."
	prerequisite_nodes = list(/datum/techweb_node/adv_shells)
	unlocked_designs = list(
		/datum/design/board/bci_implanter,
		/datum/design/bci_shell,
		/datum/design/component/bci/bci_action,
		/datum/design/component/bci/bar_overlay,
		/datum/design/component/bci/counter_overlay,
		/datum/design/component/bci/object_overlay,
		/datum/design/component/bci/target_intercept,
		/datum/design/component/bci/thought_listener,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/movable_shells_tech
	tech_tier = 2
	display_name = "Movable Shell Research"
	description = "Grants access to movable shells."
	prerequisite_nodes = list(/datum/techweb_node/adv_shells, /datum/techweb_node/robotics)
	unlocked_designs = list(
		/datum/design/component/pull,
		/datum/design/drone_shell,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/server_shell_tech
	tech_tier = 2
	display_name = "Server Technology Research"
	description = "Grants access to a server shell that has a very high capacity for components."
	prerequisite_nodes = list(/datum/techweb_node/adv_shells, /datum/techweb_node/computer_hardware_basic)
	unlocked_designs = list(/datum/design/server_shell)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/advanced_circuit_templates
	tech_tier = 2
	display_name = "Advanced Circuit Templates"
	description = "Circuit Templates. Some broken, some not very useful"
	prerequisite_nodes = list(/datum/techweb_node/math_circuits, /datum/techweb_node/list_circuits, /datum/techweb_node/adv_shells, /datum/techweb_node/bci_shells, /datum/techweb_node/movable_shells_tech, /datum/techweb_node/server_shell_tech)
	unlocked_designs = list(
		/datum/design/integrated_circuit_template/broken_translator,
		/datum/design/integrated_circuit_template/scanning_gate,
		/datum/design/integrated_circuit_template/vending_circuit,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)
