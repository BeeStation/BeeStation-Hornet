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
	///List of deselected traits
	var/list/deselected_traits = list()
	///List of selected traits we'll put on the label
	var/list/label_traits = list()
	///List of possible trait filters
	var/list/trait_filters = list(
	list("icon" = "eye", "desc" = "Traits that can appear in the material description."),
	list("icon" = "hand-sparkles", "desc" = "Traits that can be detected by 'feeling' the artifact."),
	list("icon" = "wrench", "desc" = "Traits that can be triggered with specific items."),
	list("icon" = "search", "desc" = "Traits that can be detected with specific items."),
	list("icon" = "clone", "desc" = "Traits that have 'clones' or 'twins'."),
	list("icon" = "dice", "desc" = "Traits with randomized effects."),
	list("icon" = "snowflake", "desc" = "Traits that spawn particles, or change the artifact's appearance."),
	list("icon" = "volume-up", "desc" = "Traits that passively make noise"))
	///List of currently enabled trait filters
	var/list/enabled_trait_filters = list()
	///List of filtered traits
	var/list/filtered_traits = list()
	///Cooldown for stickers
	var/sticker_cooldown = 5 SECONDS
	COOLDOWN_DECLARE(sticker_cooldown_timer)

/obj/item/xenoarchaeology_labeler/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_ARTIFACT_IGNORE, GENERIC_ITEM_TRAIT)
	//Fill enabled filters with all filters
	for(var/filter in trait_filters)
		enabled_trait_filters += filter["icon"]

/obj/item/xenoarchaeology_labeler/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "XenoartifactLabeler")
		ui.open()

/obj/item/xenoarchaeology_labeler/ui_data(mob/user)
	var/list/data = list()
	data["selected_traits"] = selected_traits
	data["deselected_traits"] = deselected_traits
	data["enabled_trait_filters"] = enabled_trait_filters
	data["filtered_traits"] = filtered_traits

	return data

/obj/item/xenoarchaeology_labeler/ui_static_data(mob/user)
	var/list/data = list()
	data["malfunction_list"] = SSxenoarchaeology.labeler_traits.malfunctions
	data["major_traits"] = SSxenoarchaeology.labeler_traits.majors
	data["minor_traits"] = SSxenoarchaeology.labeler_traits.minors
	data["activator_traits"] = SSxenoarchaeology.labeler_traits.activators
	data["tooltip_stats"] = SSxenoarchaeology.labeler_tooltip_stats

	data["trait_filters"] = trait_filters

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
			var/list/focus = list(SSxenoarchaeology.labeler_traits.activators, SSxenoarchaeology.labeler_traits.minors, SSxenoarchaeology.labeler_traits.majors, SSxenoarchaeology.labeler_traits.malfunctions)
			for(var/list/foci as anything in focus)
				if(!(trait_key in foci))
					continue
				//Selected traits
				if(trait_key in selected_traits)
					selected_traits -= trait_key
					label_traits -= SSxenoarchaeology.xenoa_all_traits_keyed[trait_key]
					if(!params["select"])
						deselected_traits += trait_key
						continue
				else if(!(trait_key in deselected_traits))
					if(params["select"])
						selected_traits.Insert(1, trait_key)
						label_traits.Insert(1, SSxenoarchaeology.xenoa_all_traits_keyed[trait_key])
					else
						deselected_traits += trait_key
						continue
				//Deselected traits
				if(trait_key in deselected_traits)
					deselected_traits -= trait_key
		if("toggle_filter")
			var/specific_filter = params["filter"]
			if(specific_filter in enabled_trait_filters)
				enabled_trait_filters -= specific_filter
				filtered_traits += SSxenoarchaeology.labeler_traits_filter[params["filter"]]
			else
				enabled_trait_filters += specific_filter
				filtered_traits -= SSxenoarchaeology.labeler_traits_filter[params["filter"]]
	return TRUE

/obj/item/xenoarchaeology_labeler/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(proximity_flag && COOLDOWN_FINISHED(src, sticker_cooldown_timer))
		COOLDOWN_START(src, sticker_cooldown_timer, 5 SECONDS)
		create_label(target, user)
	else if(!COOLDOWN_FINISHED(src, sticker_cooldown_timer))
		to_chat(user, "<span class='warning'>The labeler is still printing.</span>")

///reset all the options
/obj/item/xenoarchaeology_labeler/proc/clear_selection()
	label_traits.Cut()
	label_traits = list()
	selected_traits.Cut()
	selected_traits = list()
	deselected_traits.Cut()
	deselected_traits = list()
	ui_update()

