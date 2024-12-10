/*
	Malfunction
	These traits cause the xenoartifact to malfunction, typically making the artifact wrose

	* weight - All malfunctions should have a weight that is a multiple of 7
	* conductivity - If a malfunction should have conductivity, it will be a multiple of 7 too
*/
/datum/xenoartifact_trait/malfunction
	priority = TRAIT_PRIORITY_MALFUNCTION
	register_targets = FALSE
	weight = 7
	conductivity = 0
	contribute_calibration = FALSE
	can_pearl = FALSE
	cooldown = XENOA_TRAIT_COOLDOWN_SAFE

/datum/xenoartifact_trait/malfunction/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	for(var/mob/living/M in oview(XENOA_TRAIT_BALLOON_HINT_DIST, get_turf(component_parent.parent)))
		do_hint(M)

/datum/xenoartifact_trait/malfunction/do_hint(mob/user, atom/item)
	//If they have science goggles, or equivilent, they are shown exatcly what trait this is
	if(!user?.can_see_reagents())
		return
	var/atom/atom_parent = component_parent.parent
	if(!isturf(atom_parent.loc))
		atom_parent = atom_parent.loc
	atom_parent.balloon_alert(user, label_name, component_parent.artifact_material.material_color, offset_y = 8)
	//show_in_chat doesn't work
	to_chat(user, "<span class='notice'>[component_parent.parent] : [label_name]</span>")
