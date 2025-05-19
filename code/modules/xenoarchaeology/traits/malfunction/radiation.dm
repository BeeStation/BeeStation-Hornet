/*
	Rapid Particle Emmision
	Irradiates the artifact and targets
*/
/datum/xenoartifact_trait/malfunction/radiation
	label_name = "R.P.E."
	alt_label_name = "Rapid Particle Emmision"
	label_desc = "Rapid Particle Emmision: A strange malfunction that causes the Artifact to irradiate itself and its targets."
	flags = XENOA_BLUESPACE_TRAIT| XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	register_targets = TRUE
	///Max amount of radiation we can deal
	var/max_rad = 25

/datum/xenoartifact_trait/malfunction/radiation/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	var/atom/atom_parent = component_parent.parent
	atom_parent.rad_act(max_rad*(component_parent.trait_strength/100))
	for(var/atom/target in focus)
		target.rad_act(max_rad*(component_parent.trait_strength/100))
	dump_targets()
	clear_focus()
