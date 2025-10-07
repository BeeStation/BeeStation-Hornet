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
	build_type = PROTOLATHE | IMPRINTER | COMPONENT_PRINTER
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

/obj/item/integrated_circuit/template/hello_world
	template_name = "hello_world"

/datum/design/integrated_circuit_template/hello_world
	name = "Hello, World!"
	desc = "A simple \"Hello, World\" circuit."
	id = "template_hello_world2"
	build_path = /obj/item/integrated_circuit/template/hello_world
	materials = list(/datum/material/glass = 1000, /datum/material/iron = 1000, /datum/material/copper = 500) //Todo: Set Materials properly.
