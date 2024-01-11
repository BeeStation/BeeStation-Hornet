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

	///trait dialogue essentially
	var/list/info_list = list()

	///passed down to sticker
	var/list/sticker_traits = list()

	///Cooldown for stickers
	COOLDOWN_DECLARE(sticker_cooldown)

/obj/item/xenoarchaeology_labeler/Initialize(mapload)
	. = ..()
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
	
	if(action == "print_traits" && COOLDOWN_FINISHED(src, sticker_cooldown))
		COOLDOWN_START(src, sticker_cooldown, 5 SECONDS)
		create_label()
		return
	else if(!COOLDOWN_FINISHED(src, sticker_cooldown) && isliving(loc))
		var/mob/living/user = loc
		to_chat(user, "<span class='warning'>The labeler is still printing.</span>")

	if(action == "clear_traits")
		clear_selection()
		return

	trait_toggle(action, "activator", activator_traits, selected_activator_traits)
	trait_toggle(action, "minor", minor_traits, selected_minor_traits)
	trait_toggle(action, "major", major_traits, selected_major_traits)
	trait_toggle(action, "malfunction", malfunction_list, selected_malfunction_traits)

	update_icon()
	return TRUE

//Get a list of all the specified trait types names
/obj/item/xenoarchaeology_labeler/proc/get_trait_list_names(list/trait_type)
	var/list/temp = list()
	for(var/datum/xenoartifact_trait/T as() in trait_type)
		temp += initial(T.label_name)
	return temp

/obj/item/xenoarchaeology_labeler/proc/look_for(list/place, culprit) //This isn't really needed but, It's easier to use as a function. What does this even do?
	if(place.Find(culprit))
		return TRUE
	return FALSE

/obj/item/xenoarchaeology_labeler/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(proximity_flag && COOLDOWN_FINISHED(src, sticker_cooldown))
		COOLDOWN_START(src, sticker_cooldown, 5 SECONDS)
		create_label(target, user)
	else if(!COOLDOWN_FINISHED(src, sticker_cooldown))
		to_chat(user, "<span class='warning'>The labeler is still printing.</span>")

///reset all the options
/obj/item/xenoarchaeology_labeler/proc/clear_selection()
	info_list = list()
	sticker_traits = list()
	selected_activator_traits = list()
	selected_minor_traits = list()
	selected_major_traits = list()
	selected_malfunction_traits = list()
	ui_update()

/obj/item/xenoarchaeology_labeler/proc/create_label(mob/target, mob/user)
	var/obj/item/sticker/xenoartifact_label/P = new(get_turf(src))
	P.traits = sticker_traits
	P.info = selected_activator_traits+selected_minor_traits+selected_major_traits+selected_malfunction_traits
	P.afterattack(target, user, TRUE)

/obj/item/xenoarchaeology_labeler/proc/trait_toggle(action, toggle_type, var/list/trait_list, var/list/active_trait_list)
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
/obj/item/xenoarchaeology_labeler/proc/desc2datum(udesc)
	for(var/datum/xenoartifact_trait/X as() in GLOB.xenoa_all_traits)
		if((udesc == initial(X.label_desc)) || (udesc == initial(X.label_name)))
			return X
	CRASH("The xenoartifact trait description '[udesc]' doesn't have a corresponding trait. Something fucked up.")

/obj/item/xenoarchaeology_labeler/debug
	name = "xenoartifact debug labeler"
	desc = "Use to create specific Xenoartifacts"

/obj/item/xenoarchaeology_labeler/debug/afterattack(atom/target, mob/user)
	return

/obj/item/xenoarchaeology_labeler/debug/create_label(new_name)
	var/obj/item/xenoartifact/A = new(get_turf(loc))
	A.AddComponent(/datum/component/xenoartifact, /datum/component/xenoartifact_material, sticker_traits)

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
	var/list/traits
	//
	var/info = ""

/obj/item/sticker/xenoartifact_label/Initialize()
	//Setup a random appearance
	icon_state = "sticker_[pick(list("star", "box", "tri", "round"))]"
	sticker_icon_state = "[icon_state]_small"
	return ..()
