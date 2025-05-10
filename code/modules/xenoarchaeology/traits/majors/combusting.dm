/*
	Combusting
	Ignites the target
*/
/datum/xenoartifact_trait/major/combusting
	label_name = "Combusting"
	label_desc = "Combusting: The artifact seems to contain combusting components. Triggering these components will ignite the target."
	flags = XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	conductivity = 24
	weight = 12
	///max fire stacks
	var/max_stacks = 6

/datum/xenoartifact_trait/major/combusting/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	for(var/atom/target in focus)
		if(iscarbon(target))
			var/mob/living/carbon/victim = target
			victim.adjust_fire_stacks(max_stacks*(component_parent.trait_strength/100))
			victim.IgniteMob()
		else
			target.fire_act(1000, 500)
	dump_targets()
	clear_focus()
