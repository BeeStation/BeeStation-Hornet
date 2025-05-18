/*
	Electrified
	Electrocutes the mob target, or charges the cell target
*/
/datum/xenoartifact_trait/major/shock
	label_name = "Electrified"
	label_desc = "Electrified: The artifact seems to contain electrifying components. Triggering these components will shock the target."
	cooldown = XENOA_TRAIT_COOLDOWN_DANGEROUS
	flags = XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	conductivity = 27
	///max damage
	var/max_damage = 25
	///Max cable charge
	var/max_cable_charge = 50000

/datum/xenoartifact_trait/major/shock/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	playsound(get_turf(component_parent.parent), 'sound/machines/defib_zap.ogg', 50, TRUE)
	do_sparks(3, FALSE, component_parent.parent)
	//electrocute targets
	for(var/atom/target in focus)
		if(iscarbon(target))
			var/mob/living/carbon/victim = target
			victim.electrocute_act(max_damage*(component_parent.trait_strength/100), component_parent.parent, 1, 1) //Deal a max of 25
		else if(istype(target, /obj/item/stock_parts/cell))
			var/obj/item/stock_parts/cell/C = target
			C.give((component_parent.trait_strength/100)*C.maxcharge) //Yes, this is potentially potentially powerful, but it will be cool
		var/atom/log_atom = component_parent.parent
		log_game("[component_parent] in [log_atom] electrocuted [key_name_admin(target)] at [world.time]. [log_atom] located at [AREACOORD(log_atom)]")
	//If there's an exposed cable below us, charge it
	var/obj/structure/cable/C = locate(/obj/structure/cable) in get_turf(component_parent.parent)
	if(C?.invisibility <= UNDERFLOOR_HIDDEN)
		C.powernet?.newavail += max_cable_charge*(component_parent.trait_strength/100)
	//Get rid of anything else, since we can't interact with it
	dump_targets()
	//Tidy up focus too
	clear_focus()
