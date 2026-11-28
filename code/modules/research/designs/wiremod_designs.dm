/datum/design/integrated_circuit
	name = "Integrated Circuit"
	desc = "The foundation of all circuits. All Circuitry go onto this."
	build_path = /obj/item/integrated_circuit
	build_type = COMPONENT_PRINTER
	category = list(RND_CATEGORY_CORE)
	materials = list(/datum/material/glass = 1000, /datum/material/iron = 1000, /datum/material/copper = 500)
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/circuit_multitool
	name = "Circuit Multitool"
	desc = "A circuit multitool to mark entities and load them into."
	build_path = /obj/item/multitool/circuit
	build_type = COMPONENT_PRINTER
	category = list(RND_CATEGORY_CORE)
	materials = list(/datum/material/glass = 1000, /datum/material/iron = 1000, /datum/material/copper = 500)
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/usb_cable
	name = "USB Cable"
	desc = "A cable that allows certain shells to connect to nearby computers and machines."
	build_path = /obj/item/usb_cable
	build_type = COMPONENT_PRINTER
	category = list(RND_CATEGORY_CORE)
	// Yes, it would make sense to make them take plastic, but then less people would make them, and I think they're cool
	materials = list(/datum/material/iron = 1000, /datum/material/copper = 1500)
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/wireless_usb
	name = "Wireless USB transceiver"
	desc = "A transceiver that allows certain shells to connect to computers and machines at a certain range."
	build_path = /obj/item/usb_cable/bluespace
	build_type = COMPONENT_PRINTER
	category = list(RND_CATEGORY_CORE)
	materials = list(/datum/material/iron = 1000, /datum/material/copper = 1500, /datum/material/bluespace = 250)
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/component
	abstract_type = /datum/design/component
	build_type = COMPONENT_PRINTER
	materials = list(/datum/material/glass = 500, /datum/material/copper = 150)
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE
	category = list(RND_CATEGORY_CIRCUITRY + RND_SUBCATEGORY_CIRCUITRY_COMPONENTS)

/datum/design/component/New()
	. = ..()
	if(build_path)
		var/obj/item/circuit_component/component_path = build_path
		desc = initial(component_path.desc)

/datum/design/component/abs
	name = "Absolute Component"
	build_path = /obj/item/circuit_component/abs
	category = list(RND_CATEGORY_MATH_COMPONENTS)

/datum/design/component/arbitrary_input_amount/arithmetic
	name = "Arithmetic Component"
	build_path = /obj/item/circuit_component/arbitrary_input_amount/arithmetic
	category = list(RND_CATEGORY_MATH_COMPONENTS)

/datum/design/component/arbitrary_input_amount/bitwise
	name = "Bitwise Component"
	build_path = /obj/item/circuit_component/arbitrary_input_amount/bitwise
	category = list(RND_CATEGORY_MATH_COMPONENTS)

/datum/design/component/bitflag
	name = "Bitflag Component"
	build_path = /obj/item/circuit_component/compare/bitflag
	category = list(RND_CATEGORY_MATH_COMPONENTS, RND_CATEGORY_LOGIC_COMPONENTS)

/datum/design/component/clock
	name = "Clock Component"
	build_path = /obj/item/circuit_component/clock
	category = list(RND_CATEGORY_TIME_COMPONENTS)

/datum/design/component/comparison
	name = "Comparison Component"
	build_path = /obj/item/circuit_component/compare/comparison
	category = list(RND_CATEGORY_LOGIC_COMPONENTS)

/datum/design/component/for_each
	name = "For Each Component"
	build_path = /obj/item/circuit_component/foreach
	category = list(RND_CATEGORY_LIST_COMPONENTS)

/datum/design/component/logic
	name = "Logic Component"
	build_path = /obj/item/circuit_component/compare/logic
	category = list(RND_CATEGORY_LOGIC_COMPONENTS)

/datum/design/component/iterator
	name = "Iterator Component"
	build_path = /obj/item/circuit_component/iterator
	category = list(RND_CATEGORY_LOGIC_COMPONENTS)

/datum/design/component/is_null_component
	name = "Is Null Component"
	build_path = /obj/item/circuit_component/is_null
	category = list(RND_CATEGORY_LOGIC_COMPONENTS)

