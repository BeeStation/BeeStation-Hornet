//TODO: Redo this code, or just improve it - Racc
/obj/item/xenoarchaeology_labeler
	name = "artifact labeler"
	icon = 'icons/obj/xenoarchaeology/xenoartifact_tech.dmi'
	icon_state = "labeler"
	desc = "A tool scientists use to label their alien bombs."
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY

	///Checked trait
	var/list/selected_activator_traits = list()
	///Display names
	var/list/activator_traits = list()

	var/list/selected_minor_traits = list()
	var/list/minor_traits = list()

	var/list/selected_major_traits = list()
	var/list/major_traits = list()

	var/list/selected_malfunction_traits = list()
	var/list/malfunction_list = list()

	///List of descriptions for selected traits
	var/list/info_list = list()

	///List of selected traits we'll put on the label
	var/list/label_traits = list()

	///Cooldown for stickers
	var/sticker_cooldown = 5 SECONDS
	COOLDOWN_DECLARE(sticker_cooldown_timer)

/obj/item/xenoarchaeology_labeler/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_ARTIFACT_IGNORE, GENERIC_ITEM_TRAIT)
	generate_xenoa_statics()
	//generate data for trait names
	activator_traits = get_trait_list_names(GLOB.xenoa_activators)
	minor_traits = get_trait_list_names(GLOB.xenoa_minors)
	major_traits = get_trait_list_names(GLOB.xenoa_majors)
	malfunction_list = get_trait_list_names(GLOB.xenoa_malfunctions)

/obj/item/xenoarchaeology_labeler/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "XenoartifactLabeler")
		ui.open()

/obj/item/xenoarchaeology_labeler/ui_data(mob/user)
	var/list/data = list()
	data["selected_activator_traits"] = selected_activator_traits
	data["selected_minor_traits"] = selected_minor_traits
	data["selected_major_traits"] = selected_major_traits
	data["selected_malfunction_traits"] = selected_malfunction_traits
	data["info_list"] = info_list

	return data

/obj/item/xenoarchaeology_labeler/ui_static_data(mob/user)
	var/list/data = list()
	data["malfunction_list"] = malfunction_list
	data["major_traits"] = major_traits
	data["minor_traits"] = minor_traits
	data["activator_traits"] = activator_traits

	return data

/obj/item/xenoarchaeology_labeler/ui_act(action, params)
	if(..())
		return
	
	//print label
	if(action == "print_traits" && COOLDOWN_FINISHED(src, sticker_cooldown_timer))
		COOLDOWN_START(src, sticker_cooldown_timer, sticker_cooldown)
		create_label()
		return
	else if(!COOLDOWN_FINISHED(src, sticker_cooldown_timer) && isliving(loc))
		var/mob/living/user = loc
		to_chat(user, "<span class='warning'>The labeler is still printing.</span>")
	//Clear selections
	if(action == "clear_traits")
		clear_selection()
		return
	//Toggle traits
	trait_toggle(action, "activator", activator_traits, selected_activator_traits)
	trait_toggle(action, "minor", minor_traits, selected_minor_traits)
	trait_toggle(action, "major", major_traits, selected_major_traits)
	trait_toggle(action, "malfunction", malfunction_list, selected_malfunction_traits)
	build_info_list()

	return TRUE

//Get a list of all the specified trait types names
/obj/item/xenoarchaeology_labeler/proc/get_trait_list_names(list/trait_type)
	var/list/temp = list()
	for(var/datum/xenoartifact_trait/T as() in trait_type)
		temp += initial(T.label_name)
		
	return temp

/obj/item/xenoarchaeology_labeler/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(proximity_flag && COOLDOWN_FINISHED(src, sticker_cooldown_timer))
		COOLDOWN_START(src, sticker_cooldown_timer, 5 SECONDS)
		create_label(target, user)
	else if(!COOLDOWN_FINISHED(src, sticker_cooldown_timer))
		to_chat(user, "<span class='warning'>The labeler is still printing.</span>")

///reset all the options
/obj/item/xenoarchaeology_labeler/proc/clear_selection()
	info_list = list()
	label_traits = list()
	selected_activator_traits = list()
	selected_minor_traits = list()
	selected_major_traits = list()
	selected_malfunction_traits = list()
	ui_update()

/obj/item/xenoarchaeology_labeler/proc/create_label(mob/target, mob/user)
	var/obj/item/sticker/xenoartifact_label/P = new(get_turf(src), label_traits)
	if(target && user)
		P.afterattack(target, user, TRUE)

/obj/item/xenoarchaeology_labeler/proc/trait_toggle(action, toggle_type, var/list/trait_list, var/list/active_trait_list)
	for(var/t in trait_list)
		if(action != "assign_[toggle_type]_[t]")
			continue
		if(t in active_trait_list)
			active_trait_list -= t
			label_traits -= GLOB.xenoa_all_traits_keyed[t]
		else
			active_trait_list += t
			label_traits += GLOB.xenoa_all_traits_keyed[t]

