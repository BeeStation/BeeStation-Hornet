
/*
	Bluespace Axis Desync
	Strips a random article from the target
*/
/datum/xenoartifact_trait/malfunction/strip
	label_name = "B.A.D."
	alt_label_name = "Bluespace Axis Desync"
	label_desc = "Bluespace Axis Desync: A strange malfunction causes the Artifact to remove articles from the target."
	flags = XENOA_BLUESPACE_TRAIT| XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	register_targets = TRUE

/datum/xenoartifact_trait/malfunction/strip/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	for(var/mob/living/M in focus)
		var/list/clothing_list = list()
		for(var/obj/item/clothing/I in M.contents)
			clothing_list += I
		if(!length(clothing_list))
			break
		var/obj/item/clothing/C = pick(clothing_list)
		if(!HAS_TRAIT_FROM(C, TRAIT_NODROP, GLUED_ITEM_TRAIT))
			M.dropItemToGround(C)
	dump_targets()
	clear_focus()
