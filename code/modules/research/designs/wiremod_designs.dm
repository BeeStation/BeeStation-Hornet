/datum/design/integrated_circuit
	name = "Integrated Circuit"
	desc = "The foundation of all circuits. All Circuitry go onto this."
	id = "integrated_circuit"
	build_path = /obj/item/integrated_circuit
	build_type = IMPRINTER | COMPONENT_PRINTER
	category = list(WIREMOD_CIRCUITRY, WIREMOD_CORE)
	materials = list(/datum/material/glass = 1000, /datum/material/iron = 1000, /datum/material/copper = 500)
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/circuit_multitool
	name = "Circuit Multitool"
	desc = "A circuit multitool to mark entities and load them into."
	id = "circuit_multitool"
	build_path = /obj/item/multitool/circuit
	build_type = PROTOLATHE | COMPONENT_PRINTER
	category = list(WIREMOD_CIRCUITRY, WIREMOD_CORE)
	materials = list(/datum/material/glass = 1000, /datum/material/iron = 1000, /datum/material/copper = 500)
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/usb_cable
	name = "USB Cable"
	desc = "A cable that allows certain shells to connect to nearby computers and machines."
	id = "usb_cable"
	build_path = /obj/item/usb_cable
	build_type = PROTOLATHE | COMPONENT_PRINTER
	category = list(WIREMOD_CIRCUITRY, WIREMOD_CORE)
	// Yes, it would make sense to make them take plastic, but then less people would make them, and I think they're cool
	materials = list(/datum/material/iron = 1000, /datum/material/copper = 1500)
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/component
	name = "Component ( NULL ENTRY )"
	desc = "A component that goes into an integrated circuit."
	build_type = IMPRINTER | COMPONENT_PRINTER
	materials = list(/datum/material/glass = 500, /datum/material/copper = 1500)
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE
	category = list(WIREMOD_CIRCUITRY)

/datum/design/component/New()
	. = ..()
	if(build_path)
		var/obj/item/circuit_component/component_path = build_path
		desc = initial(component_path.display_desc)

/datum/design/component/arbitrary_input_amount/arithmetic
	name = "Arithmetic Component"
	id = "comp_arithmetic"
	build_path = /obj/item/circuit_component/arbitrary_input_amount/arithmetic
	category = list(WIREMOD_CIRCUITRY, WIREMOD_MATH_COMPONENTS)

/datum/design/component/arbitrary_input_amount/bitwise
	name = "Bitwise Component"
	id = "comp_bitwise"
	build_path = /obj/item/circuit_component/arbitrary_input_amount/bitwise
	category = list(WIREMOD_CIRCUITRY, WIREMOD_MATH_COMPONENTS)

/datum/design/component/bitflag
	name = "Bitflag Component"
	id = "comp_bitflag"
	build_path = /obj/item/circuit_component/compare/bitflag
	category = list(WIREMOD_CIRCUITRY, WIREMOD_MATH_COMPONENTS, WIREMOD_LOGIC_COMPONENTS)

/datum/design/component/clock
	name = "Clock Component"
	id = "comp_clock"
	build_path = /obj/item/circuit_component/clock
	category = list(WIREMOD_CIRCUITRY, WIREMOD_TIME_COMPONENTS)

/datum/design/component/comparison
	name = "Comparison Component"
	id = "comp_comparison"
	build_path = /obj/item/circuit_component/compare/comparison
	category = list(WIREMOD_CIRCUITRY, WIREMOD_LOGIC_COMPONENTS)

/datum/design/component/logic
	name = "Logic Component"
	id = "comp_logic"
	build_path = /obj/item/circuit_component/compare/logic
	category = list(WIREMOD_CIRCUITRY, WIREMOD_LOGIC_COMPONENTS)

/datum/design/component/delay
	name = "Delay Component"
	id = "comp_delay"
	build_path = /obj/item/circuit_component/delay
	category = list(WIREMOD_CIRCUITRY, WIREMOD_TIME_COMPONENTS)

/datum/design/component/index
	name = "Index Component"
	id = "comp_index"
	build_path = /obj/item/circuit_component/indexer/index
	category = list(WIREMOD_CIRCUITRY, WIREMOD_LIST_COMPONENTS)