//Idk how efficient this is
/obj/item/xenoarchaeology_labeler/proc/build_info_list()
	var/list/focus = list()
	focus += selected_activator_traits
	focus += selected_minor_traits
	focus += selected_major_traits
	focus += selected_malfunction_traits

	info_list = list()
	for(var/t in focus)
		var/datum/xenoartifact_trait/description_holder = GLOB.xenoa_all_traits_keyed[t]
		description_holder = new description_holder()
		info_list += list(list("name" = description_holder.label_name,"desc" = description_holder.label_desc, "hints" = description_holder.get_dictionary_hint()))
		qdel(description_holder)

/obj/item/xenoarchaeology_labeler/debug
	name = "xenoartifact debug labeler"
	desc = "Use to create specific Xenoartifacts"
	icon_state = "labeler_debug"
	sticker_cooldown = 0 SECONDS

//Create an artifact with all the traits we have selected, but from the item we target
/obj/item/xenoarchaeology_labeler/debug/afterattack(atom/target, mob/user)
	if(length(label_traits))
		target.AddComponent(/datum/component/xenoartifact, /datum/xenoartifact_material, label_traits, TRUE, FALSE)
	else
		target.AddComponent(/datum/component/xenoartifact, /datum/xenoartifact_material, null, TRUE, FALSE)

//Create an artifact with all the traits we hve selected
/obj/item/xenoarchaeology_labeler/debug/create_label(new_name)
	var/obj/item/xenoartifact/no_traits/A = new(get_turf(loc))
	A.AddComponent(/datum/component/xenoartifact, /datum/xenoartifact_material, label_traits)

/*
	Sticker for labeler, so we can label artifact's with their traits
*/

/obj/item/sticker/xenoartifact_label
	icon = 'icons/obj/xenoarchaeology/xenoartifact_sticker.dmi'
	icon_state = "sticker_star"
	name = "artifact label"
	desc = "An adhesive label, for artifacts."
	do_outline = FALSE
	///List of artifact traits we're labelling
	var/list/traits = list()
	///A special examine description built from the traits we have
	var/examine_override = ""
	///The original custom price of the item we're going to label
	var/old_custom_price

/obj/item/sticker/xenoartifact_label/Initialize(mapload, list/_traits)
	ADD_TRAIT(src, TRAIT_ARTIFACT_IGNORE, GENERIC_ITEM_TRAIT)
	//Setup traits & examine desc
	traits = _traits
	if(length(traits))
		examine_override = "Traits:"
		for(var/datum/xenoartifact_trait/T as() in traits)
			examine_override = "[examine_override]\n	- [initial(T.label_name)]"
	//Setup a random appearance
	icon_state = "sticker_[pick(list("star", "box", "tri", "round"))]"
	sticker_icon_state = "[icon_state]_small"
	return ..()

/obj/item/sticker/xenoartifact_label/examine(mob/user)
	. = ..()
	. += examine_override

/obj/item/sticker/xenoartifact_label/afterattack(atom/movable/target, mob/user, proximity_flag, click_parameters)
	//If you somehow make traits start working with mobs, remove this isliving() check
	if(!isliving(target) && (locate(/obj/item/sticker/xenoartifact_label) in target.contents))
		to_chat(user, "<span class='watning'>[target] already has a label!</span>")
		return
	. = ..()
	if(!can_stick(target) || !proximity_flag)
		return
	//Set custom price with the artifact component
	var/datum/component/xenoartifact/artifact = target.GetComponent(/datum/component/xenoartifact)
	if(artifact)
		old_custom_price = target.custom_price
		for(var/i in artifact.artifact_traits)
			for(var/datum/xenoartifact_trait/T as() in artifact.artifact_traits[i])
				if(locate(T) in traits)
					target.custom_price *= XENOA_LABEL_REWARD
				else
					target.custom_price *= XENOA_LABEL_PUNISHMENT
	RegisterSignal(target, COMSIG_PARENT_EXAMINE, PROC_REF(parent_examine))

/obj/item/sticker/xenoartifact_label/attack_hand(mob/user)
	if(sticker_state == STICKER_STATE_STUCK)
		UnregisterSignal(loc, COMSIG_PARENT_EXAMINE)
	//Set custom price back
	var/datum/component/xenoartifact/artifact = loc.GetComponent(/datum/component/xenoartifact)
	if(artifact)
		loc.custom_price = old_custom_price
	. = ..()

/obj/item/sticker/xenoartifact_label/proc/parent_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER

	examine_text += "<span class='notice'>There is an artifact label attached.</span>"
	examine_text += examine_override
