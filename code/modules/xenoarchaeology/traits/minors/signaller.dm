/*
	Signaller
	Sends a signal when the artifact is activated
*/
/datum/xenoartifact_trait/minor/signaller
	label_name = "Signaller"
	label_desc = "Signaller: The artifact's design seems to incorporate signalling elements. This will cause the artifact to send a signal when activated."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	conductivity = 15
	var/atom/movable/artifact_particle_holder/particle_holder
	///Signal code
	var/code
	///Signal frequency
	var/datum/radio_frequency/radio_connection
	//Signal
	var/datum/signal/signal

/datum/xenoartifact_trait/minor/signaller/New(atom/_parent)
	. = ..()
	//Code
	code = rand(0, 100)
	//Signal
	signal = new(list("code" = code))
	//Frequency
	radio_connection = SSradio.add_object(src, FREQ_SIGNALER, "[RADIO_XENOA]_[REF(src)]")

/datum/xenoartifact_trait/minor/signaller/register_parent(datum/source)
	. = ..()
	if(!component_parent?.parent)
		return
	setup_generic_item_hint()
	if(!(locate(/datum/xenoartifact_trait/activator/signal) in component_parent.traits_catagories[TRAIT_PRIORITY_ACTIVATOR]))
		addtimer(CALLBACK(src, PROC_REF(do_sonar)), 2 SECONDS)

/datum/xenoartifact_trait/minor/signaller/Destroy(force, ...)
	SSradio.remove_object(src, FREQ_SIGNALER)
	QDEL_NULL(signal)
	return ..()

/datum/xenoartifact_trait/minor/signaller/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	INVOKE_ASYNC(src, PROC_REF(do_signal))

/datum/xenoartifact_trait/minor/signaller/do_hint(mob/user, atom/item)
	if(istype(item, /obj/item/analyzer))
		to_chat(user, "<span class='warning'>[item] detects an output frequency & code of [FREQ_SIGNALER]-[code]!</span>")
		return ..()

/datum/xenoartifact_trait/minor/signaller/generate_trait_appearance(atom/movable/target)
	. = ..()
	if(!ismovable(target))
		return
	particle_holder = new(component_parent?.parent)
	particle_holder.add_emitter(/obj/emitter/sonar/out, "sonar", 10)
	target.vis_contents += particle_holder

/datum/xenoartifact_trait/minor/signaller/cut_trait_appearance(atom/movable/target)
	. = ..()
	if(!ismovable(target))
		return
	target.vis_contents -= particle_holder
	QDEL_NULL(particle_holder)

/datum/xenoartifact_trait/minor/signaller/proc/do_signal()
	if(!radio_connection || !signal)
		return
	radio_connection.post_signal(src, signal)

/datum/xenoartifact_trait/minor/signaller/proc/receive_signal(datum/signal/signal)
	return

/datum/xenoartifact_trait/minor/signaller/proc/do_sonar(repeat = TRUE)
	if(QDELETED(src))
		return
	playsound(get_turf(component_parent?.parent), 'sound/effects/ping.ogg', 60, TRUE)
	var/rand_time = rand(6, 12) SECONDS
	addtimer(CALLBACK(src, PROC_REF(do_sonar)), rand_time)

/datum/xenoartifact_trait/minor/signaller/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_DETECT("analyzer, which will also reveal its output code & frequency"),
	XENOA_TRAIT_HINT_RANDOMISED, XENOA_TRAIT_HINT_APPEARANCE("This trait will make radar particles appear around the artifact."),
	XENOA_TRAIT_HINT_SOUND("sonar ping"))
