//TODO: Redo this code, or just improve it - Racc
/obj/item/xenoarchaeology_labeler
	name = "artifact labeler"
	icon = 'icons/obj/xenoarchaeology/xenoartifact_tech.dmi'
	icon_state = "labeler"
	desc = "A tool scientists use to label their alien bombs."
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY

	///Checked traits
	var/list/selected_traits = list()
	///Trait lists
	var/list/activator_traits = list()
	var/list/minor_traits = list()
	var/list/major_traits = list()
	var/list/malfunction_list = list()

	///List of trait stats for tooltip shit, this is kinda fucked but who gives a shit
	var/list/tooltip_stats = list()

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
	activator_traits = get_trait_list_stats(GLOB.xenoa_activators)
	minor_traits = get_trait_list_stats(GLOB.xenoa_minors)
	major_traits = get_trait_list_stats(GLOB.xenoa_majors)
	malfunction_list = get_trait_list_stats(GLOB.xenoa_malfunctions)

/obj/item/xenoarchaeology_labeler/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "XenoartifactLabeler")
		ui.open()

/obj/item/xenoarchaeology_labeler/ui_data(mob/user)
	var/list/data = list()
	data["selected_traits"] = selected_traits

	return data

/obj/item/xenoarchaeology_labeler/ui_static_data(mob/user)
	var/list/data = list()
	data["malfunction_list"] = malfunction_list
	data["major_traits"] = major_traits
	data["minor_traits"] = minor_traits
	data["activator_traits"] = activator_traits
	data["tooltip_stats"] = tooltip_stats

	return data

/obj/item/xenoarchaeology_labeler/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("print_traits")
			if(COOLDOWN_FINISHED(src, sticker_cooldown_timer))
				COOLDOWN_START(src, sticker_cooldown_timer, sticker_cooldown)
				create_label()
			else if(!COOLDOWN_FINISHED(src, sticker_cooldown_timer) && isliving(loc))
				to_chat(loc, "<span class='warning'>The labeler is still printing.</span>")
			return
		if("clear_traits")
			clear_selection()
			return
		if("toggle_trait")
			var/trait_key = params["trait_name"]
			var/list/focus = list(activator_traits, minor_traits, major_traits, malfunction_list)
			for(var/list/i as() in focus)
				if(!(trait_key in i))
					continue
				if(trait_key in selected_traits)
					selected_traits -= trait_key
					label_traits -= GLOB.xenoa_all_traits_keyed[trait_key]
				else
					selected_traits += trait_key
					label_traits += GLOB.xenoa_all_traits_keyed[trait_key]
	return TRUE

//Get a list of all the specified trait types stats
//TODO: Consider baking this
/obj/item/xenoarchaeology_labeler/proc/get_trait_list_stats(list/trait_type)
	var/list/temp = list()
	for(var/datum/xenoartifact_trait/T as() in trait_type)
		temp += list(initial(T.label_name))
		var/datum/xenoartifact_trait/hint_holder = new T()
		tooltip_stats["[initial(T.label_name)]"] = list("weight" = initial(T.weight), "conductivity" = initial(T.conductivity), "alt_name" = initial(T.alt_label_name), "desc" = initial(T.label_desc), "hints" = hint_holder.get_dictionary_hint())
		qdel(hint_holder)
		//Generate material availability
		var/list/materials = list(XENOA_BLUESPACE, XENOA_PLASMA, XENOA_URANIUM, XENOA_BANANIUM, XENOA_PEARL)
		tooltip_stats["[initial(T.label_name)]"] += list("availability" = list())
		for(var/datum/xenoartifact_material/M as() in materials)
			if(initial(M.trait_flags) & initial(T.flags))
				tooltip_stats["[initial(T.label_name)]"]["availability"] += list(list("color" = initial(M.material_color), "icon" = initial(M.label_icon)))
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
	label_traits = list()
	selected_traits = list()
	ui_update()

/obj/item/xenoarchaeology_labeler/proc/create_label(mob/target, mob/user)
	var/obj/item/sticker/xenoartifact_label/P = new(get_turf(src), label_traits)
	if(target && user)
		P.afterattack(target, user, TRUE)

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

/obj/item/sticker/xenoartifact_label/old
	name = "old artifact label"
	color = "#bd812e"

/obj/item/sticker/xenoartifact_label/old/build_stuck_appearance()
	var/mutable_appearance/MA = mutable_appearance(sticker_icon || src.icon, sticker_icon_state || src.icon_state)
	MA.color = color
	return MA


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
		//Build list of artifact's traits
		var/list/artifact_traits = list()
		for(var/i in artifact.artifact_traits)
			for(var/datum/xenoartifact_trait/T as() in artifact.artifact_traits[i])
				artifact_traits += T
		//Compare them to ours
		for(var/datum/xenoartifact_trait/T as() in traits)
			if(locate(T) in artifact_traits)
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
