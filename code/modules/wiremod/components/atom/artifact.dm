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
	artifact_comp = AddComponent(/datum/component/xenoartifact, /datum/xenoartifact_material, list(), FALSE, FALSE)

/obj/item/circuit_component/artifact/get_ui_notices()
	. = ..()
	. += create_ui_notice("Speech Cooldown", "orange", "stopwatch")

/obj/item/circuit_component/artifact/populate_ports()
	target = add_input_port("Target", PORT_TYPE_ATOM)

/obj/item/circuit_component/artifact/input_received(datum/port/input/port)
	if(target?.value)
		artifact_comp.register_target(target.value, FALSE, XENOA_ACTIVATION_CONTACT)
		artifact_comp.trigger()

/obj/item/circuit_component/artifact/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	//Pearls
	var/obj/item/trait_pearl/P = I
	if(istype(P))
		if(!artifact_comp.add_individual_trait(P.stored_trait))
			playsound(get_turf(src), 'sound/machines/uplinkerror.ogg', 60)
		else
			P.forceMove(src)

/obj/item/circuit_component/artifact/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	//Dump the pearls
	for(var/obj/item/trait_pearl/P in contents)
		P.forceMove(get_turf(src))
	//Clear the artifact's traits
	for(var/i in artifact_comp.artifact_traits)
		for(var/datum/xenoartifact_trait/T as() in artifact_comp.artifact_traits[i])
			artifact_comp.remove_individual_trait(T)

