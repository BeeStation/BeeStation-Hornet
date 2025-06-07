/*
	Immediate Organ Extraction
	steals the target's appendix
*/
/datum/xenoartifact_trait/malfunction/organ_stealer
	label_name = "I.O.E"
	alt_label_name = "Immediate Organ Extraction"
	label_desc = "Immediate Organ Extraction: A strange malfunction causes the Artifact to extract the target's appendix."
	flags = XENOA_BLUESPACE_TRAIT| XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	register_targets = TRUE
	///What organ slot do we yank from
	var/target_organ_slot = ORGAN_SLOT_APPENDIX

/datum/xenoartifact_trait/malfunction/organ_stealer/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	for(var/mob/living/carbon/M in focus)
		var/obj/item/organ/O = M.get_organ_slot(target_organ_slot)
		O?.Remove(M)
		O?.forceMove(get_turf(component_parent.parent))
	dump_targets()
	clear_focus()

/datum/xenoartifact_trait/malfunction/organ_stealer/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("steal the target's appendix"))

//This variant will steal the target's tongue
/datum/xenoartifact_trait/malfunction/organ_stealer/tongue
	label_name = "I.O.E Δ"
	alt_label_name = "Immediate Organ Extraction Δ"
	label_desc = "Immediate Organ Extraction Δ: A strange malfunction causes the Artifact to extract the target's tongue."
	target_organ_slot = ORGAN_SLOT_TONGUE
	conductivity = 14

/datum/xenoartifact_trait/malfunction/organ_stealer/tongue/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("steal the target's tongue"))
