//TODO: Redo this code, or just improve it - Racc
/obj/item/xenoartifact_labeller
	name = "artifact labeller"
	icon = 'icons/obj/xenoarchaeology/xenoartifact_tech.dmi'
	icon_state = "xenoartifact_labeller"
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

	///trait dialogue essentially
	var/list/info_list = list()

	///Name artifacts something pretty
	var/sticker_name
	///passed down to sticker
	var/list/sticker_traits = list()

	///Cooldown for stickers
	COOLDOWN_DECLARE(sticker_cooldown)

/obj/item/xenoartifact_labeller/Initialize(mapload)
	. = ..()
	generate_xenoa_statics()
	//generate data for trait names
	activator_traits = get_trait_list_names(GLOB.xenoa_activators)
	minor_traits = get_trait_list_names(GLOB.xenoa_minors)
	major_traits = get_trait_list_names(GLOB.xenoa_majors)
	malfunction_list = get_trait_list_names(GLOB.xenoa_malfunctions)

/obj/item/xenoartifact_labeller/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "XenoartifactLabeler")
		ui.open()

/obj/item/xenoartifact_labeller/ui_data(mob/user)
	var/list/data = list()
	data["selected_activator_traits"] = selected_activator_traits
	data["activator_traits"] = activator_traits
	data["selected_minor_traits"] = selected_minor_traits
	data["minor_traits"] = minor_traits
	data["selected_major_traits"] = selected_major_traits
	data["major_traits"] = major_traits
	data["selected_malfunction_traits"] = selected_malfunction_traits
	data["malfunction_list"] = malfunction_list
	data["info_list"] = info_list
	return data

/obj/item/xenoartifact_labeller/ui_act(action, params)
	if(..())
		return
	
	if(action == "print_traits" && COOLDOWN_FINISHED(src, sticker_cooldown))
		COOLDOWN_START(src, sticker_cooldown, 5 SECONDS)
		create_label(sticker_name)
		return
	else if(!COOLDOWN_FINISHED(src, sticker_cooldown) && isliving(loc))
		var/mob/living/user = loc
		to_chat(user, "<span class='warning'>The labeler is still printing.</span>")

	if(action == "clear_traits")
		clear_selection()
		return

	if(action == "change_print_name" && istext(params["name"]))
		sticker_name = sanitize_text(params["name"])
		return

	trait_toggle(action, "activator", activator_traits, selected_activator_traits)
	trait_toggle(action, "minor", minor_traits, selected_minor_traits)
	trait_toggle(action, "major", major_traits, selected_major_traits)
	trait_toggle(action, "malfunction", malfunction_list, selected_malfunction_traits)

	update_icon()
	return TRUE

//Get a list of all the specified trait types names
/obj/item/xenoartifact_labeller/proc/get_trait_list_names(list/trait_type)
	var/list/temp = list()
	for(var/datum/xenoartifact_trait/T as() in trait_type)
		temp += initial(T.label_name)
	return temp

/obj/item/xenoartifact_labeller/proc/look_for(list/place, culprit) //This isn't really needed but, It's easier to use as a function. What does this even do?
	if(place.Find(culprit))
		return TRUE
	return FALSE

/obj/item/xenoartifact_labeller/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(proximity_flag && COOLDOWN_FINISHED(src, sticker_cooldown))
		COOLDOWN_START(src, sticker_cooldown, 5 SECONDS)
		create_label(sticker_name, target, user)
	else if(!COOLDOWN_FINISHED(src, sticker_cooldown))
		to_chat(user, "<span class='warning'>The labeler is still printing.</span>")

///reset all the options
/obj/item/xenoartifact_labeller/proc/clear_selection()
	sticker_name = null
	info_list = list()
	sticker_traits = list()
	selected_activator_traits = list()
	selected_minor_traits = list()
	selected_major_traits = list()
	selected_malfunction_traits = list()
	ui_update()

/obj/item/xenoartifact_labeller/proc/create_label(new_name, mob/target, mob/user)
	var/obj/item/xenoartifact_label/P = new(get_turf(src))
	if(new_name)
		P.name = new_name
		P.set_name = TRUE
	P.trait_list = sticker_traits
	P.info = selected_activator_traits+selected_minor_traits+selected_major_traits+selected_malfunction_traits
	P.attempt_attach(target, user, TRUE)

/obj/item/xenoartifact_labeller/proc/trait_toggle(action, toggle_type, var/list/trait_list, var/list/active_trait_list)
	var/datum/xenoartifact_trait/description_holder
	var/new_trait
	for(var/t in trait_list)
		new_trait = desc2datum(t)
		description_holder = new_trait
		if(action != "assign_[toggle_type]_[t]")
			continue
		if(!look_for(active_trait_list, t))
			active_trait_list += t
			info_list += initial(description_holder.label_desc)
			sticker_traits += new_trait
		else
			active_trait_list -= t
			info_list -= initial(description_holder.label_desc)
			sticker_traits -= new_trait