/datum/design/component/switch_case
	name = "Switch Case"
	build_path = /obj/item/circuit_component/switch_case
	category = list(RND_CATEGORY_LOGIC_COMPONENTS)


/datum/design/component/delay
	name = "Delay Component"
	build_path = /obj/item/circuit_component/delay
	category = list(RND_CATEGORY_TIME_COMPONENTS)

/datum/design/component/index
	name = "Index Component"
	build_path = /obj/item/circuit_component/index
	category = list(RND_CATEGORY_LIST_COMPONENTS)

/datum/design/component/write
	name = "Write Component"
	build_path = /obj/item/circuit_component/indexer/write
	category = list(RND_CATEGORY_LIST_COMPONENTS)

/datum/design/component/append
	name = "Append Component"
	build_path = /obj/item/circuit_component/append
	category = list(RND_CATEGORY_LIST_COMPONENTS)

/datum/design/component/pop
	name = "Pop Component"
	build_path = /obj/item/circuit_component/pop
	category = list(RND_CATEGORY_LIST_COMPONENTS)

/datum/design/component/length
	name = "Length Component"
	build_path = /obj/item/circuit_component/length
	category = list(RND_CATEGORY_LIST_COMPONENTS, RND_CATEGORY_STRING_COMPONENTS)

/datum/design/component/trim
	name = "String Trim Component"
	build_path = /obj/item/circuit_component/trim
	category = list(RND_CATEGORY_STRING_COMPONENTS)

/datum/design/component/light
	name = "Light Component"
	build_path = /obj/item/circuit_component/light
	category = list(RND_CATEGORY_OUTPUT_COMPONENTS)

/datum/design/component/list_constructor
	name = "List Constructor"
	build_path = /obj/item/circuit_component/arbitrary_input_amount/list_constructor
	category = list(RND_CATEGORY_LIST_COMPONENTS)

/datum/design/component/list_length_constructor
	name = "List Length Constructor"
	build_path = /obj/item/circuit_component/list_length_constructor
	category = list(RND_CATEGORY_LIST_COMPONENTS)

/datum/design/component/not
	name = "Not Component"
	build_path = /obj/item/circuit_component/not
	category = list(RND_CATEGORY_LOGIC_COMPONENTS)

/datum/design/component/random
	name = "Random Component"
	build_path = /obj/item/circuit_component/random
	category = list(RND_CATEGORY_MATH_COMPONENTS, RND_CATEGORY_LOGIC_COMPONENTS)

/datum/design/component/round
	name = "Round Component"
	build_path = /obj/item/circuit_component/round
	category = list(RND_CATEGORY_MATH_COMPONENTS)

/datum/design/component/species
	name = "Get Species Component"
	build_path = /obj/item/circuit_component/species
	category = list(RND_CATEGORY_LOGIC_COMPONENTS, RND_CATEGORY_INPUT_COMPONENTS)

/datum/design/component/get_name
	name = "Get Name Component"
	build_path = /obj/item/circuit_component/get_name
	category = list(RND_CATEGORY_LOGIC_COMPONENTS, RND_CATEGORY_INPUT_COMPONENTS)

/datum/design/component/speech
	name = "Speech Component"
	build_path = /obj/item/circuit_component/speech
	category = list(RND_CATEGORY_OUTPUT_COMPONENTS)

/datum/design/component/tostring
	name = "To String Component"
	build_path = /obj/item/circuit_component/tostring
	category = list(RND_CATEGORY_STRING_COMPONENTS, RND_CATEGORY_CONVERSION_COMPONENTS)

/datum/design/component/trig
	name = "Trigonometry Component"
	build_path = /obj/item/circuit_component/trig/trig
	category = list(RND_CATEGORY_MATH_COMPONENTS)

/datum/design/component/adv_trig
	name = "Advanced Trigonometry Component"
	build_path = /obj/item/circuit_component/trig/adv_trig
	category = list(RND_CATEGORY_MATH_COMPONENTS)

/datum/design/component/hyper_trig
	name = "Hyperbolic Trigonometry Component"
	build_path = /obj/item/circuit_component/trig/hyper_trig
	category = list(RND_CATEGORY_MATH_COMPONENTS)

