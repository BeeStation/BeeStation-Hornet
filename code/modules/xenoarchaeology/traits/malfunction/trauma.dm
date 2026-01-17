/*
	Cerebral Dysfunction Emergence
	Gives the target a trauma
*/
/datum/xenoartifact_trait/malfunction/trauma
	label_name = "C.D.E."
	alt_label_name = "Cerebral Dysfunction Emergence"
	label_desc = "Cerebral Dysfunction Emergence: A strange malfunction causes the Artifact to cause traumas to emerge in the target."
	flags = XENOA_BLUESPACE_TRAIT| XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	register_targets = TRUE
	///Possbile traumas
	var/list/possible_traumas = list(
			/datum/brain_trauma/mild/hallucinations, /datum/brain_trauma/mild/stuttering, /datum/brain_trauma/mild/dumbness,
			/datum/brain_trauma/mild/speech_impediment, /datum/brain_trauma/mild/concussion, /datum/brain_trauma/mild/muscle_weakness,
			/datum/brain_trauma/mild/expressive_aphasia, /datum/brain_trauma/severe/narcolepsy, /datum/brain_trauma/severe/discoordination,
			/datum/brain_trauma/severe/pacifism, /datum/brain_trauma/special/beepsky)
	///Choosen trauma
	var/datum/brain_trauma/trauma

/datum/xenoartifact_trait/malfunction/trauma/New(atom/_parent)
	. = ..()
	trauma = pick(possible_traumas)

/datum/xenoartifact_trait/malfunction/trauma/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	for(var/mob/living/carbon/M in focus)
		M.Unconscious(0.5 SECONDS)
		M.gain_trauma(trauma, TRAUMA_RESILIENCE_BASIC)
	dump_targets()
	clear_focus()
