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
	//TODO: Stop people adding INF traits - Racc
	//TODO: Stop people adding wrong trait proportions - Racc
	if(!can_stick(target) || !proximity_flag)
		return
	if(isliving(target) || target.GetComponent(/datum/component/xenoartifact))
		to_chat(user, "<span class='warning'>You are unable to affix [src] to [target].</span>")
		return
	to_chat(user, "<span class='notice'>You affix [src] to [target].</span>")
	return ..()

/obj/item/sticker/trait_pearl/examine(mob/user)
	. = ..()
	if(user.can_see_reagents())
		. += "<span class='notice'>[src] holds '[initial(stored_trait.label_name)]'.</span>"

/obj/item/sticker/trait_pearl/build_stuck_appearance()
	var/mutable_appearance/MA = setup_appearance(mutable_appearance(sticker_icon || src.icon, sticker_icon_state || src.icon_state))
	MA.blend_mode = BLEND_INSET_OVERLAY
	return MA
