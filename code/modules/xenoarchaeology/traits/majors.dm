/datum/xenoartifact_trait/major

/*
	Shock
	Electrocutes the mob target, or charges the cell target
*/
/datum/xenoartifact_trait/major/shock
	label_name = "Electrified"
	label_desc = "The artifact seems to contain electrifying components. Triggering these components will shock the target."
	cooldown = XENOA_TRAIT_COOLDOWN_DANGEROUS
	flags = PLASMA_TRAIT | URANIUM_TRAIT | BANANIUM_TRAIT
	conductivity = 10

/datum/xenoartifact_trait/major/shock/trigger(datum/source, _priority, atom/A)
	. = ..()
	if(length(targets))
		playsound(get_turf(parent.parent), 'sound/machines/defib_zap.ogg', 50, TRUE)
	for(var/atom/target in targets)
		if(iscarbon(target))
			var/mob/living/carbon/victim = target
			victim.electrocute_act(parent.trait_strength*0.25, parent.parent, 1, 1) //Deal a max of 25
			unregister_target(target)
		else if(istype(target, /obj/item/stock_parts/cell))
			var/obj/item/stock_parts/cell/C = target
			C.give((parent.trait_strength/100)*C.maxcharge) //Yes, this is potentially potentially powerful, but it will be cool
	dump_targets() //Get rid of anything else, since we can't interact with it

/*
	Hollow
	Captures the target for an amount of time
*/
/datum/xenoartifact_trait/major/hollow
	examine_desc = "hollow"
	label_name = "Hollow"
	label_desc = "The artifact seems to contain hollow components. Triggering these components will capture the target."
	cooldown = XENOA_TRAIT_COOLDOWN_DANGEROUS
	flags = BLUESPACE_TRAIT | URANIUM_TRAIT | BANANIUM_TRAIT
	weight = -10
	///Maximum time we hold people for
	var/hold_time = 20 SECONDS

/datum/xenoartifact_trait/major/hollow/trigger(datum/source, _priority, atom/A)
	. = ..()
	for(var/atom/target in targets)
		if(ismovable(target))
			var/atom/movable/M = target
			var/atom/movable/AM = parent.parent
			//handle being held
			if(!isturf(AM.loc) && locate(AM.loc) in targets)
				AM.forceMove(get_turf(AM.loc))
			M.forceMove(parent.parent)
			//Buckle targets to artifact
			AM.buckle_mob(M)
			//Add timer to undo this
			addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/xenoartifact_trait, un_trigger)), hold_time*(parent.trait_strength/100))
		else
			unregister_target(target)

/datum/xenoartifact_trait/major/hollow/un_trigger(atom/A)
	if(length(targets))
		var/atom/movable/AM = parent.parent
		AM.unbuckle_all_mobs()
		for(var/atom/target in targets)
			if(ismovable(target))
				var/atom/movable/M = target
				if(M.loc == AM)
					M.forceMove(get_turf(AM))
	return ..()