/obj/item/xenoarchaeology_labeler/proc/create_label(mob/target, mob/user)
	var/obj/item/sticker/xenoartifact_label/P = new(get_turf(src), label_traits)
	if(target && user)
		P.afterattack(target, user, TRUE)
/*
	Debug variant, spawns artifacts
*/
/obj/item/xenoarchaeology_labeler/debug
	name = "xenoartifact debug labeler"
	desc = "Use to create specific Xenoartifacts"
	icon_state = "labeler_debug"
	sticker_cooldown = 0 SECONDS
	///Flag for enabling or disabling trait patches
	var/patch_traits = FALSE
	///What type of material we're applying
	var/datum/xenoartifact_material/material = /datum/xenoartifact_material
	///Hack fix for double creation, who cares about a debug tool
	var/skip_label = FALSE

//Create an artifact with all the traits we have selected, but from the item we target
/obj/item/xenoarchaeology_labeler/debug/afterattack(atom/target, mob/user)
	target.AddComponent(/datum/component/xenoartifact, material, length(label_traits) ? label_traits : null, TRUE, FALSE, patch_traits)
	skip_label = TRUE
	return ..()

/obj/item/xenoarchaeology_labeler/debug/AltClick(mob/user)
	. = ..()
	var/choice = tgui_alert(user, "Select Action", "Select Action", list("Toggle Patch", "Change Material"))
	switch(choice)
		if("Toggle Patch")
			patch_traits = !patch_traits
			to_chat(user, "<span class='notice'>Toggled patch: [patch_traits ? "On" : "Off"].</span>")
		if("Change Material")
			var/list/possible_materials = typesof(/datum/xenoartifact_material)
			material = tgui_input_list(user, "Select artifact material.", "Select Material", possible_materials, /datum/xenoartifact_material)

/obj/item/xenoarchaeology_labeler/debug/examine(mob/user)
	. = ..()
	. += "<span>Alt+Click to toggle settings.</span>"

/obj/item/xenoarchaeology_labeler/debug/create_label()
	if(skip_label)
		skip_label = FALSE
		return
	var/obj/item/xenoartifact/no_traits/artifact = new(get_turf(src))
	artifact.AddComponent(/datum/component/xenoartifact, material, length(label_traits) ? label_traits : null, TRUE, TRUE, patch_traits)

/*
	Sticker for labeler, so we can label artifact's with their traits
*/

/obj/item/sticker/xenoartifact_label
	icon = 'icons/obj/xenoarchaeology/xenoartifact_sticker.dmi'
	icon_state = "sticker_star"
	name = "artifact label"
	desc = "An adhesive label, for artifacts."
	do_outline = FALSE
	roll_unusual = FALSE
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
	traits = _traits?.Copy()
	if(length(traits))
		examine_override = "Traits:"
		for(var/datum/xenoartifact_trait/trait_datum as anything in traits)
			examine_override = "[examine_override]\n	- [initial(trait_datum.label_name)]"
	//Setup a random appearance
	icon_state = "sticker_[pick(list("star", "box", "tri", "round"))]"
	sticker_icon_state = "[icon_state]_small"
	return ..()

/obj/item/sticker/xenoartifact_label/examine(mob/user)
	. = ..()
	. += examine_override

/obj/item/sticker/xenoartifact_label/afterattack(atom/movable/target, mob/user, proximity_flag, click_parameters)
	//If you somehow make traits start working with mobs, remove this isliving() check
	if(ismob(target) && !isliving(target) || (locate(/obj/item/sticker/xenoartifact_label) in target.contents))
		to_chat(user, "<span class='warning'>[target] already has a label!</span>")
		return
	. = ..()
	if(!can_stick(target) || !proximity_flag)
		return
	//Set custom price with the artifact component
	var/datum/component/xenoartifact/artifact = target.GetComponent(/datum/component/xenoartifact)
	if(artifact)
		old_custom_price = target.custom_price
		//Build list of artifact's traits
		var/list/traits_catagories = list()
		for(var/trait in artifact.traits_catagories)
			for(var/datum/xenoartifact_trait/trait_datum as anything in artifact.traits_catagories[trait])
				traits_catagories += trait_datum
		//Compare them to ours
		for(var/datum/xenoartifact_trait/trait_datum as anything in traits)
			if(locate(trait_datum) in traits_catagories)
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
