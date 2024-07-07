/obj/item/sticker/trait_pearl
	name = "xenopearl"
	icon = 'icons/obj/xenoarchaeology/xenoartifact.dmi'
	icon_state = "trait_pearl"
	w_class = WEIGHT_CLASS_TINY
	desc = "A smooth alien pearl."
	sticker_icon = 'icons/obj/xenoarchaeology/xenoartifact.dmi'
	sticker_icon_state = "trait_pearl_sticker"
	do_outline = FALSE
	///What trait do we have stored
	var/datum/xenoartifact_trait/stored_trait

/obj/item/sticker/trait_pearl/Initialize(mapload, trait)
	. = ..()
	stored_trait = trait

/obj/item/sticker/trait_pearl/afterattack(atom/movable/target, mob/user, proximity_flag, click_parameters)
	//Prechecks
	if(!can_stick(target) || !proximity_flag)
		return
	if(isliving(target) || isstructure(target) || target.GetComponent(/datum/component/xenoartifact) || target.GetComponent(/datum/component/storage))
		to_chat(user, "<span class='warning'>You are unable to affix [src] to [target].</span>")
		return
	//Stop people adding too many traits, and check the trait limits
	var/list/pearl_index = list(TRAIT_PRIORITY_ACTIVATOR = 0, TRAIT_PRIORITY_MINOR = 0, TRAIT_PRIORITY_MAJOR = 0, TRAIT_PRIORITY_MALFUNCTION = 0)
	var/datum/xenoartifact_material/pearl/material = /datum/xenoartifact_material/pearl
	for(var/obj/item/sticker/trait_pearl/P in target.contents)
		//Just check against generic pearl limits
		if(istype(P.stored_trait, /datum/xenoartifact_trait/activator) && pearl_index[TRAIT_PRIORITY_ACTIVATOR] < initial(material.trait_activators))
			pearl_index[TRAIT_PRIORITY_ACTIVATOR] += 1
		else if(istype(P.stored_trait, /datum/xenoartifact_trait/minor) && pearl_index[TRAIT_PRIORITY_MINOR] < initial(material.trait_minors))
			pearl_index[TRAIT_PRIORITY_MINOR] += 1
		else if(istype(P.stored_trait, /datum/xenoartifact_trait/major) && pearl_index[TRAIT_PRIORITY_MAJOR] < initial(material.trait_majors))
			pearl_index[TRAIT_PRIORITY_MAJOR] += 1
		else if(istype(P.stored_trait, /datum/xenoartifact_trait/malfunction) && pearl_index[TRAIT_PRIORITY_MALFUNCTION] < initial(material.trait_malfunctions))
			pearl_index[TRAIT_PRIORITY_MALFUNCTION] += 1
		else
			to_chat(user, "<span class='warning'>You are unable to affix [src] to [target].</span>")
			return
	//Affix if we're chilling
	to_chat(user, "<span class='notice'>You affix [src] to [target].</span>")
	return ..()

/obj/item/sticker/trait_pearl/examine(mob/user)
	. = ..()
	if(user.can_see_reagents())
		. += "<span class='notice'>[src] holds '[initial(stored_trait.label_name) || "nothing"]'.\nYou can affix it to an item.</span>"

/obj/item/sticker/trait_pearl/build_stuck_appearance()
	var/mutable_appearance/MA = setup_appearance(mutable_appearance(sticker_icon || src.icon, sticker_icon_state || src.icon_state))
	MA.blend_mode = BLEND_INSET_OVERLAY
	return MA