//This is just a hacky way of getting the info from a datum using its desc becuase I wrote this last and it's not heartbreaking
/obj/item/xenoartifact_labeller/proc/desc2datum(udesc)
	for(var/datum/xenoartifact_trait/X as() in GLOB.xenoa_all_traits)
		if((udesc == initial(X.label_desc)) || (udesc == initial(X.label_name)))
			return X
	CRASH("The xenoartifact trait description '[udesc]' doesn't have a corresponding trait. Something fucked up.")

// Not to be confused with labeller
/obj/item/xenoartifact_label
	icon = 'icons/obj/xenoarchaeology/xenoartifact_sticker.dmi'
	icon_state = "sticker_star"
	name = "artifact label"
	desc = "An adhesive label describing the characteristics of a Xenoartifact."
	var/info = ""
	var/set_name = FALSE
	var/mutable_appearance/sticker_overlay
	var/list/trait_list = list() //List of traits used to compare and generate modifier.

/obj/item/xenoartifact_label/Initialize()
	. = ..()
	icon_state = "sticker_[pick("star", "box", "tri", "round")]"
	var/sticker_state = "[icon_state]_small"
	sticker_overlay = mutable_appearance(icon, sticker_state)
	sticker_overlay.layer = FLOAT_LAYER
	sticker_overlay.appearance_flags = RESET_COLOR

/obj/item/xenoartifact_label/proc/attempt_attach(atom/target, mob/user, instant = FALSE)
	if(istype(target, /mob/living))
		to_chat(target, "<span class='warning'>[user] attempts to stick a [src] to you!</span>")
		to_chat(user, "<span class='warning'>You attempt to stick a [src] on [target]!</span>")
		if(!do_after(user, 30, target = target))
			if(instant)
				qdel(src)
			return
		if(!user.temporarilyRemoveItemFromInventory(src))
			if(instant)
				qdel(src)
			return
		add_sticker(target)
		addtimer(CALLBACK(src, PROC_REF(remove_sticker), target), 15 SECONDS, TIMER_STOPPABLE)
		return TRUE
	else if(istype(target, /obj/item/xenoartifact))
		var/obj/item/xenoartifact/xenoa_target = target
		if(set_name) //You can update the name now
			xenoa_target.name = name
		calculate_modifier(xenoa_target)
		add_sticker(xenoa_target)
		if(set_name)
			xenoa_target.name = name
		if(info)
			var/textinfo = list2text(info)
			xenoa_target.desc += "There's a sticker attached, it says-\n[textinfo]"
		return TRUE

/obj/item/xenoartifact_label/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(proximity_flag)
		attempt_attach(target, user, FALSE)

/obj/item/xenoartifact_label/proc/add_sticker(mob/target)
	if(locate(/obj/item/xenoartifact_label) in target) //Remove old stickers
		qdel(locate(/obj/item/xenoartifact_label) in target)
	target.add_overlay(sticker_overlay)
	forceMove(target)

/obj/item/xenoartifact_label/proc/remove_sticker(mob/target) //Peels off
	target.cut_overlay(sticker_overlay)
	forceMove(get_turf(target))

/obj/item/xenoartifact_label/proc/calculate_modifier(obj/item/xenoartifact/X) //Modifier based off preformance of slueth. To:Do revisit this, complexity would be nice
	//var/datum/xenoartifact_trait/trait //TODO: - Racc
	var/datum/component/xenoartifact_pricing/xenop = X.GetComponent(/datum/component/xenoartifact_pricing)
	if(!xenop)
		return
	xenop.modifier = initial(xenop.modifier)
	/*
	TODO: - Racc
	for(var/t in trait_list)
		trait = new t
		if(X.get_trait(trait))
			xenop.modifier += 0.15
		else
			xenop.modifier -= 0.35
	*/

/obj/item/xenoartifact_label/proc/list2text(list/listo) //list2params acting weird. Probably already a function for this.
	var/text = ""
	for(var/X in listo)
		text = "[text] [X]\n"
	return text

/obj/item/xenoartifact_labeller/debug
	name = "xenoartifact debug labeler"
	desc = "Use to create specific Xenoartifacts"

/obj/item/xenoartifact_labeller/debug/afterattack(atom/target, mob/user)
	return

/obj/item/xenoartifact_labeller/debug/create_label(new_name)
	var/obj/item/xenoartifact/A = new(get_turf(loc))
	A.AddComponent(/datum/component/xenoartifact, /datum/component/xenoartifact_material, sticker_traits)
