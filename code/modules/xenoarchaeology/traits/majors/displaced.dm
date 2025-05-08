/*
	Displaced
	Teleports the target to a random nearby turf
*/
/datum/xenoartifact_trait/major/displaced
	label_name = "Displaced"
	label_desc = "Displaced: The artifact seems to contain displacing components. Triggering these components will displace the target."
	cooldown = XENOA_TRAIT_COOLDOWN_SAFE
	flags =  XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	weight = 15
	conductivity = 15

/datum/xenoartifact_trait/major/displaced/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	for(var/atom/movable/target in focus)
		if(!target.anchored)
			do_teleport(target, get_turf(target), (component_parent.trait_strength*0.3)+1, channel = TELEPORT_CHANNEL_BLUESPACE)
			var/atom/log_atom = component_parent.parent
			log_game("[component_parent] in [log_atom] teleported [key_name_admin(target)] at [world.time]. [log_atom] located at [AREACOORD(log_atom)]")
		unregister_target(target)
	dump_targets()
	clear_focus()