/datum/design/component/write
	name = "Write Component"
	id = "comp_write"
	build_path = /obj/item/circuit_component/indexer/write
	category = list(WIREMOD_CIRCUITRY, WIREMOD_LIST_COMPONENTS)

/datum/design/component/append
	name = "Append Component"
	id = "comp_append"
	build_path = /obj/item/circuit_component/append
	category = list(WIREMOD_CIRCUITRY, WIREMOD_LIST_COMPONENTS)

/datum/design/component/pop
	name = "Pop Component"
	id = "comp_pop"
	build_path = /obj/item/circuit_component/pop
	category = list(WIREMOD_CIRCUITRY,WIREMOD_LIST_COMPONENTS)

/datum/design/component/length
	name = "Length Component"
	id = "comp_length"
	build_path = /obj/item/circuit_component/length
	category = list(WIREMOD_CIRCUITRY, WIREMOD_LIST_COMPONENTS, WIREMOD_STRING_COMPONENTS)

/datum/design/component/light
	name = "Light Component"
	id = "comp_light"
	build_path = /obj/item/circuit_component/light
	category = list(WIREMOD_CIRCUITRY, WIREMOD_OUTPUT_COMPONENTS)

/datum/design/component/list_constructor
	name = "List Constructor"
	id = "comp_list_constructor"
	build_path = /obj/item/circuit_component/arbitrary_input_amount/list_constructor
	category = list(WIREMOD_CIRCUITRY, WIREMOD_LIST_COMPONENTS)

/datum/design/component/list_length_constructor
	name = "List Length Constructor"
	id = "comp_list_length_constructor"
	build_path = /obj/item/circuit_component/list_length_constructor
	category = list(WIREMOD_CIRCUITRY, WIREMOD_LIST_COMPONENTS)

/datum/design/component/not
	name = "Not Component"
	id = "comp_not"
	build_path = /obj/item/circuit_component/not
	category = list(WIREMOD_CIRCUITRY, WIREMOD_LOGIC_COMPONENTS)

/datum/design/component/ram
	name = "RAM Component"
	id = "comp_ram"
	build_path = /obj/item/circuit_component/ram
	category = list(WIREMOD_CIRCUITRY, WIREMOD_MEMORY_COMPONENTS)

/datum/design/component/random
	name = "Random Component"
	id = "comp_random"
	build_path = /obj/item/circuit_component/random
	category = list(WIREMOD_CIRCUITRY, WIREMOD_MATH_COMPONENTS, WIREMOD_LOGIC_COMPONENTS)

/datum/design/component/round
	name = "Round Component"
	id = "comp_round"
	build_path = /obj/item/circuit_component/round
	category = list(WIREMOD_CIRCUITRY, WIREMOD_MATH_COMPONENTS)

/datum/design/component/species
	name = "Get Species Component"
	id = "comp_species"
	build_path = /obj/item/circuit_component/species
	category = list(WIREMOD_CIRCUITRY, WIREMOD_LOGIC_COMPONENTS, WIREMOD_INPUT_COMPONENTS)

/datum/design/component/speech
	name = "Speech Component"
	id = "comp_speech"
	build_path = /obj/item/circuit_component/speech
	category = list(WIREMOD_CIRCUITRY, WIREMOD_OUTPUT_COMPONENTS)

/datum/design/component/tostring
	name = "To String Component"
	id = "comp_tostring"
	build_path = /obj/item/circuit_component/tostring
	category = list(WIREMOD_CIRCUITRY, WIREMOD_STRING_COMPONENTS, WIREMOD_CONVERSION_COMPONENTS)

/datum/design/component/trig
	name = "Trigonometry Component"
	id = "comp_trig"
	build_path = /obj/item/circuit_component/trig/trig
	category = list(WIREMOD_CIRCUITRY, WIREMOD_MATH_COMPONENTS)

/datum/design/component/adv_trig
	name = "Advanced Trigonometry Component"
	id = "comp_adv_trig"
	build_path = /obj/item/circuit_component/trig/adv_trig
	category = list(WIREMOD_CIRCUITRY, WIREMOD_MATH_COMPONENTS)

/datum/design/component/hyper_trig
	name = "Hyperbolic Trigonometry Component"
	id = "comp_hyper_trig"
	build_path = /obj/item/circuit_component/trig/hyper_trig
	category = list(WIREMOD_CIRCUITRY, WIREMOD_MATH_COMPONENTS)

