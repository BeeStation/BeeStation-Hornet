/*
	Mass Hallucinatory Injection
	Makes the target/s hallucinate
*/
/datum/xenoartifact_trait/malfunction/hallucination
	label_name = "M.H.I."
	alt_label_name = "Mass Hallucinatory Injection"
	label_desc = "Mass Hallucinatory Injection: The Artifact causes the target to hallucinate."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_PLASMA_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	register_targets = TRUE

/datum/xenoartifact_trait/malfunction/hallucination/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	for(var/mob/living/target in focus)
		var/datum/hallucination/H = pick_weight(GLOB.random_hallucination_weighted_list)
		target.cause_hallucination(H, "xenoartifact hallucination")
	dump_targets()
	clear_focus()
