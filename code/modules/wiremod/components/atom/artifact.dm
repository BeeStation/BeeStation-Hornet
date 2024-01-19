/**
 * # Artifact Component
 *
 * Works like an artifact, requires xenopearls to function, essentially
 */
/obj/item/circuit_component/artifact
	display_name = "Simulated Artifact"
	desc = "A component that simulates a xenoartifact."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL
	///The target the artifact is triggering on
	var/datum/port/input/target
	///Ref to the artifact component
	var/datum/component/xenoartifact/artifact_comp

/obj/item/circuit_component/artifact/ComponentInitialize()
	. = ..()
	artifact_comp = AddComponent(/datum/component/xenoartifact, /datum/xenoartifact_material, null, FALSE, FALSE)

/obj/item/circuit_component/artifact/get_ui_notices()
	. = ..()
	. += create_ui_notice("Speech Cooldown", "orange", "stopwatch")

/obj/item/circuit_component/artifact/populate_ports()
	target = add_input_port("Target", PORT_TYPE_ATOM)

/obj/item/circuit_component/artifact/input_received(datum/port/input/port)
	if(target?.value)
		artifact_comp.register_target(target.value, FALSE, XENOA_ACTIVATION_CONTACT)
		artifact_comp.trigger()