/datum/design/component/typecast
	name = "Typecast Component"
	id = "comp_typecast"
	build_path = /obj/item/circuit_component/compare/typecast
	category = list(WIREMOD_CIRCUITRY, WIREMOD_LOGIC_COMPONENTS)

/datum/design/component/concat
	name = "Concatenation Component"
	id = "comp_concat"
	build_path = /obj/item/circuit_component/concat
	category = list(WIREMOD_CIRCUITRY, WIREMOD_STRING_COMPONENTS)

/datum/design/component/textcase
	name = "Textcase Component"
	id = "comp_textcase"
	build_path = /obj/item/circuit_component/textcase
	category = list(WIREMOD_CIRCUITRY, WIREMOD_STRING_COMPONENTS)

/datum/design/component/hear
	name = "Voice Activator Component"
	id = "comp_hear"
	build_path = /obj/item/circuit_component/hear
	category = list(WIREMOD_CIRCUITRY, WIREMOD_INPUT_COMPONENTS)

/datum/design/component/contains
	name = "String Contains Component"
	id = "comp_string_contains"
	build_path = /obj/item/circuit_component/compare/contains
	category = list(WIREMOD_CIRCUITRY, WIREMOD_STRING_COMPONENTS)

/datum/design/component/self
	name = "Self Component"
	id = "comp_self"
	build_path = /obj/item/circuit_component/self
	category = list(WIREMOD_CIRCUITRY, WIREMOD_REFERENCE_COMPONENTS)

/datum/design/component/radio
	name = "Radio Component"
	id = "comp_radio"
	build_path = /obj/item/circuit_component/radio
	category = list(WIREMOD_CIRCUITRY, WIREMOD_OUTPUT_COMPONENTS)

/datum/design/component/gps
	name = "GPS Component"
	id = "comp_gps"
	build_path = /obj/item/circuit_component/gps
	category = list(WIREMOD_CIRCUITRY, WIREMOD_INPUT_COMPONENTS)

/datum/design/component/direction
	name = "Direction Component"
	id = "comp_direction"
	build_path = /obj/item/circuit_component/direction
	category = list(WIREMOD_CIRCUITRY, WIREMOD_INPUT_COMPONENTS)

/datum/design/component/health
	name = "Health Component"
	id = "comp_health"
	build_path = /obj/item/circuit_component/health
	category = list(WIREMOD_CIRCUITRY, WIREMOD_INPUT_COMPONENTS)

/datum/design/component/combiner
	name = "Combiner Component"
	id = "comp_combiner"
	build_path = /obj/item/circuit_component/combiner
	category = list(WIREMOD_CIRCUITRY, WIREMOD_LOGIC_COMPONENTS)

/datum/design/component/pull
	name = "Pull Component"
	id = "comp_pull"
	build_path = /obj/item/circuit_component/pull
	category = list(WIREMOD_CIRCUITRY, WIREMOD_OUTPUT_COMPONENTS)

/datum/design/component/soundemitter
	name = "Sound Emitter Component"
	id = "comp_soundemitter"
	build_path = /obj/item/circuit_component/soundemitter
	category = list(WIREMOD_CIRCUITRY, WIREMOD_OUTPUT_COMPONENTS)

/datum/design/component/mmi
	name = "MMI Component"
	id = "comp_mmi"
	build_path = /obj/item/circuit_component/mmi
	category = list(WIREMOD_CIRCUITRY, WIREMOD_INPUT_COMPONENTS)

/datum/design/component/multiplexer
	name = "Multiplexer Component"
	id = "comp_multiplexer"
	build_path = /obj/item/circuit_component/multiplexer
	category = list(WIREMOD_CIRCUITRY, WIREMOD_LOGIC_COMPONENTS)

/datum/design/component/get_column
	name = "Get Column Component"
	id = "comp_get_column"
	build_path = /obj/item/circuit_component/get_column
	category = list(WIREMOD_CIRCUITRY, WIREMOD_LIST_COMPONENTS)

/datum/design/component/index_table
	name = "Index Table Component"
	id = "comp_index_table"
	build_path = /obj/item/circuit_component/index_table
	category = list(WIREMOD_CIRCUITRY, WIREMOD_LIST_COMPONENTS)

/datum/design/component/concat_list
	name = "Concatenate List Component"
	id = "comp_concat_list"
	build_path = /obj/item/circuit_component/concat_list
	category = list(WIREMOD_CIRCUITRY, WIREMOD_LIST_COMPONENTS)

