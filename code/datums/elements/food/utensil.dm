/datum/element/utensil
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	/// overlay ontop a utensil
	var/food_overlay_state
	var/bite_word
	var/eat_sound
	/// soup scooper slurp slurp
	var/scoops_soup

/datum/element/utensil/Attach(obj/item/target, food_overlay_state, bite_word, eat_sound, scoops_soup = FALSE)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	src.food_overlay_state = food_overlay_state
	src.bite_word = bite_word
	src.eat_sound = eat_sound
	src.scoops_soup = scoops_soup
	target.create_reagents(5, NO_REACT)
	ADD_TRAIT(target, TRAIT_UTENSIL, ELEMENT_TRAIT(type))
	RegisterSignal(target, COMSIG_ITEM_PRE_ATTACK, PROC_REF(on_pre_attack))
	RegisterSignal(target, COMSIG_ITEM_UTENSIL_SCOOP, PROC_REF(on_scoop))
	RegisterSignal(target, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))

/datum/element/utensil/Detach(obj/item/source)
	. = ..()
	REMOVE_TRAIT(source, TRAIT_UTENSIL, ELEMENT_TRAIT(type))
	UnregisterSignal(source, list(COMSIG_ITEM_PRE_ATTACK, COMSIG_ITEM_UTENSIL_SCOOP, COMSIG_ATOM_UPDATE_OVERLAYS))

/datum/element/utensil/proc/on_update_overlays(obj/item/source, list/overlays)
	SIGNAL_HANDLER

	if(source.reagents.total_volume)
		overlays += mutable_appearance(source.icon, food_overlay_state, appearance_flags = RESET_COLOR, color = mix_color_from_reagents(source.reagents.reagent_list))

/datum/element/utensil/proc/on_pre_attack(obj/item/source, atom/target, mob/living/user)
	SIGNAL_HANDLER

	if(user.combat_mode || !source.reagents.total_volume || !iscarbon(target))
		return
	INVOKE_ASYNC(src, PROC_REF(feed), source, target, user)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/element/utensil/proc/on_scoop(obj/item/source, atom/food, mob/user)
	SIGNAL_HANDLER

	if(source.reagents.total_volume)
		to_chat(user, span_warning("You already have food on your [source.name]!"))
		return
	if(istype(food, /obj/item/food/soup) != scoops_soup)
		if(scoops_soup)
			to_chat(user, span_warning("[food] doesn't seem to fit on your [source.name]! Maybe try a fork."))
		else
			to_chat(user, span_warning("You try to scoop up [food] with your [source.name], but it slips through the prongs! Maybe try a spoon."))
		return
	user.do_item_attack_animation(food, used_item = source)
	user.visible_message(span_notice("[user] scoops a [bite_word] of [food] with [user.p_their()] [source.name]."), span_notice("You scoop a [bite_word] of [food] with your [source.name]."))
	return COMPONENT_UTENSIL_SCOOPED

/datum/element/utensil/proc/feed(obj/item/source, mob/living/carbon/eater, mob/living/user)
	var/obj/item/covering = eater.is_mouth_covered()
	if(covering)
		to_chat(user, span_warning("You have to remove [eater == user ? "your" : "[eater.p_their()]"] [covering.name] first!"))
		return
	if(eater != user)
		eater.visible_message(span_notice("[user] starts feeding [eater] a [bite_word] of food..."), span_userdanger("[user] starts feeding you a [bite_word]..."))
		if(!do_after(user, 1.5 SECONDS, eater, extra_checks = CALLBACK(src, PROC_REF(is_loaded), source)))
			return
		log_combat(user, eater, "fed", source.reagents.log_list(), important = FALSE)
		eater.visible_message(span_notice("[user] feeds [eater] a [bite_word] of food!"))
	else
		eater.visible_message(span_notice("[user] eats a [bite_word] of food!"), span_notice("You eat a [bite_word] of food!"))
	playsound(eater, eat_sound, 25, TRUE)
	source.reagents.trans_to(eater, source.reagents.total_volume, transfered_by = user, method = INGEST)
	source.update_appearance(UPDATE_OVERLAYS)

/datum/element/utensil/proc/is_loaded(obj/item/source)
	return source.reagents.total_volume > 0
