/obj/item/event_vine_remover
	name = "vine remover"
	desc = "vine removal tool"
	w_class = WEIGHT_CLASS_NORMAL
	item_flags = ISWEAPON

/obj/item/event_vine_remover/attack_self(mob/living/carbon/user)
	var/vine_found = FALSE
	var/vines_removed
	if(do_after(user, 1 SECONDS, null, null, TRUE))
		for(var/obj/effect/forcefield/event/vines/V in range(1, user))
			vine_found = TRUE //There's probably a better way to do this, isn't there?
			var/vine_turf = get_turf(V)
			if(istype(vine_turf, /turf/open))
				new /obj/structure/spacevine(vine_turf)
			vines_removed++
			qdel(V)
		if(vine_found)
			to_chat(user, "<span class='danger'>The vine remover saps your strength!</span>")
			new /obj/effect/temp_visual/cult/sparks(get_turf(user), "#960000")
			user.adjustBruteLoss((vines_removed * 2), 0)
		else
			to_chat(user, "<span class='notice'>The vine remover glows softly, it's unable to find a valid target.</span>")
