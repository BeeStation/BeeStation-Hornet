//This file is a child of item/integrated_circuit and attempts to load a circuit from approved_circuits.json upon creation.
/obj/item/integrated_circuit/template
	/// The name from approved_circuits.json to load
	var/template_name = "hello_world"

//The research design template
/datum/design/integrated_circuit_template
	name = "Hello, World!"
	desc = "A simple \"Hello, World\" circuit."
	id = "template_hello_world"
	build_path = /obj/item/integrated_circuit/template/hello_world
	category = list(WIREMOD_TEMPLATES)
	materials = list(/datum/material/glass = 1000, /datum/material/iron = 1000, /datum/material/copper = 500) //Todo: Set Materials properly.
	build_type = IMPRINTER | COMPONENT_PRINTER
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/obj/item/integrated_circuit/template/Initialize(mapload)
	.=..()

	var/list/errors = list()
	var/circuit_json = pick(strings(APPROVED_CIRCUITS_FILE, template_name))
	load_circuit_data(circuit_json, errors)

	if(length(errors))
		to_chat(src, span_warning("The following errors were found whilst compiling the circuit data:"))
		for(var/error in errors)
			to_chat(src, span_warning("[error]"))

//Hello World
/obj/item/integrated_circuit/template/hello_world
	template_name = "hello_world"

/datum/design/integrated_circuit_template/hello_world
	name = "Hello, World!"
	desc = "A simple \"Hello, World\" circuit."
	id = "template_hello_world"
	build_path = /obj/item/integrated_circuit/template/hello_world
	materials = list(/datum/material/glass = 1000, /datum/material/iron = 1000, /datum/material/copper = 500) //Todo: Set Materials properly.

//Greeter
/obj/item/integrated_circuit/template/greeter
	template_name = "greeter"

/datum/design/integrated_circuit_template/greeter
	name = "Greeter"
	desc = "A simple circuit which greets you."
	id = "template_greeter"
	build_path = /obj/item/integrated_circuit/template/greeter
	materials = list(/datum/material/glass = 1000, /datum/material/iron = 1000, /datum/material/copper = 500) //Todo: Set Materials properly.

//Ticker
/obj/item/integrated_circuit/template/ticker
	template_name = "ticker"

/datum/design/integrated_circuit_template/ticker
	name = "Ticker"
	desc = "Tick Tock, a circuit which keeps time."
	id = "template_ticker"
	build_path = /obj/item/integrated_circuit/template/ticker
	materials = list(/datum/material/glass = 1000, /datum/material/iron = 1000, /datum/material/copper = 500) //Todo: Set Materials properly.

//Simple Math
/obj/item/integrated_circuit/template/simple_math
	template_name = "simple_math"

/datum/design/integrated_circuit_template/simple_math
	name = "Simple Math"
	desc = "A simple circuit which does basic math and tells you if it is greater than 5."
	id = "template_simple_math"
	build_path = /obj/item/integrated_circuit/template/simple_math
	materials = list(/datum/material/glass = 1000, /datum/material/iron = 1000, /datum/material/copper = 500) //Todo: Set Materials properly.

//Times Table
/obj/item/integrated_circuit/template/times_table
	template_name = "times_table"

/datum/design/integrated_circuit_template/times_table
	name = "Times Table"
	desc = "You needed to learn your 7 times table, right?"
	id = "template_times_table"
	build_path = /obj/item/integrated_circuit/template/times_table
	materials = list(/datum/material/glass = 1000, /datum/material/iron = 1000, /datum/material/copper = 500) //Todo: Set Materials properly.