/datum/design/component/select_query
	name = "Select Query Component"
	id = "comp_select_query"
	build_path = /obj/item/circuit_component/select
	category = list(WIREMOD_CIRCUITRY, WIREMOD_LIST_COMPONENTS, WIREMOD_LOGIC_COMPONENTS)

/datum/design/compact_remote_shell
	name = "Compact Remote Shell"
	desc = "A handheld shell with one big button."
	id = "compact_remote_shell"
	build_path = /obj/item/compact_remote
	materials = list(/datum/material/glass = 2000, /datum/material/iron = 5000)
	build_type = PROTOLATHE | COMPONENT_PRINTER
	category = list(WIREMOD_CIRCUITRY, WIREMOD_SHELLS)

/datum/design/controller_shell
	name = "Controller Shell"
	desc = "A handheld shell with several buttons."
	id = "controller_shell"
	build_path = /obj/item/controller
	build_type = PROTOLATHE | COMPONENT_PRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/iron = 7000)
	category = list(WIREMOD_CIRCUITRY, WIREMOD_SHELLS)

/datum/design/scanner_shell
	name = "Scanner Shell"
	desc = "A handheld shell with a scanner."
	id = "scanner_shell"
	build_path = /obj/item/scanner
	build_type = PROTOLATHE | COMPONENT_PRINTER
	materials = list(/datum/material/glass = 4000, /datum/material/iron = 5000)
	category = list(WIREMOD_CIRCUITRY, WIREMOD_SHELLS)

/datum/design/bot_shell
	name = "Bot Shell"
	desc = "An immobile shell that can store more components. Has a USB port to be able to connect to computers and machines."
	id = "bot_shell"
	build_path = /obj/item/shell/bot
	build_type = PROTOLATHE | COMPONENT_PRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/iron = 10000)
	category = list(WIREMOD_CIRCUITRY, WIREMOD_SHELLS)

/datum/design/money_bot_shell
	name = "Money Bot Shell"
	desc = "An immobile shell that is similar to a regular bot shell, but accepts monetary inputs and can also dispense money."
	id = "money_bot_shell"
	build_path = /obj/item/shell/money_bot
	build_type = PROTOLATHE | COMPONENT_PRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/iron = 10000, /datum/material/gold = 50)
	category = list(WIREMOD_CIRCUITRY, WIREMOD_SHELLS)

/datum/design/drone_shell
	name = "Drone Shell"
	desc = "A shell with the ability to move itself around."
	id = "drone_shell"
	build_path = /obj/item/shell/drone
	build_type = PROTOLATHE | COMPONENT_PRINTER
	materials = list(
		/datum/material/glass = 2000,
		/datum/material/iron = 11000,
		/datum/material/gold = 500,
	)
	category = list(WIREMOD_CIRCUITRY, WIREMOD_SHELLS)

/datum/design/server_shell
	name = "Server Shell"
	desc = "A very large shell that cannot be moved around. Stores the most components."
	id = "server_shell"
	materials = list(
		/datum/material/glass = 5000,
		/datum/material/iron = 15000,
		/datum/material/gold = 1500,
	)
	build_path = /obj/item/shell/server
	build_type = PROTOLATHE | COMPONENT_PRINTER
	category = list(WIREMOD_CIRCUITRY, WIREMOD_SHELLS)

/datum/design/airlock_shell
	name = "Airlock Shell"
	desc = "A door shell that cannot be moved around when assembled."
	id = "door_shell"
	materials = list(
		/datum/material/glass = 5000,
		/datum/material/iron = 15000,
	)
	build_path = /obj/item/shell/airlock
	build_type = PROTOLATHE | COMPONENT_PRINTER
	category = list(WIREMOD_CIRCUITRY, WIREMOD_SHELLS)

/datum/design/assembly_shell
	name = "Modular Assembly Shell"
	desc = "A shell that functions as an assembly."
	id = "assembly_shell"
	materials = list(
		/datum/material/glass = 2000,
		/datum/material/iron = 5000,
	)
	build_path = /obj/item/assembly/modular
	build_type = PROTOLATHE | COMPONENT_PRINTER
	category = list(WIREMOD_CIRCUITRY, WIREMOD_SHELLS)