/datum/design/component/typecast
	name = "Typecast Component"
	build_path = /obj/item/circuit_component/typecast
	category = list(RND_CATEGORY_LOGIC_COMPONENTS)

/datum/design/component/tonumber
	name = "To Number"
	build_path = /obj/item/circuit_component/tonumber
	category = list(RND_CATEGORY_STRING_COMPONENTS, RND_CATEGORY_CONVERSION_COMPONENTS)

/datum/design/component/concat
	name = "Concatenation Component"
	build_path = /obj/item/circuit_component/concat
	category = list(RND_CATEGORY_STRING_COMPONENTS)

/datum/design/component/textcase
	name = "Textcase Component"
	build_path = /obj/item/circuit_component/textcase
	category = list(RND_CATEGORY_STRING_COMPONENTS)

/datum/design/component/hear
	name = "Voice Activator Component"
	build_path = /obj/item/circuit_component/hear
	category = list(RND_CATEGORY_INPUT_COMPONENTS)

/datum/design/component/contains
	name = "String Contains Component"
	build_path = /obj/item/circuit_component/compare/contains
	category = list(RND_CATEGORY_STRING_COMPONENTS)

/datum/design/component/self
	name = "Self Component"
	build_path = /obj/item/circuit_component/self
	category = list(RND_CATEGORY_REFERENCE_COMPONENTS)

/datum/design/component/radio
	name = "Radio Component"
	build_path = /obj/item/circuit_component/radio
	category = list(RND_CATEGORY_OUTPUT_COMPONENTS)

/datum/design/component/gps
	name = "GPS Component"
	build_path = /obj/item/circuit_component/gps
	category = list(RND_CATEGORY_INPUT_COMPONENTS)

/datum/design/component/direction
	name = "Direction Component"
	build_path = /obj/item/circuit_component/direction
	category = list(RND_CATEGORY_INPUT_COMPONENTS)

/datum/design/component/health
	name = "Health Component"
	build_path = /obj/item/circuit_component/health
	category = list(RND_CATEGORY_INPUT_COMPONENTS)

/datum/design/component/bci/relative_coords
	name = "Get relative coords Component"
	build_path = /obj/item/circuit_component/relative_coords

/datum/design/component/split
	name = "Split Component"
	build_path = /obj/item/circuit_component/split
	category = list(RND_CATEGORY_LOGIC_COMPONENTS)

/datum/design/component/pull
	name = "Pull Component"
	build_path = /obj/item/circuit_component/pull
	category = list(RND_CATEGORY_OUTPUT_COMPONENTS)

/datum/design/component/soundemitter
	name = "Sound Emitter Component"
	build_path = /obj/item/circuit_component/soundemitter
	category = list(RND_CATEGORY_OUTPUT_COMPONENTS)

/datum/design/component/mmi
	name = "MMI Component"
	build_path = /obj/item/circuit_component/mmi
	category = list(RND_CATEGORY_INPUT_COMPONENTS)

/datum/design/component/router
	name = "Router Component"
	build_path = /obj/item/circuit_component/router
	category = list(RND_CATEGORY_OUTPUT_COMPONENTS)

/datum/design/component/multiplexer
	name = "Multiplexer Component"
	build_path = /obj/item/circuit_component/router/multiplexer
	category = list(RND_CATEGORY_LOGIC_COMPONENTS)

/datum/design/component/get_column
	name = "Get Column Component"
	build_path = /obj/item/circuit_component/get_column
	category = list(RND_CATEGORY_LIST_COMPONENTS)

/datum/design/component/index_table
	name = "Index Table Component"
	build_path = /obj/item/circuit_component/index_table
	category = list(RND_CATEGORY_LIST_COMPONENTS)

/datum/design/component/concat_list
	name = "Concatenate List Component"
	build_path = /obj/item/circuit_component/concat_list
	category = list(RND_CATEGORY_LIST_COMPONENTS)

/datum/design/component/select_query
	name = "Select Query Component"
	build_path = /obj/item/circuit_component/select
	category = list(RND_CATEGORY_CORE)

/datum/design/component/pathfind
	name = "Pathfinder"
	build_path = /obj/item/circuit_component/pathfind
	category = list(RND_CATEGORY_LOGIC_COMPONENTS)

