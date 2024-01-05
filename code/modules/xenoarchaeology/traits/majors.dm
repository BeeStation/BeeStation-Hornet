/datum/xenoartifact_trait/major

/*
	Shock
	Electrocutes the mob target, or charges the cell target
*/
/datum/xenoartifact_trait/major/shock
	cooldown = 2 SECONDS

/datum/xenoartifact_trait/major/shock/trigger(atom/A, _priority)
	. = ..()
	if(length(targets))
		playsound(get_turf(parent.parent), 'sound/machines/defib_zap.ogg', 50, TRUE)
	for(var/atom/A in targets)
		if(iscarbon(A))
			var/mob/living/carbon/victim = A
			victim.electrocute_act(parent.trait_strength*0.25, parent.parent, 1, 1) //Deal a max of 25
			unregister_target(M, FALSE)
		else if(istype(A, /obj/item/stock_parts/cell))
			var/obj/item/stock_parts/cell/C = target
			C.give((parent.trait_strength/100)*C.maxcharge) //Yes, this is potentially potentially powerful, but it will be cool
	dump_targets() //Get rid of anything else, since we can't interact with it
