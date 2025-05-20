/*
	Signal
	This trait activates the artifact when it's signalled
*/
/datum/xenoartifact_trait/activator/signal
	label_name = "Signal"
	label_desc = "Signal: The artifact seems to be made of a radio sensitive material. This material seems to be triggered by radio pulses."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	///Signal code
	var/code
	///Signal frequency
	var/datum/radio_frequency/radio_connection
	//Signal
	var/datum/signal/signal
	///Annoying soung
	var/sound_timer

	///Reference to our particle holder - we need to use holders & vis contents, otherwise shit gets fucky with filters
	var/atom/movable/artifact_particle_holder/particle_holder

/datum/xenoartifact_trait/activator/signal/New(atom/_parent)
	. = ..()
	//Code
	code = rand(0, 100)
	//Signal
	signal = new(list("code" = code))
	//Frequency
	radio_connection = SSradio.add_object(src, FREQ_SIGNALER, "[RADIO_XENOA]_[REF(src)]")
	radio_connection.add_listener(src)

/datum/xenoartifact_trait/minor/signaller/Destroy(force, ...)
	SSradio.remove_object(src, FREQ_SIGNALER)
	QDEL_NULL(signal)
	return ..()

/datum/xenoartifact_trait/activator/signal/register_parent(datum/source)
	. = ..()
	if(!component_parent?.parent)
		return
	setup_generic_item_hint()
	sound_timer = addtimer(CALLBACK(src, PROC_REF(do_sonar)), 5 SECONDS, TIMER_STOPPABLE)

/datum/xenoartifact_trait/activator/signal/remove_parent(datum/source, pensive)
	if(sound_timer)
		deltimer(sound_timer)
	return ..()

/datum/xenoartifact_trait/activator/signal/generate_trait_appearance(atom/movable/target)
	. = ..()
	if(!ismovable(target))
		return
	//Build particle holder
	particle_holder = new(component_parent?.parent)
	particle_holder.add_emitter(/obj/emitter/sonar, "sonar", 9)
	//Layer onto parent
	target.vis_contents += particle_holder

/datum/xenoartifact_trait/activator/signal/cut_trait_appearance(atom/movable/target)
	. = ..()
	if(!ismovable(target))
		return
	target.vis_contents -= particle_holder
	QDEL_NULL(particle_holder)

/datum/xenoartifact_trait/activator/signal/do_hint(mob/user, atom/item)
	if(istype(item, /obj/item/analyzer))
		to_chat(user, "<span class='warning'>[item] detects an input frequency & code of [FREQ_SIGNALER]-[code]!</span>")
		return ..()

/datum/xenoartifact_trait/activator/signal/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_TRIGGER("signaller assembly"),
	XENOA_TRAIT_HINT_DETECT("analyzer, which will also reveal its trigger code & frequency"),
	XENOA_TRAIT_HINT_RANDOMISED, list("icon" = "exclamation", "desc" = "This trait will activate on the nearest living target."),
	XENOA_TRAIT_HINT_APPEARANCE("This trait will make radar particles appear around the artifact."),
	XENOA_TRAIT_HINT_SOUND("sonar pings"))

/datum/xenoartifact_trait/activator/signal/proc/receive_signal(datum/signal/signal)
	if(!signal)
		return
	if(signal.data["code"] != code)
		return
	for(var/atom/target in oview(component_parent.target_range, get_turf(component_parent?.parent)))
		//Only add mobs
		if(!ismob(target))
			continue
		trigger_artifact(target, XENOA_ACTIVATION_CONTACT)
		break
	if(!length(component_parent.targets))
		component_parent.trigger()

/datum/xenoartifact_trait/activator/signal/proc/do_sonar(repeat = TRUE)
	if(QDELETED(src))
		return
	var/atom/atom_parent = component_parent.parent
	if(isturf(atom_parent.loc))
		playsound(get_turf(component_parent?.parent), 'sound/effects/ping.ogg', 60, TRUE)
	var/rand_time = rand(5, 15) SECONDS
	sound_timer = addtimer(CALLBACK(src, PROC_REF(do_sonar)), rand_time / (isturf(atom_parent.loc) ? 2 : 1), TIMER_STOPPABLE)