/datum/design/component/tempsensor
	name = "Temperature Sensor Component"
	build_path = /obj/item/circuit_component/tempsensor
	category = list(RND_CATEGORY_INPUT_COMPONENTS)

/datum/design/component/pressuresensor
	name = "Pressure Sensor Component"
	build_path = /obj/item/circuit_component/pressuresensor
	category = list(RND_CATEGORY_INPUT_COMPONENTS)

/datum/design/component/module
	name = "Module Component"
	build_path = /obj/item/circuit_component/module
	category = list(RND_CATEGORY_CORE)

/datum/design/component/ntnet_receive
	name = "NTNet Receiver"
	build_path = /obj/item/circuit_component/ntnet_receive
	category = list(RND_CATEGORY_INPUT_COMPONENTS)

/datum/design/component/ntnet_send
	name = "NTNet Transmitter"
	build_path = /obj/item/circuit_component/ntnet_send
	category = list(RND_CATEGORY_OUTPUT_COMPONENTS)

/datum/design/component/noop
	name = "No Operation Component"
	build_path = /obj/item/circuit_component/noop
	category = list(RND_CATEGORY_CIRCUITRY + RND_SUBCATEGORY_CIRCUITRY_COMPONENTS)


/datum/design/component/list_literal
	name = "List Literal Component"
	build_path = /obj/item/circuit_component/list_literal
	category = list(RND_CATEGORY_LIST_COMPONENTS)

/datum/design/component/bci
	category = list(RND_CATEGORY_BCI_COMPONENTS)

/datum/design/component/bci/bci_action
	name = "BCI Action Component"
	build_path = /obj/item/circuit_component/equipment_action/bci

/datum/design/component/gate/toggle
	name = "Toggle Gate (T Flip-Flop)"
	build_path = /obj/item/circuit_component/gate/toggle

/datum/design/component/gate/toggle
	name = "Toggle Gate (T Flip-Flop)"
	build_path = /obj/item/circuit_component/gate/toggle
	category = list(RND_CATEGORY_GATE_COMPONENTS)

/datum/design/component/gate/set_reset
	name = "Set/Reset Component (RS Latch)"
	build_path = /obj/item/circuit_component/gate/set_reset
	category = list(RND_CATEGORY_GATE_COMPONENTS)
/*
/datum/design/component/mod_action
	name = "MOD Action Component"
	build_path = /obj/item/circuit_component/equipment_action/mod
*/

/datum/design/component/bci/object_overlay
	name = "Object Overlay Component"
	build_path = /obj/item/circuit_component/object_overlay

/datum/design/component/bci/bar_overlay
	name = "Bar Overlay Component"
	build_path = /obj/item/circuit_component/object_overlay/bar

/datum/design/component/bci/target_intercept
	name = "BCI Target Interceptor"
	build_path = /obj/item/circuit_component/target_intercept

/datum/design/component/bci/counter_overlay
	name = "Counter Overlay Component"
	build_path = /obj/item/circuit_component/counter_overlay

/datum/design/component/bci/thought_listener
	name = "Thought Listener Component"
	build_path = /obj/item/circuit_component/thought_listener

/datum/design/component/bci/install_detector
	name = "Install Detector Component"
	build_path = /obj/item/circuit_component/install_detector

/datum/design/component/bci/reagent_injector
	name = "Reagent Injector Component"
	build_path = /obj/item/circuit_component/reagent_injector

/datum/design/compact_remote_shell
	name = "Compact Remote Shell"
	desc = "A handheld shell with one big button."
	build_path = /obj/item/shell/compact_remote
	materials = list(/datum/material/glass = 2000, /datum/material/iron = 5000)
	build_type = COMPONENT_PRINTER
	category = list(RND_CATEGORY_SHELLS)

/datum/design/controller_shell
	name = "Controller Shell"
	desc = "A handheld shell with several buttons."
	build_path = /obj/item/shell/controller
	build_type = COMPONENT_PRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/iron = 7000)
	category = list(RND_CATEGORY_SHELLS)

/datum/design/scanner_shell
	name = "Scanner Shell"
	desc = "A handheld scanner shell that can scan entities."
	build_path = /obj/item/shell/wiremod_scanner
	build_type = COMPONENT_PRINTER
	materials = list(/datum/material/glass = 4000, /datum/material/iron = 5000)
	category = list(RND_CATEGORY_SHELLS)

