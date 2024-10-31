/*
	EMP
	Creates an EMP effect at the position of the artfiact
*/
/datum/xenoartifact_trait/major/emp
	label_name = "EMP"
	label_desc = "EMP: The artifact seems to contain electromagnetic pulsing components. Triggering these components will create an EMP."
	cooldown = XENOA_TRAIT_COOLDOWN_GAMER
	flags = XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	register_targets = FALSE
	rarity = XENOA_TRAIT_WEIGHT_MYTHIC //Fuck this trait
	weight = 9
	conductivity = 36

/datum/xenoartifact_trait/major/emp/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	INVOKE_ASYNC(src, PROC_REF(do_emp)) //empluse() calls stoplag(), which calls sleep()

/datum/xenoartifact_trait/major/emp/proc/do_emp()
	var/turf/T = get_turf(component_parent.parent)
	if(!T)
		return
	playsound(T, 'sound/magic/disable_tech.ogg', 50, TRUE)
	empulse(T, max(1, component_parent.trait_strength*0.03), max(1, component_parent.trait_strength*0.05, 1))
	var/atom/log_atom = component_parent.parent
	log_game("[component_parent] in [log_atom] made an EMP at [world.time]. [log_atom] located at [AREACOORD(log_atom)]")