/datum/design/bot_shell
	name = "Bot Shell"
	desc = "An immobile shell that can store more components. Has a USB port to be able to connect to computers and machines."
	build_path = /obj/item/shell/bot
	build_type = COMPONENT_PRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/iron = 10000)
	category = list(RND_CATEGORY_SHELLS)

/datum/design/money_bot_shell
	name = "Money Bot Shell"
	desc = "An immobile shell that is similar to a regular bot shell, but accepts monetary inputs and can also dispense money."
	build_path = /obj/item/shell/money_bot
	build_type = COMPONENT_PRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/iron = 10000, /datum/material/gold = 50)
	category = list(RND_CATEGORY_SHELLS)

/datum/design/drone_shell
	name = "Drone Shell"
	desc = "A shell with the ability to move itself around."
	build_path = /obj/item/shell/drone
	build_type = COMPONENT_PRINTER
	materials = list(
		/datum/material/glass = 2000,
		/datum/material/iron = 11000,
		/datum/material/gold = 500,
	)
	category = list(RND_CATEGORY_SHELLS)

/datum/design/server_shell
	name = "Server Shell"
	desc = "A very large shell that cannot be moved around. Stores the most components."
	materials = list(
		/datum/material/glass = 5000,
		/datum/material/iron = 15000,
		/datum/material/gold = 1500,
	)
	build_path = /obj/item/shell/server
	build_type = COMPONENT_PRINTER
	category = list(RND_CATEGORY_SHELLS)

/datum/design/airlock_shell
	name = "Airlock Shell"
	desc = "A door shell that cannot be moved around when assembled."
	materials = list(
		/datum/material/glass = 5000,
		/datum/material/iron = 15000,
	)
	build_path = /obj/item/shell/airlock
	build_type = COMPONENT_PRINTER
	category = list(RND_CATEGORY_SHELLS)

/datum/design/assembly_shell
	name = "Modular Assembly Shell"
	desc = "A shell that functions as an assembly."
	materials = list(
		/datum/material/glass = 2000,
		/datum/material/iron = 5000,
	)
	build_path = /obj/item/assembly/modular
	build_type = COMPONENT_PRINTER
	category = list(RND_CATEGORY_SHELLS)

/datum/design/bci_shell
	name = "Brain-Computer Interface Shell"
	desc = "An implant that can be placed in a user's head to control circuits using their brain."
	materials = list(
		/datum/material/glass = 2000,
		/datum/material/iron = 8000,
	)
	build_path = /obj/item/shell/bci
	build_type = COMPONENT_PRINTER
	category = list(RND_CATEGORY_SHELLS)

/datum/design/ipc_control
	name = "Upgrade Control Module Shell"
	desc = "A special FPGA that can be installed in the chest of a user to control any synth upgrades they may have."
	materials = list(
		/datum/material/glass = 2000,
		/datum/material/iron = 8000,
	)
	build_path = /obj/item/shell/ipc_control
	build_type = COMPONENT_PRINTER
	category = list(RND_CATEGORY_CIRCUITRY, RND_CATEGORY_SHELLS)

/datum/design/scanner_gate_shell
	name = "Scanner Gate Shell"
	desc = "A scanner gate shell that performs mid-depth scans on people when they pass through it."
	materials = list(
		/datum/material/glass = 4000,
		/datum/material/iron = 12000,
	)
	build_path = /obj/item/shell/scanner_gate
	build_type = COMPONENT_PRINTER
	category = list(RND_CATEGORY_SHELLS)

/datum/design/board/bci_implanter
	name = "Brain-Computer Interface Manipulation Chamber"
	desc = "A machine that, when given a brain-computer interface, will implant it into an occupant. Otherwise, will remove any brain-computer interfaces they already have."
	build_path = /obj/item/circuitboard/machine/bci_implanter
	build_type = COMPONENT_PRINTER
	category = list(RND_CATEGORY_CORE)

/datum/design/mod_module_shell
	name = "MOD Module Shell"
	desc = "A module shell that allows a circuit to be inserted into, and interface with, a MODsuit."
	materials = list(/datum/material/glass = 2000)
	build_path = /obj/item/mod/module/circuit
	build_type = MECHFAB | COMPONENT_PRINTER
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_SCIENCE, RND_CATEGORY_SHELLS)

/datum/design/integrated_circuit_template
	abstract_type = /datum/design/integrated_circuit_template
	category = list(RND_CATEGORY_TEMPLATES)
	materials = list(/datum/material/iron = 6700, /datum/material/glass = 3550, /datum/material/copper = 550) //Hello world costs
	build_type = COMPONENT_PRINTER
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

// Printable at circuit fabs for ease of finding. Yes, it's not really realistic, but this is a tutorial.
/datum/design/integrated_circuit_template/professors_notes
	name = "0. The Professor's Notes"
	desc = "I could use some help! Please read me!"
	build_path = /obj/item/clipboard/preloaded/circuit_templates
	materials = list(/datum/material/iron = 3000) //Ehh, seems about right.

/datum/design/integrated_circuit_template/hello_world
	name = "1. Hello, World!"
	desc = "A simple \"Hello, World\" circuit."
	build_path = /obj/item/integrated_circuit/template/hello_world
	materials = list(/datum/material/iron = 6700, /datum/material/glass = 3550, /datum/material/copper = 650)

/datum/design/integrated_circuit_template/greeter
	name = "2. Greeter"
	desc = "A simple circuit which greets you."
	build_path = /obj/item/integrated_circuit/template/greeter
	materials = list(/datum/material/iron = 6700, /datum/material/glass = 5050, /datum/material/copper = 1100)

/datum/design/integrated_circuit_template/ticker
	name = "3. Ticker"
	desc = "Tick Tock, a circuit which keeps time."
	build_path = /obj/item/integrated_circuit/template/ticker
	materials = list(/datum/material/iron = 6700, /datum/material/glass = 4550, /datum/material/copper = 950)

/datum/design/integrated_circuit_template/simple_math
	name = "4. Simple Math"
	desc = "A simple circuit which does basic math and tells you if it is greater than 5."
	build_path = /obj/item/integrated_circuit/template/simple_math
	materials = list(/datum/material/iron = 6700, /datum/material/glass = 4050, /datum/material/copper = 800)

/datum/design/integrated_circuit_template/times_table
	name = "5. Times Table"
	desc = "You needed to learn your 7 times table, right?"
	build_path = /obj/item/integrated_circuit/template/times_table
	materials = list(/datum/material/iron = 6700, /datum/material/glass = 5550, /datum/material/copper = 1250)

/datum/design/integrated_circuit_template/coin_flip
	name = "6. Coin Flip"
	desc = "A Simple Coin Flipper"
	build_path = /obj/item/integrated_circuit/template/coin_flip
	materials = list(/datum/material/iron = 6700, /datum/material/glass = 5050, /datum/material/copper = 1100)

/datum/design/integrated_circuit_template/atmos_checker
	name = "7. Atmos Safety Checker"
	desc = "Is your air safe? Find out!"
	build_path = /obj/item/integrated_circuit/template/atmos_checker
	materials = list(/datum/material/iron = 6700, /datum/material/glass = 10050, /datum/material/copper = 2600)

/datum/design/integrated_circuit_template/broken_translator
	name = "A1. Broken Translator"
	desc = "A translator that doesn't work"
	build_path = /obj/item/integrated_circuit/template/broken_translator
	materials = list(/datum/material/iron = 6700, /datum/material/glass = 4550, /datum/material/copper = 950)

/datum/design/integrated_circuit_template/scanning_gate
	name = "A2. NTNet Scanning Gate"
	desc = "A wireless scanning gate"
	build_path = /obj/item/integrated_circuit/template/scanning_gate
	materials = list(/datum/material/iron = 13700, /datum/material/glass = 7050, /datum/material/copper = 1100)

/datum/design/integrated_circuit_template/vending_circuit
	name = "A3. Vending Circuit"
	desc = "A simple vending machine circuit"
	build_path = /obj/item/integrated_circuit/template/vending_circuit
	materials = list(/datum/material/iron = 11700, /datum/material/glass = 6050, /datum/material/gold = 50, /datum/material/copper = 1400)
